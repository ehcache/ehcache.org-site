---
---
# Cache Configuration


 

## Introduction
Caches can be configured in Ehcache either declaratively, in XML, or by creating them programmatically and specifying their parameters in the constructor.

While both approaches are fully supported it is generally a good idea to separate the cache configuration from runtime use. There are also these benefits:

* It is easy if you have all of your configuration in one place.

    Caches consume memory, and disk space. They need to be carefully tuned. You can see the total effect in a configuration file. You could do this all in code, but it would not as visible.

* Cache configuration can be changed at deployment time.
* Configuration errors can be checked for at start-up, rather than causing a runtime error.
* A defaultCache configuration exists and will always be loaded.

    While a defaultCache configuration is not required, an error is generated if caches are created by name (programmatically) with no defaultCache loaded. 

The Ehcache documentation focuses on XML declarative configuration. Programmatic configuration is explored in certain examples and is documented in [Javadocs](http://ehcache.org/apidocs/).

Ehcache is redistributed by lots of projects, some of which may not provide a sample Ehcache XML configuration file (or they provide an outdated one). If one is not provided, [download Ehcache](http://ehcache.org/downloads). The latest ehcache.xml and ehcache.xsd are provided in the distribution.

## Dynamically Changing Cache Configuration

After a Cache has been started, its configuration is not generally changeable. However, since Ehcache 2.0, certain cache configuration parameters can be modified dynamically at runtime. In the current version of Ehcache, this includes the following:

* timeToLive

    The maximum number of seconds an element can exist in the cache regardless of use. The element expires at this limit and will no longer be returned from the cache. The default value is 0, which means no TTL eviction takes place (infinite lifetime).

* timeToIdle

    The maximum number of seconds an element can exist in the cache without being accessed. The element expires at this limit and will no longer be returned from the cache. The default value is 0, which means no TTI eviction takes place (infinite lifetime).

* Local sizing attributes maxEntriesLocalHeap, maxBytesLocalHeap, maxBytesLocalOffHeap, maxEntriesLocalDisk, maxBytesLocalDisk.
* memory-store eviction policy
* CacheEventListeners can be added and removed dynamically

Note that the `eternal` attribute, when set to "true", overrides `timeToLive` and `timeToIdle` so that no expiration can take place.
This example shows how to dynamically modify the cache configuration of running cache:

    Cache cache = manager.getCache("sampleCache");
    CacheConfiguration config = cache.getCacheConfiguration();
    config.setTimeToIdleSeconds(60);
    config.setTimeToLiveSeconds(120);
    config.setmaxEntriesLocalHeap(10000);
    config.setmaxEntriesLocalDisk(1000000);
    
Dynamic cache configurations can also be frozen to prevent future changes:

    Cache cache = manager.getCache("sampleCache");
    cache.disableDynamicFeatures();

In `ehcache.xml`, you can disable dynamic configuration by setting the `<ehcache>` element's `dynamicConfig` attribute to "false".

### Dynamic Configuration Changes for Distributed Cache
Just as for a standalone cache, mutating the configuration of a distributed cache requires access to the set methods of `cache.getCacheConfiguration()`.

The following table provides information dynamically changing common cache configuration options in a Terracotta cluster. The table's Scope column, which specifies where the configuration is in effect, can have one of the following values:

* Client – The Terracotta client where the CacheManager runs.
* TSA – The Terracotta Server Array for the cluster.
* BOTH – Both the client and the TSA.

Note that configuration options whose scope covers "BOTH" are distributed and therefore affect a cache on all clients.

<table markdown="1">
<tr><th>Configuration Option</th><th>Dynamic</th><th>Scope</th><th>Notes</th></tr>
<tr>
<td>Cache name</td>
<td>NO</td>
<td>TSA</td>
<td></td>
</tr><tr>
<td>Nonstop</td>
<td>NO</td>
<td>Client</td>
<td>Enable High Availability</td>
</tr><tr>
<td>Timeout</td>
<td>YES</td>
<td>Client</td>
<td>For nonstop.</td>
</tr><tr>
<td>Timeout Behavior</td>
<td>YES</td>
<td>Client</td>
<td>For nonstop.</td>
</tr><tr>
<td>Immediate Timeout When Disconnected</td>
<td>YES</td>
<td>Client</td>
<td>For nonstop.</td>
</tr><tr>
<td>Time to Idle</td>
<td>YES</td>
<td>BOTH</td>
<td></td>
</tr><tr>
<td>Maximum Entries or Bytes in Local Stores</td>
<td>YES</td>
<td>Client</td>
<td>This and certain other sizing attributes that are part of <a href="/documentation/arc/index">ARC</a> may be pooled by the CacheManager, creating limitations on how they can be changed.</td>
</tr><tr>
<td>Time to Live</td>
<td>YES</td>
<td>BOTH</td>
<td></td>
</tr><tr>
<td>Maximum Elements on Disk</td>
<td>YES</td>
<td>TSA</td>
<td></td>
</tr><tr>
<td>Overflow to Disk</td>
<td>N/A</td>
<td>N/A</td>
<td></td>
</tr><tr>
<td>Persist to Disk</td>
<td>N/A</td>
<td>N/A</td>
<td></td>
</tr><tr>
<td>Disk Expiry Thread Interval</td>
<td>N/A</td>
<td>N/A</td>
<td></td>
</tr><tr>
<td>Disk Spool Buffer Size</td>
<td>N/A</td>
<td>N/A</td>
<td></td>
</tr><tr>
<td>Overflow to Off-Heap</td>
<td>N/A</td>
<td>N/A</td>
<td></td>
</tr><tr>
<td>Maximum Off-heap</td>
<td>N/A</td>
<td>N/A</td>
<td>Maximum off-heap memory allotted to the TSA.</td>
</tr><tr>
<td>Eternal</td>
<td>YES</td>
<td>BOTH</td>
<td></td>
</tr><tr>
<td>Clear on Flush</td>
<td>NO</td>
<td>Client</td>
<td></td>
</tr><tr>
<td>Copy on Read</td>
<td>NO</td>
<td>Client</td>
<td></td>
</tr><tr>
<td>Copy on Write</td>
<td>NO</td>
<td>Client</td>
<td></td>
</tr><tr>
<td>Memory Store Eviction Policy</td>
<td>NO</td>
<td>Client</td>
<td></td>
</tr><tr>
<td>Statistics</td>
<td>YES</td>
<td>Client</td>
<td>Cache statistics. Change dynamically with <code>cache.setStatistics(boolean)</code> method.</td>
</tr><tr>
<td>Logging</td>
<td>NO</td>
<td>Client</td>
<td>Ehcache and Terracotta logging is specified in configuration. However, <a href="/documentation/apis/cluster-events">cluster events</a> can be set dynamically.</td>
</tr><tr>
<td>Consistency</td>
<td>NO</td>
<td>Client</td>
<td>It is possible to switch to and from <a href="/documentation/apis/bulk-loading">bulk mode</a>.</td>
</tr><tr>
<td>Synchronous Writes</td>
<td>NO</td>
<td>Client</td>
<td></td>
</tr>
</table>

To apply non-dynamic L1 changes, remove the existing cache and then add (to the same CacheManager) a new cache with the same name as the removed cache, and which has the new configuration. Restarting the CacheManager with an updated configuration, where all cache names are the same as in the previous configuration, will also apply non-dynamic L1 changes.

## Memory-Based Cache Sizing (Ehcache 2.5 and higher)

Historically Ehcache has only permitted sizing of caches in the Java heap (the OnHeap store) and the disk (DiskStore). BigMemory introduced the OffHeap store, where sizing of caches is also allowed.

To learn more about sizing caches, see [How to Size Caches](/documentation/configuration/cache-size).


### Pinning of Caches and Elements in Memory (2.5 and higher)
Pinning of caches or specific elements is discussed in [Pinning, Expiration, and Eviction](/documentation/configuration/data-life).


## Cache Warming for multi-tier Caches 
**(Ehcache 2.5 and higher)**

When a cache starts up, the On-Heap and Off-Heap stores are always empty. Ehcache provides a BootstrapCacheLoader
mechanism to overcome this. The BootstrapCacheLoader is run before the cache is set to alive. If synchronous, loading
completes before the CacheManager starts, or if asynchronous, the CacheManager starts but loading continues agressively
rather than waiting for elements to be requested, which is a lazy loading approach.

Replicated caches provide a boot strap mechanism which populates them. For example following is the JGroups bootstrap
cache loader:

    <bootstrapCacheLoaderFactory class="net.sf.ehcache.distribution.jgroups.JGroupsBootstrapCacheLoaderFactory" properties="bootstrapAsynchronously=true"/>

There are two new bootstrapCacheLoaderFactory implementations: one for standalone caches with DiskStores, and one for Terracotta Distributed caches.

### DiskStoreBootstrapCacheLoaderFactory

The DiskStoreBootstrapCacheLoaderFactory loads elements from the DiskStore to the On-Heap Store and the Off-Heap store
until either:

* the memory stores are full
* the DiskStore has been completely loaded

#### Configuration

The DiskStoreBootstrapCacheLoaderFactory is configured as follows:

    <bootstrapCacheLoaderFactory class="net.sf.ehcache.store.DiskStoreBootstrapCacheLoaderFactory" properties="bootstrapAsynchronously=true"/>

### TerracottaBootstrapCacheLoaderFactory

The TerracottaBootstrapCacheLoaderFactory loads elements from the Terracotta L2 to the L1 based on what it was using
the last time it ran. If this is the first time it has been run it has no effect.

It works by periodically writing the keys used by the L1 to disk.

#### Configuration

The TerracottaStoreBootstrapCacheLoaderFactory is configured as follows:

    <bootstrapCacheLoaderFactory class="net.sf.ehcache.terracotta.TerracottaBootstrapCacheLoaderFactory"
    properties="bootstrapAsynchronously=true,
               directory=dumps,
               interval=5,
               immediateShutdown=false,
               snapshotOnShutDown=true,
               doKeySnapshot=false,
               useDedicatedThread=false"/>

The configuration properties are:

* bootstrapAsynchronously: Whether to bootstrap asynchronously or not.
  Asynchronous bootstrap will allow the cache to start up for use while loading continues.
* directory: the directory that snapshots are created in.
  By default this will use the CacheManager's DiskStore path.
* interval: interval in seconds between each key snapshot. Default is every 10 minutes (600 seconds).
 Cache performance overhead increases with more frequent snapshots and is dependent on such factors as cache size and disk speed. Thorough testing with various values is highly recommended.
* immediateShutdown: whether, when shutting down the Cache, it should let the keysnapshotting
 (if in progress) finish or terminate right away. Defaults to true.
* snapshotOnShutDown: Whether to take the local key-set snapshot when the Cache is disposed. Defaults to false.
* doKeySnapshot : Set to false to disable keysnapshotting. Default is true.
 Enables loading from an existing snapshot without taking new snapshots after the existing one been loaded (stable snapshot). Or to only snapshot at cache disposal (see snapshotOnShutdown).
* useDedicatedThread : By default, each CacheManager uses a thread pool of 10 threads to do the snapshotting. If you want the cache to use a dedicated thread for the snapshotting, set this to true

Key snapshots will be in the diskstore directory configured at the cachemanager level.

One file is created for each cache with the name `<cacheName>.keySet`.

In case of a abrupt termination, while new snapshots are being written they are written using the extension `.temp`
and then after the write is complete the existing file is renamed to `.old`, the `.temp` is renamed to `.keyset` and finally
the `.old` file is removed. If an abrupt termination occurs you will see some of these files in the directory which will
be cleaned up on the next startup.

Like other DiskStore files, keyset snapshot files can be migrated to other nodes for warmup.

If between restarts, the cache can't hold the entire hot set locally, the Loader will stop loading as soon as the on-heap (or off-heap)
store has been filled.

## copyOnRead and copyOnWrite cache configuration

A cache can be configured to copy the data, rather than return reference to it on get or put. This is configured using the
`copyOnRead` and `copyOnWrite` attributes of cache and defaultCache elements in your configuration or programmatically as follows:

    CacheConfiguration config = new CacheConfiguration("copyCache", 1000).copyOnRead(true).copyOnWrite(true);
    Cache copyCache = new Cache(config);

The default configuration will be false for both options.

In order to copy elements on put()-like and/or get()-like operations, a CopyStrategy is being used. The default implementation
uses serialization to copy elements. You can provide your own implementation of `net.sf.ehcache.store.compound.CopyStrategy` like
this:

    <cache name="copyCache"
        maxEntriesLocalHeap="10"
        eternal="false"
        timeToIdleSeconds="5"
        timeToLiveSeconds="10"
        overflowToDisk="false"
        copyOnRead="true"
        copyOnWrite="true">
      <copyStrategy class="com.company.ehcache.MyCopyStrategy"/>
    </cache>

Per cache, a single instance of your `CopyStrategy` is used. Therefore, in your implementation of `CopyStrategy.copy(T)`, T has to be thread-safe.

A copy strategy can be added programmatically in the following:

    CacheConfiguration cacheConfiguration = new CacheConfiguration("copyCache", 10);

    CopyStrategyConfiguration copyStrategyConfiguration = new CopyStrategyConfiguration();
    copyStrategyConfiguration.setClass("com.company.ehcache.MyCopyStrategy");

    cacheConfiguration.addCopyStrategy(copyStrategyConfiguration);


## Special System Properties

<a id="net.sf.ehcache.disabled"></a>
### net.sf.ehcache.disabled
Setting this system property to `true` (using `java -Dnet.sf.ehcache.disabled=true` in the Java command line) disables caching in ehcache. If disabled, no elements can be added to a cache (puts are silently discarded).

<a id="net.sf.ehcache.use.classic.lru"></a>
### net.sf.ehcache.use.classic.lru
When LRU is selected as the eviction policy, set this system property to `true` (using `java -Dnet.sf.ehcache.use.classic.lru=true` in the Java command line) to use the older LruMemoryStore implementation. This is provided for ease of migration.

## ehcache.xsd
Ehcache configuration files must be comply with the Ehcache XML schema, `ehcache.xsd`.
It can be downloaded from [http://ehcache.org/ehcache.xsd](http://ehcache.org/ehcache.xsd).

## ehcache-failsafe.xml
If the CacheManager default constructor or factory method is called, Ehcache looks for a
  file called `ehcache.xml` in the top level of the classpath. Failing that it looks for
  `ehcache-failsafe.xml` in the classpath. `ehcache-failsafe.xml` is packaged in the Ehcache JAR
  and should always be found.

`ehcache-failsafe.xml` provides an extremely simple default configuration to enable users to
get started before they create their own `ehcache.xml`.

If it used Ehcache will emit a warning, reminding the user to set up a proper configuration.
The meaning of the elements and attributes are explained in the section on `ehcache.xml`.

    <ehcache>
      <diskStore path="java.io.tmpdir"/>
      <defaultCache
         maxEntriesLocalHeap="10000"
         eternal="false"
         timeToIdleSeconds="120"
         timeToLiveSeconds="120"
         overflowToDisk="true"
         maxEntriesLocalDisk="10000000"
         diskPersistent="false"
         diskExpiryThreadIntervalSeconds="120"
         memoryStoreEvictionPolicy="LRU"
      />
    </ehcache>

## Update Checker

The update checker is used to see if you have the latest version of Ehcache. It is also used
to get non-identifying feedback on the OS architectures using Ehcache.
To disable the check, do one of the following:

### By System Property

    -Dnet.sf.ehcache.skipUpdateCheck=true

### By Configuration

The outer `ehcache` element takes an `updateCheck` attribute, which is set to false as in the
following example.

    <ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="ehcache.xsd"
        updateCheck="false" monitoring="autodetect"
        dynamicConfig="true">

## ehcache.xml and Other Configuration Files

Prior to ehcache-1.6, Ehcache only supported ASCII ehcache.xml configuration files.
  Since ehcache-1.6, UTF8 is supported, so that configuration can use Unicode. As UTF8 is
  backwardly compatible with ASCII, no conversion is necessary.

If the CacheManager default constructor or factory method is called, Ehcache looks for a
  file called ehcache.xml in the top level of the classpath.

The non-default creation methods allow a configuration file to be specified which can be
  called anything.

One XML configuration is required for each CacheManager that is created. It is an error to
use the same configuration, because things like directory paths and listener ports will
conflict. Ehcache will attempt to resolve conflicts and will emit a warning reminding the
user to configure a separate configuration for multiple CacheManagers with conflicting
settings.

The sample `ehcache.xml` is included in the Ehcache distribution. It contains full commentary required to configure each element. Further
  information can be found in specific chapters in the Guide.

It can also be downloaded from [http://ehcache.org/ehcache.xml](http://ehcache.org/ehcache.xml).

## Ehcache Configuration With Terracotta Clustering

See the [distributed-cache configuration guidelines](/documentation/configuration/distributed-cache-configuration) for more information on configuration with distributed caches in a Terracotta cluster.
