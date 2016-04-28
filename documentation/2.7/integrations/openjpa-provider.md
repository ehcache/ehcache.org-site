---
---
# OpenJPA Caching Provider <a name="openjpa-caching-provider"/>

 

## Introduction
Ehcache easily integrates with the [OpenJPA](http://openjpa.apache.org/) persistence framework. This page provides installation and configuration information.

## Installation
To use OpenJPA, add a Maven dependency for ehcache-openjpa.

~~~ xml
<groupId>net.sf.ehcache</groupId>
<artifactId>ehcache-openjpa</artifactId>
<version>0.1</version>
~~~

Or, download from [Downloads](http://ehcache.org/downloads/catalog).

## Configuration
 For enabling Ehcache as second level cache, the persistence.xml file should include the following configurations:

~~~ xml
<property name="openjpa.Log" value="SQL=TRACE" /> 
<property name="openjpa.QueryCache" value="ehcache" /> 
<property name="openjpa.DataCache" value="true"/> 
<property name="openjpa.RemoteCommitProvider" value="sjvm"/> 
<property name="openjpa.DataCacheManager" value="ehcache" /> 
~~~

The ehcache.xml file can be configured like this example:

~~~ xml
<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="ehcache.xsd" updateCheck="false" monitoring="autodetect" 
 	dynamicConfig="true" name="TestCache">
  <diskStore path="/path/to/store/data"/>

  <defaultCache 
      maxEntriesLocalHeap="10000" 
      eternal="false" 
      timeToIdleSeconds="120" 
      timeToLiveSeconds="120" 
      memoryStoreEvictionPolicy="LRU"> 
    <persistence strategy="localTempSwap"/>
  </defaultCache>

  <cache name="com.terracotta.domain.DataTest"
      maxEntriesLocalHeap="200" 
      eternal="false" 
      timeToIdleSeconds="2400" 
      timeToLiveSeconds="2400"
      memoryStoreEvictionPolicy="LRU">	
  </cache>

  <cache name="openjpa"
      maxEntriesLocalHeap="20000" 
      eternal="true" 
      memoryStoreEvictionPolicy="LRU">	
  </cache>

  <cache name="openjpa-querycache"
      maxEntriesLocalHeap="20000" 
      eternal="true" 
      memoryStoreEvictionPolicy="LRU">	
  </cache>

  <cacheManagerPeerListenerFactory
      class="org.terracotta.ehcachedx.monitor.probe.ProbePeerListenerFactory"
      properties="monitorAddress=localhost, monitorPort=9889, memoryMeasurement=true" />
</ehcache>
~~~


## Default Cache
As with Hibernate, Ehcache's OpenJPA module (from 0.2) uses the `defaultCache` configured in ehcache.xml
to create caches.
For production, we recommend configuring a cache configuration in ehcache.xml for each cache, so that
it may be correctly tuned.

## Troubleshooting

To verify that that OpenJPA is using Ehcache:

* look for hits/misses in the [Ehcache monitor](/documentation/2.7/operations/monitor)
* view the SQL Trace to find out whether it queries the database 

If there are still problems, verify in the logs and that your ehcache.xml file is being used. (It could be that if the ehcache.xml file is not found, ehcache-failsafe.xml is used by default.) 

## For Further Information
For more on caching in OpenJPA, refer to the [Apache OpenJPA project](http://openjpa.apache.org/builds/1.0.2/apache-openjpa-1.0.2/docs/manual/ref_guide_caching.html).
