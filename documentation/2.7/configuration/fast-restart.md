---
---
# Persistence and Restartability <a name="Fast-Restart"/>
 

## Introduction

This page covers cache persistence, fast restartability, and using the local disk as a cache storage tier. While Ehcache offers various disk usage choices (summarized [here](#comparison-of-disk-usage-options)), as of version 2.6, the recommended option for persistence is the Fast Restart store, which is available in [BigMemory Go](http://terracotta.org/products/bigmemorygo) and [BigMemory Max](http://terracotta.org/products/bigmemorymax). Open-source Ehcache offers a limited version of persistence, as noted in this document.

Fast Restart provides enterprise-ready crash resilience with an option to store a fully consistent copy of the cache on the local disk at all times. The persistent storage of the cache on disk means that after any kind of shutdown &mdash; planned or unplanned &mdash; the next time that the application starts up, all of the previously cached data is still available and very quickly accessible. The advantages of the Fast Restart store include:

1.  A persistent store of the cache on disk survives crashes, providing the fastest restart. Because cached data does not need to be reloaded from the data source after a crash, but is instead loaded from the local disk, applications can resume at full speed after restart. Recovery of even terabytes of data after a failure will be very fast, minimizing downtime.

2. A persistent store on disk always contains a real-time copy of the cache, providing true fault tolerance. Even with BigMemory, where terabytes of data can be held in memory, the synchronous backup of data to disk provides the equivalent of a hot mirror right at the application and server nodes.

3. A consistent copy of the cache on local disk provides many possibilities for business requirements, such as working with different datasets according to time-based needs or moving datasets around to different locations. It can range from a simple key-value persistence mechanism with fast read performance, to an operational store with in-memory speeds during operation for both reads and writes. 
 
 
## Cache Persistence Implementation
Ehcache has a RestartStore which provides fast restartability and options for cache persistence. The RestartStore implements an on-disk mirror of the in-memory cache. After any restart, data that was last in the cache will automatically load from disk into the RestartStore, and from there the data will be available to the cache.
 
Cache persistence on disk is configured by adding the `<persistence>` sub-element to a cache configuration. The `<persistence>` sub-element includes two attributes: `strategy` and `synchronousWrites`.

    <cache>
       <persistence strategy=”localRestartable|localTempSwap|none|distributed” synchronousWrites=”false|true”/>
    </cache>
 
###Strategy Options
The options for the `strategy` attribute are:

*  **"localRestartable"** &mdash; Enables the RestartStore and copies all cache entries (on-heap and/or off-heap) to disk. This option provides fast restartability with fault tolerant cache persistence on disk. This option is available for [BigMemory Go](http://terracotta.org/products/bigmemorygo) only.

*  **"distributed"** &mdash; Defers to the `<terracotta>` configuration for persistence settings. This option is for [BigMemory Max](http://terracotta.org/products/bigmemorymax) only. 

*  **"localTempSwap"** &mdash; Enables temporary local disk usage. This option provides an extra tier for storage during cache operation, but this disk storage is not persisted. After a restart, the disk tier is cleared of any cache data. 

*  **"none"** &mdash; Does not offload cache entries to disk. With this option, all of the cache is kept in memory. This is the default mode.

###Synchronous Writes Options
If the `strategy` attribute is set to "localRestartable", then the `synchronousWrites` attribute may be configured. The options for `synchronousWrites` are:

*  **synchronousWrites=”false”** &mdash; This option provides an eventually consistent copy of the cache on disk at all times. Writes to disk happen when efficient, and cache operations proceed without waiting for acknowledgement of writing to disk. After a restart, the cache is recovered as it was when last synced. This option is faster than `synchronousWrites="true"`, but after a crash, the last 2-3 seconds of written data may be lost. 

	If not specified, the default for `synchronousWrites` is "false".

*  **synchronousWrites=”true”** &mdash; This option provides a fully consistent copy of the cache on disk at all times. As elements are put into the cache, they are synchronously written to disk. The write to disk happens before a put returns to the caller. After a restart, the cache is recovered exactly as it was before shutdown. This option is slower than `synchronousWrites="false"`, but after a crash, it provides full cache consistency.

  For transaction caching with `synchronousWrites`, soft locks are used to protect access. If there is a crash in the middle of a transaction, then upon recovery the soft locks are cleared on next access.

**Note**: The `synchronousWrites` attribute is also available in the `<terracotta>` sub-element. If configured in both places, it must have the same value.  


###DiskStore Path
The path to the directory where any required disk files will be created is configured with the `<diskStore>` sub-element of the Ehcache configuration. 

For "localTempSwap", if the DiskStore path is not specified, a default path is used for the disk storage tier, and the default path will be auto-resolved in the case of a conflict with another CacheManager.
 
## Configuration Examples
This section presents possible disk usage configurations for open-source Ehcache 2.6 and higher.

###Temporary Disk Storage

The "localTempSwap" persistence strategy allows the cache to use the local disk during cache operation. The disk storage is temporary and is cleared after a restart. 

    <ehcache>
      <diskStore path="/auto/default/path"/>
      <cache>
        <persistence strategy=”localTempSwap”/>
      </cache>
    </ehcache>  
   
**Note**: With the "localTempSwap" strategy, you can use `maxEntriesLocalDisk` or `maxBytesLocalDisk` at either the Cache or CacheManager level to control the size of the disk tier. 

###In-memory Only Cache
When the persistence strategy is "none", all cache stays in memory (with no overflow to disk nor persistence on disk).

    <cache>
      <persistence strategy=”none”/>
    </cache>	
        

###Programmatic Configuration Example
The following is an example of how to programmatically configure cache persistence on disk:

    Configuration cacheManagerConfig = new Configuration()
        .diskStore(new DiskStoreConfiguration()
        .path("/path/to/store/data"));
    CacheConfiguration cacheConfig = new CacheConfiguration()
        .name("my-cache")
        .maxBytesLocalHeap(16, MemoryUnit.MEGABYTES)
        .maxBytesLocalOffHeap(256, MemoryUnit.MEGABYTES)
        .persistence(new PersistenceConfiguration().strategy(Strategy.LOCALTEMPSWAP));

    cacheManagerConfig.addCache(cacheConfig);

    CacheManager cacheManager = new CacheManager(cacheManagerConfig);
    Ehcache myCache = cacheManager.getEhcache("my-cache");



## Compatibility with Previous Versions
###Comparison of Disk Usage Options
The following table summarizes the configuration options for disk usage in Ehcache 2.6 and higher as compared with previous versions.

| Disk Usage | Ehcache 2.6 (and higher) | Ehcache 2.5 and Earlier |
|:-------|:------------|:------------|
|Fast Restartability with Strong Consistency|`persistence strategy=”localRestartable” synchronousWrites=”true”` (Enterprise only)|Not available|
|Fast Restartability with Eventual Consistency|`persistence strategy=”localRestartable” synchronousWrites=”false”` (Enterprise only)|Not available|
|Persistence for Clustered Caches|`persistence strategy=”distributed”`|Remove or edit out any disk persistence configuration elements|
|Non-Fault-Tolerant Persistence|Use one of the fault-tolerant options above*|`overflowToDisk="true" diskPersistent="true"`**|
|Temporary Storage Tier|`persistence strategy=”localTempSwap”`|`overflowToDisk="true" diskPersistent="false"`|
|In-memory Only (no disk usage)|`persistence strategy=”none”`|`overflowToDisk="false"`|


*It is recommended to use one of the fault-tolerant options, however non-fault-tolerant persistence is still available. If `<persistence>` has not been specified, you can still use `overflowToDisk="true" diskPersistent="true"`.

**In Ehcache 2.5 and earlier, cache persistence on disk for standalone Ehcache is configured with the `overflowToDisk` and `diskPersistent` attributes. If both are set to "true", cached data is saved to disk asynchronously and can be recovered after a clean shutdown or planned flush. To prevent corrupt or inconsistent data from being returned, checking measures are performed upon a restart, and if any discrepancy is found, the cache that was stored on disk is emptied and must be reloaded from the data source.


###Upgrading from Ehcache 2.5 and Earlier

After upgrading from a version of Ehcache previous to 2.6, it is strongly recommended to add the `<persistence>` sub-element to your cache configuration, and to delete, disable, or edit out disk persistence configuration elements from previous versions. The previous elements include:

*  `overflowToDisk`
*  `diskPersistence`
*  `DiskStoreBootstrapCacheLoaderFactory`

**Note**: If any of the elements above are specified in the same configuration with either the `<persistence>` sub-element or the `<terracotta>` sub-element, it will cause an Invalid Configuration Exception.

After upgrading, however, it is not mandatory to add the `<persistence>` sub-element. In Ehcache 2.6 or higher, disk persistence configuration elements from previous Ehcache versions will continue to be available with the same functionality, as long as the `<persistence>` sub-element has not been specified. 

For cache persistence on disk, you should continue to use the `overflowToDisk` and `diskPersistent` attributes. For more information, refer to [Persistence](http://ehcache.org/documentation/2.7/2.5/get-started/storage-options#Persistence) in the Ehcache 2.5 documentation.


