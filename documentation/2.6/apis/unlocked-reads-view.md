---
---
# UnlockedReadsView <a name="UnlockedReadsView"/>

 

## Introduction
`UnlockedReadsView` is a [decorated cache](/documentation/2.6/apis/cache-decorators) which provides an eventually consistent view
of a strongly consistent cache. Views of data are taken without regard to that data's consistency. Writes are not affected by `UnlockedReadsView`.
You can have both the unlocked view and a strongly consistent cache at the same time.

The UnlockedReadsView is placed in the CacheManager under its own name so that 
it can be separately referenced. The purpose of this is to allow business logic faster access to data. It is
akin to the READ\_UNCOMMITTED database isolation level. Normally, a read lock must first be obtained to read data
backed with Terracotta. If there is an outstanding write lock, the read lock queues up. This is done so that
the *happens before* guarantee can be made. However, if the business logic is happy to read stale data even
if a write lock has been acquired in preparation for changing it, then much higher speeds can be obtained.


## Creating an UnlockedReadsView


### Programmatically

<pre><code>Cache cache = cacheManager.getCache("existingUndecoratedCache");
UnlockedReadsView unlockedReadsView = new UnlockedReadsView(cache, newName);
cacheManager.addDecoratedCache(unlockedReadsView);  //adds a decorated Ehcache
</code></pre>

If the UnlockedReadsView has the same name as the cache it is decorating, 
`CacheManager.replaceCacheWithDecoratedCache(Ehcache ehcache, Ehcache decoratedCache)` should be used, instead of
using `CacheManager.addDecoratedCache(Ehcache decoratedCache)` as shown above.

If added to the CacheManager, it can be accessed like following:

<pre><code>Ehcache unlockedReadsView = cacheManager.getEhcache(newName);
</code></pre>

NOTE: Right now, `UnlockedReadsView` only accepts `net.sf.ehcache.Cache` instances in the constructor, meaning
it can be used to decorate only `net.sf.ehcache.Cache` instances. One disadvantage is that it cannot be used to 
decorate other already decorated `net.sf.ehcache.Ehcache` instances like `NonStopCache`.


### By Configuration

It can be configured in ehcache.xml using the "cacheDecoratorFactory" element. You can specify a factory to create 
decorated caches and `net.sf.ehcache.constructs.unlockedreadsview.UnlockedReadsViewDecoratorFactory` is available in
the unlockedreadsview module itself.

    <cache name="sample/DistributedCache3"
          maxEntriesLocalHeap="10"
          eternal="false"
          timeToIdleSeconds="100"
          timeToLiveSeconds="100">
        <persistence strategy="localTempSwap"/>
       <cacheDecoratorFactory
          class="net.sf.ehcache.constructs.unlockedreadsview.UnlockedReadsViewDecoratorFactory"
          properties="name=unlockedReadsViewOne" />
    </cache>

It is mandatory to specify the properties for the UnlockedReadsViewDecoratorFactory with "name" property. That property
is used as the name of the UnlockedReadsView that will be created.


## Download <a name="Download"/>


### File
The file is available for download [here](http://sourceforge.net/projects/ehcache/files/ehcache-unlockedreadsview).


### Maven
The UnlockedReadsView is in the ehcache-unlockedreadsview module in the Maven central repo.
Add this snippet to your dependencies:

    <dependency>
      <groupId>net.sf.ehcache</groupId>
      <artifactId>ehcache-unlockedreadsview</artifactId>
    </dependency>

## FAQ


### Why is this a CacheDecorator?

This API is emerging. It is production quality and supported, but it is a new API and may evolve over time.
As a decorator in its own module, it can evolve separately from ehcache-core.


### Why do I see stale values in certain Ehcache nodes for up to 5 minutes?

UnlockedReadsView uses unlocked reads of the Terracotta Server Array combined with a local TTL which, in
versions up to Ehcache 2.4, are hardcoded to 300 seconds (5 minutes). If you are already holding a copy
in a local node, you will not see an updated value for 5 minutes.
As of Ehcache 2.4.1, you also have the option of simply configuring the whole cache as `consitency="eventual"`,
which sends changed data to the node as soon as possible. However the whole cache is eventually consistent - you
cannot use that with a strongly consistent cache.
We plan to make this TTL configurable in a future release.
