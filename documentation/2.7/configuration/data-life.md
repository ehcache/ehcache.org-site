---
---
# Pinning, Expiration, and Eviction

 

## Introduction
The architecture of an Ehcache node can include a number of tiers that store data. One of the most important aspects of managing cached data involves managing the life of that data in those tiers.

<img style="float:right" src="/images/documentation/data-life-elements.png" />

Use the figure at right with the definitions below to understand the life of data in the tier of Ehcache nodes backed by the Terracotta Server Array, available with [BigMemory Max](http://terracotta.org/products/bigmemorymax). These definitions apply similarly in standalone Ehcache, but limited to two tiers (heap and disk). [BigMemory Go](http://terracotta.org/products/bigmemorymax) can add an off-heap tier to standalone nodes.

* Flush &ndash; To move a cache entry to a lower tier. Flushing is used to free up resources while still keeping data in the cluster. Entry E1 is shown to be flushed from the L1 off-heap store to the Terracotta Server Array (TSA).
* Fault &ndash; To copy a cache entry from a lower tier to a higher tier. Faulting occurs when data is required at a higher tier but is not resident there. The entry is not deleted from the lower tiers after being faulted. Entry E2 is shown to be faulted from the TSA to L1 heap.
* Eviction &ndash; To remove a cache entry from the cluster. The entry is deleted; it can only be reloaded from a source outside the cluster. Entries are evicted to free up resources. Entry E3, which exists only on the L2 disk, is shown to be evicted from the cluster.
* Expiration &ndash; A status based on Time To Live and Time To Idle settings. To maintain cache performance, expired entries  may not be immediately flushed or evicted. Entry E4 is shown to be expired but still in the L1 heap.
* Pinning &ndash; To force data to remain in certain tiers. Pinning can be set on individual entries or an entire cache, and must be used with caution to avoid exhausting a resource such as heap. E5 is shown pinned to L1 heap.


The sections below explore in more detail the aspects of managing data life in Ehcache and the TSA, including the pinning features of Automatic Resource Control (ARC).

## Setting Expiration <a name="24283"/>
Cache entries expire based on parameters with configurable values. When eviction occurs, expired elements are the first to be removed. Having an effective expiration configuration is critical to optimizing use of resources such as heap and maintaining cache performance.

To add expiration, edit the values of the following `<cache>` attributes and tune these values based on results of performance tests:

* `timeToIdleSeconds` &ndash; The maximum number of seconds an element can exist in the cache without being accessed. The element expires at this limit and will no longer be returned from the cache. The default value is 0, which means no TTI eviction takes place (infinite lifetime).
* `timeToLiveSeconds` &ndash; The maximum number of seconds an element can exist in the cache regardless of use. The element expires at this limit and will no longer be returned from the cache. The default value is 0, which means no TTL eviction takes place (infinite lifetime).
* `maxEntriesLocalDisk` &ndash; The maximum sum total number of elements (cache entries) allowed on the disk tier for the cache. If this target is exceeded, eviction occurs to bring the count within the allowed target. The default value is 0, which means no eviction takes place (infinite size is allowed). **A setting of 0 means that no eviction of the cache's entries takes place, and consequently can cause the node to run out of disk space.**
* `eternal` &ndash;  If the cache’s `eternal` flag is set, it overrides any finite TTI/TTL values that have been set.

See [How Configuration Affects Element Eviction](#30343) for more information on how configuration can impact eviction. See this BigMemory Max document on [distributed cache configuration](http://terracotta.org/documentation/2.7/4.0/bigmemorymax/configuration/distributed-configuration) for definitions of other available configuration properties.


## Pinning Data

Data that should remain in the cache regardless of resource constraints can be pinned. 

Entire caches can be pinned using the `pinning` element in cache configuration. This element has a required attribute (`store`) to specify which data tiers the cache should be pinned to:

    <pinning store="localMemory" />
    
The `store` attribute can have one of the following values:

* localMemory &ndash; Cache data is pinned to the local heap (or off-heap for [BigMemory Go](http://terracotta.org/products/bigmemorygo) and [BigMemory Max](http://terracotta.org/products/bigmemorymax)). Unexpired entries can never be flushed to a lower tier or be evicted.
* inCache &ndash; Cache data is pinned in the cache, which can be in any tier cache data is stored. The tier is chosen based on performance-enhancing efficiency algorithms.

For example, the following cache is configured to pin its entries:

    <cache name="Cache1" ... >
         <pinning store="inCache" />
    </cache>

The following cache is configured to pin its entries to heap only:

    <cache name="Cache2" ... >
         <pinning store="localMemory" />
    </cache>


### Scope of Pinning
Pinning as a setting exists in the local Ehcache client memory. It is never replicated or distributed in a cluster. Pinning achieved programmatically will not be persisted &mdash; after a restart the pinned entries are no longer pinned. Cache pinning in configuration is reinstated with the configuration file.

### Unpinning Caches
To unpin all of a cache's pinned entries, clear the cache. Specific entries can be removed from a cache using `Cache.remove()`. To empty the entire cache, use `Cache.removeAll()`. If the cache itself is removed (`Cache.dispose()` or `CacheManager.removeCache()`), then any data still remaining in the cache is also removed locally.

Caches can also be cleared using the [Terracotta Management Console](http://www.terracotta.org/documentation/2.7/4.0/tms/tms).

## How Configuration Affects Element Flushing and Eviction <a name="30343"/>
The following example shows a cache with certain expiration settings:

    <cache name="myCache"
          maxEntriesLocalDisk="10000" eternal="false" timeToIdleSeconds="3600"
          timeToLiveSeconds="0" memoryStoreEvictionPolicy="LFU">
    </cache>

Note the following about the myCache configuration:

* Accessing an entry in myCache that has been idle for more than an hour (`timeToIdleSeconds`) causes that element to be evicted.
* If an entry expires but is not accessed, and no resource constraints force eviction, then the expired entry remains in place.
* Entries in myCache can remain in the cache forever if accessed at least once per 60 minutes (`timeToLiveSeconds`). However, unexpired entries may still be flushed based on  other limitations (see [How to Size Caches](/documentation/2.7/configuration/cache-size)).
* In all, myCache can store a maximum of 10000 entries (`maxEntriesLocalDisk`). This is the effective maximum number of entries myCache is allowed. Note, however, that this value may be exceeded as it is overridden by settings such as pinning.

### Pinning Overrides Cache Sizing
Pinning takes priority over configured cache sizes. For example, in the following cache  pinning configuration overrides the `maxEntriesOnHeap` setting:

    <cache name="myCache"
         maxEntriesLocalHeap="10000"
         ... >
        <pinning store="localHeap" />
    </cache>

While expired cache entries (even ones that have been pinned) can always be flushed and eventually evicted from the cluster, most non-expired elements can as well if resource limitations are reached. However, elements resident in a pinned cache cannot be evicted if they haven't expired.


<table markdown="1">
<caption>CAUTION: Pinning Could Cause Failures</caption>
<tr><td>
Potentially, pinned caches could grow to an unlimited size. Caches should never be pinned unless they are designed to hold a limited amount of data (such as reference data) or their usage and expiration characteristics are understood well enough to conclude that they cannot cause errors. 
</td></tr>
</table>
