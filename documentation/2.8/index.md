---
---

# Documentation Overview

The Table of Contents provides an overview of the Ehcache 2.8 documentation on this site. Each topic below corresponds to a menu item at the left. The sections following are pointers to essential information about Ehcache.

## Ehcache 2.8 Documentation Table of Contents

| Topic | Description |
|:-------|:------------|
|[Getting Started](/documentation/2.8/get-started/index.html)|Introduction to Ehcache and general concepts in caching, as well as a quick start guide.|
|[Configuration](/documentation/2.8/configuration/index.html)|Everything you need to know to get up and running with Ehcache.|
|[BigMemory](/documentation/2.8/bigmemory/index.html)|Configuring Ehcache with BigMemory greatly extends the memory available for caching. The BigMemory overview page provides links to the important topics for working with BigMemory.|
|[Automatic Resource Control (ARC)](/documentation/2.8/arc/index.html)|ARC includes features such as memory-based cache sizing, dynamic allocation of memory across multiple caches, and automatic load balancing. The ARC overview page provides links to the important topics for configuring ARC.|
|[APIs](/documentation/2.8/apis/index.html)|The APIs menu includes a page for each API that provides comprehensive coverage of the application features.|
|[Operations](/documentation/2.8/operations/index.html)|The Operations menu includes pages on monitoring, logging, improving performance, and troubleshooting.|
|[Replication](/documentation/2.8/replication/index.html)|How to use Ehcache for replicated caching with RMI, JGroups, and JMS. (For specifics on distributed caching, see the [Distributed Ehcache Configuration Guide](/documentation/2.8/configuration/distributed-cache-configuration).)|
|[Modules](/documentation/2.8/modules/index.html)|The Modules menu includes pages about the Cache Server web services and web caching.|
|[Hibernate 2nd-Level Cache](/documentation/2.8/hibernate/index.html)|The Hibernate overview page provides links to the important topics for integrating Ehcache with Hibernate.|
|[Integrations](/documentation/2.8/integrations/index.html)|The Integrations menu includes a page for each container or platform supported. See also the [note](#integrating-ehcache) below on Ehcache versions.|
|[Recipes](/documentation/2.8/recipes/index.html)|Specific use cases and solutions to common problems.|
|[Code Samples](/documentation/2.8/code-samples/index.html)|Examples that will help you get started with Ehcache.|
|[FAQ](/documentation/2.8/faq.html)|A clearinghouse of frequently asked questions about distributed caching, replicated caching, and Ehcache in general.|



## Caching Pointers
If you are new to caching, you might want to start with the following pages:

* [Introduction to caching](/documentation/2.8/get-started/introduction.html)
* [Concepts in caching](/documentation/2.8/get-started/getting-started.html)
* [Recipes](/documentation/2.8/recipes/index.html) and [Code Samples](/documentation/2.8/code-samples/index.html)
* [Dynamic sizing of memory and other resources](/documentation/2.8/configuration/cache-size.html) and [pinning caches and entries](/documentation/2.8/configuration/data-life.html). These pages describe Automatic Resource Control (ARC), which provides a wealth of benefits, including:

    * Sizing limitations on in-memory caches to avoid OutOfMemory errors
    * Pooled (CacheManager-level) sizing &ndash; no requirement to size caches individually
    * Differentiated tier-based sizing for flexibility
    * Sizing by bytes, entries, or percentages for more flexibility
    * Keeping hot or eternal data where it can substantially boost performance

* [Compatibility Matrix](http://www.terracotta.org/confluence/display/release/Library+to+Server+Compatibility+Matrix)

## A Distributed or Replicated Cache?
If your application node shares cached data, and you are evaluating distribution versus replication, see this page on [cache topologies](/documentation/2.8/get-started/cache-topologies.html).


## Integrating Ehcache

**NOTE:** Some containers and frameworks have a built-in dependency on earlier versions of Ehcache and may have out-of-date Ehcache in their classpath. In this case, an older version of Ehcache may actually be loaded at runtime, which can cause ClassNotFound and other errors.

The links below provide details for each platform:

* [Hibernate](/documentation/2.8/integrations/hibernate.html)
* [Coldfusion](/documentation/2.8/integrations/coldfusion.html)
* Containers ([Tomcat](/documentation/2.8/integrations/tomcat.html), [Glassfish](/documentation/2.8/integrations/glassfish.html))
* [Grails](/documentation/2.8/integrations/grails.html)
* [Ruby](/documentation/2.8/integrations/jruby.html) (Rails and JRuby)
* [Transactional Environments](/documentation/2.8/apis/transactions.html)
* [Google App Engine](/documentation/2.8/integrations/googleappengine.html)


## Improving Performance and Troubleshooting

* [GC Tuning](/documentation/2.8/operations/garbage-collection.html)
* [Logging](/documentation/2.8/operations/logging.html)
* [RMI Debugger](/documentation/2.8/operations/remotedebugger.html)

## Previous Versions

Documentation is also available for the following versions of Ehcache:

* [Ehcache Documentation Home](/documentation/)


For a listing of current and previous releases, and links to release notes and platform compatibility tables, go to the <a href="http://www.terracotta.org/confluence/display/release/Home"> Release Information page</a>.


For documentation on earlier versions of Terracotta software, contact <a href="&#109;&#097;&#105;&#108;&#116;&#111;&#58;customersupport&#064;terracottatech.com">Customer Support</a>.

## Acknowledgements

Ehcache has had many contributions in the form of forum discussions, feature requests, bug reports, patches and code commits.
Rather than try and list the many hundreds of people who have contributed to Ehcache in some way it is better to link
to the web site where contributions are acknowledged in the following ways:

* Bug reports and features requests appear in [Jira](http://jira.terracotta.org).
* Patch contributors generally end up with an author tag in the source they contributed to.
