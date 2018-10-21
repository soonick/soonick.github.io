---
id: 3087
title: Trunk development flow with git
date: 2015-07-29T18:58:52+00:00
author: adrian.ancona
layout: post
guid: http://ncona.com/?p=3087
permalink: /2015/07/trunk-development-flow-with-git/
tags:
  - automation
  - git
---
The trunk development flow is an alternative to [gitflow](https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow) or [github flow](https://guides.github.com/introduction/flow/) that is used at very big companies(LinkedIn, Google, FaceBook) to allow many developers to work in the same code base with the least amount of friction.

This model existed before git, so it doesn&#8217;t really use all its power. If you have done development using another flow, it might even feel wrong at the beginning, because it discourages branching and merging, but it is all for a good reason.

These are the rules I follow when using the trunk model with git:

  * **Master is always stable** &#8211; The master branch should always be stable and deployable. For this reason your codebase should be guarded by as many tests and monitoring as possible. Developers should feel comfortable deploying anything that goes to master as soon as it is committed because there may be a system that continuously deploys the master branch.
  * **No merges allowed** &#8211; The master branch should remain flat by always rebasing to it. Keeping the master branch flat makes is easier to bisect and revert commits.
  * **No branches for large tasks** &#8211; On other flows, branches are created for large tasks that may take days or weeks. This makes development easy, but integration hard. When you are done developing your feature and are ready to add your changes to master, there may be conflicts. Fixing conflicts that are weeks old is hard and error prone. To avoid this problem and still allow for large tasks, use [feature toggles](http://martinfowler.com/bliki/FeatureToggle.html) instead.

<!--more-->
