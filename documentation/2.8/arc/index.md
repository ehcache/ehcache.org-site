---
---

# Automatic Resource Control Overview

Automatic Resource Control (ARC) is an intelligent approach to caching with fine-grained controls for tuning cache performance. ARC offers a wealth of benefits, including:

* Sizing limitations on in-memory caches to avoid OutOfMemory errors
* Pooled (CacheManager-level) sizing – no requirement to size caches individually
* Differentiated tier-based sizing for flexibility
* Sizing by bytes, entries, or percentages for more flexibility
* Keeping hot or eternal data where it can substantially boost performance

The following sections provide a documentation Table of Contents and additional information sources for ARC.

## ARC Table of Contents

| Topic | Description |
|:-------|:------------|
|[Dynamic Sizing of Memory](/documentation/2.8/configuration/cache-size)|Tuning Ehcache often involves sizing cached data appropriately. Ehcache provides a number of ways to size the different data tiers using simple cache-configuration sizing attributes. This page explains simplified tuning of cache size by configuring dynamic allocation of memory and automatic load balancing.|
|[Pinning Caches and Entries](/documentation/2.8/configuration/data-life)|The architecture of an Ehcache node can include a number of tiers that store data. One of the most important aspects of managing cached data involves managing the life of the data in each tier. This page covers managing data life in Ehcache and the Terracotta Server Array, including the pinning features of Automatic Resource Control (ARC).|


## Additional Information about ARC
The following pages provide information on ARC in an enterprise environment:

* [ARC Introduction](http://terracotta.org/documentation/4.1/bigmemorymax/quick-start#additional-configuration-topics)
* [ARC Code Sample](http://terracotta.org/documentation/4.1/bigmemorymax/code-samples#example-6-automatic-resource-control-arc)

