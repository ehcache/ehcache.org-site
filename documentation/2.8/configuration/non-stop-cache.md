---
---
<a id="96087"></a>
# Nonstop (Non-Blocking) Cache <a name="nonstop"/>

A nonstop cache allows certain cache operations to proceed on clients that have become disconnected from the cluster, or if a cache operation cannot complete by the nonstop timeout value. This is useful in meeting service-level agreement (SLA) requirements, responding to node failures, and building a more robust High Availability cluster.

One way clients go into nonstop mode is when they receive a "cluster offline" event. Note that a nonstop cache can go into nonstop mode even if the node is not disconnected, such as when a cache operation is unable to complete within the timeout allotted by the nonstop configuration.

Nonstop can be used in conjunction with [rejoin](http://terracotta.org/documentation/2.8/terracotta-server-array/high-availability#71266).

Use cases include:

* Setting timeouts on cache operations.

    For example, say you use the cache rather than a mainframe. The SLA calls for 3 seconds. There is a temporary network interruption that delays the response to a cache request. With the timeout you can return after 3 seconds. The lookup is then done against the mainframe. This could also be useful for write-through, writes to disk, or synchronous writes.
    
* Automatically responding to cluster topology events to take a pre-configured action.

* Allowing Availability over Consistency within the CAP theorem when a network partition occurs.

* Providing graceful degradation to user applications when Distributed Cache becomes unavailable.

Nonstop caches are available with [BigMemory Max](http://terracotta.org/products/bigmemorymax).
