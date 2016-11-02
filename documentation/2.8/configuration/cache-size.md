---
---
# How to Size Caches


## Introduction
Tuning Ehcache often involves sizing cached data appropriately. Ehcache provides a number of ways to size the different data tiers using simple cache-configuration sizing attributes. These sizing attributes affect local memory and disk resources, allowing them to be set differently on each node.

## Cache Configuration Sizing Attributes

The following table summarizes cache-sizing attributes for standalone Ehcache.

| Tier | Attribute | Pooling available at CacheManager level? | Description |
| :-- | :-- | :-- | :-- |
| Heap | `maxEntriesLocalHeap` `maxBytesLocalHeap` | `maxBytesLocalHeap` only | The maximum number of cache entries or bytes a cache can use in local heap memory, or, when set at the CacheManager level (maxBytesLocalHeap only), a local pool available to all caches under that CacheManager. This setting is required for every cache or at the CacheManager level. |
| Off-heap | `maxBytesLocalOffHeap` | Yes | This tier is available with <a href="http://terracotta.org/products/bigmemorygo">BigMemory Go</a>.The maximum number of bytes a cache can use in off-heap memory, or, when set at the CacheManager level, as a pool available to all caches under that CacheManager. This setting requires BigMemory. |
| Local disk | `maxEntriesLocalDisk` `maxBytesLocalDisk` | `maxBytesLocalDisk` only | The maximum number of cache entries or bytes a standalone cache can use on the local disk, or, when set at the CacheManager level (maxBytesLocalDisk only), a local pool available to all caches under that CacheManager. Distributed caches cannot use the local disk. Note that these settings apply only to temporary swapping of data to disk ("localTempSwap"); these settings do not apply to disk persistence. |


Attributes that set a number of entries take an integer. Attributes that set a memory size (bytes) use the Java -Xmx syntax (for example: "500k", "200m", "2g") or percentage (for example: "20%"). Percentages, however, can be used only in the case where a CacheManager-level pool has been configured (see below).

The following diagram illustrates the tiers and their effective sizing attributes.

![Ehcache Data Tiers and Sizing Attributes](/images/documentation/tier-size-standalone.png)

## Pooling Resources Versus Sizing Individual Caches
You can constrain the size of any cache on a specific tier in that cache's configuration. You can also constrain the size of all of a CacheManager's caches in a specific tier by configuring an overall size at the CacheManager level.

If there is no CacheManager-level pool specified for a tier, an individual cache claims the amount of that tier specified in its configuration. If there is a CacheManager-level pool specified for a tier, an individual cache claims that amount _from the pool_. In this case, caches with no size configuration for that tier receive an equal share of the remainder of the pool (after caches with explicit sizing configuration have claimed their portion).

For example, if CacheManager with eight caches pools one gigabyte of heap, and two caches each explicitly specify 200MB of heap while the remaining caches do not specify a size, the remaining caches will share 600MB of heap equally. Note that caches must use bytes-based attributes to claim a portion of a pool; entries-based attributes such as `maxEntriesLocal` cannot be used with a pool.

On startup, the sizes specified by caches are checked to ensure that any CacheManager-level pools are not over-allocated. If over-allocation occurs for any pool, an InvalidConfigurationException is thrown. Note that percentages should not add up to more than 100% of a single pool.

If the sizes specified by caches for any tier take exactly the entire CacheManager-level pool specified for that tier, a warning is logged. In this case, caches that do not specify a size for that tier cannot use the tier as nothing is left over.

### Local Heap
A size must be provided for local heap, either in the CacheManager (`maxBytesLocalHeap` only) or in each individual cache (`maxBytesLocalHeap` or `maxEntriesLocalHeap`). Not doing so causes an InvalidConfigurationException.

If pool is configured, it can be combined with a local-heap setting in an individual cache. This allows the cache to claim a specified portion of the heap setting configured in the pool. However, in this case the cache setting must use `maxBytesLocalHeap` (same as the CacheManager).

In any case, every cache **must** have a local-heap setting, either configured explicitly or taken from the pool configured in the CacheManager.

### BigMemory (Local Off-Heap)
If you are using [BigMemory Go](http://terracotta.org/products/bigmemorygo), off-heap sizing is available. Off-heap sizing can be configured in bytes only, never by entries.

If a CacheManager has a pool configured for off-heap, your application cannot add caches dynamically that have off-heap configuration &mdash; doing so generates an error. In addition, if any caches that used the pool are removed programmatically or through the Developer Console, other caches in the pool cannot claim the unused portion. To allot the entire off-heap pool to the remaining caches, remove the unwanted cache from the Ehcache configuration and then reload the configuration.

To use local off-heap as a data tier, a cache must have `overflowToOffHeap` set to "true". If a CacheManager has a pool configured for using off-heap, the `overflowToOffHeap` attribute is automatically set to "true" for all caches. In this case, you can prevent a specific cache from overflowing to off-heap by explicitly setting its `overflowToOffHeap` attribute to "false".

### Local Disk
The local disk can be used as a data tier. Note the following:

* Distributed caches cannot use the local disk.
* To use the local disk as a data tier, a cache must have `persistenceStrategy` set to "localTempSwap".
* The local disk is the slowest local tier.

## Cache Sizing Examples
The following examples illustrate both pooled and individual cache-sizing configurations.

### Pooled Resources

The following configuration sets pools for all of this CacheManager's caches:

~~~ xml
<ehcache xmlns="..."
    name="CM1"
    maxBytesLocalHeap="100M"
    maxBytesLocalOffHeap="10G"
    maxBytesLocalDisk="50G">
  ...

  <cache name="Cache1" ...> </cache>
  <cache name="Cache2" ...> </cache>
  <cache name="Cache3" ...> </cache>

</ehcache>
~~~

CacheManager CM1 automatically allocates these pools equally among its three caches. Each cache gets one third of the allocated heap, off-heap, and local disk. Note that at the CacheManager level, resources can be allocated in bytes only.

### Explicitly Sizing Caches
You can explicitly allocate resources to specific caches:

~~~ xml
<ehcache xmlns="..."
    name="CM1"
    maxBytesLocalHeap="100M"
    maxBytesLocalOffHeap="10G"
    maxBytesLocalDisk="60G">
  ...

  <cache name="Cache1" ...
      maxBytesLocalHeap="50M">
    ...
  </cache>

  <cache name="Cache2" ...
      maxBytesLocalOffHeap="5G">
    ...
  </cache>
  
  <cache name="Cache3">
    ... 
  </cache>
</ehcache>
~~~

In the example above, Cache1 reserves 50Mb of the 100Mb local-heap pool; the other caches divide the remaining portion of the pool equally. Cache2 takes half of the local off-heap pool; the other caches divide the remaining portion of the pool equally. Cache3 receives 25Mb of local heap, 2.5Gb of off-heap, and 20Gb of the local disk.

Caches that reserve a portion of a pool are not required to use that portion. Cache1, for example, has a fixed portion of the local heap but may have any amount of data in heap up to the configured value of 50Mb.

Note that caches must use the same sizing attributes used to create the pool. Cache1, for example, cannot use `maxEntriesLocalHeap` to reserve a portion of the pool.

### Mixed Sizing Configurations
If a CacheManager does not pool a particular resource, that resource can still be allocated in cache configuration, as shown in the following example.

~~~ xml
<ehcache xmlns="..."
    name="CM2"
    maxBytesLocalHeap="100M">
  ...

  <cache name="Cache4" ...
      maxBytesLocalHeap="50M"
      maxEntriesLocalDisk="100000">
    ...
  </cache>

  <cache name="Cache5" ...
      maxBytesLocalOffHeap="10G">
    ...
  </cache>
  <cache name="Cache6"> ... </cache>
</ehcache>
~~~

CacheManager CM2 creates one pool (local heap). Its caches all use the local heap and are constrained by the pool setting, as expected. However, cache configuration can allocate other resources as desired. In this example, Cache4 allocates disk space for its data, and Cache5 allocates off-heap space for its data. Cache6 gets 25Mb of local heap only.

### Using Percents
The following configuration sets pools for each tier:

~~~ xml
<ehcache xmlns...
    name="CM1"
    maxBytesLocalHeap="1G"
    maxBytesLocalOffHeap="10G"
    maxBytesLocalDisk="50G">
  ...

  <!-- Cache1 gets 400Mb of heap, 2.5Gb of off-heap, and 5Gb of disk. -->
  <cache name="Cache1" ...
      maxBytesLocalHeap="40%">
  </cache>

  <!-- Cache2 gets 300Mb of heap, 5Gb of off-heap, and 5Gb of disk. -->
  <cache name="Cache2" ...
      maxBytesLocalOffHeap="50%">
  </cache>

  <!-- Cache2 gets 300Mb of heap, 2.5Gb of off-heap, and 40Gb of disk. -->
  <cache name="Cache3" ...
      maxBytesLocalDisk="80%">
  </cache>
</ehcache>
~~~

<caption>NOTE: Configuring Cache Sizes with Percentages</caption>

|You can use a percentage of the total JVM heap for the CacheManager maxBytesLocalHeap. The CacheManager percentage, then, is a portion of the total JVM heap, and in turn, the Cache percentage is the portion of the CacheManager pool for that tier.|

### Sizing Caches Without a Pool

The CacheManager in this example does not pool any resources.

~~~ xml
<ehcache xmlns="..."
    name="CM3"
    ... >
  ...

  <cache name="Cache7" ...
      maxBytesLocalHeap="50M"
      maxEntriesLocalDisk="100000">
    ...
  </cache>

  <cache name="Cache8" ...
      maxEntriesLocalHeap="1000"
      maxBytesLocalOffHeap="10G">
    ...
  </cache>
  <cache name="Cache9" ...
      maxBytesLocalHeap="50M">
    ...
  </cache>

</ehcache>
~~~

Caches can be configured to use resources as necessary. Note that every cache in this example must declare a value for local heap. This is because no pool exists for the local heap; implicit (CacheManager configuration) or explicit (cache configuration) local-heap allocation is required.

### Overflows
Caches that do not specify overflow will overflow if a pool is set for off-heap and disk.

~~~ xml
<ehcache maxBytesLocalHeap="1g" maxBytesLocalOffHeap="4g"
         maxBytesLocalDisk="100g" >

  <cache name="explicitlyAllocatedCache1"
      maxBytesLocalHeap="50m"
     	maxBytesLocalOffHeap="200m"
     	timeToLiveSeconds="100">
  </cache>

  <!-- Does not use off-heap because overflow has been explicitly disabled. -->
  <cache name="automaticallyAllocatedCache2"
      timeToLiveSeconds="100"
      overflowToOffHeap="false">
  </cache>

  <!-- Does not overflow to disk because the cache is configured for Fast Restart (a different use of the disk which supercedes overflow to disk). -->
  <cache name="explicitlyAllocatedCache2"
      maxLocalHeap="10%"
     	maxBytesLocalOffHeap="200m"
     	timeToLiveSeconds="100">
    <persistence strategy="localRestartable"/>
  </cache>

  <!-- Overflows automatically to off-heap and disk because no specific override and resources are set at the CacheManager level -->
  <cache name="automaticallyAllocatedCache1"
      timeToLiveSeconds="100">
  </cache>
</ehcache>
~~~


## Sizing Distributed Caches
Distributed caches, available with [BigMemory Max](http://terracotta.org/products/bigmemorymax), can be sized as noted above, except that they do not use the local disk and therefore cannot be configured with *LocalDisk sizing attributes. Distributed caches use the storage resources (off-heap and disk) available on the Terracotta Server Array.

Cache-configuration sizing attributes behave as local configuration, which means that every node can load its own sizing attributes for the same caches. That is, while some elements and attributes are fixed by the first Ehcache configuration loaded in the cluster, cache-configuration sizing attributes can vary across nodes for the same cache.

For example, a cache may have the following configuration on one node:

~~~ xml
  <cache name="myCache"
      maxEntriesOnHeap="10000"
      maxBytesLocalOffHeap="8g"
      eternal="false"
      timeToIdleSeconds="3600"
      timeToLiveSeconds="1800">
    <persistence strategy="distributed"/>
    <terracotta/>
  </cache>
~~~

The same cache may have the following size configuration on another node:

~~~ xml
  <cache name="myCache"
      maxEntriesOnHeap="10000"
      maxBytesLocalOffHeap="10g"
      eternal="false"
      timeToIdleSeconds="3600"
      timeToLiveSeconds="1800">
    <persistence strategy="distributed"/>
    <terracotta/>
  </cache>
~~~

If the cache exceeds its size constraints on a node, then with this configuration the Terracotta Server Array provides myCache with an unlimited amount of disk space for spillover and backup. To impose a limit, you must set `maxEntriesInCache` to a positive non-zero value:

~~~ xml
  <cache name="myCache"
      maxEntriesOnHeap="10000"
      maxBytesLocalOffHeap="10g"
      eternal="false"
      timeToIdleSeconds="3600"
      timeToLiveSeconds="1800"
      maxEntriesInCache="1000000">
    <persistence strategy="distributed"/>
    <terracotta/>
  </cache>
~~~

The Terracotta Server Array will now evict myCache entries to stay within the limit set by `maxEntriesInCache`. However, for any particular cache, eviction on the Terracotta Server Array is based on the largest size configured for that cache. In addition, the Terracotta Server Array will _not_ evict any cache entries that exist on at least one client node, regardless of the limit imposed by `maxEntriesInCache`.


## Overriding Size Limitations

Pinned caches can override the limits set by cache-configuration sizing attributes, potentially causing OutOfMemory errors. This is because pinning prevents flushing of cache entries to lower tiers. For more information on pinning, see [Pinning, Eviction, and Expiration](/documentation/2.8/configuration/data-life.html).


## Built-In Sizing Computation and Enforcement

Internal Ehcache mechanisms track data-element sizes and enforce the limits set by CacheManager sizing pools.

### Sizing of cached entries

Elements put in a memory-limited cache will have their memory sizes measured. The entire Element instance added
 to the cache is measured, including key and value, as well as the memory footprint of adding that instance to
 internal data structures. Key and value are measured as object graphs &ndash; each reference is followed and the object
 reference also measured. This goes on recursively.

Shared references will be measured by each class that references it. This will result in an overstatement. Shared references
 should therefore be ignored.

#### Ignoring for Size Calculations

For the purposes of measurement, references can be ignored using the `@IgnoreSizeOf` annotation. The annotation may be declared at the class level, on a field, or on a package. You can also specify a file containing the fully qualified names of classes, fields, and packages to be ignored.

This annotation is not inherited, and must be added to any subclasses that should also be excluded from sizing.

The following example shows how to ignore the `Dog` class.

~~~ java
@IgnoreSizeOf
public class Dog {
  private Gender gender;
  private String name;
}
~~~

The following example shows how to ignore the `sharedInstance` field.

~~~ java
public class MyCacheEntry {
  @IgnoreSizeOf
  private final SharedClass sharedInstance;
  ...
}
~~~

Packages may also be ignored if you add the @IgnoreSizeOf annotation to appropriate package-info.java of the desired package. Here is a sample package-info.java for and in the com.pany.ignore package:

~~~ java
@IgnoreSizeOf
package com.pany.ignore;
import net.sf.ehcache.pool.sizeof.filter.IgnoreSizeOf;
~~~

Alternatively, you may declare ignored classes and fields in a file and specify a `net.sf.ehcache.sizeof.filter` system property to point to that file.

~~~
# That field references a common graph between all cached entries
com.pany.domain.cache.MyCacheEntry.sharedInstance

# This will ignore all instances of that type
com.pany.domain.SharedState

# This ignores a package
com.pany.example
~~~

Note that these measurements and configurations apply only to on-heap storage. If Elements are moved to off-heap memory, disk, or the Terracotta Server Array, they
are serialized as byte arrays. The serialized size is then used as the basis for measurement.

#### Configuration for Limiting the Traversed Object Graph
As noted above, sizing caches involves traversing object graphs, a process that can be limited with annotations. This process can also be controlled at both the CacheManager and cache levels.

Note that the following configuration has no effect on distributed caches.

##### Size-Of Limitation at the CacheManager Level
Control how deep the size-of engine can go when sizing on-heap elements by adding the following element at the CacheManager level:

~~~ xml
<sizeOfPolicy maxDepth="100" maxDepthExceededBehavior="abort"/>
~~~

This element has the following attributes

* `maxDepth` &ndash; Controls how many linked objects can be visited before the size-of engine takes any action. This attribute is required.
* `maxDepthExceededBehavior` &ndash; Specifies what happens when the max depth is exceeded while sizing an object graph:
    * "continue" &ndash; DEFAULT Forces the size-of engine to log a warning and continue the sizing operation. If this attribute is not specified, "continue" is the behavior used.
    * "abort" &ndash; Forces the SizeOf engine to abort the sizing, log a warning, and mark the cache as not correctly tracking memory usage. With this setting, `Ehcache.hasAbortedSizeOf()` returns true.

The SizeOf policy can be configured at the cache manager level (directly under `<ehcache>`) and at
the cache level (under `<cache>` or `<defaultCache>`). The cache policy always overrides the cache manager
one if both are set. This element has no effect on distributed caches.


##### Size-Of Limitation at the Cache level
Use the `<sizeOfPolicy>` as a subelement in any `<cache>` block to control how deep the size-of engine can go when sizing on-heap elements belonging to the target cache. This cache-level setting overrides the CacheManager size-of setting.


#### Debugging of Size-Of Related Errors

If warnings or errors appear that seem related to size-of measurement (usually caused by the size-of engine walking the graph), generate more log information on sizing activities:

* Set the `net.sf.ehcache.sizeof.verboseDebugLogging` system property to true.
* Enable debug logs on `net.sf.ehcache.pool.sizeof` in your chosen implementation of SLF4J.


### Eviction When Using CacheManager-Level Storage

When a CacheManager-level storage pool is exhausted, a cache is selected on which to perform eviction to recover pool space. The eviction from
 the selected cache is performed using the cache's configured eviction algorithm (LRU, LFU, etc...).
 The cache from which eviction is performed is selected using the "minimal eviction cost" algorithm described below:

<pre>
 eviction-cost = mean-entry-size * drop-in-hit-rate
</pre>

 Eviction cost is defined as the increase in bytes requested from the underlying SOR (the database for example) per unit time used
 by evicting the requested number of bytes from the cache.

If we model the hit distribution as a simple power-law then:

<pre>
 P(hit n'th element) ~ 1/n^{alpha"/>
</pre>

 In the continuous limit this means the total hit rate is proportional to the integral of this distribution function over the elements in
 the cache. The change in hit rate due to an eviction is then the integral of this distribution function between the initial size and
 the final size.  Assuming that the eviction size is small compared to the overall cache size we can model this as:

<pre>
 drop ~ access * 1/x^{alpha} * Delta(x)
</pre>

 Where 'access' is the overall access rate (hits + misses) and x is a unit-less measure of the 'fill level' of the cache.  Approximating the fill level as the
 ratio of hit rate to access rate, and substituting in to the eviction-cost expression we get:

<pre>
 eviction-cost = mean-entry-size * access * 1/(hits/access)^{alpha} * (eviction / (byteSize / (hits/access)))
</pre>

 Simplifying:

<pre>
 eviction-cost = (byteSize / countSize) * access * 1/(h/A)^{alpha} * (eviction * hits)/(access * byteSize)
 eviction-cost = (eviction * hits) / (countSize * (hits/access)^{alpha})
</pre>

 Removing the common factor of 'eviction' which is the same in all caches lead us to evicting from the cache with the minimum value of:

<pre>
 eviction-cost = (hits / countSize) / (hits/access)^{alpha"/>
</pre>

 When a cache has a zero hit-rate (it is in a pure loading phase) we deviate from this algorithm and allow the cache to occupy 1/n'th of the pool space where 'n' is the number of caches using the pool.  Once the cache starts to be accessed we re-adjust to match the actual usage pattern of that cache.
