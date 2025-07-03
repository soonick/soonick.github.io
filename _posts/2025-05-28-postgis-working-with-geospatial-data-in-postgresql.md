---
title: PostGIS - Working With Geospatial Data in PostgreSQL
author: adrian.ancona
layout: post
date: 2025-05-28
permalink: /2025/05/postgis-working-with-geospatial-data-in-postgresql/
tags:
  - databases
  - postgresql
---

In this article, we are going to show how to get started with Geospatial data in PostgreSQL. More specifically, we are going to learn how to store spatial information (e.g. Coordinates in a map) and how we can index and perform searches on this data (e.g. Find all coordinates inside a given area).

## Installing PostGIS

PostGIS is an extension of standard PostgreSQL that allows us to work with geospatial data. This means, if the extension is not present, we won't have these capabilities.

To check if our database has PostGIS, we can use this query:

```sql
SELECT PostGIS_Version();
```

If PostGIS is not enabled, we will get a message similar to this one:

```
ERROR:  42883: function postgis_version() does not exist
```

If PostGIS is enabled, we will get something like this:

```
postgres=# SELECT PostGIS_Version();
            postgis_version
---------------------------------------
 3.5 USE_GEOS=1 USE_PROJ=1 USE_STATS=1
```

If PostGIS is not installed on our system, we can follow the [installation instructions](https://postgis.net/documentation/getting_started/#installing-postgis) based on our system.

<!--more-->

## Points

One of the most common use cases for PostGIS is storing coordinates in a map. For this, we can use the `POINT` type.

Let's say we want to have a table that stores information about places, including their coordinates. We can create this table:

```sql
CREATE TABLE places (
    id SERIAL PRIMARY KEY,
    name VARCHAR(64),
    location GEOMETRY(POINT, 4326)
);
```

You might be wondering what `4326` means. EPSG:4326 is a standard coordinate reference system (CRS) used in geographic information systems (GIS). This is the standard used by most systems that work with geographic information (Google Maps, Leaflet, etc.), so we use it too.

Since we want to perform geospatial queries against this field, we need to create an index:

```sql
CREATE INDEX idx_places_location ON places USING GIST (location);
```

We can insert a new place with this query:

```sql
INSERT INTO places(name, location)
VALUES('Central Park', ST_GeomFromText('POINT(-73.9654 40.7829)'));
```

In this case, we inserted a record for [Central Park, in New York](https://www.google.com/maps/@40.7829,-73.9654,17z). Note that the first value (`-73.9654`) is the longitude and the second is the latitude.

The data is saved in a binary encoding, so it won't be easy to read if we just query it:

```sql
SELECT * FROM places;

 id |     name     |                      location
----+--------------+----------------------------------------------------
  1 | Central Park | 0101000020E6100000BDE3141DC97D52C0EA04341136644440
```

If we want to see the point representation, we can use a query like this one:

```sql
SELECT id, name, ST_AsText(location) FROM places;

 id |     name     |        st_astext
----+--------------+-------------------------
  1 | Central Park | POINT(-73.9654 40.7829)
```

## Areas

If instead of just a point, we want to store an area (i.e. the polygon that delimits a location), we need to use a `POLYGON` instead of a `POINT`:

```sql
CREATE TABLE areas (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    boundary GEOMETRY(POLYGON, 4326)
);
```

To insert Central Park, we can use this query:

```sql
INSERT INTO areas (name, boundary)
VALUES (
    'Central Park',
    ST_GeomFromText('POLYGON((
        -73.9731 40.7644,
        -73.9819 40.7681,
        -73.9580 40.8006,
        -73.9498 40.7968,
        -73.9731 40.7644
    ))')
);
```

Note that we call the `POLYGON` function with a list of points that delimit the area we are interested in. Also note that the first and last points must be exactly the same.

We can query the date similarly:

```sql
SELECT name, ST_AsText(boundary) FROM areas;

 id |     name     |                                         boundary_text
----+--------------+------------------------------------------------------------------------------------------------
  1 | Central Park | POLYGON((-73.9731 40.7644,-73.9819 40.7681,-73.958 40.8006,-73.9498 40.7968,-73.9731 40.7644))
```

## Geojson

Geojson is a standard format for encoding geographic data using JSON. The format is easy to read and write, and it's supported by many tools, including PostGIS.

We can, for example, use this query to see the Central Park area as Geojson:

```sql
SELECT name, ST_AsGeoJSON(boundary) FROM areas;

     name     |                                                            st_asgeojson
--------------+------------------------------------------------------------------------------------------------------------------------------------
 Central Park | {"type":"Polygon","coordinates":[[[-73.9731,40.7644],[-73.9819,40.7681],[-73.958,40.8006],[-73.9498,40.7968],[-73.9731,40.7644]]]}
```

This gives us the benefit of being able to use the output in other tools. For example, we can visualize the area in [Geojson.io](https://geojson.io):

[<img src="/images/posts/geojsonio-central-park.png" alt="Central Park in Geojson.io" />](/images/posts/geojsonio-central-park.png)

We can also use Geojson when inserting data:

```sql
INSERT INTO areas (name, boundary)
VALUES (
    'Dolores Park',
    ST_GeomFromGeoJSON('{
        "type": "Polygon",
        "coordinates": [
          [
            [ -122.42836549322851, 37.76123463001613 ],
            [ -122.42806139698865, 37.75811926165099 ],
            [ -122.42592638797277, 37.758254497406654 ],
            [ -122.42620514285912, 37.76137987710844 ],
            [ -122.42836549322851, 37.76123463001613 ]
          ]
        ]
    }')
);
```

## Geo queries

Now that we have Geographic information in our database, we can perform all kinds of queries against it.

It's often useful to figure out if a point is inside an area. For example, we can use this query to check if our `Central Park` point is inside our `Central Park` area:

```sql
SELECT ST_Contains(
  ST_GeomFromText('POLYGON(( -73.9731 40.7644, -73.9819 40.7681, -73.9580 40.8006, -73.9498 40.7968, -73.9731 40.7644))', 4326),
  ST_GeomFromText('POINT(-73.9654 40.7829)', 4326)
);

 st_contains
-------------
 t
```

Or, using the values already in our database:

```sql
SELECT ST_Contains(
  (SELECT boundary FROM areas WHERE name = 'Central Park' LIMIT 1),
  (SELECT location FROM places WHERE name = 'Central Park' LIMIT 1)
);
```

We might also want to get all locations inside a polygon. We can do it with this query:

```sql
SELECT id, name
FROM places
WHERE ST_Contains(
  ST_GeomFromText(
    'POLYGON((
      -73.9731 40.7644,
      -73.9819 40.7681,
      -73.9580 40.8006,
      -73.9498 40.7968,
      -73.9731 40.7644
    ))', 4326),
    location
);
```

There are many other possible operations, but we are not going to cover those in this article.

## Conclusion

Handling geospatial data can seem intimidating, but there are many common use cases that can be easily achieved with PostGIS.

If you want to try the commands in this article, you can find a [ready to use docker image in my examples repo](https://github.com/soonick/ncona-code-samples/tree/master/postgis-working-with-geospatial-data-in-postgresql).
