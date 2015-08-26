---
---
#Recipes and Code Samples

The Recipes and Code Samples page contains recipes - short concise examples for specific use cases - and a set of code samples that will help you get started with Ehcache.

If you have a suggestion or an idea for a recipe or more code samples, please tell us about it using the [forums](http://forums.terracotta.org/forums/forums/show/16.page) or [mailing list](http://lists.terracotta.org/mailman/listinfo/ehcache-list).

## Recipes

| Recipe | Description |
|:-------|:------------|
|[Web Page and Fragment Caching](/documentation/recipes/pagecaching)|How to use inluded Servlet Filters to Cache Web Page and Web Page Fragments|
|[Configure a Grails App for Clustering](/documentation/recipes/grails)|How to configure a Grails Application for clustered Hibernate 2nd Level Cache|
|[Data Freshness and Expiration](/documentation/recipes/expiration)|How to maintain cache "freshness" by configuring TTL and data expiration properly|
|[Enable Terracotta Programmatically](/documentation/recipes/programmatic)|How to enable Terracotta support for Ehcache programmatically|
|[WAN Replication](/documentation/recipes/wan)|3 Strategies for configuring WAN replication|
|[Caching Empty Values](/documentation/recipes/cachenull)|Why caching empty values can be desirable to deflect load from the database|
|[Database Read Overload](/documentation/recipes/thunderingherd)|When many readers simultaneously request the same data element it is called the "Thundering Herd" problem.  How to prevent it in a single jvm or clustered configuration|
|[Database Write Overload](/documentation/recipes/writebehind)|Writing to the Database is a Bottleneck. Configure write-behind to offload database writes.|
|[Caching methods with Spring Annotations](/documentation/recipes/spring-annotations)|Adding caching to methods using Ehcache Annotations for Spring project|
|[Cache Wrapper](/documentation/recipes/wrapper)|A simple class to make accessing Ehcache easier for simple use cases|


<br>
## Code Samples

### Using the CacheManager <a name="Using-the-CacheManager"/>
All usages of Ehcache start with the creation of a CacheManager.

#### Singleton versus Instance
As of ehcache-1.2, Ehcache CacheManagers can be created as either singletons (use the create factory method) or instances (use new).
Create a singleton CacheManager using defaults, then list caches.

<pre>
CacheManager.create();
String[] cacheNames = CacheManager.getInstance().getCacheNames();
</pre>

Create a CacheManager instance using defaults, then list caches.

<pre>
CacheManager manager = new CacheManager();
String[] cacheNames = manager.getCacheNames();
</pre>

Create two CacheManagers, each with a different configuration, and list the caches in each.

<pre>
CacheManager manager1 = new CacheManager("src/config/ehcache1.xml");
CacheManager manager2 = new CacheManager("src/config/ehcache2.xml");
String[] cacheNamesForManager1 = manager1.getCacheNames();
String[] cacheNamesForManager2 = manager2.getCacheNames();
</pre>

### Ways of loading Cache Configuration
When the CacheManager is created it creates caches found in the configuration.
Create a CacheManager using defaults. Ehcache will look for ehcache.xml in the classpath.

<pre>
CacheManager manager = new CacheManager();
</pre>

 Create a CacheManager specifying the path of a configuration file.

<pre>
CacheManager manager = new CacheManager("src/config/ehcache.xml");
</pre>

Create a CacheManager from a configuration resource in the classpath.

<pre>
URL url = getClass().getResource("/anotherconfigurationname.xml");
CacheManager manager = new CacheManager(url);
</pre>

Create a CacheManager from a configuration in an InputStream.

<pre>
InputStream fis = new FileInputStream(new File("src/config/ehcache.xml").getAbsolutePath());
try {
  CacheManager manager = new CacheManager(fis);
} finally {
  fis.close();
"/>
</pre>

### Adding and Removing Caches Programmatically
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
manager.addCache(memoryOnlyCache);
Cache test = singletonManager.getCache("testCache");
</pre>

See the cache [constructor](/xref/net/sf/ehcache/Cache.html) for the full parameters  for a new Cache:
Remove cache called sampleCache1

<pre>
CacheManager singletonManager = CacheManager.create();
singletonManager.removeCache("sampleCache1");
</pre>

### Shutdown the CacheManager
Ehcache should be shutdown after use. It does have a shutdown hook, but it is best practice to shut it down
in your code.
Shutdown the singleton CacheManager

<pre>
CacheManager.getInstance().shutdown();
</pre>

Shutdown a CacheManager instance, assuming you have a reference to the CacheManager called &lt;manager>
<pre>
manager.shutdown();
</pre>

See the [CacheManagerTest](/xref-test/net/sf/ehcache/CacheManagerTest.html) for more examples.

## Creating Caches Programmatically

### Creating a new cache from defaults
A new cache with a given name can be created from defaults very simply:

<pre>
manager.addCache(cache name);
</pre>

### Creating a new cache with custom parameters
The configuration for a Cache can be specified programmatically as an argument to the Cache constructor:

<pre>
public Cache(CacheConfiguration cacheConfiguration) {
  ...
"/>
</pre>

Here is an example which creates a cache called test.

<pre>
//Create a CacheManager using defaults
CacheManager manager = CacheManager.create();

//Create a Cache specifying its configuration.
Cache testCache = new Cache(
  new CacheConfiguration("test", maxElements)
    .memoryStoreEvictionPolicy(MemoryStoreEvictionPolicy.LFU)
    .overflowToDisk(true)
    .eternal(false)
    .timeToLiveSeconds(60)
    .timeToIdleSeconds(30)
    .diskPersistent(false)
    .diskExpiryThreadIntervalSeconds(0));
  manager.addCache(cache);
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

### Disk Persistence on demand
<sampleCache1> has a persistent diskStore. We wish to ensure that the data and index are written immediately.

<pre>
Cache cache = manager.getCache("sampleCache1");
cache.flush();
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
Get the number of times requested items were found in the cache. i.e. cache hits

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

Get the number of times requested items were not found in the cache. i.e. cache misses.

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getMissCountNotFound();
</pre>

Get the number of times requested items were not found in the cache due to expiry of the elements.

<pre>
Cache cache = manager.getCache("sampleCache1");
int hits = cache.getMissCountExpired();
</pre>

These are just the most commonly used methods. See [CacheTest](/xref-test/net/sf/ehcache/CacheTest.html) for more examples.
See [Cache](/xref/net/sf/ehcache/Cache.html) for the full API.

### Dynamically Modifying Cache Configurations
This example shows how to dynamically modify the cache configuration of an already running cache:

<pre>
Cache cache = manager.getCache("sampleCache");
CacheConfiguration config = cache.getCacheConfiguration();
config.setTimeToIdleSeconds(60);
config.setTimeToLiveSeconds(120);
config.setMaxElementsInMemory(10000);
config.setMaxElementsOnDisk(1000000);
</pre>

Dynamic cache configurations can also be frozen to prevent future changes:

<pre>
Cache cache = manager.getCache("sampleCache");
cache.disableDynamicFeatures();
</pre>

### JTA
A cache will automatically participate in the ongoing UserTransaction when configured in transactionalMode XA.
This can be done programmatically:

<pre>
//Create a CacheManager using defaults
CacheManager manager = CacheManager.create();
//Create a Cache specifying its configuration.
Cache xaCache = new Cache(
       new CacheConfiguration("test", 1000)
           .overflowToDisk(true)
           .eternal(false)
           .transactionalMode(CacheConfiguration.TransactionalMode.XA)
           .terracotta(new TerracottaConfiguration().clustered(true)));
manager.addCache(xaCache);
</pre>

Or in your CacheManager's configuration file :

<pre>
&lt;cache name="xaCache"
   maxElementsInMemory="500"
   eternal="false"
   timeToIdleSeconds="300"
   timeToLiveSeconds="600"
   overflowToDisk="false"
   diskPersistent="false"
   diskExpiryThreadIntervalSeconds="1"
   transactionalMode="xa"&gt;
 &lt;terracotta clustered="true"/&gt;
&lt;/cache&gt;
</pre>

Please note that XA Transactional caches are supported only for local Ehcache or when distributed with Terracotta.
Replicated Ehcache architectures such as RMI|JMS|JGroups are not supported as there is no locking in those architectures.
The Cache can then be used without any special requirement. Changes will only become visible to others, once the transaction
has been committed.

<pre>
Ehcache cache = cacheManager.getEhcache("xaCache");
transactionManager.begin();
try {
    Element e = cache.get(key);
    Object result = complexService.doStuff(element.getValue());
    // This put will be rolled back should complexService.doMoreStuff throw an Exception
    cache.put(new Element(key, result));
    // Any changes to result in that call, will be visible to others when the Transaction commits
    complexService.doMoreStuff(result);
    transactionManager.commit();
} catch (Exception e) {
    transactionManager.rollback();
"/>
</pre>

## Using Distributed Caches

### Terracotta Example
See the fully worked examples in [Terracotta Clustering](./terracotta/code-samples).

## Cache Statistics and Monitoring

### Registering CacheStatistics in an MBeanServer
This example shows how to register CacheStatistics in the JDK1.5 platform MBeanServer, which
works with the JConsole management agent.

<pre>
CacheManager manager = new CacheManager();
MBeanServer mBeanServer = ManagementFactory.getPlatformMBeanServer();
ManagementService.registerMBeans(manager, mBeanServer, false, false, false, true);
</pre>

## More examples

### JCache Examples
See the examples in [JCache](./jsr107.html).

### Cache Server Examples
See the examples in [Cache Server](./cache_server.html).

### Browse the JUnit Tests
Ehcache comes with a comprehensive JUnit test suite, which not only tests the code, but shows you how to use ehcache.
A link to [browsable unit test source code](/xref-test/index.html) for the major Ehcache classes is given per section. The unit tests are also
  in the src.zip in the Ehcache tarball.
