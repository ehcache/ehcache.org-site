---
---

# BigMemory Overview

BigMemory gives Java applications instant, effortless access to a large memory footprint with **in-memory data management** that lets you store large amounts of data closer to your application, improving memory utilization and application performance with both standalone and distributed caching. BigMemory's in-process, off-heap cache is not subject to Java garbage collection, is 100x faster than DiskStore, and allows you to create very large caches. In fact, the size of the off-heap cache is limited only by address space and the amount of RAM on your hardware. In performance tests, we’ve achieved fast, predictable response times with terabyte caches on a single machine.

Rather than stack lots of 1-4 GB JVMs on a single machine in an effort to minimize the GC problem, with BigMemory you can increase application density, running a smaller number of larger-memory JVMs. This simpler deployment model eases application scale out and provides a more sustainable, efficient solution as your dataset inevitably grows.

The following sections provide a documentation Table of Contents and additional information sources for BigMemory.

## BigMemory Table of Contents

| Topic | Description |
|:-------|:------------|
|[BigMemory Configuration](/documentation/2.6/configuration/bigmemory)|Introduction to BigMemory, how to configure Ehcache with BigMemory, performance comparisons, FAQs, and more.|
|[Further Performance Analysis](http://ehcache.org/documentation/2.6/configuration/bigmemory-further-performance-analysis)|Further performance results for off-heap store for a range of scenarios.|
|[Pooling Resources Versus Sizing Individual Caches](/documentation/2.6/configuration/cache-size#pooling-resources-versus-sizing-individual-caches)|Additional information for configuring Ehcache to use local off-heap memory.|
|[Storage Options](/documentation/2.6/get-started/storage-options)|Discussion of BigMemory in the context of storage options for Ehcache.|
|[Terracotta Clustering Configuration Elements](/documentation/2.6/configuration/distributed-cache-configuration#95592)|The role of BigMemory in data consistency for the distributed cache.|
   

## BigMemory Resources
Additional information and downloads:

* [About BigMemory](http://terracotta.org/documentation/bigmemory/overview)
* [Tutorial of Ehcache with BigMemory](http://terracotta.org/documentation/bigmemory/get-started)
* [Using BigMemory in a Terracotta Server Array](http://terracotta.org/documentation/bigmemory/terracotta-server-array)
