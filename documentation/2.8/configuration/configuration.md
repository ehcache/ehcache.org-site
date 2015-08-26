---
---
# Cache Configuration


 

## Introduction
Caches can be configured in Ehcache either declaratively in XML, or by creating caches programmatically and specifying their parameters in the constructor.

While both approaches are fully supported, it is generally a good idea to separate the cache configuration from runtime use. There are also these benefits:

* It is easy if you have all of your configuration in one place.

    Caches consume memory, and disk space. They need to be carefully tuned. You can see the total effect in a configuration file. You could do this all in code, but it would not as visible.

* Cache configuration can be changed at deployment time.
* Configuration errors can be checked for at start-up, rather than causing a runtime error.
* A defaultCache configuration exists and will always be loaded.

    While a defaultCache configuration is not required, an error is generated if caches are created by name (programmatically) with no defaultCache loaded. 

The Ehcache documentation focuses on XML declarative configuration. Programmatic configuration is explored in certain examples and is documented in [Javadocs](http://ehcache.org/apidocs/2.8.4/).

Ehcache is redistributed by many projects, some of which might not provide an up-to-date sample Ehcache XML configuration file. If so, [download Ehcache](http://ehcache.org/downloads). The latest ehcache.xml and ehcache.xsd are provided in the distribution.

## Dynamically Changing Cache Configuration

After a Cache has been started, its configuration is not generally changeable. However, since Ehcache 2.0, certain cache configuration parameters can be modified dynamically at runtime. In the current version of Ehcache, this includes the following:

* timeToLive

    The maximum number of seconds an element can exist in the cache regardless of use. The element expires at this limit and will no longer be returned from the cache. The default value is 0, which means no timeToLive (TTL) eviction takes place (infinite lifetime).

* timeToIdle

    The maximum number of seconds an element can exist in the cache without being accessed. The element expires at this limit and will no longer be returned from the cache. The default value is 0, which means no timeToIdle (TTI) eviction takes place (infinite lifetime).

* Local sizing attributes maxEntriesLocalHeap, maxBytesLocalHeap, maxEntriesLocalDisk, maxBytesLocalDisk.
* CacheEventListeners can be added and removed dynamically

Note that the `eternal` attribute, when set to "true", overrides `timeToLive` and `timeToIdle` so that no expiration can take place.
This example shows how to dynamically modify the cache configuration of a running cache:

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


## Memory-Based Cache Sizing (Ehcache 2.5 and higher)

Initially, Ehcache only permitted sizing of caches in the Java heap (the OnHeap store) and the disk (DiskStore). [BigMemory](http://terracotta.org/products) introduced the OffHeap store, where sizing of caches is also allowed.

To learn more about sizing caches, see [How to Size Caches](/documentation/2.8/configuration/cache-size).


### Pinning of Caches and Elements in Memory (2.5 and higher)
Pinning of caches or specific elements is discussed in [Pinning, Expiration, and Eviction](/documentation/2.8/configuration/data-life).


## Cache Warming for multi-tier Caches 
**(Ehcache 2.5 and higher)**

When a cache starts up, the stores are always empty. Ehcache provides a BootstrapCacheLoader mechanism to overcome this. The BootstrapCacheLoader is run before the cache is set to alive. If synchronous, loading completes before the CacheManager starts, or if asynchronous, the CacheManager starts but loading continues aggressively rather than waiting for elements to be requested, which is a lazy loading approach.

Replicated caches provide a bootstrap mechanism that populates them. For example, the following is the JGroups bootstrap cache loader:

    <bootstrapCacheLoaderFactory class="net.sf.ehcache.distribution.jgroups.JGroupsBootstrapCacheLoaderFactory" properties="bootstrapAsynchronously=true"/>


## copyOnRead and copyOnWrite cache configuration

A cache can be configured to copy the data, rather than return reference to it on get or put. This is configured using the
`copyOnRead` and `copyOnWrite` attributes of cache and defaultCache elements in your configuration or programmatically as follows:

    CacheConfiguration config = new CacheConfiguration("copyCache", 1000).copyOnRead(true).copyOnWrite(true);
    Cache copyCache = new Cache(config);

The default configuration is false for both options.

To copy elements on put()-like and/or get()-like operations, a CopyStrategy is used. The default implementation uses serialization to copy elements. You can provide your own implementation of `net.sf.ehcache.store.compound.CopyStrategy` like
this:

    <cache name="copyCache"
        maxEntriesLocalHeap="10"
        eternal="false"
        timeToIdleSeconds="5"
        timeToLiveSeconds="10"
        copyOnRead="true"
        copyOnWrite="true">
      <persistence strategy="none"/>
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
Ehcache configuration files must comply with the Ehcache XML schema, `ehcache.xsd`, which can be downloaded from [http://ehcache.org/ehcache.xsd](http://ehcache.org/ehcache.xsd).

Note that some elements documented by the Ehcache XML schema pertain only to [BigMemory](http://terracotta.org/products) and are not valid for the open-source version of Ehcache.

## ehcache-failsafe.xml
If the CacheManager default constructor or factory method is called, Ehcache looks for a
  file called `ehcache.xml` in the top level of the classpath. If Ehcache does not find that file, Ehcache looks for
  `ehcache-failsafe.xml` in the classpath. `ehcache-failsafe.xml` is packaged in the Ehcache JAR and is always be found.

`ehcache-failsafe.xml` provides an extremely simple default configuration to enable users to
get started before they create their own `ehcache.xml`.

If the default configuration is used, Ehcache will emit a warning to remind the user to set up a proper configuration.
The meaning of the elements and attributes are explained in the section on `ehcache.xml`.

    <ehcache>
      <diskStore path="java.io.tmpdir"/>
      <defaultCache
         maxEntriesLocalHeap="10000"
         eternal="false"
         timeToIdleSeconds="120"
         timeToLiveSeconds="120"
         maxEntriesLocalDisk="10000000"
         diskExpiryThreadIntervalSeconds="120"
         memoryStoreEvictionPolicy="LRU"
         <persistence strategy="localTempSwap"/>
      />
    </ehcache>

## Update Checker

The update checker is used to see if you have the latest version of Ehcache. It is also used
to get non-identifying feedback on the operating system architectures using Ehcache.
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
  Starting with ehcache-1.6, UTF8 is supported, so that configuration can use Unicode. Because UTF8 is
  backwardly compatible with ASCII, no conversion is necessary.

If the CacheManager default constructor or factory method is called, Ehcache looks for a
  file called ehcache.xml in the top level of the classpath.

The non-default creation methods allow a configuration file to be specified with any name you want.

One XML configuration is required for each CacheManager that is created. It is an error to
use the same configuration for multiple CacheManagers, because settings such as directory paths and listener ports will
conflict. Ehcache will attempt to resolve conflicts and will emit a warning reminding the
user to configure a separate configuration for multiple CacheManagers with conflicting
settings.

The sample `ehcache.xml` is included in the Ehcache distribution and can also be downloaded from [http://ehcache.org/ehcache.xml](http://ehcache.org/ehcache.xml). It contains comments to help you configure each element.

Note that some elements documented in the sample Ehcache XML file pertain only to [BigMemory](http://terracotta.org/products) and are not valid for the open-source version of Ehcache.


