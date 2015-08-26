---
---
<a id="96087"></a>
# Nonstop (Non-Blocking) Cache <a name="nonstop"/>

 

## Introduction
A nonstop cache allows certain cache operations to proceed on clients that have become disconnected from the cluster or if a cache operation cannot complete by the nonstop timeout value. This is useful in meeting SLA requirements, responding to node failures, building a more robust High Availability cluster, and more.

One way clients go into nonstop mode is when they receive a "cluster offline" event. Note that a nonstop cache can go into nonstop mode even if the node is not disconnected, such as when a cache operation is unable to complete within the timeout allotted by the nonstop configuration.

Nonstop can be used in conjunction with [rejoin](http://terracotta.org/documentation/enterprise-ehcache/reference-guide#71266).

Use cases include:

* Setting timeouts on cache operations.

    For example, say you use the cache rather than a mainframe. The SLA calls for 3 seconds. There is a temporary network interruption which delays the response to a cache request. With the timeout you can return after 3 seconds. The lookup is then done against the mainframe. This could also be useful for write-through, writes to disk, or synchronous writes.
    
* Automatically responding to cluster topology events to take a pre-configured action.

* Allowing Availability over Consistency within the CAP theorem when a network partition occurs.

* Providing graceful degradation to user applications when Distributed Cache becomes unavailable.

## Configuring Nonstop Cache 

Nonstop is configured in a `<cache>` block under the `<terracotta>` subelement. In the following example, myCache has nonstop configuration:

    <cache name="myCache" maxEntriesLocalHeap="10000" eternal="false"
           overflowToDisk="false">
     <terracotta>
       <nonstop immediateTimeout="false" timeoutMillis="30000">
         <timeoutBehavior type="noop" />
       </nonstop>
     </terracotta>
    </cache>

Nonstop is enabled by default or if `<nonstop>` appears in a cache’s `<terracotta>` block.


## Nonstop Timeouts and Behaviors

Nonstop caches can be configured with the following attributes:

* `enabled` &ndash;  Enables ("true" DEFAULT) or disables ("false") the ability of a cache to execute certain actions after a Terracotta client disconnects. This attribute is optional for enabling nonstop.
* `immediateTimeout` &ndash;  Enables ("true") or disables ("false" DEFAULT) an immediate timeout response if the Terracotta client detects a network interruption (the node is disconnected from the cluster). If enabled, this parameter overrides `timeoutMillis`, so that the option set in `timeoutBehavior` is in effect immediately.
* `timeoutMillis` &ndash;  Specifies the number of milliseconds an application waits for any cache operation to return before timing out. The default value is 30000 (thirty seconds). The behavior after the timeout occurs is determined by `timeoutBehavior`.

`<nonstop>` has one self-closing subelement, &lt;timeoutBehavior>. This subelement determines the response after a timeout occurs (`timeoutMillis` expires or an immediate timeout occurs). The response can be set by the &lt;timeoutBehavior> attribute `type`. This attribute can have one of the values listed in the following table:

<table markdown="1">
<tr>
<th>Value</th>
<th>Behavior</th>
</tr>
<tr>
<td>
`exception`
</td>
<td>
(DEFAULT) Throw `NonStopCacheException`. See <a href="#97568">When is NonStopCacheException Thrown?</a> for more information on this exception.
</td>
</tr>
<tr>
<td>
`noop`
</td>
<td>
Return null for gets. Ignore all other cache operations. Hibernate users may want to use this option to allow their application to continue with an alternative data source.
</td>
</tr>
<tr>
<td>
`localReads`
</td>
<td>
For caches with Terracotta clustering, allow inconsistent reads of cache data. Ignore all other cache operations. For caches without Terracotta clustering, throw an exception.
</td>
</tr>
</table>


### Tuning Nonstop Timeouts and Behaviors <a name="78696"/>

You can tune the default timeout values and behaviors of nonstop caches to fit your environment. 

#### Network Interruptions
For example, in an environment with regular network interruptions, consider disabling `immediateTimeout` and increasing `timeoutMillis` to prevent timeouts for most of the interruptions.

For a cluster that experiences regular but short network interruptions, and in which caches clustered with Terracotta carry read-mostly data or there is tolerance of potentially stale data, you may want to set `timeoutBehavior` to `localReads`.

#### Slow Cache Operations
In an environment where cache operations can be slow to return and data is required to always be in sync, increase `timeoutMillis` to prevent frequent timeouts. Set `timeoutBehavior` to `noop` to force the application to get data from another source or `exception` if the application should stop.

For example, a `cache.acquireWriteLockOnKey(key)` operation may exceed the nonstop timeout while waiting for a lock. This would trigger nonstop mode only because the lock couldn't be acquired in time. Using `cache.tryWriteLockOnKey(key, timeout)`, with the method's timeout set to less than the nonstop timeout, avoids this problem.

#### Bulk Loading
If a nonstop cache is bulk-loaded using the <a href="http://terracotta.org/documentation/enterprise-ehcache/api-guide#75664">Bulk-Load API</a>, a multiplier is applied to the configured nonstop timeout whenever the method `net.sf.ehcache.Ehcache.setNodeBulkLoadEnabled(boolean)` is used. The default value of the multiplier is 10. You can tune the multiplier using the `bulkOpsTimeoutMultiplyFactor` system property:

~~~
-DbulkOpsTimeoutMultiplyFactor=10
~~~

This multiplier also affects the methods `net.sf.ehcache.Ehcache.getAll()`, `net.sf.ehcache.Ehcache.removeAll()`, `net.sf.ehcache.Ehcache.removeAll(boolean)`, and `net.sf.ehcache.Ehcache.setNodeCoherent(boolean)` (DEPRECATED).

## Nonstop Exceptions
Typically, application code may access the cache frequently and at various points. Therefore, with a nonstop cache, where your application could encounter NonStopCacheExceptions is difficult to predict. The following sections provide guidance on when to expect NonStopCacheExceptions and how to handle them.

### When is NonStopCacheException Thrown? <a name="97568"/>

NonStopCacheException is usually thrown when it is the configured behavior for a nonstop cache in a client that disconnects from the cluster. In the following example, the exception would be thrown 30 seconds after the disconnection (or the "cluster offline" event is received):

    <nonstop immediateTimeout="false" timeoutMillis="30000">
    <timeoutBehavior type="exception" />
    </nonstop>

However, under certain circumstances the NonStopCache exception can be thrown even if a nonstop cache’s timeout behavior is *not* set to throw the exception. This can happen when the cache goes into nonstop mode during an attempt to acquire or release a lock. These lock operations are associated with certain lock APIs and special cache types such as <a href="http://terracotta.org/documentation/enterprise-ehcache/api-guide#31478">Explicit Locking</a>, BlockingCache, SelfPopulatingCache, and UpdatingSelfPopulatingCache.

A NonStopCacheException can also be thrown if the cache must fault in an element to satisfy a `get()` operation. If the Terracotta Server Array cannot respond within the configured nonstop timeout, the exception is thrown.

A related exception, InvalidLockAfterRejoinException, can be thrown during or after client rejoin (see <a href="http://terracotta.org/documentation/enterprise-ehcache/reference-guide#71266">Using Rejoin to Automatically Reconnect Terracotta Clients</a>). This exception occurs when an unlock operation takes place on a lock obtained *before* the rejoin attempt completed.

<table markdown="1">
<caption>TIP: Use try-finally Blocks</caption>
<tr>
<td>
To ensure that locks are released properly, application code using Ehcache lock APIs should encapsulate lock-unlock operations with try-finally blocks:

    myLock.acquireLock();
    try {
      // Do some work.
    } finally {
      myLock.unlock();
    "/>

</td>
</tr>
</table>

### Handling Nonstop Exceptions

Your application can handle nonstop exceptions in the same way it handles other exceptions. For nonstop caches, an unhandled-exceptions handler could, for example, refer to a separate thread any cleanup needed to manage the problem effectively.

Another way to handle nonstop exceptions is by using a dedicated Ehcache decorator that manages the exception outside of the application framework. The following is an example of how the decorator might operate:

    try { cache.put(element); } 
    
    catch(NonStopCacheException e) { 
    
      handler.handleException(cache, element, e);
    "/>
