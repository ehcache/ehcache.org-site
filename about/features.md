---
layout: about_page
title: Features
visible_title: "Features of Ehcache"
active_sub_menu_id: ehc_mnu_about_features
---


## Fast and Light Weight


### Fast

Ehcache's concurrency features are designed for large, high concurrency systems.

Extensive performance tests in the test suite keep Ehcache's performance consistent between releases.

Ehcache 3.0 has daily automated perf testing whereby check-ins that cause degradations are immediately flagged.

### Simple

Many users of Ehcache hardly know they are using it. Sensible defaults require no initial configuration.

The API is very simple and easy to use, making it possible to get up and running in minutes. See the
[Code Samples](/generated/2.10.0/html/ehc-all/#page/Ehcache_Documentation_Set%2Fto-codebasics_basic_caching.html%23) for details.


### Small foot print

Ehcache strives to maintain a small footprint - keeping your apps as light as they can be.

With Ehcache 3.0 there is a renewed emphasis in this area - with strong results.


### Minimal dependencies

The only dependency for core use is SLF4J.

---

## Scalable

### Provides for scalability into terabytes

The largest Ehcache installations utilize multiple terabytes of data storage.

And with off-heap storage, Ehcache has been tested to store 6TB data in a single process (jvm).


### Scalable to hundreds of caches

The largest Ehcache installations use hundreds of caches.


### Tuned for high concurrent load on large/wide multi-CPU servers

There is a tension between thread safety and performance. Ehcache is specifically built and tested to run well under highly concurrent access on systems with dozens of CPU cores.


### Scalable to hundreds of nodes with the Terracotta Server Array

By adding [Terracotta](http://terracotta.org/downloads/open-source/catalog), Ehcache can scale to any use case, enabling clustered caches over a distributed deployment architecture.


---


## Flexible

Provides multiple strategies for:

* Expiration policies
* Eviction policies
* Storage engines (on-heap, off-heap, disk)
* Static/Dynamic/Runtime configuration of caches


---


## Standards Based


### Full implementation of JSR107 JCACHE API


For a number of years, Terracotta staff have been participating on the expert committee for JSR107.

Ehcache offers the the most complete implementation of the JSR107 JCache to date.  Implementers can code to the JCache API which will create portability to other caching solutions in the future.

For the Ehcache 2.x line, a JSR107 compliant wrapper is, [available on github](https://github.com/ehcache/ehcache-jcache).

For "Native" JSR107 support check out [Ehcache 3](http://ehcache.github.io/).


---

## Extensible

* Listener interfaces
* Decorator interfaces
* Cache Loaders, Cache Writers
* Exception Handlers

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

## Distributed Caching


Ehcache has full support for high performance distributed caching.

### Distributed Caching with Terracotta

Simple yet powerful clustered caching. Just two lines of configuration is all that is required. For more
information see [Distributed Caching With Terracotta](http://terracotta.org/generated/4.3.1/html/bmm-all/#page/bigmemory-max-webhelp%2Fco-cfgdist_about_distributed_config.html%23  "Configuring Distributed Cache").


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

This is the trusty old command pattern with a twist: asynchronous behavior, fault tolerance and caching.
Creates a command, caches it and then attempts to execute it.


### Works with Hibernate

Ehcache is popularly used as Hibernate's second-level cache.


### Works with Google App Engine

Ehcache-1.6 is compatible with Google App Engine.

See the [Google App Engine How-To](/generated/2.10.1/html/ehc-all/#page/Ehcache_Documentation_Set%2Fto-gae_using_ehcache_with_the_google_app_engine.html%23).


### Transactional support through JTA

Ehcache supports JTA and is a fully XA compliant resource participating in the transaction, two-phase commit and recovery. Ehcache also supports local transactions.

See the complete [transaction documentation](/generated/2.10.1/html/ehc-all/#page/Ehcache_Documentation_Set%2Fto-tx_transaction_support.html%23).


---


## Open Source Licensing

### Apache 2.0 license

Ehcache is released under the updated Apache 2.0 license.

The Apache license is also friendly one, making it safe and easy to include Ehcache in other open source projects or commercial products.
