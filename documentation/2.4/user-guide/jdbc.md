---
---
# JDBC Caching <a name="JDBC-Caching"/>
 

Ehcache can easily be combined with your existing JDBC code.  Whether
you access JDBC directly, or have a DAO/DAL layer, Ehcache can be 
combined with your existing data access pattern to speed up frequently 
accessed data to reduce page load times, improve performance, and 
reduce load from your database.

This document discusses how to add caching to a JDBC application using
the commonly used DAO/DAL layer patterns:

## Adding JDBC caching to a DAO/DAL layer

If your application already has a DAO/DAL layer, this is a natural place
to add caching.  To add caching, follow these steps:

* identify methods which can be cached
* instantiate a cache and add a member variable to your DAO to hold a reference to it
* Put and get values from the cache

### Identifying methods which can be cached

Normally, you will want to cache the following kinds of method calls:

* Any method which retrieves entities by an Id
* Any queries which can be tolerate some inconsistent or out of date data

Example methods that are commonly cacheable:

<pre>
public V getById(final K id);
public Collection<V> findXXX(...);
</pre>

### Instantiate a cache and add a member variable

Your DAO is probably already being managed by Spring or Guice, so simply 
add a setter method to your DAO layer such as `setCache(Cache cache)`.
Configure the cache as a bean in your Spring or Guice config, and then 
use the the frameworks injection methodology to inject an instance of 
the cache.

If you are not using a DI framework such as Spring or Guice, then you will
need to instantiate the cache during the bootstrap of your application.  As
your DAO layer is being instantiated, pass the cache instance to it.

### Put and get values from the cache

Now that your DAO layer has a cache reference, you can start to use it.
You will want to consider using the cache using one of two standard cache
access patterns:

* cache-aside
* cache-as-sor

You can read more about these in the [Concepts cache-as-sor](concepts#cache-as-sor) and [Concepts cache-aside](concepts#cache-aside) sections.

## Putting it all together - an example

Here is some example code that demonstrates a DAO based cache using a 
cache aside methodology wiring it together with Spring.

This code implements a PetDao modeled after the Spring Framework PetClinic
sample application.

It implements a standard pattern of creating an abstract 
GenericDao implementation which all Dao implementations will 
extend.  

It also uses Spring's SimpleJdbcTemplate to make the job of accessing 
the database easier.

Finally, to make Ehcache easier to work with in Spring, it implements
a wrapper that holds the cache name.

### The example files
The following are relevant snippets from the example files.  A full project
will be available shortly.

#### CacheWrapper.java
Simple get/put wrapper interface.

<pre>
public interface CacheWrapper&lt;K, V&gt; 
{
 void put(K key, V value);
 V get(K key);
"/>
</pre>

#### EhcacheWrapper.java
The wrapper implementation.  Holds the name so caches can be named.

<pre>
public class EhCacheWrapper&lt;K, V&gt; implements CacheWrapper&lt;K, V&gt; 
{
    private final String cacheName;
    private final CacheManager cacheManager;
    public EhCacheWrapper(final String cacheName, final CacheManager cacheManager)
    {
	this.cacheName = cacheName;
	this.cacheManager = cacheManager;
    "/>
    public void put(final K key, final V value)
    {
	getCache().put(new Element(key, value));
    "/>
    public V get(final K key, CacheEntryAdapter&lt;V&gt; adapter) 
    {
	Element element = getCache().get(key);
	if (element != null) {
	    return (V) element.getValue();
	"/>
	return null;
    "/>
    public Ehcache getCache() 
    {
	return cacheManager.getEhcache(cacheName);
    "/>
"/>
</pre>

#### GenericDao.java
The Generic Dao.  It implements most of the work.

<pre>
public abstract class GenericDao&lt;K, V extends BaseEntity&gt; implements Dao&lt;K, V&gt;
{
    protected DataSource datasource;
    protected SimpleJdbcTemplate jdbcTemplate;
    /* Here is the cache reference */
    protected CacheWrapper&lt;K, V&gt; cache;
    public void setJdbcTemplate(final SimpleJdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    "/>
    public void setDatasource(final DataSource datasource) {
        this.datasource = datasource;
    "/>
    public void setCache(final CacheWrapper&lt;K, V&gt; cache) {
        this.cache = cache;
    "/>
    /* the cacheable method */
    public V getById(final K id) {
	V value;
	if ((value = cache.get(id)) == null) {
	    value = this.jdbcTemplate.queryForObject(findById, mapper, id);
	    if (value != null) {
		cache.put(id, value);
	    "/>
	"/>
	return value;
    "/>
    /** rest of GenericDao implementation here **/
    /** ... **/
    /** ... **/
    /** ... **/
"/>
</pre>

#### PetDaoImpl.java

The Pet Dao implementation, really it doesn't need to do anything unless
specific methods not available via GenericDao are cacheable.

<pre>
public class PetDaoImpl extends GenericDao&lt;Integer, Pet&gt; implements PetDao 
{
/** ... **/
"/>
</pre>

We need to configure the JdbcTemplate, Datasource, CacheManager, PetDao, 
and the Pet cache using the spring configuration file.

#### application.xml

The Spring configuration file.

<pre>
&lt;!-- datasource and friends --&gt;
&lt;bean id="dataSource" class="org.springframework.jdbc.datasource.FasterLazyConnectionDataSourceProxy"&gt;
  &lt;property name="targetDataSource" ref="dataSourceTarget"/&gt;
&lt;/bean&gt;
&lt;bean id="dataSourceTarget" class="com.mchange.v2.c3p0.ComboPooledDataSource"
      destroy-method="close"&gt;
  &lt;property name="user" value="${jdbc.username}"/&gt;
  &lt;property name="password" value="${jdbc.password}"/&gt;
  &lt;property name="driverClass" value="${jdbc.driverClassName}"/&gt;
  &lt;property name="jdbcUrl" value="${jdbc.url}"/&gt;
  &lt;property name="initialPoolSize" value="50"/&gt;
  &lt;property name="maxPoolSize" value="300"/&gt;
  &lt;property name="minPoolSize" value="30"/&gt;
  &lt;property name="acquireIncrement" value="2"/&gt;
  &lt;property name="acquireRetryAttempts" value="0"/&gt;
&lt;/bean&gt;
&lt;!-- jdbctemplate --&gt;
&lt;bean id="jdbcTemplate" class="org.springframework.jdbc.core.simple.SimpleJdbcTemplate"&gt;
  &lt;constructor-arg ref="dataSource"/&gt;
&lt;/bean&gt;
&lt;!-- the cache manager --&gt;
&lt;bean id="cacheManager" class="EhCacheManagerFactoryBean"&gt;
  &lt;property name="configLocation" value="classpath:${ehcache.config}"/&gt;
&lt;/bean&gt;
&lt;!-- the pet cache to be injected into the pet dao --&gt;
&lt;bean name="petCache" class="EhCacheWrapper"&gt;
  &lt;constructor-arg value="pets"/&gt;
  &lt;constructor-arg ref="cacheManager"/&gt;
&lt;/bean&gt;
&lt;!-- the pet dao --&gt;
&lt;bean id="petDao" class="PetDaoImpl"&gt;
  &lt;property name="cache" ref="petCache"/&gt;
  &lt;property name="jdbcTemplate" ref="jdbcTemplate"/&gt;
  &lt;property name="datasource" ref="dataSource"/&gt;
&lt;/bean&gt;
</pre>
