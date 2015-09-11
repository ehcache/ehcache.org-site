---
---
# Using Spring and BigMemory Go



##Introduction
BigMemory Go's Ehcache has had excellent Spring integration for years. Spring 3.1 includes an Ehcache implementation. See the [ Spring 3.1 JavaDoc](http://static.springsource.org/spring/docs/3.1.0.M1/javadoc-api/org/springframework/cache/ehcache/package-summary.html).

## Spring 3.1
Spring Framework 3.1 has a generic cache abstraction for transparently applying caching to Spring applications.
It has caching support for classes and methods using two annotations:

### @Cacheable
Cache a method call.
In the following example, the value is the return type, a Manual. The key is extracted from the ISBN argument using the id.

<pre>
@Cacheable(value="manual", key="#isbn.id")
public Manual findManual(ISBN isbn, boolean checkWarehouse)
</pre>

### @CacheEvict
Clears the cache when called.

<pre>
@CacheEvict(value = "manuals", allEntries=true)
public void loadManuals(InputStream batch)
</pre>

For an excellent blog post covering SpEL expressions, see <http://blog.springsource.com/2011/02/23/spring-3-1-m1-caching/>.

## Spring 2.5 - 3.1: Annotations For Spring
This open source, led by Eric Dalquist, predates the Spring 3.1 project. You can use it with earlier versions of Spring, or you
can use it with 3.1.

### @Cacheable
As with Spring 3.1 it uses an @Cacheable annotation to cache a method. In this example calls to findMessage are stored in a cache
named "messageCache". The values are of type `Message`. The id for each entry is the `id` argument given.

<pre>
@Cacheable(cacheName = "messageCache")
public Message findMessage(long id)
</pre>

### @TriggersRemove
And for cache invalidation, there is the @TriggersRemove annotation.
In this example, `cache.removeAll()` is called after the method is invoked.

<pre>
@TriggersRemove(cacheName = "messagesCache",
when = When.AFTER_METHOD_INVOCATION, removeAll = true)
public void addMessage(Message message)
</pre>

See <http://blog.goyello.com/2010/07/29/quick-start-with-ehcache-annotations-for-spring/> for a blog post explaining its use
and providing further links.


## The Annotations for Spring Project

To dynamically configure caching of method return values, use the [Ehcache Annotations for Spring project at code.google.com](http://code.google.com/p/ehcache-spring-annotations/). This project will allow you to configure caching of method calls dynamically using just configuration. The way it works is that the parameter values of the method will be used as a composite key into the cache, caching the return value of the method.

For example, suppose you have a method: `Dog getDog(String name)`.

Once caching is added to this method, all calls to the method will be cached using the "name" parameter as a key.

So, assume at time t0 the application calls this method with the name equal to "fido". Since "fido" doesn't exist, the method is allowed to run, generating the "fido" Dog object, and returning it. This object is then put into the cache using the key "fido".

Then assume at time t1 the application calls this method with the name equal to "spot". The same process is repeated, and the cache is now populated with the Dog object named "spot".

Finally, at time t2 the application again calls the method with the name "fido". Since "fido" exists in the cache, the "fido" Dog object is returned from the cache instead of calling the method.

To implement this in your application, follow these steps:

**Step 1:**

Add the jars to your application as listed on the [Ehcache Annotations for Spring project site](http://code.google.com/p/ehcache-spring-annotations).

**Step 2:**

Add the Annotation to methods you would like to cache. Lets assume you are using the Dog getDog(String name) method from above:

    @Cacheable(name="getDog")
    Dog getDog(String name)
    {
        ....
    "/>
**Step 3:**

Configure Spring. You must add the following to your Spring configuration file in the beans declaration section:

    <ehcache:annotation-driven cache-manager="ehCacheManager" />

More details can be found at:

* [Ehcache Annotations for Spring project](http://code.google.com/p/ehcache-spring-annotations)
* [the project getting started page](http://code.google.com/p/ehcache-spring-annotations/wiki/UsingCacheable)
* [this blog](http://www.jeviathon.com/2010/04/caching-java-methods-with-spring-3.html)
