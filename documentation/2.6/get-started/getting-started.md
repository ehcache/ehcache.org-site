---
---
# Using Ehcache

 

## Introduction
Ehcache can be used directly. It also supports use with the popular Hibernate Object/Relational tool and caching with the Java EE Servlet. This page is a quick guide to get you started. The rest of the documentation can be explored for a deeper understanding.

## General-Purpose Caching

* Download [Ehcache&nbsp;&rsaquo;](http://ehcache.org/downloads)

    Beginning with Ehcache 1.7.1, Ehcache
depends on SLF4J ([http://www.slf4j.org](http://www.slf4j.org)) for logging. SLF4J is a logging framework with a choice of concrete logging implementations. See the chapter on Logging for configuration details.

* Use Java 1.5 or 1.6.
* Place the Ehcache jar into your classpath.
* Configure ehcache.xml and place it in your classpath.
* Optionally, configure an appropriate [logging](/documentation/2.6/operations/logging) level.
  See the [Code Samples](/documentation/2.6/recipes) chapter for more information on direct interaction with ehcache.

## Cache Usage Patterns

There are several common access patterns when using a cache.  Ehcache
supports the following patterns:

* cache-aside (or direct manipulation)
* cache-as-sor (a combination of read-through and write-through or write-behind patterns)
* read-through
* write-through
* write-behind (or write-back)

### cache-aside
Here, application code uses the cache directly.

This means that application code which accesses the [system-of-record](#system-of-record)
(SOR) should consult the cache first, and if the cache contains the data, then return the data directly from the cache, bypassing the SOR.

Otherwise, the application code must fetch the data from the
system-of-record, store the data in the cache, and then return it.

When data is written, the cache must be updated with the system-of-record.
This results in code that often looks like the following pseudo-code:

    public class MyDataAccessClass
    {
      private final Ehcache cache;
      public MyDataAccessClass(Ehcache cache)
      {
        this.cache = cache;
      "/>

      /* read some data, check cache first, otherwise read from sor */
      public V readSomeData(K key)
      {
         Element element;
         if ((element = cache.get(key)) != null) {
             return element.getValue();
         "/>
          // note here you should decide whether your cache
         // will cache 'nulls' or not
         if (value = readDataFromDataStore(key)) != null) {
             cache.put(new Element(key, value));
         "/>
         return value;
      "/>
      /* write some data, write to sor, then update cache */
      public void writeSomeData(K key, V value)
      {
         writeDataToDataStore(key, value);
         cache.put(new Element(key, value);
      "/>

### cache-as-sor

The cache-as-sor pattern implies using the cache as though it
were the primary [system-of-record](#system-of-record) (SOR).  The pattern delegates SOR
reading and writing activies to the cache, so that application
code is absolved of this responsibility.

To implement the cache-as-sor pattern, use a combination of the
following read and write patterns:

* read-through
* write-through or write-behind

Advantages of using the cache-as-sor pattern are:

* less cluttered application code (improved maintainability)
* easily choose between write-through or write-behind strategies on a
per-cache basis (use only configuration)
* allow the cache to solve the "thundering-herd" problem

A disadvantage of using the cache-as-sor pattern is:

* less directly visible code-path

### read-through
The read-through pattern mimics the structure of the cache-aside pattern
when reading data.  The difference is that you must implement the
`CacheEntryFactory` interface to instruct the cache how to read
objects on a cache miss, and you must wrap the Ehcache instance with
an instance of `SelfPopulatingCache`.
Compare the appearance of the read-through pattern code to the
code provided in the cache-aside pattern.  (The full example is
provided at the end of this document that includes a read-through
and write-through implementation).

### write-through
The write-through pattern mimics the structure of the cache-aside pattern
when writing data.  The difference is that you must implement the
`CacheWriter` interface and configure the cache for write-through
or write-behind.
A write-through cache writes data to the system-of-record in the same
thread of execution, therefore in the common scenario of using a database
transaction in context of the thread, the write to the database is covered
by the transaction in scope.
More details (including configuration settings) can be found in the User
Guide chapter on
[Write-through and Write-behind Caching](/documentation/2.6/apis/write-through-caching).

### write-behind
The write-behind pattern changes the timing of the write to the
system-of-record. Rather than writing to the System of Record in the
same thread of execution, write-behind queues the data for write at a
later time.

The consequences of the change from write-through to write-behind are that
the data write using write-behind will occur outside of the scope of the
transaction.

This often-times means that a new transaction must be created to commit
the data to the system-of-record that is separate from the main transaction.
More details (including configuration settings) can be found in the User
Guide chapter on [Write-through and Write-behind Caching](/documentation/2.6/apis/write-through-caching).

### cache-as-sor example

<pre>
public class MyDataAccessClass
{
private final Ehcache cache;
public MyDataAccessClass(Ehcache cache)
{
   cache.registerCacheWriter(new MyCacheWriter());
   this.cache = new SelfPopulatingCache(cache);
"/>
/* read some data - notice the cache is treated as an SOR.
* the application code simply assumes the key will always be available
*/
public V readSomeData(K key)
{
   return cache.get(key);
"/>
/* write some data - notice the cache is treated as an SOR, it is
* the cache's responsibility to write the data to the SOR.
*/
public void writeSomeData(K key, V value)
{
   cache.put(new Element(key, value);
"/>
/**
* Implement the CacheEntryFactory that allows the cache to provide
* the read-through strategy
*/
private class MyCacheEntryFactory implements CacheEntryFactory
{
   public Object createEntry(Object key) throws Exception
   {
       return readDataFromDataStore(key);
   "/>
"/>
/**
* Implement the CacheWriter interface which allows the cache to provide
* the write-through or write-behind strategy.
*/
private class MyCacheWriter implements CacheWriter
   public CacheWriter clone(Ehcache cache) throws CloneNotSupportedException;
   {
       throw new CloneNotSupportedException();
   "/>
    public void init() { "/>
   void dispose() throws CacheException { "/>
    void write(Element element) throws CacheException;
   {
       writeDataToDataStore(element.getKey(), element.getValue());
   "/>
    void writeAll(Collection<Element> elements) throws CacheException
   {
       for (Element element : elements) {
           write(element);
       "/>
   "/>
    void delete(CacheEntry entry) throws CacheException
   {
       deleteDataFromDataStore(element.getKey());
   "/>
    void deleteAll(Collection<CacheEntry> entries) throws CacheException
   {
       for (Element element : elements) {
           delete(element);
       "/>
   "/>
"/>
"/>
</pre>

### Copy Cache
A Copy Cache can have two behaviors: it can copy Element instances it returns, when `copyOnRead` is true and copy elements it stores,
when  `copyOnWrite` to true.

A copy on read cache can be useful when you can't let multiple threads access the same Element instance (and the
value it holds) concurrently. For example, where the programming model doesn't allow it, or you want to isolate changes done concurrently from
each other.

Copy on write also lets you determine exactly what goes in the cache and when. i.e. when the value that will be in the cache will be
in state it was when it actually was put in cache. *All mutations to the value, or the element, after the put operation will not be
reflected in the cache*.

A concrete example of a copy cache is a Cache configured for `XA`. It will always be configured `copyOnRead` and `copyOnWrite` to provide proper
transaction isolation and clear transaction boundaries (the state the objects are in at commit time is the state making it into the cache).
By default, the copy operation will be performed using standard Java object serialization. We do recognize though that for some
applications this might not be good (or fast) enough. You can configure your own `CopyStrategy` which will be used to perform
these copy operations. For example, you could easily implement use cloning rather than Serialization.

More information on configuration can be found here: [copyOnRead and copyOnWrite cache configuration](/documentation/2.6/configuration/configuration#copyonread-and-copyonwrite-cache-configuration).

## Specific Technologies

### Distributed Caching
Distributed Ehcache combines the power of the Terracotta platform with the ease of Ehcache application-data caching. Ehcache supports [distributed caching](http://terracotta.org/documentation/enterprise-ehcache/get-started) with two lines of configuration.

By integrating Enterprise Ehcache with the Terracotta platform, you can take advantage of BigMemory and expanded Terracotta Server Arrays to greatly scale your application and cluster.

The distributed-cache documentation covers how to configure Ehcache in a Terracotta cluster and how to use its  API in your application.


### Hibernate

* Perform the same steps as for general-purpose caching (above).
* Create caches in ehcache.xml.

See the [Hibernate Caching](/documentation/2.6/integrations/hibernate) chapter for more information.


### Caching with Java EE Servlet

* Perform the same steps as for general-purpose caching above.
* Configure a cache for your web page in ehcache.xml.
* To cache an entire web page, either use SimplePageCachingFilter or create your own subclass of CachingFilter
* To cache a jsp:Include or anything callable from a RequestDispatcher, either use SimplePageFragmentCachingFilter
or create a subclass of PageFragmentCachingFilter.
* Configure the web.xml. Declare the filters created above and create filter mapping associating the filter with
a URL.

See the [Web Caching](/documentation/2.6/modules/web-caching) chapter for more information.

### RESTful and SOAP Caching with the Cache Server

* Download the ehcache-standalone-server from [https://sourceforge.net/projects/ehcache/files/ehcache-server](https://sourceforge.net/projects/ehcache/files/ehcache-server).
* cd to the bin directory
* Type `startup.sh` to start the server with the log in the foreground.
  By default it will listen on port 8080,
 will have both RESTful and SOAP web services enabled, and will use a sample Ehcache configuration from the WAR module.
* See the [code samples](/documentation/2.6/modules/cache-server#restful-code-samples) on the Cache Server page. You can use Java or any other programming language with the Cache Server.

See the [Cache Server](/documentation/2.6/modules/cache-server) page for more information.

### JCache style caching

Ehcache contains an early draft implementation of JCache contained in the net.sf.ehcache.jcache package.
See the [JSR107](/documentation/2.6/integrations/jsr107) chapter for usage.

### Spring, Cocoon, Acegi and other frameworks

Usually, with these, you are using Ehcache without even realising it. The first steps in getting more control over what is happening are:

* discover the cache names used by the framework
* create your own ehcache.xml with settings for the caches and place it in the application classpath.
