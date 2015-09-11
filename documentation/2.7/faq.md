---
---
# Ehcache Technical FAQ

The Ehcache Technical FAQ answers frequently asked questions on how to use Ehcache, integration with other products, and solving issues. Other resources for resolving issues include:

* [Release Notes](http://www.terracotta.org/confluence/display/release/Home) &ndash; Lists features and issues for specific versions of Ehcache and other Terracotta products.
* [Compatibility Information](http://www.terracotta.org/confluence/display/release/Home) &ndash; Includes tables on compatible versions of Ehcache and other Terracotta products, JVMs, and application servers.
* [General Information](http://www.ehcache.org/about) &ndash; For feature descriptions and news about Ehcache.
* [Ehcache Forums](https://groups.google.com/forum/#!forum/ehcache-users) &ndash; If your question doesn't appear below, consider posting it on the Ehcache Forum.

This FAQ is organized into the following sections:





## CONFIGURATION



### General Ehcache

#### Where is the source code?
 The source code is distributed in the root directory of the download.
It is also available through [SVN](http://svn.terracotta.org/svn/ehcache/).

#### Can you use more than one instance of Ehcache in a single VM?

 As of Ehcache 1.2, yes. Create your CacheManager using new
CacheManager(...) and keep hold of the reference. The singleton
approach, accessible with the getInstance(...) method, is still available
too. Remember that Ehcache can support hundreds of
caches within one CacheManager. You would use separate CacheManagers
where you want different configurations.
 The Hibernate EhCacheProvider has also been updated to support this behavior.

#### What elements are mandatory in ehcache.xml?
 The documentation has been updated with comprehensive coverage of the
schema for Ehcache and all elements and attributes, including whether
they are mandatory. See the [Configuration](/documentation/2.7/configuration/configuration) page.

#### How is auto-versioning of elements handled?
Automatic element versioning works only with unclustered MemoryStore caches. Distributed caches or caches that use off-heap or disk stores cannot use auto-versioning.

To enable auto-versioning, set the system property `net.sf.ehcache.element.version.auto` to true (it is false by default). Manual (user provided) versioning of cache elements is ignored when auto-versioning is in effect. Note that if this property is turned on for one of the ineligible caches, auto-versioning will silently fail.

#### How do I get a memory-only cache to persist to disk between VM restarts?
The Ehcache Fast Restart feature provides the option to store a fully consistent copy of the in-memory data on the local disk at all times. After any kind of shutdown — planned or unplanned — the next time your application starts up, all of the data that was in memory is still available and very quickly accessible. To configure your cache for disk persistence, use the "localRestartable" persistence strategy. For more information, refer to [Persistence and Restartability](/documentation/2.7/configuration/fast-restart).


### Replicated Caching

#### What is the minimum configuration to get replicated caching going?
 The minimum configuration you need to get replicated caching going is:

    <cacheManagerPeerProviderFactory
       class="net.sf.ehcache.distribution.RMICacheManagerPeerProviderFactory"
       properties="peerDiscovery=automatic,
                   multicastGroupAddress=230.0.0.1,
                   multicastGroupPort=4446"/>
    <cacheManagerPeerListenerFactory
       class="net.sf.ehcache.distribution.RMICacheManagerPeerListenerFactory"/>

and then at least one cache declaration with

    <cacheEventListenerFactory
       class="net.sf.ehcache.distribution.RMICacheReplicatorFactory"/`>

in it. An example cache is:

    <cache name="sampleDistributedCache1"
          maxEntriesLocalHeap="10"
          eternal="false"
          timeToIdleSeconds="100"
          timeToLiveSeconds="100">
       <cacheEventListenerFactory
          class="net.sf.ehcache.distribution.RMICacheReplicatorFactory"/>
    </cache>

Each peer server can have the same configuration.

#### How do I add a CacheReplicator to a cache that already exists?

The cache event listening works but it does not get plumbed into the peering mechanism. The current API does not have a CacheManager event for cache configuration change. You can however make it work
by calling the notifyCacheAdded event.

    getCache().getCacheManager().getCacheManagerEventListenerRegistry().notifyCacheAdded("cacheName");


### Distributed Caching

#### What stores are available and how are they configured?
The Terracotta server provides an additional store, generally referred to as the Level 2 or L2 store.
The JVM MemoryStore and OffHeapStore in the local node is referred to as the L1 store.
`maxBytesLocalHeap` and `maxBytesLocalOffHeap` comprise the maximum size of the local L1 store.
`maxBytesLocalDisk` is overridden when using Terracotta to provide the L2 size. The L2 size is effectively the maximum cache size.
'localTempSwap' configures overflow to the local DiskStore. When using Terracotta, the local DiskStore
is not used, and the cache should be configured for 'distributed' persistence strategy. When the a cache configured for 'distributed' persistence strategy gets full, it overflows to the Terracotta L2 store running on the server. The L2
can be further configured with the `tc-config.xml`.

#### What is the recommended way to write to a database?
There are two patterns available: write-through and write-behind caching. In write-through caching, writes to the cache cause writes to an underlying resource. The cache acts as a facade to the underlying resource. With this pattern, it often makes sense to read through the cache too. Write-behind caching uses the same client API; however, the write happens asynchronously.

While file systems or a web-service clients can underlie the facade of a write-through cache, the most common underlying resource is a database.


#### How do I make the Terracotta URL available in different environments using different Terracotta servers?

You can externalize the value of the `terracottaConfig url` from the ehcache.xml file by using a system property for the `url` attribute. Add this in your ehcache.xml config file:

    <terracottaConfig url="${my.terracotta.server.url}"/>

and define my.terracotta.server.url as a system property.

#### What classloader is used to deserialize clustered objects in valueMode="serialization"?
The following classloaders are tried in this order:

* Thread.currentThread().getContextClassLoader() (so set this to override)
* The classloader used to define the Ehcache CacheManager - the one that loaded the ehcache-terracotta.jar

#### What happened to coherent=true|false in ehcache.xml?
It has been deprecated. Use the "consistency" attribute instead.
Any configuration files using coherent=true will be mapped to consistency=strong, and coherent=false
will be mapped to consistency=eventual.

#### Should I use the following directive when doing distributed caching?

      <cacheManagerEventListenerFactory class="" properties=""/>

No, it is unrelated. It is for listening to changes in your local CacheManager.




## DEVELOPMENT



### General Ehcache

#### Can I use Ehcache as a memory cache only?
 Yes. Just set the persistence strategy of cache to "none".

#### Can I use Ehcache as a disk cache only?
 As of Ehcache 2.0, this is not possible. You can set the maxEntriesLocalHeap to 1, but
setting the maxSize to 0 now gives an infinite capacity.

#### Is it thread-safe to modify element values after retrieval from a Cache?
 Remember that a value in a cache element is globally accessible from
multiple threads. It is inherently not thread-safe to modify the value.
It is safer to retrieve a value, delete the cache element and then
reinsert the value.
 The [UpdatingCacheEntryFactory](/apidocs/2.7.6/net/sf/ehcache/constructs/blocking/UpdatingCacheEntryFactory.html)
does work by modifying the contents of values in place in the
cache. This is outside of the core of Ehcache and is targeted at
high performance CacheEntryFactories for SelfPopulatingCaches.

#### Can non-Serializable objects be stored in a cache?
 As of Ehcache 1.2, they can be stored in caches with MemoryStores.
 If an attempt is made to replicate or overflow a non-serializable element to disk, the element is removed and a warning is logged.

#### What is the difference between TTL, TTI, and eternal?
 These are three cache attributes that can be used to build an effective eviction configuration. It is advised to test and tune these values to help optimize cache performance. TTI `timeToIdleSeconds` is the maximum number of seconds that an element can exist in the cache without being accessed, while TTL `timeToLiveSeconds` is the maximum number of seconds that an element can exist in the cache whether or not is has been accessed. If the `eternal` flag is set, elements are allowed to exist in the cache eternally and none are evicted. The eternal setting overrides any TTI or TTL settings.
 These attributes are set for the entire cache in the configuration file. If you want to set them per element, you must do it programmatically.
 For more information, see [Setting Expiration](/documentation/2.7/configuration/data-life#24283).

#### If null values are stored in the cache, how can my code tell the difference between "intentional" nulls and non-existent entries?

See this [recipe](/documentation/2.7/recipes/cachenull).

#### What happens when maxEntriesLocalHeap is reached? Are the oldest items expired when new ones come in?
When the maximum number of elements in memory is reached, the Least
Recently Used (LRU) element is removed. "Used" in this case means
inserted with a `put` or accessed with a `get`.
 If the cache is not configured with a persistence strategy, the LRU element is
evicted. If the cache is configured for "localTempSwap", the LRU element is flushed asynchronously to the DiskStore.

#### Why is there an expiry thread for the DiskStore but not for the MemoryStore?
 Because the MemoryStore has a fixed maximum number of
elements, it will have a maximum memory use equal to the number of
elements multiplied by the average size. When an element is added beyond the
maximum size, the LRU element gets pushed into the DiskStore.
 While we could have an expiry thread to expire elements periodically,
it is far more efficient to only check when we need to. The tradeoff is
higher average memory use.
The expiry thread keeps the DiskStore clean. There is hopefully less
contention for the DiskStore's
locks because commonly used values are in the MemoryStore. We mount our
DiskStore on Linux using RAMFS so it is using OS memory. While we have
more of this than the 2GB 32-bit process size limit, it is still an
expensive resource. The DiskStore thread keeps it under control.
 If you are concerned about CPU utilization and locking in the
DiskStore, you can set the diskExpiryThreadIntervalSeconds to a high
number, such as 1 day. Or, you can effectively turn it off by setting the
diskExpiryThreadIntervalSeconds to a very large value.



### Replicated Caching

#### How many threads does Ehcache use, and how much memory does that consume?
The amount of memory consumed per thread is determined by the Stack Size. This is set using -Xss.
The amount varies by OS.  The default is 512KB (for Linux), but 100kb is also recommended.
The threads are created per cache as follows:
* DiskStore expiry thread - if DiskStore is used
* DiskStore spool thread - if DiskStore is used
* Replication thread - if asynchronous replication is configured.
If you are not doing any of the above, no extra threads are created.

#### Why can't I run multiple applications using Ehcache on one machine?
With JDK versions prior to JDK1.5, the number of RMI registries is limited to one per virtual machine, and therefore Ehcache is limited to one CacheManager per virtual machine operating in a replicated cache topology. Because this is the expected deployment configuration, however,
there should be no practical effect. The telltale error is `java.rmi.server.ExportException: internal error: ObjID already in use`
On JDK1.5 and higher, it is possible to have multiple CacheManagers per VM, each participating in the same or different replicated cache topologies.
Indeed the replication tests do this with 5 CacheManagers on the same VM, all run from JUnit.


### Distributed Caching

#### Is expiry the same in distributed Ehcache?
`timeToIdle` and `timeToLive` work as usual. Note however that the `eternal` attribute, when set to "true", overrides `timeToLive` and `timeToIdle` so that no expiration can take place.
Note also that expired elements are *not* necessarily evicted elements, and that evicted elements are *not* necessarily expired elements.
See the [Terracotta documentation](http://www.terracotta.org/documentation/2.7/enterprise-ehcache/reference-guide) for more information on expiration and eviction in a distributed cache.
Ehcache 1.7 introduced a less fine-grained age recording in Element
which rounds up to the nearest second. Some APIs may be sensitive to this change.
In Ehcache, elements can have overridden TTI and TTLs. Terracotta distributed Ehcache supports this functionality.

#### What eviction strategies are supported?
Standalone Ehcache supports LRU, LFU and FIFO eviction strategies, as well as custom evictors. For more information, refer to [Cache Eviction Algorthims](/documentation/2.7/apis/cache-eviction-algorithms).

**Note**: There is no user selection of eviction algorithms with clustered caches. The attribute MemoryStoreEvictionPolicy is ignored (a clock eviction policy is used instead), and if allowed to remain in a clustered cache configuration, the MemoryStoreEvictionPolicy may cause an exception.

#### How does the TSA eviction algorithm work?
The Terracotta Server Array algorithm is optimised for fast server-side performance.
It does not evict as soon as it is full, but periodically checks the size. Based on how much overfull it is (call that *n*) it will, in it's next
eviction pass, evict those *n* elements.
It picks a random sample 30% larger than *n*.
It then works through the sample and:

* skips any elements that are in any L1, on the basis that they have been recently used
* evicts any expired elements
* evicts enough non-expired elements to make *n*.

#### When do elements overflow?
Two things can cause elements to be flushed from L1 to L2.

* When the L1 store exceeds maxEntriesLocalHeap.
* When the local JVM exceeds 70% of Old Generation. This can be turned off in the TC Config. By default it is on (in 1.7).

#### How does element equality work in serialization mode?
An element, key and value in Ehcache is guaranteed to `.equals()` another as it moves between stores.
In the express install or serialization mode of Terracotta, which is the default, Terracotta is the same. Elements will
not `==` each other as they move between stores.

#### How does element equality work in identity mode?
An element in Ehcache is guaranteed to `.equals()` another as it moves between stores.
However in identity mode, Terracotta makes a further guarantee that the key and the value `==`. This is achieved
using extensions to the Java Memory Model.




## ENVIRONMENT AND INTEROPERABILITY



### General Ehcache

#### What version of JDK does Ehcache run with?

JDK 1.6 or higher.

#### Can you use Ehcache with Hibernate and outside of Hibernate at the same time?

 Yes. You use 1 instance of Ehcache and 1 ehcache.xml. You configure your
caches with Hibernate names for use by Hibernate. You can have other
caches which you interact with directly, outside of Hibernate.
 That is how I use Ehcache in the original project where it was developed.
For Hibernate we have about 80 Domain Object caches, 10
StandardQueryCaches, 15 Domain Object Collection caches.
 We have around 5 general caches we interact with directly using
BlockingCacheManager. We have 15 general caches we interact with
directly using SelfPopulatingCacheManager. You can use one of those or
you can just use CacheManager directly.
See the tests for example code on using the caches directly. Look at
CacheManagerTest, CacheTest and SelfPopulatingCacheTest.

#### My Hibernate Query caches entries are replicating, but why are the other caches in the topology not using them?
This is a Hibernate 3 bug. See [http://opensource.atlassian.com/projects/hibernate/browse/HHH-3392](http://opensource.atlassian.com/projects/hibernate/browse/HHH-3392) for tracking. It is fixed in 3.3.0.CR2, which was
released in July 2008.


#### How do I create an OSGi bundle with Ehcache?
See the [OSGi section](http://terracotta.org/documentation/2.7/enterprise-ehcache/reference-guide) for Enterprise Ehcache. If you are not using distributed cache, leave out the `<terracotta>` element shown in the configuration example.


#### Is Ehcache compatible with Google App Engine?
Version 1.6 is compatible. See [Google App Engine Caching](/documentation/2.7/integrations/googleappengine).

#### Why is ActiveMQ retaining temporary destinatons?
ActiveMQ seems to have a bug in at least ActiveMQ 5.1, where it does not cleanup temporary queues, even though they have been
deleted. That bug appears to be long standing but was thought to have been fixed.
See [http://issues.apache.org/activemq/browse/AMQ-1255](http://issues.apache.org/activemq/browse/AMQ-1255).

The JMSCacheLoader uses temporary reply queues when loading. The Active MQ issue is readily reproduced in
Ehcache integration testing. Accordingly, use of the JMSCacheLoader with ActiveMQ is not recommended. Open MQ
tests fine.

#### I am using Tomcat 5, 5.5 or 6 and I am having a problem. What can I do?
Tomcat is such a common deployment option for applications using Ehcache that there is a page on known
issues and recommended practices.
See [Tomcat Issues and Best Practices](/documentation/2.7/integrations/tomcat).

### Replicated Caching

#### With replicated caching on Ubuntu or Debian, why am I see the warning below?

<pre><code>
WARN [Replication Thread] RMIAsynchronousCacheReplicator.flushReplicationQueue(324)
| Unable to send message to remote peer.
Message was: Connection refused to host: 127.0.0.1; nested exception is:
java.net.ConnectException: Connection refused
java.rmi.ConnectException: Connection refused to host: 127.0.0.1; nested exception is:
java.net.ConnectException: Connection refused
</code></pre>

This is caused by a 2008 change to the Ubuntu/Debian Linux default network configuration.
Essentially, the Java call `InetAddress.getLocalHost();` always returns the loopback address, which
is 127.0.0.1. Why? Because in these recent distros, a system call of `$ hostname` always returns an address
mapped onto the loopback device, and this causes Ehcache's RMI peer creation logic to always assign the loopback address, which causes the error you are seeing.
All you need to do is crack open the network config and make sure that the hostname of the machine returns a valid network address accessible by other peers on the network.

#### Can my app server use JMS for replication?
Some app servers do not permit the creation of message listeners. This issue has been reported on Websphere 5.
Websphere 4 did allow it. Tomcat allows it. Glassfish Allows it. Jetty allows it.
Usually there is a way to turn off strict support for EJB checks in your app server. See your vendor documentation.

### Distributed Caching

#### Why is JRockit slow?
JRockit has an has a bug where it reports the younggen size instead of the old to our CacheManager so we over-aggressively
flush to L2 when using percentage of max heap based config. As a workaround, set maxEntriesLocalHeap instead.

#### What versions of Ehcache and Terracotta work together?
For the latest compatibility information, see [Release Information](http://www.terracotta.org/confluence/display/release/Home).

#### Do CacheEventListeners work?
A local CacheEventListener will work locally, but other nodes in a Terracotta cluster are not notified unless the
TerracottaCacheEventReplicationFactory event listener is registered for the cache.




## OPERATIONS



### General Ehcache

#### How do you get an element without affecting statistics?
 Use the [Cache.getQuiet()](/apidocs/2.7.6/net/sf/ehcache/Cache.html#getQuiet%28java.io.Serializable%29) method. It returns an element without updating statistics.

#### Is there a simple way to disable Ehcache when testing?
Set the system property `net.sf.ehcache.disabled=true` to disable Ehcache. This can easily be done using `-Dnet.sf.ehcache.disabled=true` in the command line. If Ehcache is disabled, no elements will be added to a cache.

#### How do I dynamically change cache attributes at runtime?
This is not possible. However, you can achieve the same result as follows:

1. Create a new cache:

        Cache cache = new Cache("test2", 1, true, true, 0, 0, true, 120, ...);
        cacheManager.addCache(cache);

    See the JavaDoc for the full parameters.

2. Get a list of keys using `cache.getKeys`, then get each element and put it in the new cache.

    None of this will use much memory because the new cache elements have values that reference the same data as the original cache.

3. Use `cacheManager.removeCache("oldcachename")` to remove the original cache.

#### Do you need to call CacheManager.getInstance().shutdown() when you finish with Ehcache?
 Yes, it is recommended. If the JVM keeps running after you stop using
Ehcache, you should call CacheManager.getInstance().shutdown() so that
the threads are stopped and cache memory is released back to the JVM. However, if the CacheManager does not get shut down, it should not be a problem.
There is a shutdown hook which calls the shutdown on JVM exit. This is
explained in the documentation [here](/documentation/2.7/operations/shutdown).

#### Can you use Ehcache after a CacheManager.shutdown()?
 Yes. When you call CacheManager.shutdown() is sets the singleton in
CacheManager to null. If you try an use a cache after this you
will get a CacheException.
 You need to call CacheManager.create(). It will create a brand new one
good to go. Internally the CacheManager singleton gets set to the new
one. So you can create and shutdown as many times as you like.
 There is a test which explicitly confirms this behavior. See
CacheManagerTest#testCreateShutdownCreate().

#### Why are statistics counters showing 0 for active caches?
Statistics gathering is disabled by default in order to optimize performance. You can enable statistics gathering in caches in one of the following ways:

* In cache configuration by adding `statistics="true"` to the `<cache>` element.
* Programmatically when setting a cache's configuration.
* In the [Terracotta Developers Console](http://terracotta.org/documentation/2.7/terracotta-tools/dev-console).

    To function, certain features in the Developers Console require statistics to be enabled.

Statistics should be enabled when using the [Ehcache Monitor](/documentation/2.7/operations/monitor).

#### How do I detect deadlocks in Ehcache?
Ehcache does not experience deadlocks. However, deadlocks in your application code can be detected with certain tools, such as [JConsole](/documentation/2.7/operations/jmx#JConsole-Example).

### Replicated Caching

#### How can I see if replicated caching is working?
You should see the listener port open on each server.
You can use the replicated cache debug tool to see what is going on. (See [Remote Network Debugging and Monitoring for Distributed Caches](http://www.ehcache.org/documentation/2.7/operations/remotedebugger)).

#### I am using the RemoteDebugger to monitor replicated cache messages, but all I see is "Cache size: 0". Why?
If you see nothing happening while cache operations should be going through, enable trace (LOG4J) or finest (JDK) level
  logging on <code>net.sf.ehcache.distribution</code> in the logging configuration being used by the debugger.
  A large volume of log messages will appear. The normal problem is that the CacheManager has not joined the replicated cache topology.
  Look for the list of cache peers.
Finally, the debugger in Ehcache 1.5 has been improved to provide far more information on the caches that are
  replicated and events which are occurring.

### Distributed Caching

#### How do I change a distributed cache configuration?
Terracotta clusters remember the configuration settings. You need to delete the cluster to change cache settings of Terracotta distributed
caches. You can also use the Terracotta Dev Console to apply persistent changes to common cache settings.

#### What are the JMX statistics available in the Terracotta Developer Console?
SampledCache and SampledCacheManager MBeans are made available in the Terracotta Developer Console.
These are time-based gauges, based on once-per-second measurements. These are different than the JMX MBeans available through the
`ManagementService`.

#### What happens when an L1 (i.e. an Ehcache node) disconnects from the L2 (i.e. the Terracotta Server Array)?

* The L1 receives an operations disabled event. It then spawns a thread with a timer waiting for an operations-enabled event.
 How long to wait depends on heart beating settings. 65 seconds should work for the default, assuming l2.l1.reconnect is
 enabled with 5s timeout.
* If in this time there is no Operations-Enabled event, then the L1 can conclude that it is disconnected and flip a
 Boolean in the application, which instructs incoming requests to not access the Terracotta Shared space.
  Note that existing threads doing I/O against the TC server (whether for data or for locks) are stuck.
* If the application desires timeouts, then you have to employ a proxy collection, e.g., a wrapper around a Queue or Map
 (in DSO) - where the Queue APIs are proxied through to a thread pool - so that you can try/join out in "timeout" seconds
 and throw a timeout to the application. This is however somewhat messy, since the application threads may receive a
 timeout but the "Terracotta transaction" may still make it through to the L2.




## TROUBLESHOOTING



### General Ehcache

#### I have created a new cache and its status is STATUS_UNINITIALISED. How do I initialise it?
You need to add a newly created cache to a CacheManager before it gets initialised. Use code like the following:

    CacheManager manager = CacheManager.create();
    Cache myCache = new Cache("testDiskOnly", 0, true, false, 5, 2);
    manager.addCache(myCache);

#### Why does Ehcache 1.6 use more memory than 1.5?
ConcurrentHashMap does not provide an eviction mechanism. We add that ourselves. For caches larger than 5000
elements, we create an extra ArrayList equal to the size of the cache which holds keys. This can be an issue
with larger keys. An optimization which cache clients can use is:

<pre><code>
http://www.codeinstructions.com/2008/09/instance-pools-with-weakhashmap.html
To reduce the number of key instances in memory to just one per logical
key, all puts to the underlying ConcurrentHashMap could be replaced by
map.put(pool.replace(key), value), as well as keyArray.set(index,
pool.replace(key))
You can take this approach when producing the keys before handing them over to EhCache.
</code></pre>

Even with this approach, there is still some added overhead consumed by a reference consumed by each ArrayList element.
Update: Ehcache 2.0 will introduce a new implementation for MemoryStore based on a custom ConcurrentHashMap. This version
provides fast iteration and does away with the need for the keyArray thus bringing memory use back down to pre 1.6 levels.
And with other memory optimizations made to Element in 1.7, memory use will actually be considerably lower than pre
1.6 levels.

#### Why did a crashed standalone Ehcache node using disk store not come up with all data intact?
It was configured for temporary disk swapping that is cleared after a restart. For crash-resilient persistence, configure your cache with persistenceStrategy="localRestartable", or use distributed cache, which is backed by the Terracotta Server Array.

#### I added a cache on Client 1, but I can't see it on Client 2. Why not?
A clustered cache created programmatically on one application node does not automatically appear on another node in the cluster. The expected behavior is that caches (whether clustered or not) added programmatically on one client are not visible on other clients. CacheManagers are not clustered, only caches are. So if you want to add a cache programmatically, you would have to add it on all the clients. If that cache is configured to be Terracotta clustered, then it will use the same store, and changes applied to cache entries on one client will automatically reflect on the second client.


### Replicated Caching

#### I see log messages about SoftReferences. What are these about and how do I stop getting the messages?
Ehcache uses SoftReferences with asynchronous RMI-based replication, so that replicating caches do not run out of memory if the network
is interrupted. Elements scheduled for replication will be collected instead. If this is happening, you will see warning messages from the
replicator. It is also possible that a SoftReference can be reclaimed during the sending, in which case you will see a debug level
message in the receiving CachePeer.
 Some things you can do to fix them:

* Set -Xms equal to -Xms. SoftReferences are also reclaimed in preference to increasing the heap size, which is a problem when an application is warming up.
* Set the -Xmx to a high enough value so that SoftReferences do not get reclaimed.

Having done the above, SoftReferences will then only be reclaimed if there is some interruption to replication and the message queue
 gets dangerously high.

### Distributed Caching

#### Why isn't the local node's disk used with Terracotta clustered caches?
Because the TSA itself provides both disk persistence (if required) and scale out, the local DiskStore
is not available with Terracotta clustered caches.

#### `Cache.removeAll()` seems to take a long time. Why?

When `removeAll()` is used with distributed caches, the operation has to clear entries in the Terracotta Server Array as well as in the client. Additional time is required for this operation to complete.

#### I have TTL/TTI not configured or set to 0 (eternal) and have created Elements with a specific TTL which is being ignored. Why?
TTL/TTI are meant to control the relevancy of data for business reasons, not as an operational constraint for managing resources. Without the occurrence of so-called "inline" eviction, which happens whenever an expired element is accessed, it is possible for expired elements
to continue existing in the Terracotta Server Array. This is to minimize the high cost of checking
individual elements for expiration. To force Terracotta servers to inspect element TTL/TTIs (which *lowers* performance), set
`ehcache.storageStrategy.dcv2.perElementTTITTL.enabled` = true" in system properties.


#### After my application interrupted a thread (or threw InterruptedException), why did the Terracotta client die?
The Terracotta client library runs with your application and is often involved in operations which your application is not necessarily aware of. These operations may get interrupted, too, which is not something the Terracotta client can anticipate. Ensure that your application does not interrupt clustered threads. This is a common error that can cause the Terracotta client to shut down or go into an error state, after which it will have to be restarted.

#### If updates to a database bypass the Terracotta clustered application, then how is that coherent?
It isn't. This is a problem with using a database as an integration point. Integration via a message queue, with a
Terracotta clustered application acting as a message queue listener and updating the database avoids this, as would
the application receiving a REST or SOAP call and writing to the database.
AQ can have DB trigger put in a poll, or AQ can push it up.

#### I have a small data set, and yet latency seems to be high.
There are a few ways to try to solve this, in order of preference:

1. Try pinning the cache. If the data set fits comfortably in heap and is not expected to grow, this will speed up gets by a noticeable factor. Pinning certain elements and/or tuning ARC settings might also be effective for certain use cases.
2. Add BigMemory to allow data sets that cannot fit in heap&mdash;but can fit in memory&mdash;to remain very close to your application.
3. Tune the [concurrency of the cache](/documentation/2.7/configuration/distributed-cache-configuration#70873). It may be set too high for a small data set.




## SPECIFIC ERRORS AND WARNINGS



### General Ehcache

#### I am using Java 6 and getting a java.lang.VerifyError on the Backport Concurrent classes. Why?
The backport-concurrent library is used in Ehcache to provide java.util.concurrency facilities for Java 4 - Java 6.
Use either the Java 4 version which is compatible with Java 4-6, or use the version for your JDK.

#### I get a javax.servlet.ServletException: Could not initialise servlet filter when using SimplePageCachingFilter. Why?
If you use this default implementation, the cache name is called "SimplePageCachingFilter". You need to define a cache with that
name in ehcache.xml. If you override CachingFilter, you are required to set your own cache name.

#### Why is there a warning in my application's log that a new CacheManager is using a resource already in use by another CacheManager?

<pre><code>
WARN  CacheManager ...  Creating a new instance of CacheManager using the diskStorePath
"C:\temp\tempcache" which is already used by an existing CacheManager.
</code></pre>

 This means that, for some reason, your application is trying to create one or more additional instances of Ehcache's
 CacheManager with the same configuration. Ehcache is automatically resolving the Disk path conflict,
  which works fine.
To eliminate the warning:

* Use a separate configuration per instance.
* If you only want one instance, use the singleton creation methods, i.e., `CacheManager.getInstance()`. In Hibernate, there is a special provider for this called
 `net.sf.ehcache.hibernate.SingletonEhCacheProvider`.
 See [Hibernate](/documentation/2.7/integrations/hibernate).

#### What does the following error mean? "Caches cannot be added by name when default cache config is not specified in the config. Please add a default cache config in the configuration."
From Ehcache 2.4, the `defaultCache` is optional. When you try to programmatically add a cache by name, `CacheManager.add(String name)`, a default cache is expected to exist in the CacheManager configuration. To fix this error, add a defaultCache to the CacheManager's configuration.

### Replicated Caching

#### Why do I get a RemoteCacheException in a replicated cache topology?

The error is `net.sf.ehcache.distribution.RemoteCacheException: Error doing put to remote peer. Message was: Error unmarshaling return header; nested exception is: java.net.SocketTimeoutException: Read timed out.`
This is typically solved by increasing `socketTimeoutMillis`. This setting is the amount of time a sender
should wait for the call to the remote peer to complete. How long it takes depends on the network and
the size of the elements being replicated.
The configuration that controls this is the `socketTimeoutMillis` setting in `cacheManagerPeerListenerFactory`.
120000 seems to work well for most scenarios.

    <cacheManagerPeerListenerFactory
           class="net.sf.ehcache.distribution.RMICacheManagerPeerListenerFactory"
           properties="hostName=fully_qualified_hostname_or_ip,
                       port=40001,
                       socketTimeoutMillis=120000"/>



### Distributed Caching

#### When I start Ehcache I get "WARN - Can't connect to server[localhost:9510:s1]. Retrying...".
You have not configured a Terracotta server for Ehcache to connect to, or that server isn't reachable.

#### I get a net.sf.ehcache.CacheException: Terracotta cache classes are not available.
You need to include the ehcache-terracotta jar in your classpath.
