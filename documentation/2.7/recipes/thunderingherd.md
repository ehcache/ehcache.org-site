---
---
# Thundering Herd

 

## Introduction
When many readers simultaneously request the same data element, there can be a database read overload, sometimes called the "Thundering Herd" problem. This page addresses how to prevent it in a single JVM or a clustered configuration.

## Problem

Many readers read an empty value from the cache and subseqeuntly try to load it from the database. The result is unnecessary database load as all readers simultaneously execute the same query against the database.

## Solution

Implement the [cache-as-sor](/documentation/2.7/get-started/concepts#cache-as-sor) pattern by using a [BlockingCache or SelfPopulatingCache](/documentation/2.7/apis/constructs) included with Ehcache.

Using the BlockingCache Ehcache will automatically block all threads that are simultaneously requesting a particular value and let one and only one thread through to the database. Once that thread has populated the cache, the other threads will be allowed to read the cached value.

Even better, when used in a cluster with Terracotta, Ehcache will automatically coordinate access to the cache across the cluster, and no matter how many application servers are deployed, still only one user request will be serviced by the database on cache misses.

## Discussion

The "thundering herd" problem occurs in a highly concurrent environment (typically, many users). When many users make a request to the same piece of data at the same time, and there is a cache miss (the data for the cached element is not present in the cache) the thundering herd problem is triggered.

Imagine that a popular news story has just surfaced on the front page of a news site. The news story has not yet been loaded in to the cache.

The application is using a cache using a read-through pattern with code that looks approximately like:

~~~ java
/* read some data, check cache first, otherwise read from SoR */
public V readSomeData(K key) {
  Element element;
  if ((element = cache.get(key)) != null) {
    return element.getValue();
  }

  // note here you should decide whether your cache
  // will cache 'nulls' or not
  if (value = readDataFromDataStore(key)) != null) {
    cache.put(new Element(key, value));
  }

  return value;
}
~~~

Upon publication to the front page of a website, a news story will then likely be clicked on by many users all at approximately the same time.

Since the application server is processing all of the user requests simultaneously, the application code will execute the above code all at approximately the same time. This is especially important to consider, because all user requests will be evaluating the cache (line 105) contents at approximately the same time, and reach the same conclusion: the cache request is a miss!

Therefore all of the user request threads will then move on to read the data from the SOR. So, even though the application designer was careful to implement caching in the application, the database is still subject to spikes of activity.

The thundering herd problem is made even worse when there are many application servers to one database server, as the number of simultaneous hits the database server may receive increases as a function of the number of application servers deployed.
