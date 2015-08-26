---
---
# Storage Options <a name="Storage-Options"/>
 

## Introduction
Ehcache has three storage tiers:

* a MemoryStore
* an OffHeapStore (BigMemory) and
* a DiskStore

This page presents these cache storage tiers and provides the suitable element types for each storage option.

For information about sizing the tiers, refer to [Cache Configuration Sizing Attributes](/documentation/2.6/configuration/cache-size#cache-configuration-sizing-attributes).

## MemoryStore
The `MemoryStore` is always enabled. It is not directly manipulated, but is a component of every cache.

### Suitable Element Types
All Elements are suitable for placement in the MemoryStore. It has the following characteristics:

* **Safe**
  * Thread safe for use by multiple concurrent threads.
  * Tested for memory leaks. The MemoryCacheTest passes for Ehcache but exploits a number of memory leaks in JCS. JCS will give an OutOfMemory error with a default 64M in 10 seconds.

* **Fast**&mdash;The MemoryStore, being all in memory, is the fastest caching option.

### Memory Use, Spooling, and Expiry Strategy

All caches specify their maximum in-memory size, in terms of the number of elements, at configuration time.

When an element is added to a cache and it goes beyond its maximum
memory size, an existing element is either deleted, if overflow
is not enabled, or evaluated for spooling to another tier, if overflow is enabled. The overflow options are `overflowToOffHeap` for BigMemory, and `<persistence>` for DiskStore.

If overflow is enabled, a check for expiry is carried out. If it is expired
it is deleted; if not it is spooled. The eviction of an item from
the memory store is based on the 'MemoryStoreEvictionPolicy' setting
specified in the configuration file.

`memoryStoreEvictionPolicy` is an optional attribute in ehcache.xml
introduced since 1.2. Legal values are LRU (default), LFU and FIFO.

LRU, LFU and FIFO eviction policies are supported. LRU is the default,
consistent with all earlier releases of Ehcache.

* **Least Recently Used (LRU)** *Default**&mdash;The eldest element, is the Least Recently Used (LRU). The last used timestamp is updated when an element is put into the cache or an element is retrieved from the cache with a get call.
* **Least Frequently Used (LFU)**&mdash;For each get call on the element the number of hits is updated. When a put call is made for a new element (and assuming that the max limit is reached for the MemoryStore) the element with least number of hits, the Less Frequently Used element, is evicted.
* **First In First Out (FIFO)**&mdash;Elements are evicted in the same order as they come in. When a put call is made for a new element (and assuming that the max limit is reached for the MemoryStore) the element that was placed first (First-In) in the store is the candidate for eviction (First-Out).

For all the eviction policies there are also `putQuiet` and `getQuiet` methods which do not update the last used timestamp.

When there is a `get` or a `getQuiet` on an element, it is checked for expiry. If expired, it is removed and null is returned.

Note that at any point in time there will usually be some expired
elements in the cache. Memory sizing of an application must always take into
account the maximum size of each cache.

There is a convenient method
which can provide an estimate of the size in bytes of the `MemoryStore`, [calculateInMemorySize()](http://ehcach.org/apidocs/2.6.9/net/sf/ehcache/Cache.html#calculateInMemorySize%28%29).
It returns the serialized size of the cache. However, do not use this method in production, as it is very slow. It is only meant to provide a rough estimate.

An alternative would be to have an expiry thread. This is a trade-off between lower memory use and short locking periods and CPU utilization. The design is in favour of the latter. For those concerned with memory use, simply reduce the cache's size in memory (see [How to Size Caches](/documentation/2.6/configuration/cache-size) for more information).

## BigMemory (Off-Heap Store)

[BigMemory](http://www.terracotta.org/bigmemory?src=ehcache_off_heap_store) is a pure Java product from Terracotta that permits caches to use an additional
type of memory store outside the object heap.  This off-heap store, which is not subject to Java GC, allows very large caches to be created (we have tested this up to 1TB).

Because off-heap data is stored in bytes, there are two implications:

* Only Serializable cache keys and values can be placed in the store, similar to DiskStore.
* Serialization and deserialization take place on putting and getting from the store. This means that the
 off-heap store is slower than the MemoryStore in an absolute sense, but this
 theoretical difference disappears due to two effects:

  * the MemoryStore holds the hottest subset of data from the off-heap store, already in deserialized form

  * when the GC involved with larger heaps is taken into account, the off-heap store is faster

### Suitable Element Types

Only Elements which are `Serializable` can be placed in the `OffHeapMemoryStore`. Any non serializable
Elements which attempt to overflow to the `OffHeapMemoryStore` will be removed instead, and a WARNING level
log message emitted.

For more information and details about BigMemory, refer to the [BigMemory](/documentation/2.6/configuration/bigmemory) page.

## DiskStore <a name="DiskStore"/>

The DiskStore provides a disk spooling facility that can be used for additional storage during cache operation and for persisting caches through system restarts.

For more information about cache persistence on disk, refer to the [Persistence and Restartability](/documentation/2.6/configuration/fast-restart) page.

#### DiskStores are Optional

The `diskStore` element in ehcache.xml is optional. If all caches use only MemoryStores,
then there is no need to configure a DiskStore. This simplifies configuration, and uses less threads. It is also good when multiple CacheManagers are being used, and multiple disk store paths would need to be configured.

DiskStores are configured on a per CacheManager basis. If one or more caches requires a DiskStore but none is configured, a default directory will be used and
a warning message will be logged to encourage explicit configuration of the DiskStore path.

#### Turning off DiskStores

To turn off disk store path creation, comment out the `diskStore` element in ehcache.xml.

The ehcache-failsafe.xml configuration uses a DiskStore. This will remain the case so as to not affect
existing Ehcache deployments. So if you do not wish to use a DiskStore, make
sure you specify your own ehcache.xml and comment out the `diskStore` element.

### Suitable Element Types

Only Elements which are `Serializable` can be placed in the DiskStore. Any non-serializable
Elements which attempt to overflow to the DiskStore will be removed instead, and a NotSerializableException will be thrown.

DiskStores are thread safe.

#### Serialization
Writes to and from the disk use `ObjectInputStream` and the Java serialization mechanism.

Serialization speed is affected by the size of the objects being
serialized and their type. It has been found in the ElementTest that:

  * The serialization time for a Java object consisting of a large Map of String arrays was 126ms, where the serialized size was 349,225 bytes.
  * The serialization time for a byte[] was 7ms, where the serialized size was 310,232 bytes.

Byte arrays are 20 times faster to serialize. Make use of byte arrays to increase DiskStore performance.


### Persistent Storage Options

Two DiskStore options are available:

*  "localTempSwap" for temporary overflow to disk
*  "localRestartable" for disk persistence (Enterprise Ehcache only)

####localTempSwap

The "localTempSwap" strategy allows the cache to overflow to disk during cache operation, providing an extra tier for cache storage. This disk storage is temporary and is cleared after a restart.

If the disk store path is not specified, a default path is used, and the default will be auto-resolved in the case of a conflict with another CacheManager.

The TempSwap DiskStore creates a data file for each cache on startup called "`<cache_name>`.data".

####localRestartable

The "localRestartable" persistence strategy implements a restartable store that is a mirror of the in-memory cache. After any restart, data that was last in the cache will automatically load into the restartable store, and from there the data will be available to the cache.

The path to the directory where any required disk files will be created is configured with the `<diskStore>` sub-element of the Ehcache configuration. In order to use the restartable store, a unique and explicitly specified path is required.


### DiskStore Configuration Element

Files are created in the directory specified by the `<diskStore>`
configuration element. The `<diskStore>` element has one attribute called `path`.


    <diskStore path="/path/to/store/data"/>


Legal values for the path attibute are legal file system paths. For example, for Unix:

<pre>
/home/application/cache
</pre>

The following system properties are also legal, in which case they are translated:

* user.home - User's home directory
* user.dir - User's current working directory
* java.io.tmpdir - Default temp file path
* ehcache.disk.store.dir - A system property you would normally specify on the command line&mdash;for example,
`java -Dehcache.disk.store.dir=/u01/myapp/diskdir`

Subdirectories can be specified below the system property, for example:

<pre>
user.dir/one
</pre>


To programmatically set a DiskStore path:

    DiskStoreConfiguration diskStoreConfiguration = new DiskStoreConfiguration();

    diskStoreConfiguration.setPath("/my/path/dir");

    // Already created a configuration object ...
    configuration.addDiskStore(diskStoreConfiguration);

    CacheManager mgr = new CacheManager(configuration);

**Note**: A CacheManager's DiskStore path cannot be changed once it is set in configuration. If the DiskStore path is changed, the CacheManager must be recycled for the new path to take effect.

### Expiry and Eviction
Expired elements are eventually evicted to free up disk space. The element is also removed from the in-memory index of elements.

One thread per cache is used to remove expired elements. The optional attribute `diskExpiryThreadIntervalSeconds`
sets the interval between runs of the expiry thread.

**Warning**: Setting `diskExpiryThreadIntervalSeconds` to a low value
is not recommended. It can cause excessive DiskStore locking and high CPU utilization. The default value is 120 seconds.

If a cache's DiskStore has a limited size, Elements will be evicted from the DiskStore when it exceeds this limit.
The LFU algorithm is used for these evictions. It is not configurable or changeable.

**Note**: With the "localTempSwap" strategy, you can use `maxEntriesLocalDisk` or `maxBytesLocalDisk` at either the Cache or CacheManager level to control the size of the swap-to-disk area.





## Some Configuration Examples

These examples show how to allocate 8GB of machine memory to different stores. It assumes a
data set of 7GB - say for a cache of 7M items (each 1kb in size).

Those who want minimal application response-time variance (or minimizing GC pause times), will likely
want all the cache to be off-heap.
Assuming that 1GB of heap is needed for the rest of the app, they will set their Java config as follows:

<pre>
java -Xms1G -Xmx1G -XX:maxDirectMemorySize=7G
</pre>

And their Ehcache config as:

<pre>
&lt;cache
 maxEntriesLocalHeap=100
 overflowToOffHeap="true"
 maxBytesLocalOffHeap="6G"
... /&gt;
</pre>

<table markdown="1">
<caption>NOTE: Direct Memory and Off-heap Memory Allocations</caption>
<tr><td>
To accommodate server communications layer requirements, the value of maxDirectMemorySize must be greater than the value of maxBytesLocalOffHeap. The exact amount greater depends upon the size of maxBytesLocalOffHeap. The minimum is 256MB, but if you allocate 1GB more to the maxDirectMemorySize, it will certainly be sufficient. The server will only use what it needs and the rest will remain available.
</td></tr>
</table>

Those who want best possible performance for a hot set of data, while still reducing overall application repsonse time variance, will likely want a combination of on-heap and off-heap. The heap will be used for the hot set, the offheap for the rest. So, for example
if the hot set is 1M items (or 1GB) of the 7GB data. They will set their Java config as follows

<pre>
java -Xms2G -Xmx2G -XX:maxDirectMemorySize=6G
</pre>

And their Ehcache config as:

<pre>
&lt;cache
  maxEntriesLocalHeap=1M
  overflowToOffHeap="true"
  maxBytesLocalOffHeap="5G"
  ...&gt;
</pre>

This configuration will compare VERY favorably against the alternative of keeping the less-hot set in a
database (100x slower) or caching on local disk (20x slower).

Where the data set is small and pauses are not a problem, the whole data set can be kept on heap:

<pre>
&lt;cache
  maxEntriesLocalHeap=1M
  overflowToOffHeap="false"
  ...&gt;
</pre>

Where latency isn't an issue overflow to disk can be used:

<pre>
&lt;cache
  maxEntriesLocalHeap=1M
  <persistence strategy="localTempSwap"/>
  ...&gt;
</pre>

## Performance Considerations

### Relative Speeds

The MemoryStore is approximately an order of magnitude faster than the DiskStore. The reason is that the DiskStore incurs the following extra overhead:

* Serialization of the key and value
* Eviction from the MemoryStore using an eviction algorithm
* Reading from disk

Note that writing to disk is not a synchronous performance overhead because it is handled by a separate thread.

### Always use some amount of Heap

For performance reasons, Ehcache should always use as much heap memory as possible without triggering GC pauses. Use BigMemory (the off-heap store) to hold the data that cannot fit in heap without causing GC pauses.
