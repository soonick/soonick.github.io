---
title: Dealing with Firestore 10 limit when using IN operator
author: adrian.ancona
layout: post
date: 2021-01-20
permalink: /2021/01/dealing-with-firestore-10-limit-with-in-operator
tags:
  - databases
  - gcp
  - golang
  - programming
---

I started using Firestore a few months ago for a project and today I discovered that the `IN` operator accepts a [maximum of `10` values](https://firebase.google.com/docs/firestore/query-data/queries#in_not-in_and_array-contains-any). This limitation makes the `IN` operator unsuitable for a lot of real world scenarios.

In this article, I'm going to explore a few ways to work around the problem using the golang client.

<!--more-->

## The problem

My application allows users to see the most recent activity of their friends. The code looks something like this:

```go
// I'm omitting error handling to save some space

// Friends is a list of usernames (strings)
friends, err := GetFriends(context, user)

// The where clause causes an error if there are more than 10 friends
query := s.firestore.Collection("activities").Where("Username", "in", friends).
    OrderBy("CreatedAt", firestore.Desc).Limit(10)

activities := []*Activity{}
iter := query.Documents(ctx)
defer iter.Stop()
for {
  result, err := iter.Next()
  if err == iterator.Done {
    return activities, nil
  }

  activity := new(Activity)
  err = result.DataTo(activity)

  activities = append(activities, activity)
}
```

The code does what I need it to do:
- Gets all the friends for a user
- Gets the 10 most recent activities for any of those users

At the same time, the code totally breaks if `friends` has more than `10` values, which makes this not a viable solution.

## Serializing queries

The simplest solution to this problem is querying for each user's activity in a loop. This comes with a problem that is completely trivial; How do we get the 10 most recent activities?

Sadly, the only way to reliably get the 10 most recent activities is by getting 10 activities per friend and then manually merging them. This has a few sad consequences:

- Makes the code more complicated
- Takes longer because we need to make a number of requests equal to the number of users, one after the other
- Takes longer because we have to merge the results
- The longer time can also translate to extra cost if using a serverless solution
- Increases cost, because instead of getting only `10` documents, we need to retrieve `10 * number of friends` documents

We can minimize some of these problems, but some of them are unavoidable.

Let's start by looking at how we can retrieve the results:

```go
// We'll put all the activities here. We might end up with 10 * number of friends
activities := []*Activity{}
for _, username := range friends{
  query := s.firestore.Collection("activities").Where("Username", "==", username).
      OrderBy("CreatedAt", firestore.Desc).Limit(10)

  iter := query.Documents(ctx)
  defer iter.Stop()
  for {
    result, err := iter.Next()
    if err == iterator.Done {
      break
    }

    activity := new(Activity)
    err = result.DataTo(activity)

    activities = append(activities, activity)
  }
}
```

`activities` now has up to `10 * number of friends` results. In order to get the `10` most recent ones we need to sort the results and get the `10` first activities.

```go
// Sort the results
sort.Slice(activities, func(i, j int) bool {
  return activities[i].CreatedAt.After(activities[j].CreatedAt)
})

// Return the top 10 results
if len(activities) > 10 {
  return activities[0:10], nil
} else {
  return activities, nil
}
```

This is probably the easiest solution to the `10` limit problem, but it's also the most inefficient. In the next section I'm going to explore some improvements.

## Serializing queries using IN

We can greatly improve the performace of our solution by combining serialization with the `IN` operator. By doing this we get:

- A little more complexity
- Reduce the number of results returned (By one order of magnitude)
- Because we have less results, cost decreases
- Because we have less results, time to merge and sort decreases

To take advantage of the `IN` operator, we need to change the way we query for results:

```go
// Now, we'll have at most a number of results equal to the number of friends
// rounded up to a multiple of 10 (i.e. If there are 91 friends, There might be
// 100 results)
activities := []*Activity{}
groups := int(math.Ceil(float64(len(friends)) / 10.0))
for i := 0; i < groups; i++ {
  lowIndex := i * 10
  highIndex := lowIndex + 10
  if highIndex > len(friends) {
    highIndex = len(friends)
  }
  groupUsernames := friends[lowIndex:highIndex]
  query := s.firestore.Collection("activities").Where("Username", "in", groupUsernames).
      OrderBy("CreatedAt", firestore.Desc).Limit(10)

  iter := query.Documents(ctx)
  defer iter.Stop()
  for {
    result, err := iter.Next()
    if err == iterator.Done {
      break
    }

    activity := new(Activity)
    err = result.DataTo(activity)

    activities = append(activities, activity)
  }
}
```

This alternative, is very similar to the previous option, but gives us much better performance. The rest of the code doesn't need to be changed.

## Parallelizing with goroutines

In the previous examples we sent queries to Firestore one after the other. We can get results faster if we submit our queries in parallel. The drawback of this is that the code gets considerably more complicated if we decide to do this.

We start by moving the code we want to execute in parallel (The queries to Firestore) to a function. This functions will perform the query to Firestore in a Goroutine and return a channel where the activities are going to be written:

```go
func retrieveActivities(fs *firestore.Client, ctx context.Context, usernames *[]string) <- chan *Activity {
  activities := make(chan *Activity)

  // This is executed in asynchronously
  go func() {
    query := fs.Collection("activities").Where("Username", "in", usernames).
        OrderBy("CreatedAt", firestore.Desc).Limit(10)

    iter := query.Documents(ctx)
    defer iter.Stop()
    for {
      result, err := iter.Next()
      if err == iterator.Done {
        // Close the channel when we are done
        close(activities)
        break
      }

      activity := new(Activity)
      err = result.DataTo(activity)

      // Write each activity to the channel
      activities <- activity
    }
  }()

  // Return the channel immediately
  return activities
}
```

We can now call this function for each of the groups of users we want to retrieve. We save all the channels in an array that we will later use to read all activities:

```go
// All channels will be saved here
chans := []<- chan *Activity{}
groups := int(math.Ceil(float64(len(friends)) / 10.0))
for i := 0; i < groups; i++ {
  lowIndex := i * 10
  highIndex := lowIndex + 10
  if highIndex > len(friends) {
    highIndex = len(friends)
  }
  groupUsernames := friends[lowIndex:highIndex]

  // These calls are all non blocking
  ch := retrieveActivities(s.firestore, ctx, &groupUsernames, until)
  chans = append(chans, ch);
}

// Reading from a channel is blocking, so this will not complete until all channels
// have been closed
activities := []*Activity{}
for _, ch := range chans {
  for act := range ch {
    activities = append(activities, act);
  }
}
```

This solution performs considerably better than the other ones when there is a high number friends (which translates to a high number of requests to Firestore). The number of documents returned from firestore is going to be the same, but we'll get them faster.

## Conclusion

Firestore's limitation turns out to be a little nightmare. The solutions explained in this article achieve the result I need, but at the cost of readability.

An alternative that in most cases turns out to be more complicated, is denormalization. It's possible to prebuild a "feed" for each user, but there are a lot of edge cases that make that solution considerably more convoluted.
