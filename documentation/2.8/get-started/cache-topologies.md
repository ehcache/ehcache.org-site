---
---
# Cache Topologies <a name="Distributed-and-Replicated-Caching"/>



## Introduction

The Ehcache API is used in the following topologies:

* Standalone &ndash; The cached data set is held in the application node. Any other application nodes are independent with no communication between them. If standalone caching is being used where there are multiple application nodes running the same application, then there is Weak Consistency between them. They contain consistent values for immutable data or after the time to live on an Element has completed and the Element needs to be reloaded. Standalone nodes can be run with open-source Ehcache or, to add off-heap memory and other features, with [BigMemory Go](http://terracotta.org/products/bigmemorygo).

* Distributed &ndash; The data is held in a Terracotta Server Array with a subset of recently used data held in each application cache node. The distributed topology, available with [BigMemory Max](http://terracotta.org/products/bigmemorymax), supports a very rich set of [consistency modes](/documentation/2.8/get-started/consistency-options).

* Replicated – The cached data set is held in each application node and data is copied or invalidated across the cluster without locking. Replication can be either asynchronous or synchronous, where the writing thread blocks while propagation occurs. The only consistency mode available in this topology is Weak Consistency. nodes can be run with open-source Ehcache.


Many production applications are deployed in clusters of multiple
instances for availability and scalability. However, without a
distributed or replicated cache, application
clusters exhibit a number of undesirable behaviors, such as:

* **Cache Drift** -- if each application instance maintains its own cache,
  updates made to one cache will not appear in the other instances.  This
  also happens to web session data.  A distributed or replicated cache ensures that all
  of the cache instances are kept in sync with each other.
* **Database Bottlenecks** -- In a single-instance
  application, a cache effectively shields a database from the overhead of
  redundant queries.  However, in a distributed application environment,
  each instance much load and keep its own cache fresh.  The overhead of
  loading and refreshing multiple caches leads to database bottlenecks as
  more application instances are added.  A distributed or replicated cache eliminates
  the per-instance overhead of loading and refreshing multiple caches from
  a database.

The following sections further explore distributed and replicated caching.

## Distributed Caching
Distributed caching uses the Terracotta Server Array, available with [BigMemory Max](http://terracotta.org/products/bigmemorymax). Distributed caching enabling data sharing among multiple CacheManagers and their caches in multiple JVMs. By combining the power of the Terracotta Server Array with the ease of Ehcache application-data caching, you can:

* linearly scale your application to grow with requirements;
* rely on data that remains consistent across the cluster;
* offload databases to reduce the associated overhead;
* increase application performance with distributed in-memory data;
* access even more powerful APIs to leverage these capabilities.

Using distributed caching is the recommended approach in a clustered or scaled-out application environment. It provides the highest level of performance, availability, and scalability.


## Replicated Caching
Ehcache has a pluggable cache replication scheme which enables the addition of cache replication mechanisms.
Ehcache modules for the following replicated caching mechanisms are available:

* RMI
* JGroups
* JMS
* Cache Server

Each of the is covered in its own chapter.
 One solution is to replicate data between the caches to keep them
consistent, or coherent. Typical operations include:

* put
* update (put which overwrites an existing entry)
* remove

Update supports updateViaCopy or updateViaInvalidate. The latter
 sends the a remove message out to the cache cluster, so that other
 caches remove the Element, thus preserving coherency. It is typically
 a lower cost option than a copy.

### Using a Cache Server
Ehcache 1.5 supports the Ehcache Cache Server.
To achieve shared data, all JVMs read to and write from a Cache Server, which runs
it in its own JVM.
To achieve redundancy, the Ehcache inside the Cache Server can be set up in its own cluster.
This technique will be expanded upon in Ehcache 1.6.

### Notification Strategies
 The best way of notifying of put and update depends on the nature of
the cache.
 If the Element is not available anywhere else then the Element
itself should form the payload of the notification. An example is a
cached web page. This notification strategy is called copy.
 Where the cached data is available in a database, there are two
choices. Copy as before, or invalidate the data. By invalidating the
data, the application tied to the other cache instance will be forced
to refresh its cache from the database, preserving cache coherency.
Only the Element key needs to be passed over the network.
 Ehcache supports notification through copy and invalidate, selectable per cache.

### Potential Issues with Replicated Caching

#### Potential for Inconsistent Data
 Timing scenarios, race conditions, delivery, reliability
constraints and concurrent updates to the same cached data can cause
inconsistency (and thus a lack of coherency) across the cache
instances.
 This potential exists within the Ehcache implementation.
These issues are the same as what is seen when two completely
separate systems are sharing a database, a common scenario.
 Whether data inconsistency is a problem depends on the data and how it
is used. For those times when it is important, Ehcache provides for
synchronous delivery of puts and updates via invalidation. These are discussed below:

##### Synchronous Delivery
 Delivery can be specified to be synchronous or asynchronous.
Asynchronous delivery gives faster returns to operations on the local
cache and is usually preferred. Synchronous delivery adds time to the
local operation, however delivery of an update to
all peers in the cluster happens before the cache operation returns.

##### Put and Update via Invalidation
 The default is to update other caches by copying the new value to
them. If the replicatePutsViaCopy property is set to false in the
replication configuration, puts are made by removing the element in
any other cache peers. If the replicateUpdatesViaCopy property is set to false in the
replication configuration, updates are made by removing the element in
any other cache peers.
 This forces the applications using the cache
peers to return to a canonical source for the data.
 A similar effect can be obtained by setting the element TTL to a low value such
as a second.
 Note that these features impact cache performance and should
not be used where the main purpose of a cache is performance boosting over
coherency.

#### Use of Time To Idle
 Time To Idle is inconsistent with replicated caching. Time-to-idle makes some entries live longer on some
nodes than in others because of cache usage patterns. However, the cache entry "last touched" timestamp
is not replicated across nodes.
 Do not use Time To Idle with replicated caching, unless you do not care about inconsistent data across nodes.
