---
---

# Documentation Overview

The Table of Contents provides an overview of the Ehcache 2.5.x documentation on this site. Each topic below corresponds to a menu item at the left. The sections following are pointers to essential information about Ehcache.

## Ehcache 2.5.x Documentation Table of Contents

| Topic | Description |
|:-------|:------------|
|[Getting Started](/documentation/2.5/get-started)|Introduction to Ehcache and general concepts in caching, as well as a quick start guide.|
|[Configuration](/documentation/2.5/configuration)|Everything you need to know to get up and running with Ehcache. The focus is on stand-alone and distributed caching. (For specifics on replicated caching, see [Replication](/documentation/2.5/replication).)|
|[BigMemory](/documentation/2.5/bigmemory/index)|Configuring Ehcache with BigMemory greatly extends the memory available for caching. The BigMemory overview page provides links to the important topics for working with BigMemory.|
|[Automatic Resource Control (ARC)](/documentation/2.5/arc)|ARC includes features such as memory-based cache sizing, dynamic allocation of memory across multiple caches, and automatic load balancing. The ARC overview page provides links to the important topics for configuring ARC.|
|[APIs](/documentation/2.5/apis)|The APIs menu includes a page for each API that provides comprehensive coverage of the application features.|
|[Operations](/documentation/2.5/operations)|The Operations menu includes pages on monitoring, logging, improving performance, and troubleshooting.|
|[Replication](/documentation/2.5/replication)|How to use Ehcache for replicated caching with RMI, JGroups, and JMS. (For specifics on distributed caching, see the [Distributed Ehcache Configuration Guide](/documentation/2.5/configuration/distributed-cache-configuration).)|
|[Modules](/documentation/2.5/modules/index)|The Modules menu includes pages about the Cache Server web services and web caching.|
|[Hibernate 2nd-Level Cache](/documentation/2.5/hibernate/index)|The Hibernate overview page provides links to the important topics for integrating Ehcache with Hibernate.|
|[Integrations](/documentation/2.5/integrations)|The Integrations menu includes a page for each container or platform supported. See also the [note](#integrating-ehcache) below on Ehcache versions.|
|[WAN Replication](/documentation/2.5/wan-replication)|All you need to get started with Terracotta distributed Ehcache WAN replication.|
|[Recipes](/documentation/2.5/recipes)|Specific use cases and solutions to common problems.|
|[Code Samples](/documentation/2.5/code-samples)|Examples that will help you get started with Ehcache.|
|[FAQ](/documentation/2.5/faq)|A clearinghouse of frequently asked questions about distributed caching, replicated caching, and Ehcache in general.|

    

## Caching Pointers
If you are new to caching, you might want to start with the following pages:

* [Introduction to caching](/documentation/2.5/get-started/introduction)
* [Concepts in caching](/documentation/2.5/get-started/concepts)
* [Recipes](/documentation/2.5/recipes/) and [Code Samples](/documentation/2.5/code-samples)
* [Dynamic sizing of memory and other resources](/documentation/2.5/configuration/cache-size) and [pinning caches and entries](/documentation/2.5/configuration/data-life). These pages describe Automatic Resource Control (ARC), which provides a wealth of benefits, including:

    * Sizing limitations on in-memory caches to avoid OutOfMemory errors
    * Pooled (CacheManager-level) sizing &ndash; no requirement to size caches individually
    * Differentiated tier-based sizing for flexibility
    * Sizing by bytes, entries, or percentages for more flexibility
    * Keeping hot or eternal data where it can substantially boost performance

* [Compatibility Matrix](http://www.terracotta.org/confluence/display/release/Library+to+Server+Compatibility+Matrix)

## A Distributed or Replicated Cache?
If your application node shares cached data, and you are evaluating distribution versus replication, see this page on [cache topologies](/documentation/2.5/get-started/cache-topologies).


## Integrating Ehcache

**NOTE:** Some containers and frameworks have a built-in dependency on earlier versions of Ehcache and may have out-of-date Ehcache in their classpath. In this case, an older version of Ehcache may actually be loaded at runtime, which can cause ClassNotFound and other errors.

The links below provide details for each platform:

* [Hibernate](/documentation/2.5/integrations/hibernate)
* [Coldfusion](/documentation/2.5/integrations/coldfusion)
* Containers ([Tomcat](/documentation/2.5/integrations/tomcat), [Glassfish](/documentation/2.5/integrations/glassfish))
* [Grails](/documentation/2.5/integrations/grails)
* [Ruby](/documentation/2.5/integrations/jruby) (Rails and JRuby)
* [Transactional Environments (JTA)](/documentation/2.5/apis/jta)
* [Google App Engine](/documentation/2.5/integrations/googleappengine)


## Improving Performance and Troubleshooting

* [GC Tuning](/documentation/2.5/operations/garbage-collection)
* [Logging](/documentation/2.5/operations/logging)
* [RMI Debugger](/documentation/2.5/operations/remotedebugger)

## Previous Versions

Documentation is also available for the following versions of Ehcache:

* [Ehcache 2.4.x](/documentation/2.4)
* [Ehcache 2.0-2.3](http://ehcache.org/files/documentation/EhcacheUserGuide-2.0-2.3.pdf)
* [Ehcache 1.7.1](http://ehcache.org/files/documentation/EhcacheUserGuide-1.7.1.pdf)
* [Ehcache 1.6](http://ehcache.org/files/documentation/EhcacheUserGuide-1.6.pdf)
* [Ehcache 1.5](http://ehcache.org/files/documentation/EhcacheUserGuide-1.5.pdf)
* [Ehcache 1.4](http://ehcache.org/files/documentation/EhcacheUserGuide-1.4.pdf)
* [Ehcache 1.3.0](http://ehcache.org/files/documentation/EhcacheUserGuide-1.3.0.pdf)
* [Ehcache 1.2.4](http://ehcache.org/files/documentation/EhcacheUserGuide-1.2.4.pdf)
* [Ehcache 1.2.3](http://ehcache.org/files/documentation/EhcacheUserGuide-1.2.3.pdf)
* [Ehcache 1.1](/documentation/documentation-1_1)

## Acknowledgements

Ehcache has had many contributions in the form of forum discussions, feature requests, bug reports, patches and code commits.
Rather than try and list the many hundreds of people who have contributed to Ehcache in some way it is better to link
to the web site where contributions are acknowledged in the following ways:

* Bug reports and features requests appear in [Jira](http://jira.terracotta.org).
* Patch contributors generally end up with an author tag in the source they contributed to.
* Team members appear on the [team list page](/community/team-list).
    
