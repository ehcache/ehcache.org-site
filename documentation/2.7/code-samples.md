---
---
# Code Samples


 


## Introduction
The Code Samples page contains examples that will help you get started with Ehcache.

If you have suggestions or ideas for more code samples, please tell us about them using the [forums](https://groups.google.com/forum/#!forum/ehcache-users).


## Using the CacheManager <a name="Using-the-CacheManager"/>
All usages of Ehcache start with the creation of a CacheManager. See [Key Classes and Methods](/documentation/2.7/get-started/key-classes-methods#cm-creation) for details on how to create CacheManagers.

### Singleton versus Instance

Create a singleton CacheManager using defaults, then list caches.

<pre>
CacheManager.create();
String[] cacheNames = CacheManager.getInstance().getCacheNames();
</pre>

Create a CacheManager instance using defaults, then list caches.

<pre>
CacheManager.newInstance();
String[] cacheNames = manager.getCacheNames();
</pre>

Create two CacheManagers, each with a different configuration, and list the caches in each.

<pre>
CacheManager manager1 = CacheManager.newInstance("src/config/ehcache1.xml");
CacheManager manager2 = CacheManager.newInstance("src/config/ehcache2.xml");
String[] cacheNamesForManager1 = manager1.getCacheNames();
String[] cacheNamesForManager2 = manager2.getCacheNames();
</pre>

## Ways of loading Cache Configuration
When the CacheManager is created it creates caches found in the configuration.
Create a CacheManager using defaults. Ehcache will look for ehcache.xml in the classpath.

<pre>
CacheManager manager = CacheManager.newInstance();
</pre>

 Create a CacheManager specifying the path of a configuration file.

<pre>
CacheManager manager = CacheManager.newInstance("src/config/ehcache.xml");
</pre>

Create a CacheManager from a configuration resource in the classpath.

<pre>
URL url = getClass().getResource("/anotherconfigurationname.xml");
CacheManager manager = CacheManager.newInstance(url);
</pre>

Create a CacheManager from a configuration in an InputStream.

<pre>
InputStream fis = new FileInputStream(new File("src/config/ehcache.xml").getAbsolutePath());
try {
  CacheManager manager = CacheManager.newInstance(fis);
} finally {
  fis.close();
"/>
</pre>

## Adding and Removing Caches Programmatically
You are not just stuck with the caches that were placed in the configuration. You can create and remove them
programmatically.
Add a cache using defaults, then use it. The following example creates a cache called &lt;testCache>, which will be configured
using defaultCache from the configuration.

<pre>
CacheManager singletonManager = CacheManager.create();
singletonManager.addCache("testCache");
Cache test = singletonManager.getCache("testCache");
</pre>

Create a Cache and add it to the CacheManager, then use it.
Note that Caches are not usable until they have been added to a CacheManager.

<pre>
CacheManager singletonManager = CacheManager.create();
Cache memoryOnlyCache = new Cache("testCache", 5000, false, false, 5, 2);
singletonManager.addCache(memoryOnlyCache);
Cache test = singletonManager.getCache("testCache");
</pre>

See the cache [constructor](http://ehcache.org/xref/net/sf/ehcache/Cache.html) for the full parameters  for a new Cache.

Remove cache called sampleCache1:

<pre>
CacheManager singletonManager = CacheManager.create();
singletonManager.removeCache("sampleCache1");
</pre>

## Shutdown the CacheManager
Ehcache should be shutdown after use. It does have a shutdown hook, but it is best practice to shut it down
in your code.

Shutdown the singleton CacheManager:

<pre>
CacheManager.getInstance().shutdown();
</pre>

Shutdown a CacheManager instance, assuming you have a reference to the CacheManager called &lt;manager>:

<pre>
manager.shutdown();
</pre>

See the [CacheManagerTest](http://ehcache.org/xref-test/net/sf/ehcache/CacheManagerTest.html) for more examples.

## Creating Caches Programmatically

### Creating a new cache from defaults
A new cache with a given name can be created from defaults very simply:

<pre>
manager.addCache(cacheName);
</pre>

### Creating a new cache with custom parameters
The configuration for a Cache can be specified programmatically as an argument to the Cache constructor:

<pre>
public Cache(CacheConfiguration cacheConfiguration) {
  ...
"/>
</pre>

Here is an example which creates a cache called "testCache."

<pre>
//Create a singleton CacheManager using defaults
CacheManager manager = CacheManager.create();

//Create a Cache specifying its configuration.
Cache testCache = new Cache(
  new CacheConfiguration("testCache", maxEntriesLocalHeap)
    .memoryStoreEvictionPolicy(MemoryStoreEvictionPolicy.LFU)
    .eternal(false)
    .timeToLiveSeconds(60)
    .timeToIdleSeconds(30)
    .diskExpiryThreadIntervalSeconds(0)
    .persistence(new PersistenceConfiguration().strategy(Strategy.LOCALTEMPSWAP)));
  manager.addCache(testCache);
</pre>

Once the cache is created, add it to the list of caches managed by the CacheManager:

<pre>
manager.addCache(testCache);
</pre>

The cache is not usable until it has been added.

## Using Caches
 All of these examples refer to &lt;manager>, which is a reference to a CacheManager, which has a cache in it
 called &lt;sampleCache1>.

### Obtaining a reference to a Cache <a name="Obtaining a reference to a Cache"/>
Obtain a Cache called "sampleCache1", which has been preconfigured in the configuration file

<pre>
Cache cache = manager.getCache("sampleCache1");
</pre>

### Performing CRUD operations
Put an element into a cache

<pre>
Cache cache = manager.getCache("sampleCache1");
Element element = new Element("key1", "value1");
cache.put(element);
</pre>

Update an element in a cache. Even though `cache.put()` is used, Ehcache knows there is an existing element, and considers
the put an update for the purpose of notifying cache listeners.

<pre>
Cache cache = manager.getCache("sampleCache1");
cache.put(new Element("key1", "value1"));
//This updates the entry for "key1"
cache.put(new Element("key1", "value2"));
</pre>

Get a Serializable value from an element in a cache with a key of "key1".

<pre>
Cache cache = manager.getCache("sampleCache1");
Element element = cache.get("key1");
Serializable value = element.getValue();
</pre>

Get a NonSerializable value from an element in a cache with a key of "key1".

<pre>
Cache cache = manager.getCache("sampleCache1");
Element element = cache.get("key1");
Object value = element.getObjectValue();
</pre>

Remove an element from a cache with a key of "key1".

<pre>
Cache cache = manager.getCache("sampleCache1");
cache.remove("key1");
</pre>

### Obtaining Cache Sizes
Get the number of elements currently in the `Cache`.

<pre>
Cache cache = manager.getCache("sampleCache1");
int elementsInMemory = cache.getSize();
</pre>

Get the number of elements currently in the `MemoryStore`.

<pre>
Cache cache = manager.getCache("sampleCache1");
long elementsInMemory = cache.getMemoryStoreSize();
</pre>

Get the number of elements currently in the `DiskStore`.

<pre>
Cache cache = manager.getCache("sampleCache1");
long elementsInMemory = cache.getDiskStoreSize();
</pre>

### Obtaining Statistics of Cache Hits and Misses
These methods are useful for tuning cache configurations.
Get the number of times requested items were found in the cache (cache hits).

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getHitCount();
</pre>

 Get the number of times requested items were found in the `MemoryStore` of the cache.

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getMemoryStoreHitCount();
</pre>

 Get the number of times requested items were found in the `DiskStore` of the cache.

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getDiskStoreCount();
</pre>

Get the number of times requested items were not found in the cache (cache misses).

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getMissCountNotFound();
</pre>

Get the number of times requested items were not found in the cache due to expiry of the elements.

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getMissCountExpired();
</pre>

These are just the most commonly used methods. See [CacheTest](http://ehcache.org/xref-test/net/sf/ehcache/CacheTest.html) for more examples.
See [Cache](http://ehcache.org/xref/net/sf/ehcache/Cache.html) for the full API.

### Dynamically Modifying Cache Configurations
This example shows how to dynamically modify the cache configuration of an already running cache:

<pre>
Cache cache = manager.getCache("sampleCache");
CacheConfiguration config = cache.getCacheConfiguration();
config.setTimeToIdleSeconds(60);
config.setTimeToLiveSeconds(120);
config.setMaxEntriesLocalHeap(10000);
config.setMaxEntriesLocalDisk(1000000);
</pre>

Dynamic cache configurations can also be frozen to prevent future changes:

<pre>
Cache cache = manager.getCache("sampleCache");
cache.disableDynamicFeatures();
</pre>

### Transactions
A cache will automatically participate in the ongoing UserTransaction when configured in [transactionalMode XA](/documentation/2.7/apis/transactions).

Note that XA Transactional caches are supported only for local Ehcache, [BigMemory Go](http://terracotta.org/documentation/bigmemorygo/api/jta), and  [BigMemory Max](http://terracotta.org/documentation/bigmemorymax/api/jta). Replication architectures such as RMI, JMS, or JGroups are not supported, as there is no locking in those architectures.


## Cache Statistics and Monitoring

### Registering CacheStatistics in an MBeanServer
This example shows how to register CacheStatistics in the JDK platform MBeanServer, which
works with the JConsole management agent.

<pre>
CacheManager manager = CacheManager.newInstance();
MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
ManagementService.registerMBeans(manager, mBeanServer, false, false, false, true);
</pre>

## More examples

### JCache Examples
See the examples in [JCache](/documentation/2.7/integrations/jsr107).

### Cache Server Examples
See the examples in [Cache Server](/documentation/2.7/modules/cache-server).

### Browse the JUnit Tests
Ehcache comes with a comprehensive JUnit test suite, which not only tests the code, but shows you how to use ehcache.
A link to [browsable unit test source code](http://ehcache.org/xref-test/index.html) for the major Ehcache classes is given per section. The unit tests are also
  in the src.zip in the Ehcache tarball.
