---
---
# BigMemory


[BigMemory](http://www.terracotta.org/products) permits caches to use an additional
type of memory store outside the object heap, called the "off-heap store." It's available for both distributed and standalone use cases.

The off-heap store, which is not subject to Java GC, is 100 times faster than the DiskStore and allows extremely large caches to be created. Because off-heap data is stored in bytes, there are two implications:

* Only Serializable cache keys and values can be placed in the store, similar to DiskStore.
* Serialization and deserialization take place on putting and getting from the store. The theoretical difference in the de/serialization overhead disappears due to two effects:
    * the MemoryStore holds the hottest subset of data from the off-heap store, already in deserialized form, and
    * when the GC involved with larger heaps is taken into account, the off-heap store is faster on average.

To get started, see the tutorial on [BigMemory Max](http://terracotta.org/documentation/2.7/4.0/bigmemorymax/get-started/quick-start) or on [BigMemory Go](http://terracotta.org/documentation/2.7/4.0/bigmemorygo/get-started).
