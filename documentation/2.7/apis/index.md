---
---

# APIs Overview

The following sections provide a documentation Table of Contents and additional information sources for the Ehcache APIs.

## APIs Table of Contents

| Topic | Description |
|:-------|:------------|
|[Cache Search](/documentation/2.7/apis/search)|The Ehcache Search API allows you to execute arbitrarily complex queries against either a standalone cache or a Terracotta clustered cache with pre-built indexes. Searchable attributes may be extracted from both keys and values. Keys, values, or summary values (Aggregators) can all be returned.|
|[Transactions](/documentation/2.7/apis/transactions)|Transactional modes are a powerful extension of Ehcache allowing you to perform atomic operations on your caches and potentially other data stores, to keep your cache in sync with your database. This page covers all of the background and configuration information for the transactional modes. Additional information about transactions can be found in the Using Caches section of the [Code Samples](/documentation/2.7/code-samples#using-caches) page.|
|[Explicit Locking](/documentation/2.7/apis/explicitlocking)|With explicit locking (using Read and Write locks), it is possible to get more control over Ehcache's locking behaviour to allow business logic to apply an atomic change with guaranteed ordering across one or more keys in one or more caches. This API can be used as a custom alternative to XA Transactions or Local transactions.|
|[CacheWriter](/documentation/2.7/apis/write-through-caching)|Write-through and write-behind are available with the Ehcache CacheWriter API for handling how writes to the cache are subsequently propagated to the SOR. This page covers all of the background and configuration information for the CacheWriter API. An additional discussion about Ehcache Write-Behind may be found in [Recipes](/documentation/2.7/recipes/writebehind).|
|[Blocking and Self-populating Caches](/documentation/2.7/apis/constructs)|With BlockingCache, which can scale up to very busy systems, all threads requesting the same key wait for the first thread to complete. Once the first thread has completed, the other threads simply obtain the cache entry and return. With SelfPopulatingCache, or pull-through cache, you can specify keys to populate entries. This page introduces these APIs. Additional information may be found in [Cache Decorators](/documentation/2.7/apis/cache-decorators) and in [Recipes](/documentation/2.7/recipes/thunderingherd).|
|[Cache Decorators](/documentation/2.7/apis/cache-decorators)|A cache decorator allows extended functionality to be added to an existing cache dynamically, and can be combined with other decorators on a per-use basis. It is generally required that a decorated cache, once constructed, is made available to other execution threads. The simplest way of doing this is to substitute the original cache for the decorated one.|
|[CacheManager Event Listeners](/documentation/2.7/apis/cachemanager-event-listeners)|CacheManager event listeners allow implementers to register callback methods that will be executed when a CacheManager event occurs. The events include adding a cache and removing a cache.|
|[Cache Event Listeners](/documentation/2.7/apis/cache-event-listeners)|Cache listeners allow implementers to register callback methods that will be executed when a cache event occurs. The events include Element puts, updates, removes, and expires. Elements can also be put or removed from a cache without notifying listeners. In clustered environments, event propagation can be configured to be propagated only locally, only remotely, or both.|
|[Cache Exception Handlers](/documentation/2.7/apis/cache-exception-handlers)|A CacheExceptionHandler can be configured to intercept Exceptions and not Errors. Ehcache can be configured with ExceptionHandling so that CacheManager.getEhcache() does not simply return the underlying undecorated cache.|
|[Cache Extensions](/documentation/2.7/apis/cache-extensions)|CacheExtensions are a general purpose mechanism, tied into the cache lifecycle, which allow generic extensions to a cache. The CacheExtension perform operations such as registering a CacheEventListener or even a CacheManagerEventListener, all from within a CacheExtension, creating more opportunities for customisation.|
|[Cache Eviction Algorithms](/documentation/2.7/apis/cache-eviction-algorithms)|A cache eviction algorithm is a way of deciding which element to evict when the cache is full. LRU, LFU, and FIFO are provided, or you can plug in your own algorithm.|
|[Class Loading](/documentation/2.7/apis/class-loading)|Ehcache allows plugins for events and distribution. This page demonstrates how to load and create plug-ins, and it covers loading ehcache.xml resources and classloading with Terracotta clustering.|

## Additional Information about APIs
The following pages provide additional information about Search, Cluster Events, Bulk-load, and other APIs:

* [BigMemory](http://terracotta.org/products)
* [CacheManager Code Examples](/documentation/2.7/code-samples#Using-the-CacheManager)



