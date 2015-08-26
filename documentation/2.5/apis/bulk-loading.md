---
---
# Bulk Loading in Ehcache <a name="Bulk-Loading}

 

## Introduction
Ehcache has a bulk loading-mode that dramatically speeds up bulk loading into caches using the Terracotta Server Array. Bulk loading is designed to be used for:

*   cache warming - where caches need to be filled before bringing an application online
*   periodic batch loading - say an overnight batch process that uploads data

## API
With bulk loading, the API for putting data into the cache stays the same. Just use `cache.put(...)`
`cache.load(...)` or `cache.loadAll(...)`.
What changes is that there is a special mode that suspends Terracotta's normal consistency guarantees
and provides optimised flushing to the Terracotta Server Array (the L2 cache).

<table markdown="1">
<caption>
NOTE: The Bulk-Load API and the Configured Consistency Mode</caption>
<tr><td>
  The initial consistency mode of a cache is set by configuration and cannot be changed programmatically (see the `<terracotta>` element's `consistency` attribute). The bulk-load API should be used for temporarily suspending the configured consistency mode to allow for bulk-load operations.
</td></tr>
</table>

The following are the bulk-load API methods that are available in `org.terracotta.modules.ehcache.Cache`.

* `public boolean isClusterBulkLoadEnabled()`
    
    Returns true if a cache is in bulk-load mode (is not consistent) throughout the cluster. Returns false if the cache is not in bulk-load mode ( is consistent) anywhere in the cluster.

* `public boolean isNodeBulkLoadEnabled()`

    Returns true if a cache is in bulk-load mode (is not consistent) on the current node. Returns false if the cache is not in bulk-load mode (is consistent) on the current node.

* `public void setNodeBulkLoadEnabled(boolean)`

    Sets a cache’s consistency mode to the configured mode (false) or to bulk load (true) on the local node. There is no operation if the cache is already in the mode specified by `setNodeBulkLoadEnabled()`. When using this method on a nonstop cache , a multiple of the nonstop cache’s timeout value applies. The bulk-load operation must complete within that timeout multiple to prevent the configured nonstop behavior from taking effect. For more information on tuning nonstop timeouts, see [Tuning Nonstop Timeouts and Behaviors](/documentation/configuration/non-stop-cache#78696).

* `public void waitUntilBulkLoadComplete()`

    Waits until a cache is consistent before returning. Changes are automatically batched and the cache is updated throughout the cluster. Returns immediately if a cache is consistent throughout the cluster.

Note the following about using bulk-load mode:

* Consistency cannot be guaranteed because `isClusterBulkLoadEnabled()` can return false in one node just before another node calls `setNodeBulkLoadEnabled(true)` on the same cache. Understanding exactly how your application uses the bulk-load API is crucial to effectively managing the integrity of cached data.
* If a cache is not consistent, any ObjectNotFound exceptions that may occur are logged.
* `get()` methods that fail with ObjectNotFound return null.
* Eviction is independent of consistency mode. Any configured or manually executed eviction proceeds unaffected by a cache’s consistency mode.

The following example code shows how a clustered application with Enterprise Ehcache can use the bulk-load API to optimize a bulk-load operation:

<pre><code>import net.sf.ehcache.Cache;
public class MyBulkLoader {
CacheManager cacheManager = new CacheManager();  // Assumes local ehcache.xml.
  Cache cache = cacheManager.getEhcache(\"myCache\"); // myCache defined in ehcache.xml.
  cache.setNodeBulkLoadEnabled(true); // myCache is now in bulk mode.
// Load data into myCache.
cache.setNodeBulkLoadEnabled(false); // Done, now set myCache back to its configured consistency mode.
}
</code></pre>

<table markdown="1">
<caption>NOTE: Potentional Error With Non-Singleton CacheManager</caption>
<tr><td>Ehcache 2.5 and higher does not allow multiple CacheManagers with the same name to exist in the same JVM. `CacheManager()` constructors creating non-Singleton CacheManagers can violate this rule, causing an error. If your code may create multiple CacheManagers of the same name in the same JVM, avoid this error by using the [static `CacheManager.create()` methods](http://ehcache.org/apidocs/net/sf/ehcache/CacheManager), which always return the named (or default unnamed) CacheManager if it already exists in that JVM. If the named (or default unnamed) CacheManager does not exist, the `CacheManager.create()` methods create it.
</td></tr>
</table>

On another node, application code that intends to touch myCache can run or wait, based on whether myCache is consistent or not:

<pre><code>...
if (!cache.isClusterBulkLoadEnabled()) {
// Do some work.
}
else {
 cache.waitUntilBulkLoadComplete()
 // Do the work when waitUntilBulkLoadComplete() returns.
}
...
</code></pre>

Waiting may not be necessary if the code can handle potentially stale data:

<pre><code>...
if (!cache.isClusterBulkLoadEnabled()) {
// Do some work.
}
else {
// Do some work knowing that data in myCache may be stale.
}
...
</code></pre>

The following methods have been deprecated: `setNodeCoherent(boolean mode)`, `isNodeCoherent()`, `isClusterCoherent()`
and `waitUntilClusterCoherent()`.

## Speed Improvement
The speed performance improvement is an order of magnitude faster.
[ehcacheperf](http://svn.terracotta.org/svn/forge/projects/ehcacheperf/trunk/) (Spring Pet Clinic) now has a bulk load test which shows the performance improvement for using
a Terracotta cluster.

## FAQ <a name="faq}

### How does bulk-loading affect pinned caches?
If a cache has been [pinned](/documentation/configuration/data-life), switching the cache into bulk-load mode removes the cached data. The data will then be faulted in from the TSA as it is needed.

### Are there any alternatives to putting the cache into bulk-load mode?
Bulk-loading Cache methods putAll(), getAll(), and removeAll() provide high-performance and eventual consistency. These can also be used with strong consistency. If you can use them, it's unnecessary to use bulk-load mode. See the [API documentation](http://ehcache.org/apidocs) for details.

### Why does the bulk loading mode only apply to Terracotta clusters?
Ehcache, both standalone and replicated is already very fast and nothing needed to be
added.

### How does bulk load with RMI distributed caching work?
The core updates are very fast. RMI updates are batched by default once per second,
so bulk loading will be efficiently replicated.

## Performance Tips <a name="performance-tips}

### When to use Multiple Put Threads
It is not necessary to create multiple threads when calling `cache.put`. Only a marginal performance
improvement will result, because the call is already so fast.
It is only necessary if the source is slow. By reading from the source in multiple threads a speed up could result.
An example is a database, where multiple reading threads will often be better.

### Bulk Loading on Multiple Nodes
The implementation scales very well when the load is split up against multiple Ehcache CacheManagers on multiple
machines.
You add extra nodes for bulk loading to get up to 93 times performance.

### Why not run in bulk load mode all the time
Terracotta clustering provides consistency, scaling and durability. Some applications will require consistency, or
not for some caches, such as reference data. It is possible to run a cache permanently in inconsistent mode.

## Download <a name="download}
The bulk loading feature is in the ehcache-core module but only provides a performance improvement to Terracotta clusters
(as bulk loading to Ehcache standalone is very fast already)
Download [here](http://sourceforge.net/projects/ehcache/files/ehcache-core).
For a full distribution enabling connection to the Terracotta Server array download [here](http://sourceforge.net/projects/ehcache/files/ehcache).

## Further Information <a name="further-information}
Saravanan who was the lead on this feature has blogged about it [here](http://sarosblog.blogspot.com/2010/02/terracotta-distributed-ehcaches-new.html).
