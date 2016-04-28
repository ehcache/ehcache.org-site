---
---
# Caching Empty Values



## Introduction
This page discusses why caching empty values can be desirable to deflect load from the database.

## Problem

Your application is querying the database excessively only to find that there is no result. Since there is no result, there is nothing to cache.

How do you prevent the query from being executed unneccesarily?

## Solution

Cache a null value, signalling that a particular key doesn't exist.

## Discussion

Ehcache supports caching null values. Simply cache a "null" value instead of a real value.

Use a maximum time to live setting in your cache settings to force a re-load every once in a while.

In code, checking for intentional nulls versus non-existent cache entries may look like:

    // cache an explicit null value:

    cache.put(new Element("key", null));

    Element element = cache.get("key");

    if (element == null) {

        // nothing in the cache for "key" (or expired) ...

    } else {

        // there is a valid element in the cache, however getObjectValue() may be null:

        Object value = element.getObjectValue();

        if (value == null) {

            // a null value is in the cache ...

        } else {

            // a non-null value is in the cache ...

        "/>

    "/>

And the ehcache.xml file may look like this (making sure to set the maximum time to live setting:

    <cache
        name="some.cache.name"
        maxEntriesLocalHeap="10000"
        eternal="false"
        timeToIdleSeconds="300"
        timeToLiveSeconds="600"
    />
