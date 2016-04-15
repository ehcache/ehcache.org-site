---
---

# Operations Overview

The following sections provide a documentation Table of Contents and additional information sources about Ehcache operations.

## Operations Table of Contents

| Topic | Description |
|:-------|:------------|
|[Tuning GC](/documentation/2.8/operations/garbage-collection.html)|Detecting Garbage Collection problems, Garbage Collection tuning, and distributed caching Garbage Collection tuning.|
|[Ehcache Monitor](/documentation/2.8/operations/monitor.html)|The Ehcache Monitor is an add-on tool for Ehcache which provides enterprise-class monitoring and management capabilities for use in both development and production. It is intended to help understand and tune cache usage, detect errors, and provide an easy-to-use access point to integrate with production management systems. It also provides administrative functionality, such as the ability to forcefully remove items from caches.|
|[JMX Management](/documentation/2.8/operations/jmx.html)|As an alternative to the Ehcache Monitor, JMX creates a standard way of instrumenting classes and making them available to a management and monitoring infrastructure.|
|[Logging](/documentation/2.8/operations/logging.html)|Ehcache uses the the slf4j logging facade, so you can plug in your own logging framework. This page also provides recommended logging levels.|
|[Shutting Down Ehcache](/documentation/2.8/operations/shutdown.html)|If you are using persistent disk stores, or distributed caching, care should be taken when shutting down Ehcache. This page covers the ServletContextListener, the shutdown hook, and dirty shutdown.|



## Additional Information about Operations
The following page provides additional information about the Ehcache Monitor:

* [Terracotta Console for Enterprise Ehcache](http://terracotta.org/documentation/2.8/terracotta-tools/dev-console#enterprise-ehcache-applications)
* [Cache Size and Statistics Code Samples](/documentation/2.8/code-samples.html#using-caches)
* [CacheManager Shutdown Code Sample](/documentation/2.8/code-samples.html#shutdown-the-cachemanager)
