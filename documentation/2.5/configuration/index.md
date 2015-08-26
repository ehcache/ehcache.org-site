---
---

# Configuration Overview

The following sections provide a documentation Table of Contents and additional information sources about Ehcache configuration.

## Configuration Table of Contents

| Topic | Description |
|:-------|:------------|
|[Introduction](/documentation/2.5/configuration/configuration)|The basics of cache configuration with Ehcache, including dynamically changing cache configuration, cache warming, and copyOnRead/copyOnWrite cache configuration.|
|[BigMemory](/documentation/2.5/configuration/bigmemory)|Introduction to BigMemory, how to configure Ehcache with BigMemory, performance comparisons, an FAQ, and more.|
|[Sizing Caches](/documentation/2.5/configuration/cache-size)|Tuning Ehcache often involves sizing cached data appropriately. Ehcache provides a number of ways to size the different data tiers using simple cache-configuration sizing attributes. This page explains simplified tuning of cache size by configuring dynamic allocation of memory and automatic load balancing.|
|[Expiration, Pinning, and Eviction](/documentation/2.5/configuration/data-life)|The architecture of an Ehcache node can include a number of tiers that store data. One of the most important aspects of managing cached data involves managing the life of the data in each tier. This page covers managing data life in Ehcache and the Terracotta Server Array, including the pinning features of Automatic Resource Control (ARC).|
|[Nonstop Cache](/documentation/2.5/configuration/non-stop-cache)|A nonstop (non-blocking) cache allows certain cache operations to proceed on clients that have become disconnected from the cluster, or to proceed when cache operations cannot complete by the nonstop timeout value. This can be useful in meeting SLA requirements, responding to node failures, building a more robust High Availability cluster, and more. This page covers configuring nonstop cache, nonstop timeouts and behaviors, and nonstop exceptions.|
|[UnlockedReadsView](/documentation/2.5/apis/unlocked-reads-view)|With this API, you can have both the unlocked view and a strongly consistent cache at the same time. UnlocksReadView provides an eventually consistent view of a strongly consistent cache. Views of data are taken without regard to that data's consistency, and writes are not affected by UnlockedReadsView. This page covers creating an UnlockedReadsView and provides a download link and an FAQ.|
|[Distributed-Cache Configuration](/documentation/2.5/configuration/distributed-cache-configuration)|The basic configuration guide for Distributed Ehcache (Ehcache with Terracotta clustering), this page also includes CacheManager configuration and Terracotta clustering configuration elements.|
|[Distributed-Cache Default Configuration](/documentation/2.5/configuration/defaults)|A number of properties control the way the Terracotta Server Array and Ehcache clients perform in a Terracotta cluster. Some of these properties are set in the Terracotta configuration file, others are set in the Ehcache configuration file, and a few must be set programmatically. This page details the most important of these properties and shows their default values.|


## Hit the Ground Running
Popular topics in Configuration:

* [Cache Warming](/documentation/2.5/configuration/configuration#cache-warming-for-multi-tier-caches)
* [Handling JVM startup and shutdown with BigMemory](/documentation/2.5/configuration/bigmemory#handling-jvm-lifecycle)
* [Sizing Distributed Caches](/documentation/2.5/configuration/cache-size#sizing-distributed-caches)
* [Terracotta Clustering Configuration Elements](/documentation/2.5/configuration/distributed-cache-configuration#95592)


## Additional Information about Configuration
The following pages provide additional information about Ehcache configuration:

* [Discussion of Data Freshness and Expiration](/documentation/2.5/recipes/expiration)
* [Enabling Terracotta Support Programmatically](/documentation/2.5/recipes/programmatic)
* [Adding and Removing Caches Programmatically](/documentation/2.5/code-samples#adding-and-removing-caches-programmatically)
* [Creating Caches Programmatically](/documentation/2.5/code-samples#creating-caches-programmatically)






