---
---
# Using Hibernate and BigMemory Go


 



## Introduction

Big Memory Go easily integrates with the [Hibernate](http://hibernate.org)
Object/Relational persistence and query service. Gavin King, the
maintainer of Hibernate, is also a committer to the BigMemory Go's Ehcache project.
This ensures BigMemory Go will remain a first class data store for Hibernate.
Configuring BigMemory Go for Hibernate is simple.  The basic steps are:

* Download and install BigMemory Go into your project
* Configure BigMemory Go as a cache provider in your project's Hibernate
configuration.
* Configure second-level caching in your project's Hibernate configuration.
* Configure Hibernate caching for each entity, collection, or query
you wish to cache.
* Configure the `ehcache.xml` file as necessary for each entity, collection, or
query configured for caching.

For more information regarding cache configuration in Hibernate see the
[Hibernate](http://www.hibernate.org/)
documentation.


## Download and Install <a name="Downloading-and-Installing-Ehcache"/>

The Hibernate provider is in the ehcache-core module. Download [the latest version](http://sourceforge.net/projects/ehcache/files/ehcache-core) of the Ehcache core module. 

## Build with Maven

Dependency versions vary with the specific kit you intend to use. Since kits are guaranteed
to contain compatible artifacts, find the artifact versions you need by downloading a kit.
Configure or add the following repository to your build (pom.xml):

~~~
<repository>
   <id>terracotta-releases</id>
   <url>http://www.terracotta.org/download/reflector/releases</url>
   <releases><enabled>true</enabled></releases>
   <snapshots><enabled>false</enabled></snapshots>
</repository>
~~~

Configure or add the the Ehcache core module defined
by the following dependency to your build (pom.xml):

~~~
<dependency>
   <groupId>net.sf.ehcache</groupId>
   <artifactId>ehcache-core</artifactId>
   <version>${ehcacheVersion}</version>
</dependency>
~~~

For the Hibernate-Ehcache integration, add the following dependency:

    <dependency>
      <groupId>org.hibernate</groupId>
      <artifactId>hibernate-ehcache</artifactId>
      <version>${hibernateVersion}</version>
    </dependency>

For example, the Hibernate-Ehcache integration dependency for Hibernate 4.0.0 is:

    <dependency>
      <groupId>org.hibernate</groupId>
      <artifactId>hibernate-ehcache</artifactId>
      <version>4.0.0</version>
    </dependency>

**NOTE:** Some versions of hibernate-ehcache may have a dependency on a specific version of Ehcache. Check the hibernate-ehcache POM for more information.


## Configure BigMemory Go as the Second-Level Cache Provider <a name="Configure-Ehcache-as-the-Second-Level-Cache-Provider"/>

To configure BigMemory Go as a Hibernate second-level cache, set the region
factory property to one of the following in the
Hibernate configuration.
Hibernate configuration is configured either via hibernate.cfg.xml,
hibernate.properties or Spring. The format given is for hibernate.cfg.xml.


### Hibernate 3.3 and higher

For instance creation:

~~~
<property name="hibernate.cache.region.factory_class">
         net.sf.ehcache.hibernate.EhCacheRegionFactory</property>
~~~

   To force Hibernate to use a singleton of Ehcache CacheManager:

~~~
<property name="hibernate.cache.region.factory_class">
         net.sf.ehcache.hibernate.SingletonEhCacheRegionFactory</property>
~~~

### Hibernate 4.x
For Hibernate 4, use `org.hibernate.cache.ehcache.EhCacheRegionFactory` instead of `net.sf.ehcache.hibernate.EhCacheRegionFactory` and `org.hibernate.cache.ehcache.SingletonEhCacheRegionFactory` instead of `net.sf.ehcache.hibernate.SingletonEhCacheRegionFactory`.


## Enable Second-Level Cache and Query Cache Settings

In addition to configuring the second-level cache provider setting,
you will need to turn on the second-level cache (by default it is
configured to off - 'false' - by Hibernate). This is done by
setting the following property in your hibernate config:

~~~
<property name="hibernate.cache.use_second_level_cache">true</property>
~~~

You may also want to turn on the Hibernate query cache.  This is done
by setting the following property in your hibernate config:

~~~
<property name="hibernate.cache.use_query_cache">true</property>
~~~

## Optional
The following settings or actions are optional.

### Configuration Resource Name
The `configurationResourceName` property is used to specify the
location of the Ehcache configuration file to be used with the given
Hibernate instance and cache provider/region-factory.
The resource is searched for in the root of the classpath. It is used
to support multiple CacheManagers in the same VM. It tells Hibernate
which configuration to use. An example might be "ehcache-2.xml".
When using multiple Hibernate instances it is therefore recommended
to use multiple non-singleton providers or region factories, each
with a dedicated Ehcache configuration resource.

~~~
net.sf.ehcache.configurationResourceName=/name_of_ehcache.xml
~~~

### Set the Hibernate cache provider programmatically <a name="Set-the-Hibernate-cache-provider-programmatically"/>
The provider can also be set programmatically in Hibernate by adding
necessary Hibernate property settings to the configuration before creating
the SessionFactory:

~~~
Configuration.setProperty("hibernate.cache.region.factory_class",
                     "net.sf.ehcache.hibernate.EhCacheRegionFactory")
~~~

For Hibernate 4, use `org.hibernate.cache.ehcache.EhCacheRegionFactory` instead of `net.sf.ehcache.hibernate.EhCacheRegionFactory`. 


## Putting it all together
If you are enabling both second-level caching
and query caching, then your hibernate config file should contain the
following:

~~~
<property name="hibernate.cache.use_second_level_cache">true</property>
<property name="hibernate.cache.use_query_cache">true</property>
<property name="hibernate.cache.region.factory_class">net.sf.ehcache.hibernate.EhCacheRegionFactory</property>
~~~

An equivalent Spring configuration file would contain:

~~~
<prop key="hibernate.cache.use_second_level_cache">true</prop>
<prop key="hibernate.cache.use_query_cache">true</prop>
<prop key="hibernate.cache.region.factory_class">net.sf.ehcache.hibernate.EhCacheRegionFactory</prop>
~~~

For Hibernate 4, use `org.hibernate.cache.ehcache.EhCacheRegionFactory` instead of `net.sf.ehcache.hibernate.EhCacheRegionFactory`. 


## Configure Hibernate Entities to use Second-Level Caching <a name="Configure-Hibernate-Entities-to-use-Second-Level-Caching"/>
In addition to configuring the Hibernate second-level cache provider, Hibernate must also be told to enable caching for entities, collections, and queries.
For example, to enable cache entries for the domain object
com.somecompany.someproject.domain.Country there would be a mapping file
something like the following:

~~~
<hibernate-mapping>
<class
name="com.somecompany.someproject.domain.Country"
table="ut_Countries"
dynamic-update="false"
dynamic-insert="false"
>
...
</class>
</hibernate-mapping>
~~~

To enable caching, add the following element.

~~~
<cache usage="read-write|nonstrict-read-write|read-only" />
~~~

For example:

~~~
<hibernate-mapping>
<class
name="com.somecompany.someproject.domain.Country"
table="ut_Countries"
dynamic-update="false"
dynamic-insert="false"
>
 <cache usage="read-write" />
...
</class>
</hibernate-mapping>
~~~

This can also be achieved using the @Cache annotation, e.g.

~~~
@Entity
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Country {
...
"/>
~~~

### Definition of the different cache strategies

#### read-only
Caches data that is never updated.

#### nonstrict-read-write
Caches data that is sometimes updated without ever locking the
cache. If concurrent access to an item is possible, this
concurrency strategy makes no guarantee that the item returned
from the cache is the latest version available in the database.
Configure your cache timeout accordingly!

#### read-write
Caches data that is sometimes updated while maintaining the semantics
of "read committed" isolation level. If the database is set to
"repeatable read", this concurrency strategy almost maintains the
semantics. Repeatable read isolation is compromised in the case
of concurrent writes.

## Configure <a name="ehcache-xml"/>
Because the `ehcache.xml` file has a defaultCache, caches will always be created
when required by Hibernate. However more control can be exerted by
specifying a configuration per cache, based on its name.
In particular, because Hibernate caches are populated from databases,
there is potential for them to get very large. This can be controlled
by capping their maxEntriesLocalHeap and specifying whether to swap to disk beyond that.
Hibernate uses a specific convention for the naming of caches of Domain
Objects, Collections, and Queries.

### Domain Objects
Hibernate creates caches named after the fully qualified name of Domain
Objects.
So, for example to create a cache for com.somecompany.someproject.domain.Country create a cache configuration
entry similar to the following in ehcache.xml.

~~~
    <?xml version="1.0" encoding="UTF-8"?>
<ehcache>
 <cache
	name="com.somecompany.someproject.domain.Country"
	maxEntriesLocalHeap="10000"
	eternal="false"
	timeToIdleSeconds="300"
	timeToLiveSeconds="600"
    <persistence strategy="localTempSwap"/>
 />
</ehcache>
~~~

#### Hibernate CacheConcurrencyStrategy
read-write, nonstrict-read-write and read-only policies apply to Domain
Objects.

### Collections
Hibernate creates collection caches named after the fully qualified
name of the Domain Object followed by "." followed by the collection
field name.
For example, a Country domain object has a set of
advancedSearchFacilities. The Hibernate doclet for the accessor
looks like:

~~~
/**
* Returns the advanced search facilities that should appear for this country.
* @hibernate.set cascade="all" inverse="true"
* @hibernate.collection-key column="COUNTRY_ID"
* @hibernate.collection-one-to-many class="com.wotif.jaguar.domain.AdvancedSearchFacility"
* @hibernate.cache usage="read-write"
*/
public Set getAdvancedSearchFacilities() {
return advancedSearchFacilities;
"/>
~~~

You need an additional cache configured for the set. The ehcache.xml configuration looks like:

~~~
    <?xml version="1.0" encoding="UTF-8"?>
<ehcache>
 <cache name="com.somecompany.someproject.domain.Country"
	maxEntriesLocalHeap="50"
	eternal="false"
	timeToLiveSeconds="600"
    <persistence strategy="localTempSwap"/>
/>
 <cache
name="com.somecompany.someproject.domain.Country.advancedSearchFacilities"
	maxEntriesLocalHeap="450"
	eternal="false"
	timeToLiveSeconds="600"
    <persistence strategy="localTempSwap"/>
/>
</ehcache>
~~~

#### Hibernate CacheConcurrencyStrategy
read-write, nonstrict-read-write and read-only policies apply to Domain
Object collections.

### Queries
Hibernate allows the caching of query results using two caches.

#### StandardQueryCache
This cache is used if you use a query cache without setting a
name. A typical ehcache.xml configuration is:

~~~
<cache
name="org.hibernate.cache.StandardQueryCache"
maxEntriesLocalHeap="5"
eternal="false"
timeToLiveSeconds="120"
<persistence strategy="localTempSwap"/>
/>
~~~

#### UpdateTimestampsCache
Tracks the timestamps of the most recent updates to particular tables.
It is important that the cache timeout of the underlying cache
implementation be set to a higher value than the timeouts of any of the
query caches. In fact, it is recommend that the the underlying cache
not be configured for expiry at all.
A typical ehcache.xml configuration is:

~~~
<cache
name="org.hibernate.cache.UpdateTimestampsCache"
maxEntriesLocalHeap="5000"
eternal="true"
<persistence strategy="localTempSwap"/>
/>
~~~

#### Named Query Caches
In addition, a QueryCache can be given a specific name in Hibernate
using Query.setCacheRegion(String name). The name of the cache in
ehcache.xml is then the name given in that method. The name can be
whatever you want, but by convention you should use "query." followed
by a descriptive name.
E.g.

~~~
<cache name="query.AdministrativeAreasPerCountry"
maxEntriesLocalHeap="5"
eternal="false"
timeToLiveSeconds="86400"
<persistence strategy="localTempSwap"/>
/>
~~~

#### Using Query Caches
For example, let's say we have a common query running against the
Country Domain.
Code to use a query cache follows:

~~~
public List getStreetTypes(final Country country) throws HibernateException {
final Session session = createSession();
try {
   final Query query = session.createQuery(
    "select st.id, st.name"
   + " from StreetType st "
   + " where st.country.id = :countryId "
   + " order by st.sortOrder desc, st.name");
   query.setLong("countryId", country.getId().longValue());
   query.setCacheable(true);
   query.setCacheRegion("query.StreetTypes");
   return query.list();
} finally {
   session.close();
"/>
"/>
~~~

The `query.setCacheable(true)` line caches the query.
The `query.setCacheRegion("query.StreetTypes")` line sets the name of the Query Cache.
Alex Miller has a good article on the query cache
[here](http://tech.puredanger.com/2009/07/10/hibernate-query-cache/).

#### Hibernate CacheConcurrencyStrategy
None of read-write, nonstrict-read-write and read-only policies apply
to Domain Objects. Cache policies are not configurable for query cache.
They act like a non-locking read only cache.

## Demo App <a name="demo-apps"/>
We have  demo application showing how to use the Hibernate CacheRegionFactory.

### Hibernate Tutorial
Check out from the [Terracotta Forge](http://svn.terracotta.org/svn/forge/projects/hibernate-tutorial-web/trunk). 

## Performance Tips <a name="Performance-Tips"/>

### Session.load
`Session.load` will always try to use the cache.

### Session.find and Query.find
`Session.find` does not use the cache for the primary object. Hibernate
will try to use the cache for any associated objects. `Session.find` does
however cause the cache to be populated.
`Query.find` works in exactly the same way.
Use these where the chance of getting a cache hit is low.

### Session.iterate and Query.iterate
`Session.iterate` always uses the cache for the primary object and any
associated objects.
`Query.iterate` works in exactly the same way.
Use these where the chance of getting a cache hit is high.


## FAQ

### If I'm using BigMemory Go with my app and with Hibernate for second-level caching, should I try to use the CacheManager created by Hibernate for my app's caches?

While you could share the resource file between the two CacheManagers, a clear separation between the two is recommended. Your app may have a different lifecycle than Hibernate, and in each case your CacheManager [Automatic Resource Control (ARC)](/documentation/2.7/bigmemorygo/get-started#configuring-bigmemory-go) settings may need to be different.

### Should I use the provider in the Hibernate distribution or in BigMemory Go's Ehcache?
Since Hibernate 2.1, Hibernate has included an Ehcache `CacheProvider`. That provider
is periodically synced up with the provider in the Ehcache Core distribution. New
features are generally added in to the Ehcache Core provider and then the Hibernate one.

### What is the relationship between the Hibernate and Ehcache projects?
Gavin King and Greg Luck cooperated to create Ehcache and include it in Hibernate. Since
2009, Greg Luck has been a committer on the Hibernate project so as to ensure Ehcache
remains a first-class 2nd level cache for Hibernate.

### Does BigMemory Go support the transactional strategy?
Yes. It was introduced in Ehcache 2.1.

### Why do certain caches sometimes get automatically cleared by Hibernate?
Whenever a `Query.executeUpdate()` is run, for example, Hibernate invalidates affected cache regions (those corresponding to affected database tables) to ensure that no data stale data is cached. This should also happen whenever stored procedures are executed.

For more information, see this [Hibernate bug report](https://hibernate.onjira.com/browse/HHH-2224).


### How are Hibernate Entities keyed?
Hibernate identifies cached Entities via an object id. This is normally
the primary key of a database row.

### Are compound keys supported?
Yes.

### I am getting this error message: An item was expired by the cache while it was locked. What is it?
Soft locks are implemented by replacing a value with a special type that marks the element as locked, thus indicating
to other threads to treat it differently to a normal element.  This is used in the Hibernate Read/Write strategy to
force fall-through to the database during the two-phase commit - since we don't know exactly what should be returned by
the cache while the commit is in process (but the database does).
If a soft-locked Element is evicted by the cache during the two-phase commit, then once the two-phase commit completes, the
cache will fail to update (since the soft-locked Element was evicted) and the cache entry will be reloaded from the database
on the next read of that object.  This is obviously non-fatal, but could cause a small rise in database load.

So, in summary the Hibernate messages are not problematic.
The underlying cause is the probabilistic evictor can theoretically evict recently loaded items. You can also use the deterministic evictor to avoid this problem. Specify the `java -Dnet.sf.ehcache.use.classic.lru=true`
system property to turn on classic LRU which contains a deterministic evictor.


