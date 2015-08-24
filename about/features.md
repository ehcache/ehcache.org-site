---
layout: about_page
title: Features
visible_title: "Features of Ehcache"
active_sub_menu_id: ehc_mnu_about_features
---


## Fast and Light Weight


### Fast

Over the years, various performance tests have shown Ehcache to be one of the fastest Java caches. Ehcache's threading is designed for large, high concurrency systems.

Extensive performance tests in the test suite keep Ehcache's performance consistent between releases.


### Simple

Many users of Ehcache hardly know they are using it. Sensible defaults require no initial configuration.

The API is very simple and easy to use, making it possible to get up and running in minutes. See the
[Code Samples](/documentation/code-samples) for details.


### Small foot print

Ehcache strives to maintain a small footprint - keeping your apps as light as they can be.


### Minimal dependencies

The only dependency for core use is SLF4J.

---

## Scalable

### Provides Memory and Disk stores for scalability into gigabytes

The largest Ehcache installations use memory and disk stores in the gigabyte range. Ehcache is tuned for
these large sizes.

And with BigMemory, that can be taken up to hundreds of GB, all in process.


### Scalable to hundreds of caches

The largest Ehcache installations use hundreds of caches.


### Tuned for high concurrent load on large multi-CPU servers

There is a tension between thread safety and performance. Ehcache's threading started off coarse-grained, but
has increasingly made use of ideas from Doug Lea to achieve greater performance. Over the years there have
been a number of scalability bottlenecks identified and fixed.


### Multiple CacheManagers per virtual machine

Ehcache 1.2 introduced multiple CacheManagers per virtual machine. This enables completely difference ehcache.xml configurations to be applied.


### Scalable to hundreds of nodes with the Terracotta Server Array

By adding Terracotta, Ehcache can scale to any use case. See more details about Terracotta caching at Distributed Caching With Terracotta.


---


## Flexible


### Supports Object or Serializable caching

As of ehcache-1.2 there is an API for Objects in addition to the one for Serializable. Non-serializable
Objects can use all parts of Ehcache except for DiskStore and replication. If an attempt is made to persist
or replicate them they are discarded and a WARNING level log message emitted.

The APIs are identical except for the return methods from Element. Two new methods on Element: getObjectValue
and getKeyValue are the only API differences between the Serializable and Object APIs. This makes it very
easy to start with caching Objects and then change your Objects to Seralizable to participate in the extra
features when needed. Also a large number of Java classes are simply not Serializable.


### Support cache-wide or Element-based expiry policies

Time to lives and time to idles are settable per cache. In addition, from ehcache-1.2.1, overrides to these
can be set per Element.


### Provides LRU, LFU and FIFO cache eviction policies

Ehcache 1.2 introduced Less Frequently Used and First In First Out caching eviction policies. These round out
the eviction policies.


### Provides Memory and Disk stores

Ehcache, like most of the cache solutions, provides high performance memory and disk stores.


### Dynamic, Runtime Configuration of Caches

The time-to-live, time-to-idle, maximum in-memory and on-disk capacities can be tuned at runtime simply by mutating the cache's configuration object.


---


## Standards Based


### Full implementation of JSR107 JCACHE API


For a number of years, Terracotta staff have been participating on the expert committee for JSR107.

Ehcache offers the the most complete implementation of the JSR107 JCache to date.  Implementers can code to the JCache API which will create portability to other caching solutions in the future.

For the Ehcache 2.x line, a JSR107 compliant wrapper is, [available on github](https://github.com/ehcache/ehcache-jcache).

For "Native" JSR107 support check out [Ehcache 3](http://ehcache.github.io/).


---

## Extensible


### Listeners may be plugged in

Ehcache 1.2 provides CacheManagerEventListener and CacheEventListener interfaces. Implementations can be
plugged in and configured in ehcache.xml.


### Peer Discovery, Replicators and Listeners may be plugged in

Distributed caching, introduced in Ehcache 1.2 involves many choices and tradeoffs. The Ehcache team believe
that one size will not fit all.

Implementers can use built-in mechanisms or write their own. A plugin development guide is included for this
purpose.


### Cache Extensions may be plugged in

Create your own Cache Extensions, which hold a reference to a cache and are bound to its lifecycle.


### Cache Loaders may be plugged in

Create your own Cache Loaders, which are general purpose asynchronous methods for loading data into caches,
or use them in pull-through configuration.


### Cache Exception Handlers may be plugged in

Create an Exception Handler which is invoked if any Exception occurs on a cache operation.


---


## Application Persistence


### Persistent disk store which stores data between VM restarts

With Ehcache 1.1 in 2004, Ehcache was the first open source Java cache to introduce persistent storage of
cache data on disk on shutdown. The cached data is then accessible the next time the application runs.

### Flush to disk on demand

With Ehcache 1.2, the flushing of entries to disk can be executed with a cache.flush() method whenever required, making it easier to use ehcache


---


## Listeners


### CacheManager listeners

Register Cache Manager listeners through the CacheManagerEventListener interface with the following event
methods:

* `notifyCacheAdded()`
* `notifyCacheRemoved()`


### Cache event listeners

Register Cache Event Listeners through the CacheEventListener interfaces, which provides a lot of flexibility
for post-processing of cache events. The methods are:

* `notifyElementRemoved`
* `notifyElementPut`
* `notifyElementUpdated`
* `notifyElementExpired`


---


## JMX Enabled

Ehcache is JMX enabled. You can monitor and manage the following MBeans:

* CacheManager
* Cache
* CacheConfiguration
* CacheStatistics

See the `net.sf.ehcache.management` package.

See <http://weblogs.java.net/blog/maxpoon/archive/2007/06/extending_the_n_2.html> for an online tutorial.


---


## Distributed Caching


Ehcache has full support for high performance distributed caching that is flexible and extensible.

Included options for distributed caching are:
* Clustered caching via Terracotta: two lines of configuration is all that is required to setup and use Ehcache with Terracotta. Cache discovery is automatic, and many options exist for tuning the cache behavior and performance for your use case.
* Replicated caching via RMI, JGroups, or JMS: Cache discovery is implemented via multicast or manual configuration. Updates are delivered either asynchronously or synchronously via custom RMI connections.
* Custom: a comprehensive plugin mechanism provides support for custom discovery and replication implementations. [See the Distributed Caching](/documentation/get-started/about-distributed-cache "Terracotta Distributed Caching") documentation for more feature details.


### Distributed Caching with Terracotta

Simple yet powerful clustered caching. Just two lines of configuration is all that is required. For more
information see [Distributed Caching With Terracotta](/documentation/configuration/distributed-cache-configuration  "Configuring Distributed Cache").


### Replicated Caching via RMI, JGroups, or JMS

No programming changes are required to make use of replication. Only configuration in ehcache.xml.

Available replication options are:

* Ehcache 1.6+ supports replication via RMI, JGroups, and JMS
* Synchronous or asynchronous replication, per cache, as appropriate.
* Copy or invalidate, per cache, as appropriate.


### Bootstrapping from Peers

Distributed caches enter and leave the cluster at different times. Caches can be configured to bootstrap
themselves from the cluster when they are first initialized.

An abstract factory, `BootstrapCacheLoaderFactory` has been defined along with an interface
`BootstrapCacheLoader` along with an RMI based default implementation.


## Search

Standalone and distributed search using a fluent query language. See the [search documentation](/documentation/apis/search)


---


## Enterprise Java and Applied Caching

High quality implementations for common caching scenarios and patterns.


### Blocking Cache to avoid duplicate processing for concurrent operations

A cache which blocks subsequent threads until the first read thread populates a cache entry.


### SelfPopulating Cache for pull through caching of expensive operations

SelfPopulatingCache - a read-through cache. A cache that populates elements as they are requested without
requiring the caller to know how the entries are populated. It also enables refreshes of cache entries
without blocking reads on the same entries.


### Enterprise Java Gzipping Servlet Filter

* CachingFilter - an abstract, extensible caching filter.
* SimplePageCachingFilter

    A high performance Java servlet filter that caches pages based on the request URI and Query String. It also gzips the pages and delivers them to browsers either gzipped or ungzipped depending on the HTTP request headers. Use to cache entire Servlet pages, whether from JSP, velocity, or any other rendering technology.

* SimplePageFragmentCachingFilter

    A high performance enterprise Java filter that caches page fragments based on the request URI and Query String. Use with Servlet request dispatchers to cache parts of pages, whether from JSP, velocity, or any other rendering technology. Can be used from JSPs using jsp:include.

* Works with Servlet 2.3 and Servlet 2.4 specifications.


### Cacheable Commands

This is the trusty old command pattern with a twist: asynchronous behaviour, fault tolerance and caching.
Creates a command, caches it and then attempts to execute it.


### Works with Hibernate

Ehcache is popularly used as Hibernate's second-level cache.


### Works with Google App Engine

Ehcache-1.6 is compatible with Google App Engine.

See the [Google App Engine How-To](/documentation/integrations/googleappengine "Google App Engine Caching").


### Transactional support through JTA

Ehcache supports JTA and is a fully XA compliant resource participating in the transaction, two-phase commit and recovery. Ehcache also supports local transactions.

See the complete [transaction documentation](/documentation/apis/transactions "Transactions in Ehcache").


---


## Open Source Licensing

### Apache 2.0 license

Ehcache is released under the updated Apache 2.0 license.

The Apache license is also friendly one, making it safe and easy to include Ehcache in other open source projects or commercial products.
