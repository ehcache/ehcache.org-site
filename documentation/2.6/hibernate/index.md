---
---

# Hibernate Overview

Accelerating Hibernate applications typically involves reducing their reliance on the database when fetching data. Terracotta offers powerful in-memory solutions for maximizing the performance of Hibernate applications:

* Ehcache as a [plug-in second-level cache for Hibernate](/documentation/2.6/integrations/hibernate) &ndash; Automatically cache common queries in memory to substantially lower latency.
* [BigMemory](/documentation/2.6/bigmemory/index) for an in-memory store &ndash; Leverage off-heap physical memory to keep more of the data set close to your application and out of reach of Java garbage collection.
* [Automatic Resource Control](/documentation/2.6/arc/index) for intelligent caching &ndash; Pin the hot set in memory for high-speed access and employ fine-grained sizing controls to avoid OutOfMemory errors.

The following sections provide a documentation Table of Contents and important information on using Ehcache with Hibernate.

## Hibernate Table of Contents

| Topic | Description |
|:-------|:------------|
|[Hibernate Second-Level Cache](/documentation/2.6/integrations/hibernate)|Ehcache easily integrates with the Hibernate Object/Relational persistence and query service. This page should be your first stop for configuration information, performance tips, and FAQs.|
|[JMX Management and Monitoring](/documentation/2.6/operations/jmx)|JMX monitoring is often used for Hibernate replicated caching. This page contains a section on [Hibernate Statistics](/documentation/2.6/operations/jmx#Hibernate-statistics).|
|[Grails](/documentation/2.6/recipes/grails)|Includes recipes and code samples for using Ehcache with Hibernate and Grails.|

   


## Important Notices - PLEASE READ

Users of Ehcache and/or Terracotta Ehcache for Hibernate prior to Ehcache 2.0 should read [Upgrade Notes for Ehcache versions prior to 2.0](http://ehcache.org/documentation/2.6/integrations/hibernate-upgrade). These instructions are for Hibernate 3.

For older instructions on how to use Hibernate 2.1, please refer to [Guide for Version 1.1](http://ehcache.org/documentation/documentation-1_1).


## Additional Information about Hibernate
The following pages provide additional information about using Ehcache with Hibernate:

* [General Ehcache FAQ](/documentation/2.6/faq)
* [Transactions FAQ](/documentation/2.6/apis/transactions#faq)
