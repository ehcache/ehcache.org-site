---
---
# Getting Started

 

First, if you haven't yet, [download Ehcache&nbsp;&rsaquo;](/downloads)

Ehcache can be used directly. It can also be used with the popular Hibernate Object/Relational tool. Finally, it
can be used for Java EE Servlet Caching.
This quick guide gets you started on each of these. The rest of the documentation can be explored for a deeper
understanding.

## General Purpose Caching

* Make sure you are using a supported [Java](./dependencies#java) version.
* Place the Ehcache jar into your classpath.
* Ensure that any libraries required to satisfy [dependencies](./dependencies) are also in the classpath.
* Configure ehcache.xml and place it in your classpath.
* Optionally, configure an appropriate [logging](./logging) level.
  See the [Code Samples](../recipes) chapter for more information on direct interaction with ehcache.

## Hibernate

* Perform the same steps as for general purpose caching (above).
* Create caches in ehcache.xml.

See the [Hibernate Caching](./hibernate) chapter for more information.

## Distributed Caching

Ehcache supports distributed caching with two lines of configuration. 

* Download the [ehcache-distribution package&nbsp;&rsaquo;](/downloads)
* Add ehcache-core jar to your classpath
* Add ehcache-terracotta jar to your classpath
* Add a 'terracotta' element to your 'cache' stanza(s) in ehcache.xml
* Add a 'terracottaConfig' element to your 'ehcache' stanza in ehcache.xml.
* See the [Distributed Caching With Terracotta](../terracotta/distributed-caching-with-terracotta) chapter for more information.

## Java EE Servlet Caching

* Perform the same steps as for general purpose caching above.
* Configure a cache for your web page in ehcache.xml.
* To cache an entire web page, either use SimplePageCachingFilter or create your own subclass of CachingFilter
* To cache a jsp:Include or anything callable from a RequestDispatcher, either use SimplePageFragmentCachingFilter
or create a subclass of PageFragmentCachingFilter.
* Configure the web.xml. Declare the filters created above and create filter mapping associating the filter with
a URL.

See the [Web Caching](./web-caching) chapter for more information.

## RESTful and SOAP Caching with the Cache Server

* Download the ehcache-standalone-server from [https://sourceforge.net/projects/ehcache/files/ehcache-server](https://sourceforge.net/projects/ehcache/files/ehcache-server).
* cd to the bin directory
* Type `startup.sh` to start the server with the log in the foreground.
  By default it will listen on port 8080,
 will have both RESTful and SOAP web services enabled, and will use a sample Ehcache configuration from the WAR module.
* See the [code samples](./cache-server#restful-code-samples) in the Cache Server chapter. You can use Java or any other programming language to the use the Cache Server.

See the [Cache Server](./cache-server) chapter for more information.

## JCache style caching

Ehcache contains an early draft implementation of JCache contained in the net.sf.ehcache.jcache package.
See the [JSR107](./jsr107) chapter for usage. 

## Spring, Cocoon, Acegi and other frameworks

Usually, with these, you are using Ehcache without even realising it. The first steps in getting more control over what is happening are:

* discover the cache names used by the framework
* create your own ehcache.xml with settings for the caches and place it in the application classpath.
