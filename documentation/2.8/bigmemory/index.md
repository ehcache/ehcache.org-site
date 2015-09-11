---
---

# BigMemory Overview

BigMemory gives Java applications instant, effortless access to a large memory footprint with **in-memory data management** that lets you store huge amounts of data closer to your application, improving memory utilization and application performance with both standalone and distributed caching. BigMemory's in-process, off-heap cache is not subject to Java garbage collection, is 100x faster than DiskStore, and allows you to create very large caches. In fact, the size of the off-heap cache is limited only by address space and the amount of RAM on your hardware. In performance tests, we’ve achieved fast, predictable response times with terabyte caches on a single machine.

Rather than stack lots of 1-4 GB JVMs on a single machine in an effort to minimize the GC problem, with BigMemory you can increase application density, running a smaller number of larger-memory JVMs. This simpler deployment model eases application scale out and provides a more sustainable, efficient solution as your dataset inevitably grows.

[BigMemory Go](http://terracotta.org/products/bigmemorygo) has all of the advantages of BigMemory for standalone applications requiring vertical scaling, while [BigMemory Max](http://terracotta.org/products/bigmemorymax) brings a flexible data-consistency model and massive horizontal scaling to distributed applications.
