---
---
# Terracotta Distributed Ehcache WAN Replication

 

## Introduction
WAN replication allows data to remain in sync across clusters connected by a WAN link. For example, geographically remote data centers can use WAN replication to maintain consistent views of data.

![Terracotta Distributed Ehcache WAN Replication of 2 Data Centers](/images/documentation/wan-replication.png)

Terracotta Distributed Ehcache WAN Replication integrates with your application simply through Ehcache configuration. While your application continues to use Terracotta Distributed Ehcache as before, caches marked for WAN replication are automatically synchronized across the WAN link. Other advantages include:

* Message buffering
* Conflict resolution
* Failover
* Supports topics and queues
* Asynchronous delivery to maximize performance
* Guaranteed message delivery (no data loss)
* Scaling (both at the local cluster and in number of WAN-linked clusters)
* Multiple types of toplogies supported
* A flexible API allowing for customized components to replace the ones provided

These configuration-based components are designed to get WAN integration up and running quickly. 

## Cache Replication Scope

The following cache operations are replicated:

* put (including updates)
* remove
* removeAll

## Requirements

The following components are required:

* JDK 1.6 (latest version)
* Terracotta Enterprise Kit version 3.5.0 or higher
* Apache ActiveMQ 5.4.2 or another JMS implementation

    Contact your Terracotta representative for more information on using WebSphereMQ. Other JMS implementations should be tested thoroughly before production use.
    
* Ehcache WAN-replication JAR

    Obtain this JAR from your Terracotta representative.

Terracotta Distributed Ehcache allows per-cache WAN replication using clustered caches and the Java Message Service (JMS). Ehcache-based applications can use Terracotta Distributed Ehcache WAN Replication to sync caches if 

* the application is running in two or more locations, and
* those locations communicate over a WAN link, and
* at least one cache is consistent in at least two of those locations.

Only consistent caches can participate in Terracotta Distributed Ehcache WAN Replication.

## Setting Up WAN Replication

To set up Terracotta Distributed Ehcache WAN Replication, follow these steps:

1. Ensure that the Terracotta clusters that will use WAN replication can run as expected without WAN replication.

    See the [installation instructions for Terracotta Distributed Enterprise Ehcache](http://terracotta.org/documentation/enterprise-ehcache/installation-guide) for more information on installing a cluster.

2. Install and configure a JMS implementation for each Terracotta cluster.

    The JMS provider can be run on any of the nodes in the cluster, or on its own host.

    [Download](http://activemq.apache.org) and install one instance of Apache ActiveMQ 5.4.2. Only one instance of ActiveMQ is required per cluster. However, you must make the ActiveMQ classes available to every Terracotta client on each Terracotta cluster that participates in the WAN replication. To do this, copy `activemq-all-5.3.2.jar` from the ActiveMQ distribution to a location on the classpath of each client application or to `WEB-INF/lib` if using a WAR file.
    
3. Install the WAN-replication JAR in the following path:

    
    **UNIX/LINUX**
    
        ${TERRACOTTA_HOME}/ehcache/ehcache-wanreplication-<version>.jar
        
    **MICROSOFT WINDOWS**
    
        %TERRACOTTA_HOME%\ehcache\ehcache-wanreplication-<version>.jar

4. Configure CacheManagers that will participate in WAN replication.

    CacheManagers managing at least one cache that will be replicated across the WAN must be configured. See [Configuring the CacheManager](#configuring-the-cachemanager).

5. Configure caches that will be replicated across the WAN.

    See Configuring the Caches.
    
6. Ensure that a reliable WAN link exists between all target clusters.

7. On each cluster, start the JMS provider and the Terracotta server before starting the clients.

    To run ActiveMQ, issue the following command from the ActiveMQ home directory:
    
    **UNIX/LINUX**
    
        [PROMPT] nohup bin/activemq > /tmp/smlog 2>&1

    **MICROSOFT WINDOWS**
    
        [PROMPT] bin\activemq

    In Microsoft Windows, you can also run ActiveMQ as a Windows service (using a Java service wrapper). See [Apache ActiveMQ](http://activemq.apache.org) for more information.

Your clusters should now be able to replicate caches across the WAN link.

## Configuring the CacheManager

An application integrated with Ehcache has at least one CacheManager configured. If any of the caches managed by a CacheManager should be replicated over the WAN, that CacheManager must be able to participate in WAN replication.

You configure a CacheManager to participate in WAN replication by adding the element `<cacheManagerPeerProviderFactory>` along with a set of properties that specify connection and message-delivery details. The following is an example of a `<cacheManagerPeerProviderFactory>` block using ActiveMQ as a JMS provider and configuring a queue-based architecture:

    <cacheManagerPeerProviderFactory
      class="net.sf.ehcache.distribution.wan.jms. JMSCacheManagerPeerProviderFactory"
      properties="initialContextFactoryName=org.apache.activemq.jdi.    
            ActiveMQInitialContextFactory,
        destinationType=queue,
        noOfReadDestinations=1,
        noOfWriteDestinations=1,
        writeProviderURL=nio://localhost:61616,
        readProviderURL=nio://10.0.4.201:61616,
        writeDestinationBindingName=dynamicQueues/queue2,
        readDestinationBindingName=dynamicQueues/queue2,
        writeDestinationConnectionFactoryBindingName=ConnectionFactory,
        readDestinationConnectionFactoryBindingName=ConnectionFactory,
        acknowledgementMode=CLIENT_ACKNOWLEDGE,
        persistent=true,
        pooledConnectionFactoryProvider=net.sf.ehcache.distribution.wan.jms.
            AmqPooledConnectionFactoryProvider,
        poolMaxConnections=10,
        poolIdleTimeout=5000,
        consumerThreads=1,
        resourceCaching=CONSUMER"
        conflictResolver=net.sf.ehcache.distribution.wan.jms.
            TimeBasedConflictResolver"
      propertySeparator=","/>
      

For topic-based architecture, certain properties must be set as shown:

    ...
    destinationType=topic,
    writeDestinationBindingName=dynamicTopics/topic1,
    readDestinationBindingName=dynamicTopics/topic2,
    ...

`<cacheManagerPeerProviderFactory>` has two attributes:

* class &ndash; A factory class that provides CacheManagerPeerProvider instances. In this case, the value is a class (found in the ehcache-wanreplication JAR file) that creates peers supporting JMS. REQUIRED.
* properties &ndash; Properties that set up the queuing service.

The following table defines the available properties:

<table markdown="1">
<tr><th>Property</th><th>Definition</th></tr>
<tr><td>initialContextFactoryName</td>
<td>A class, typically provided by the application, that initializes the context to a given JMS provider. The value in this case is a factory class that extends org.apache.activemq.jndi.ActiveMQInitialContextFactory.</td></tr>
<tr><td>destinationType</td><td>TDetermines whether a queue or a topic architecture is used.</td></tr>
<tr><td>noOfReadDestinations</td><td>The number of content sources that will be read from. These sources are other clusters with similar JMS implementations.</td></tr>
<tr><td>noOfWriteDestinations</td><td>The number of content targets that will be written to. These are the queues or topics that the local cluster writes to.</td></tr>
<tr><td>writeProviderURL</td><td>URL where the write queueing service is available (used in loading the initial context). The value `localhost` reflects the fact that the writes are on the same host.</td></tr>
<tr><td>readProviderURL</td><td>URL for the source where the read queueing service is available (used in loading the initial context).</td></tr>
<tr><td>writeDestinationBindingName</td><td>The JNDI binding name for the write queue or topic.</td></tr>
<tr><td>readDestinationBindingName</td><td>The JNDI binding name for the read queue or topic.</td></tr>
<tr><td>writeDestinationConnectionFactoryBindingName</td><td>The JNDI binding names for the write QueueConnectionFactory or the TopicConnectionFactory.</td></tr>
<tr><td>readDestinationConnectionFactoryBindingName</td><td>The JNDI binding names for the read QueueConnectionFactory or the TopicConnectionFactory.</td></tr>
<tr><td>acknowledgementMode</td><td>Sets how the messaging system is informed that a message has been received. `CLIENT_ACKNOWLEDGE` is the value used where guaranteed message delivery is required.</td></tr>
<tr><td>persistent</td><td>Boolean value that sets whether messages should be persisted during interruptions or disruptions to service. Use `true` where guaranteed message delivery is required.</td></tr>
<tr><td>pooledConnectionFactoryProvider</td><td>The class that provides the connection pool.</td></tr>
<tr><td>poolMaxConnections</td><td>The maximum number of connections the connection pool can make available. Improves performance at the cost of memory and other overhead.</td></tr>
<tr><td>poolIdleTimeout</td><td>The maximum number of milliseconds the application waits for a connection before timing out.</td></tr>
<tr><td>consumerThreads</td><td>The number of consumer threads in the messaging service.</td></tr>
<tr><td>resourceCaching</td><td>The location of cached resources. Resources are cached to improve performance. The default value is `CONSUMER`.</td></tr>
<tr><td>conflictResolver</td><td>The class defining the method of resolution for  conflicts between existing copies of the same data (a put cache Element). Time and version-based methods relying on Ehcache Element metadata are provided. A custom resolver can be used.</td></tr>
<tr><td>propertySeparator</td><td>The designated delimiter for properties in the `properties` attribute.</td></tr>
</table>


Note that for properties whose values are classnames, the fully qualified name of the class is required.


## Configuring the Caches
A clustered cache is configured for clustering with Terracotta by adding a `<terracotta>` element to that cache’s `<cache>` block in the Terracotta Distributed Ehcache configuration file. For example, the following cache is configured for clustering:

    <cache name="Foo" eternal="false" timeToIdleSeconds="3600" timeToLiveSeconds="0" memoryStoreEvictionPolicy="LFU">
      <!-- Adding the element <terracotta /> turns on Terracotta clustering for the cache Foo. -->
      <terracotta />
    </cache>

Clustered caches can be configured for WAN replication by adding a `<cacheEventListenerFactory>` subelement to the cache’s `<cache>` block:

    <cache name="Foo" eternal="false" timeToIdleSeconds="3600"   
        timeToLiveSeconds="0" memoryStoreEvictionPolicy="LFU">
      <terracotta />
      <!-- If <terracotta /> exists, adding <cacheEventListenerFactory> turns on
           WAN replication for Foo. -->
      <cacheEventListenerFactory
        class="net.sf.ehcache.distribution.wan.jms.JMSCacheReplicatorFactory" properties="replicateAsynchronously=true,
        replicatePuts=true,
        replicateUpdates=true,
        replicateUpdatesViaCopy=true,
        replicateRemovals=true, conflationEnabled=true, asynchronousReplicationIntervalMillis=30000,
        propertySeparator=","/>
    </cache>

`<cacheEventListenerFactory>` has two attributes:

* class – A factory class that provides CacheEventListener instances. In this case, the value is a class (found in the ehcache-wanreplication JAR file) that creates listeners supporting JMS.
* properties – Properties that configure the replication.

The following table defines the available properties:

<table markdown="1">
<tr><th>Property</th><th>Definition</th></tr>
<tr><td>replicateAsynchronously</td><td>Asynchronous replication ("true") delivers events to a message buffer, from which delivery to the JMS provider takes place. Synchronous replication ("false") causes application threads to deliver events to the JMS provider directly. Asynchronous replication is the recommended mode because it yields better performance, as application threads do not block while delivering messages to the JMS provider.</td></tr>
<tr><td>replicatePuts</td><td>Set to "true" if puts to the cache should be replicated instead of ignored ("false").</td></tr>
<tr><td>replicateUpdates</td><td>Set to "true" if an overridden (replaced) cache element should cause invalidation (resulting in updates) of remote elements having the same key, or should be ignored ("false") by remote caches.</td></tr>
<tr><td>replicateUpdatesViaCopy</td><td>Set to "true" if updates to the cache should be copied to remote caches instead of removed from those caches ("false").</td></tr>
<tr><td>replicateRemovals</td><td>Set to "true" if explicit element removals (not expirations) should be replicated instead of ignored ("false").</td></tr>
<tr><td>asynchronousReplicationIntervalMillis</td><td>The poll interval to check if a JMS message transmission is necessary. In effect only if replicateAsynchronously=true.</td></tr>
<tr><td>propertySeparator</td><td>The character used to delimit the properties.</td></tr>
</table>

## Other Options for WAN Replication Topologies

Terracotta Distributed Ehcache WAN Replication is a flexible solution supporting a number of complex topologies, including:

* Master-Slave
* Multi-Site
* Gateways

To learn more about using Terracotta Distributed Ehcache WAN Replication in your architecture, contact your Terracotta representative.

For a discussion on simple WAN replication setups, see [Strategies For Setting Up WAN Replication](/documentation/recipes/wan).
