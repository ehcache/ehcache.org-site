---
---
# Key Classes and Methods 
 


## Introduction

Ehcache consists of a `CacheManager`, which manages caches. Caches contain Elements,
which are essentially name value pairs. Caches are physically implemented, either in-memory or on disk. The logical representations of these components are actualized mostly through the classes discussed below. The methods provided by these classes are largely responsible for providing programmatic access to working with Ehcache.

### CacheManager 

Creation of, access to, and removal of caches is controlled by the `CacheManager`.

#### CacheManager Creation Modes <a name="cm-creation"/>

`CacheManager` supports two creation modes: singleton and instance.

Versions of Ehcache before version 2.5 allowed any number of CacheManagers with the same name (same configuration resource) to exist in a JVM. Therefore, each time `new CacheManager(...)` was called, a new CacheManager was created without regard to existing CacheManagers. Calling `CacheManager.create(...)` returned the existing singleton CacheManager with the configured name (if it existed) or created the singleton based on the passed-in configuration.

Ehcache 2.5 and higher does not allow multiple CacheManagers with the same name to exist in the same JVM. `CacheManager()` constructors creating non-Singleton CacheManagers can violate this rule, causing a NullPointerException. If your code may create multiple CacheManagers of the same name in the same JVM, avoid this error by using the [static `CacheManager.create()` methods](http://ehcache.org/apidocs/2.6.9/net/sf/ehcache/CacheManager), which always return the named (or default unnamed) CacheManager if it already exists in that JVM. If the named (or default unnamed) CacheManager does not exist, the `CacheManager.create()` methods create it.

NOTE: In Ehcache 2.5.0/2.5.1 `Cachemanager.create(...)` gets or creates the CacheManager regardless of whether it is a singleton or not. In Ehcache 2.5.2, calling `CacheManager.create(...)` returns the existing singleton CacheManager with the configured name (if it exists) or creates the singleton based on the passed-in configuration.

Ehcache 2.5.2 introduced the `CacheManager.newInstance(...)` method, which parses the passed-in configuration to either get the existing named CacheManager or create that CacheManager if it doesn't exist.

With Ehcache 2.5.2 and higher, the behavior of the CacheManager creation methods is as follows:

* `CacheManager.newInstance(Configuration configuration)` &ndash; Create a new CacheManager or return the existing one named in the configuration.
* `CacheManager.create()` &ndash; Create a new singleton CacheManager with default configuration, or return the existing singleton. This is the same as `CacheManager.getInstance()`.
* `CacheManager.create(Configuration configuration)` &ndash; Create a singleton CacheManager with the passed-in configuration, or return the existing singleton.
* `new CacheManager(Configuration configuration)` &ndash; Create a new CacheManager, or throw an exception if the CacheManager named in the configuration already exists or if the parameter (configuration) is null.

See the [Ehcache API documentation](http://ehcache.org/apidocs/2.6.9/net/sf/ehcache/CacheManager) for more information on these methods, including options for passing in configuration. For examples, see [Code Samples](/documentation/2.6/code-samples#Using-the-CacheManager).

##### Singleton Mode

Ehcache-1.1 supported only one `CacheManager` instance which was a singleton. CacheManager can still be used in this way using the static factory methods.

##### Instance Mode

From ehcache-1.2, CacheManager has constructors which mirror the
various static create methods. This enables multiple CacheManagers to
be created and used concurrently. Each CacheManager requires its own
configuration.

If the Caches under management use only the MemoryStore, there
are no special considerations. If Caches use the DiskStore, the
diskStore path specified in each CacheManager configuration should be
unique. When a new CacheManager is created, a check is made that there
are no other CacheManagers using the same diskStore path. If there are,
a CacheException is thrown. If a CacheManager is part of a cluster,
there will also be listener ports which must be unique.

##### Mixed Singleton and Instance Mode

If an application creates instances of CacheManager using a
constructor, and also calls a static create method, there will exist a
singleton instance of CacheManager which will be returned each time the
create method is called together with any other instances created via
constructor. The two types will coexist peacefully.

### Ehcache

All caches implement the `Ehcache` interface. A cache has a name and attributes. Each cache contains Elements.

A Cache in Ehcache is analogous to a cache region in other caching systems.

Cache elements are stored in the `MemoryStore`. Optionally they also overflow to a `DiskStore`.

### Element

An element is an atomic entry in a cache. It has a key, a value and a record of
accesses. Elements are put into and removed from caches. They can also
expire and be removed by the Cache, depending on the Cache settings.

As of ehcache-1.2 there is an API for Objects in addition to the one for Serializable. Non-serializable Objects can
use all parts of Ehcache except for DiskStore and replication. If an attempt is made to persist or replicate them
they are discarded without error and with a DEBUG level log message.

The APIs are identical except for the return methods from Element. Two new methods on
Element: getObjectValue and getKeyValue are the only API differences between the Serializable and Object APIs. This
makes it very easy to start with caching Objects and then change your Objects to Seralizable to participate in
the extra features when needed. Also a large number of Java classes are simply not Serializable.

