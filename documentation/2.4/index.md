---
---
# Ehcache 2.4 Documentation

The following sections describe some of the topics covered in Ehcache documentation.

If you are new to caching, start with the following pages:

* [Introduction to caching](/documentation/user-guide/introduction)
* [Concepts in caching](/documentation/user-guide/concepts)
* [Code samples](/documentation/recipes/)

Ehcache documentation is also available in a [Single Page PDF User Guide](/files/documentation/EhcacheUserGuide.pdf).

## A Distributed or Replicated Cache?
If your application node share cached data, and you evaluating distribution versus replication, see this page on [cache topologies](/documentation/user-guide/cache-topologies).


## Integrating Ehcache

**NOTE:** Some containers and frameworks have a built-in dependency on earlier versions of Ehcache and may have out-of-date Ehcache in their classpath. In this case, an older version of Ehcache may actually be loaded at runtime, which can cause ClassNotFound and other errors.

* [Hibernate](/documentation/user-guide/hibernate)
* [Coldfusion](/documentation/user-guide/coldfusion)
* Containers ([Tomcat](/documentation/user-guide/tomcat), [Glassfish](/documentation/user-guide/glassfish))
* [Grails](/documentation/user-guide/grails)
* [Ruby](/documentation/user-guide/jruby) (Rails and JRuby)
* [Transactional Environments (JTA)](/documentation/user-guide/jta)
* [Google App Engine](/documentation/user-guide/googleappengine)


## Improving Performance and Troubleshooting

* [GC Tuning](/documentation/user-guide/garbage-collection)
* [Logging](/documentation/user-guide/logging)
* [RMI Debugger](/documentation/user-guide/remotedebugger)
