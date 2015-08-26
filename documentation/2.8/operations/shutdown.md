---
---
# Shutting Down Ehcache <a name="Shutting-Down-Ehcache"/>

 

## Introduction
If you are using persistent disk stores (Open Source), or distributed caching, care should be taken to shutdown Ehcache.
Note that Hibernate automatically shuts down its Ehcache `CacheManager`.
The recommended way to shutdown the Ehcache is:

* to call `CacheManager.shutdown()`
* in a web app, register the Ehcache `ShutdownListener`

Though not recommended, Ehcache also lets you register a JVM shutdown hook.

## ServletContextListener
Ehcache proivdes a ServletContextListener that shutsdown CacheManager. Use this when you want to shutdown
Ehcache automatically when the web application is shutdown.
To receive notification events, this class must be configured in the deployment
descriptor for the web application.
To do so, add the following to web.xml in your web application:

    <listener>
      <listener-class>net.sf.ehcache.constructs.web.ShutdownListener</listener-class>
    </listener>

## The Shutdown Hook
Ehcache CacheManager can optionally register a shutdown hook.
To do so, set the system property `net.sf.ehcache.enableShutdownHook=true`.
This will shutdown the CacheManager when it detects the Virtual Machine shutting down and
it is not already shut down.

Use the shutdown hook where:

*   you need guaranteed orderly shutdown, when for example using persistent disk stores,
   or distributed caching.
*   the CacheManager is not already being shutdown by a framework you are using or by your application.

**Note**: Shutdown hooks are inherently problematic. The JVM is shutting down, so sometimes things that can never be null are. Ehcache guards against as many of these as it can, but the shutdown hook should be the last option to use.

The shutdown hook is on CacheManager and simply calls the shutdown method.
The sequence of events is:

*   call dispose for each registered CacheManager event listener.
*   call dispose for each Cache.

    Each Cache will:
*   shutdown the MemoryStore. The MemoryStore will flush to the DiskStore.
*   shutdown the DiskStore. If the DiskStore is persistent, it will write the entries and index to disk.
*   shutdown each registered CacheEventListener.
*   set the Cache status to shutdown, preventing any further operations on it.
*   set the CacheManager status to shutdown, preventing any further operations on it.

The shutdown hook runs when:

* A program exists normally. For example,  `System.exit()` is called, or the last non-daemon thread exits.
* the Virtual Machine is terminated. e.g. CTRL-C. This corresponds to `kill -SIGTERM pid` or `kill -15 pid` on Unix systems.

The shutdown hook will not run when:

* the Virtual Machine aborts
* A SIGKILL signal is sent to the Virtual Machine process on Unix
systems. e.g. `kill -SIGKILL pid` or `kill -9 pid`
* A `TerminateProcess` call is sent to the process on Windows systems.

## Dirty Shutdown
If shut down dirty, all in-memory data will be retained if Ehcache is configured for restartability. For more information, refer to [Persistence and Restartability](/documentation/2.8/configuration/fast-restart).

If using Open Source disk persistence when shut down dirty, then any persistent disk stores will be corrupted. They will be deleted, with a log message, on the next startup.
Replications waiting to happen to other nodes in a distributed cache will also not get written.
