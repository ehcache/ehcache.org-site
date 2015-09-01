---
---
# About Distributed Cache


Distributed caching is available with the [Terracotta Server](http://terracotta.org/downloads/open-source/catalog) - please use Ehcache 2.10 or greater with it.


# The below documentation is much dated


# About Distributed Cache




## Introduction
Distributed Cache, formally called Terracotta Distributed Ehcache, is Ehcache running in a Terracotta cluster. Distributed caching is the recommended method of operating Ehcache in a clustered or scaled-out application environment, as it enables data sharing among multiple CacheManagers and their caches in multiple JVMs.

You can find [tutorials](http://terracotta.org/documentation/enterprise-ehcache/get-started), [installation procedures](http://terracotta.org/documentation/enterprise-ehcache/installation-guide), [best practices](http://terracotta.org/documentation/best-practices), details on the [Terracotta Server Array](http://terracotta.org/documentation/terracotta-server-array/introduction), and more in the Terracotta documentation.

## Architecture <a name="Architecture"/>
Distributed Ehcache combines an in-process Ehcache with the Terracotta Server Array acting as a backing cache store.


### Logical View
With Terracotta Server Array the data is split between an Ehcache node (the L1 cache) and the Terracotta Server Array itself (the L2 Cache). As with the
other replication mechanisms, the L1 can hold as much data as is comfortable. But there is always a complete copy of all cache
data in the L2. The L1 therefore acts as a hot-set of recently used data.
Distributed Ehcache is persistent and highly available, leaving the cache unaffected by the termination of an Ehcache node. When the node comes back up it reconnects
to the Terracotta Server Array L2 and as it uses data fills its local L1.

![Ehcache Image](/images/documentation/terracotta-logical.png)

### Network View
From a network topology point of view Distributed Ehcache consists of:

* L1 - the Ehcache library is present in each app. An Ehcache instance, running in-process sits in each JVM.
* L2 - Each Ehcache instance (or node) maintains a connection with one or more Terracotta servers. These are arranged in pairs
     for high availability. A pair is known as a *mirror group*. For high availability each server runs on a dedicated server.
     For scale out multiple pairs are added. Consistent hashing is used by the Ehcache nodes to store
     and retrieve cache data in the correct server pair. The terms Stripe or Partition are then used to refer to each mirror group.

![Ehcache Image](/images/documentation/terracotta-network-topology.png)

### Memory Hierarchy View
Another way to look at the architecture of Distributed Ehcache is as a tiered memory hierarchy.
Each in-process Ehcache instance (L1s) can have:

*   Heap memory
*   Off-heap memory (BigMemory). This is stored in direct byte buffers.

    The Terractta servers (L2s) run as Java processes with their own memory hierarchy:

*   Heap memory
*   Off-heap memory (BigMemory). This is stored in direct byte buffers.
*   Disk storage. This is optional. It provides persistence in the event both servers in a mirror group suffer a crash or power
   outage at the same time.

![Ehcache Image](/images/documentation/tiered-memory.png)

## Differences Between Terracotta Distributed Cache and Standalone or Replicated Cache
Differences in behavior and available functionality between distributed cache and standalone and replicated caches are called out in the documentation. Some major differences are listed here:

* In distributed caches locking takes effect on individual keys, while in standalone caches locking takes effect on segments that include a number of keys.
* In distributed caches, all cache stores are shared.
* Only distributed caches can be made transactional caches (`<cache ... transactionalMode="xa">`).
* Standalone caches load very quickly and do not require a [bulk-loading API](/documentation/apis/bulk-loading).
* Distributed caches are "cluster safe" for Hibernate (locks are used for writing to distributed  caches). There is no need for `session.refresh()` as with replicated caches.
* Extreme scaling using multiple server stripes is available for distributed cache.
* Replication requires use of CacheEventListeners.
* Distributed caching can be used to create a clustered message queue for updating a database in a way that keeps data consistent.
* Distributed caches come with Terracotta High Availability and durability, greatly benefitting use cases requiring features such as write-through (CacheWriter) queues (`<cacheWriter writeMode="write-behind">`).
* When using read-through with write-behind, distributed caches can add cluster-wide consistency to cache data.

## Code Samples


As this example shows, running Ehcache with Terracotta clustering is no different from normal programmatic use.


    import net.sf.ehcache.Cache;
    import net.sf.ehcache.CacheManager;
    import net.sf.ehcache.Element;
    public class TerracottaExample {
    CacheManager cacheManager = new CacheManager();
      public TerracottaExample() {
        Cache cache = cacheManager.getCache("sampleTerracottaCache");
        int cacheSize = cache.getKeys().size();
        cache.put(new Element("" + cacheSize, cacheSize));
        for (Object key : cache.getKeys()) {
          System.out.println("Key:" + key);
        "/>
      "/>
      public static void main(String[] args) throws Exception {
        new TerracottaExample();
      "/>
    "/>


The above example looks for sampleTerracottaCache.
In ehcache.xml, we need to uncomment or add the following line:

<pre>
&lt;terracottaConfig url="localhost:9510"/&gt;
</pre>

This tells Ehcache to load the Terracotta server config from localhost port 9510. For `url` configuration options, refer to "Adding an URL Attribute" in [Terracotta Clustering Configuration Elements](/documentation/configuration/distributed-cache-configuration#95592). Note: You must have a
Terracotta 3.1.1 or higher server running locally for this example.

Next we want to enable Terracotta clustering for the cache named `sampleTerracottaCache`. Uncomment or add the
following in ehcache.xml.

<pre>
  &lt;cache name="sampleTerracottaCache"
     maxEntriesLocalHeap="1000"
     eternal="false"
     timeToIdleSeconds="3600"
     timeToLiveSeconds="1800"
     overflowToDisk="false"&gt;
    &lt;terracotta/&gt;
  &lt/cache&gt;
</pre>

That's it!


## Development with Maven and Ant

With a Distributed Ehcache, there is a Terracotta Server Array. At development time, this necessitates running a server locally for integration and/or interactive testing.
There are plugins for Maven and Ant to simplify and automate this process.

For Maven, Terracotta has a  plugin available which makes this very simple.

### Setting up for Integration Testing

    <pluginRepositories>
       <pluginRepository>
           <id>terracotta-snapshots</id>
           <url>http://www.terracotta.org/download/reflector/maven2</url>
           <releases>
               <enabled>true</enabled>
           </releases>
           <snapshots>
               <enabled>true</enabled>
           </snapshots>
       </pluginRepository>
    </pluginRepositories>
    <plugin>
       <groupId>org.terracotta.maven.plugins</groupId>
       <artifactId>tc-maven-plugin</artifactId>
       <version>1.5.1</version>
       <executions>
           <execution>
               <id>run-integration</id>
               <phase>pre-integration-test</phase>
               <goals>
                   <goal>run-integration</goal>
               </goals>
           </execution>
           <execution>
               <id>terminate-integration</id>
               <phase>post-integration-test</phase>
               <goals>
                   <goal>terminate-integration</goal>
               </goals>
           </execution>
       </executions>
    </plugin>

### Interactive Testing
To start Terracotta:

    mvn tc:start

To stop Terracotta:

    mvn tc:stop

See the [Terracotta Forge](http://forge.terracotta.org/releases/projects/tc-maven-plugin/) for a complete reference.
