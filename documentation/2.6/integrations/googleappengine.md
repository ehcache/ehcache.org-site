---
---
# Google App Engine (GAE) Caching <a name="google-app-engine-caching} 

 

##Introduction
The ehcache-googleappengine module combines the speed of Ehcache with the scale of Google's memcache and provide the best of both worlds:

* Speed - Ehcache cache operations take a few microseconds, versus around 60ms for Google's provided client-server cache, memcacheg.
* Cost -  Because it uses way less resources, it is also cheaper.
* Object Storage - Ehcache in-process cache works with Objects that are not Serializable.

## Compatibility
Ehcache is compatible and works with Google App Engine.
Google App Engine provides a constrained runtime which restricts networking, threading and file system access.

## Limitations
All features of Ehcache can be used except for the DiskStore and replication. Having said that, there are workarounds
for these limitations. See the Recipes section below.
As of June 2009, Google App Engine appears to be limited to a heap size of 100MB.
(See [this blog](http://gregluck.com/blog/?s=limitations) for the evidence of this).

## Dependencies
Version 2.3 and higher of Ehcache are compatible with Google App Engine.
Older versions will not work.

## Configuring ehcache.xml
Make sure the following elements are commented out:

* &lt;diskStore path="/path/to/store/data"/>
* &lt;cacheManagerPeerProviderFactory class= ../>
* &lt;cacheManagerPeerListenerFactory class= ../>

Within each cache element, ensure that:

* overFlowToDisk and diskPersistent are omitted
* persistence strategy=none
* no replicators are added
* there is no bootstrapCacheLoaderFactory
* there is no Terracotta configuration

Use following Ehcache configuration to get started.

    <?xml version="1.0" encoding="UTF-8"?>
    <ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:noNamespaceSchemaLocation="ehcache.xsd" >
        <cacheManagerEventListenerFactory class="" properties=""/>
        <defaultCache
           maxEntriesOnHeap="10000"
           eternal="false"
           timeToIdleSeconds="120"
           timeToLiveSeconds="120"
           memoryStoreEvictionPolicy="LRU">
           <persistence strategy="none"/>
        </defaultCache>
    <!--Example sample cache-->
        <cache name="sampleCache1"
          maxEntriesOnHeap="10000"
          maxEntriesLocalDisk="1000"
          eternal="false"
          timeToIdleSeconds="300"
          timeToLiveSeconds="600"
          memoryStoreEvictionPolicy="LFU"
           />
    </ehcache>

## Recipes

### Setting up Ehcache as a local cache in front of memcacheg
The idea here is that your caches are set up in a cache hierarchy. Ehcache sits in front and memcacheg behind.
Combining the two lets you elegantly work around limitations imposed by Google App Engine.
You get the benefits of the speed of Ehcache together with the umlimited size of memcached.
Ehcache contains the hooks to easily do this.
To update memcached, use a `CacheEventListener`.
To search against memcacheg on a local cache miss, use `cache.getWithLoader()` together with a
`CacheLoader` for memcacheg.

### Using memcacheg in place of a `DiskStore`
In the `CacheEventListener`, ensure that when `notifyElementEvicted()` is called, which it will be
when a put exceeds the MemoryStore's capacity, that the key and value are put into memcacheg.

### Distributed Caching
Configure all notifications in `CacheEventListener` to proxy throught to memcacheg.
Any work done by one node can then be shared by all others, with the benefit of local caching of frequently
used data.

### Dynamic Web Content Caching
Google App Engine provides acceleration for files declared static in `appengine-web.xml`.

For example:

    <static-files>
      <include path="/**.png" />
      <exclude path="/data/**.png" />
    </static-files>

You can get acceleration for dynamic files using Ehcache's caching filters as you usually would.
See  [Web Caching](/documentation/2.6/modules/web-caching) for more information.

## Troubleshooting <a name="google-app-engine-faq"/>

### NoClassDefFoundError
If you get the error `java.lang.NoClassDefFoundError: java.rmi.server.UID is a restricted class` then you are using a version of Ehcache prior to 1.6.

## Sample application
The easiest way to get started is to play with a simple sample app. We provide [a simple Rails application](http://svn.terracotta.org/svn/forge/projects/ehcache-rails-demo/) which stores an integer value in a cache along with increment and decrement operations.
The sample app shows you how to use ehcache as a caching plugin and how to use it directly from the Rails
caching API.
