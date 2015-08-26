---
---
# Architecture <a name="Architecture"/>
Distributed Ehcache combines an in-process Ehcache with the Terracotta Server Array ("TSA") acting as a backing cache store.

 

## Logical View
With TSA the data is split between an Ehcache node (the L1 cache) and the TSA itself (the L2 Cache). As with the
other replication mechanisms, the L1 can hold as much data as is comfortable. But there is always a complete copy of all cache
data in the L2. The L1 therefore acts as a hot-set of recently used data.
Distributed Ehcache is persistent and highly available, leaving the cache unaffected by the termination of an Ehcache node. When the node comes back up it reconnects
to the TSA L2 and as it uses data fills its local L1.

![Ehcache Image](/images/documentation/terracotta-logical.png)

## Network View
From a network topology point of view Distributed Ehcache consists of:

* L1 - the Ehcache library is present in each app. An Ehcache instance, running in-process sits in each JVM.
* L2 - Each Ehcache instance (or node) maintains a connection with one or more Terracotta servers. These are arranged in pairs
     for high availability. A pair is known as a *mirror group*. For high availability each server runs on a dedicated server.
     For scale out multiple pairs are added. Consistent hashing is used by the Ehcache nodes to store
     and retrieve cache data in the correct server pair. The terms Stripe or Partition are then used to refer to each mirror group.

![Ehcache Image](/images/documentation/terracotta-network-topology.png)

## Memory Hierarchy View
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
