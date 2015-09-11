---
---
# Ehcache Search API



## Introduction

The Ehcache Search API allows you to execute arbitrarily complex queries against caches with pre-built indexes. The development of alternative indexes on values provides the ability for data to be looked up based on multiple criteria instead of just keys.

[BigMemory Go](http://terracotta.org/products/bigmemorygo) (called "standalone Ehcache with BigMemory" in this document) and [BigMemory Max](http://terracotta.org/products/bigmemorygo) (called "distributed" Ehcache in this document) use indexing. The Ehcache Search API also queries open-source Ehcache (called "standalone Ehcache without BigMemory" in this document) using a direct search method. For more information, refer to the [Implementation and Performance](#implementation-and-performance) section below.

Searchable attributes may be extracted from both keys and values. Keys, values,
or summary values (Aggregators) can all be returned.
 Here is a simple example: Search for 32-year-old males and return the element values.

    Results results = cache.createQuery().includeValues()
      .addCriteria(age.eq(32).and(gender.eq("male"))).execute();

#### What is Searchable?

Searches can be performed against Element keys and values, but they must be treated as attributes. Some Element keys and values are directly searchable and can simply be added to the search index as attributes. Some Element keys and values must be made searchable by extracting attributes with supported search types out of the keys and values. It is the attributes themselves which are searchable.


## Making a Cache Searchable
Caches can be made searchable, on a per cache basis, either by configuration or programmatically.

#### By Configuration

Caches are made searchable by adding a `<searchable/>` tag to the ehcache.xml.

~~~
<cache name="cache2" maxBytesLocalHeap="16M" eternal="true" maxBytesLocalOffHeap="256M">
	<persistence strategy="localRestartable"/>
	<searchable/>
</cache>
~~~

This configuration will scan keys and values and, if they are of supported search types, add them as
attributes called "key" and "value" respectively. If you do not want automatic indexing of keys and values,
you can disable it with:

~~~
<cache name="cacheName" ...>
	<searchable keys="false" values="false"/>
	   ...
	</searchable>
</cache>
~~~

You might want to do this if you have a mix of types for your keys or values. The automatic indexing will throw
an exception if types are mixed.


If you think that you will want to add search attributes after the cache is initialized, you can explicitly indicate the dynamic search configuration. Set the `allowDynamicIndexing` attribute to "true" to enable use of the dynamic attributes extractor (described in the [Defining Attributes](/documentation/2.8/apis/search.html#defining-attributes) section below):

~~~
<cache name="cacheName" ...>
	<searchable allowDynamicIndexing="true">
	   ...
	</searchable>
</cache>
~~~

Often keys or values will not be directly searchable and instead you will need to extract searchable attributes out of them.
The following example shows this more typical case.  Attribute Extractors are explained in more detail in the following section.

~~~
<cache name="cache3" maxEntriesLocalHeap="10000" eternal="true" maxBytesLocalOffHeap="10G">
	<persistence strategy="localRestartable"/>
	<searchable>
   		<searchAttribute name="age" class="net.sf.ehcache.search.TestAttributeExtractor"/>
   		<searchAttribute name="gender" expression="value.getGender()"/>
	</searchable>
</cache>
~~~


#### Programmatically

The following example shows how to programmatically create the cache configuration, with search attributes.

    Configuration cacheManagerConfig = new Configuration();
    CacheConfiguration cacheConfig = new CacheConfiguration("myCache", 0).eternal(true);
    Searchable searchable = new Searchable();
    cacheConfig.addSearchable(searchable);
    // Create attributes to use in queries.
    searchable.addSearchAttribute(new SearchAttribute().name("age"));
    // Use an expression for accessing values.
    searchable.addSearchAttribute(new SearchAttribute()
        .name("first_name")
        .expression("value.getFirstName()"));
    searchable.addSearchAttribute(new SearchAttribute().name("last_name").expression("value.getLastName()"));
         searchable.addSearchAttribute(new SearchAttribute().name("zip_code").expression("value.getZipCode()"));
    cacheManager = new CacheManager(cacheManagerConfig);
    cacheManager.addCache(new Cache(cacheConfig));
    Ehcache myCache = cacheManager.getEhcache("myCache");
    // Now create the attributes and queries, then execute.
    ...

To learn more about the Ehcache Search API, see the `net.sf.ehcache.search*` packages in this [Javadoc](/apidocs/2.8.5/index.html).


## Defining Attributes

  In addition to configuring a cache to be searchable, you must define the attributes to be used in searches. Attributes are extracted from keys or values using `AttributeExtractor`s. The following types are supported for extracted attributes:

*   Boolean
*   Byte
*   Character
*   Double
*   Float
*   Integer
*   Long
*   Short
*   String
*   java.util.Date
*   java.sql.Date
*   Enum

If an attribute cannot be extracted, due to not being found or being the wrong type, an AttributeExtractorException is thrown on search execution or, if using Distributed Ehcache, on `put()`.


#### Well-known Attributes

The parts of an Element that are well-known attributes can be referenced by some predefined, well-known names.
If a key and/or value is of a supported search type, it is added automatically as an attribute with the name
"key" or "value".
These well-known attributes have the convenience of being constant attributes made available on the `Query` class.
So, for example, the attribute for "key" may be referenced in a query by `Query.KEY`. For even greater readability, it is
recommended to statically import so that, in this example, you would just use `KEY`.

| Well-known Attribute Name | Attribute Constant |
| --- | --- |
| key               |     Query.KEY |
| value             |     Query.VALUE |


#### ReflectionAttributeExtractor

The ReflectionAttributeExtractor is a built-in search attribute extractor which uses JavaBean conventions and also understands a simple form of expression. Where a JavaBean property is available and it is of a searchable type, it can be simply declared:

    <cache>
      <searchable>
        <searchAttribute name="age"/>
      </searchable>
    </cache>

 The expression language of the ReflectionAttributeExtractor also uses method/value dotted expression chains. The expression chain must start with one of either "key", "value", or "element". From the starting object a chain of either method calls or field names follows. Method calls and field names can be freely mixed in the chain. Some more examples:

    <cache>
      <searchable>
        <searchAttribute name="age" expression="value.person.getAge()"/>
      </searchable>
    </cache>
    <cache>
      <searchable>
         <searchAttribute name="name" expression="element.toString()"/>
      </searchable>
    </cache>

 *Note*: The method and field name portions of the expression are case sensitive.


#### Custom AttributeExtractor

 In more complex situations, you can create your own attribute extractor by implementing the AttributeExtractor interface. Provide your extractor class, as shown in the following example:

    <cache name="cache2" maxEntriesLocalHeap="0" eternal="true">
      <persistence strategy="none"/>
      <searchable>
         <searchAttribute name="age" class="net.sf.ehcache.search.TestAttributeExtractor"/>
      </searchable>
    </cache>

 If you need to pass state to your custom extractor, you may do so with properties, as shown in the following example:

    <cache>
      <searchable>
        <searchAttribute name="age"
        class="net.sf.ehcache.search.TestAttributeExtractor"
        properties="foo=this,bar=that,etc=12" />
      </searchable>
    </cache>

If properties are provided, then the attribute extractor implementation must have a public constructor that accepts a single `java.util.Properties` instance.

#### Dynamic Attributes Extractor

The `DynamicAttributesExtractor` provides flexibility by allowing the search configuration to be changed after the cache is initialized. This is done with one method call, at the point of element insertion into the cache. The `DynamicAttributesExtractor` method returns a map of attribute names to index and their respective values. This method is called for every Ehcache.put() and replace() invocation.

Assuming that we have previously created Person objects containing attributes such as name, age, and gender, the following example shows how to create a dynamically searchable cache and register the `DynamicAttributesExtractor`:

	Configuration config = new Configuration();
	config.setName("default");
  	CacheConfiguration cacheCfg = new CacheConfiguration(“PersonCache”);
  	cacheCfg.setEternal(true);
  	Searchable searchable = new Searchable().allowDynamicIndexing(true);

	cacheCfg.addSearchable(searchable);
	config.addCache(cacheCfg);

	CacheManager cm = new CacheManager(config);
	Ehcache cache = cm.getCache(“PersonCache”);
	final String attrNames[] = {“first_name”, “age”};
	// Now you can register a dynamic attribute extractor that would index the cache elements, using a subset of known fields
	cache.registerDynamicAttributesExtractor(new DynamicAttributesExtractor() {
		Map<String, Object> attributesFor(Element element) {
			Map<String, Object> attrs = new HashMap<String, Object>();
			Person value = (Person)element.getObjectValue();
			// For example, extract first name only
			String fName = value.getName() == null ? null : value.getName().split(“\\s+”)[0];
			attrs.put(attrNames[0], fName);
			attrs.put(attrNames[1], value.getAge());
			return attrs;
		"/>
	});
	// Now add some data to the cache
	cache.put(new Element(10, new Person(“John Doe”, 34, Person.Gender.MALE)));

Given the code above, the newly put element would be indexed on values of name and age fields, but not gender. If, at a later time, you would like to start indexing the element data on gender, you would need to create a new `DynamicAttributesExtractor` instance that extracts that field for indexing.

#####Dynamic Search Rules

* In order to use the `DynamicAttributesExtractor`, the cache must be configured to be searchable and dynamically indexable (refer to [Making a Cache Searchable](/documentation/2.8/apis/search.html#making-a-cache-searchable) above).

* A dynamically searchable cache must have a dynamic extractor registered before data is added to it. (This is to prevent potential races between extractor registration and cache loading which might result in an incomplete set of indexed data, leading to erroneous search results.)

* Each call on the `DynamicAttributesExtractor` method replaces the previously registered extractor, as there can be at most one extractor instance configured for each such cache.

* If a dynamically searchable cache is initially configured with a predefined set of search attributes, then this set of attributes will always be queried for extracted values, regardless of whether or not there is a dynamic search attribute extractor configured.

* The initial search configuration takes precedence over dynamic attributes, so if the dynamic attribute extractor returns an attribute name already used in the initial searchable configuration, an exception will be thrown.

* Clustered Ehcache clients do not share dynamic extractor instances or implementations. In a clustered searchable deployment, the initially configured attribute extractors cannot vary from one client to another, and this is enforced by propagating them across the cluster. However, for dynamic attribute extractors, each clustered client maintains its own dynamic extractor instance, not shared with the others. Each distributed application using dynamic search must therefore maintain its own attribute extraction consistency.

## Creating a Query
Ehcache Search uses a fluent, object-oriented Query API, following DSL principles, which should feel familiar and natural to Java programmers.
Here is a simple example:

    Query query = cache.createQuery().addCriteria(age.eq(35)).includeKeys().end();
    Results results = query.execute();

### Using Attributes in Queries
 If declared and available, the well-known attributes are referenced by their names or the convenience attributes are used
  directly, as shown in this example:

    Results results = cache.createQuery().addCriteria(Query.KEY.eq(35)).execute();
    Results results = cache.createQuery().addCriteria(Query.VALUE.lt(10)).execute();

Other attributes are referenced by the names given them in the configuration. For example:

    Attribute<Integer> age = cache.getSearchAttribute("age");
    Attribute<String> gender = cache.getSearchAttribute("gender");
    Attribute<String> name = cache.getSearchAttribute("name");


### Expressions

A Query is built up using Expressions. Expressions may include logical operators such as &lt;and&gt; and &lt;or&gt;, and comparison operators such as &lt;ge&gt; (&gt;=), &lt;between&gt;, and &lt;like&gt;.
The configuration `addCriteria(...)` is used to add a clause to a query. Adding a further clause automatically "&lt;and&gt;s" the clauses.

    query = cache.createQuery().includeKeys().addCriteria(age.le(65)).add(gender.eq("male")).end();

Both logical and comparison operators implement the `Criteria` interface.
To add a criteria with a different logical operator, explicitly nest it within a new logical operator Criteria Object. For example, to check for age = 35 or gender = female, do the following:

    query.addCriteria(new Or(age.eq(35),
                 gender.eq(Gender.FEMALE))
                );

More complex compound expressions can be further created with extra nesting.
See the [Expression JavaDoc](/apidocs/2.8.5/net/sf/ehcache/search/expression/package-frame.html) for a complete list of expressions.

### List of Operators
Operators are available as methods on attributes, so they are used by adding a ".". For example, "lt" means "less than" and is used as `age.lt(10)`, which is a shorthand way of saying `age LessThan(10)`.
The full listing of operator shorthand is shown below.

| Shorthand | Criteria Class | Description
|----------|--------------|--------------
| and    |  And          | The Boolean AND logical operator
| between | Between      | A comparison operator meaning between two values
| eq     | EqualTo       | A comparison operator meaning Java "equals to" condition
| gt     | GreaterThan   | A comparison operator meaning greater than.
| ge     | GreaterThanOrEqual | A comparison operator meaning greater than or equal to.
| in     | InCollection  | A comparison operator meaning in the collection given as an argument
| lt     | LessThan      | A comparison operator meaning less than.
| le     | LessThanOrEqual| A comparison operator meaning less than or equal to
| ilike  | ILike          | A regular expression matcher. "?" and "*" may be used. Note that placing a wildcard in front of the expression will cause a table scan. ILike is always case insensitive.
| isNull | IsNull        | Tests whether the value of attribute with given name is null
| notNull| NotNull       | Tests whether the value of attribute with given name is NOT null
| not    | Not           | The Boolean NOT logical operator
| ne     | NotEqualTo    | A comparison operator meaning not the Java "equals to" condition
| or     | Or            | The Boolean OR logical operator

Note: For Strings, the operators are case-insensitive.

### Making Queries Immutable

 By default, a query can be executed and then modified and re-executed. If `end` is called,
 the query is made immutable.


## Obtaining and Organizing Query Results

Queries return a `Results` object which contains a list of objects of class `Result`. Each `Element` in the cache found with a query will be represented as a `Result` object. So if a query finds
350 elements, there will be 350 `Result` objects. An exception to this would be if no keys or attributes are included but
aggregators are -- in this case, there will be exactly one `Result` present.

A Result object can contain:

*    the Element key - when `includeKeys()` is added to the query,
*    the Element value - when `includeValues()` is added to the query,
*    predefined attribute(s) extracted from an Element value - when `includeAttribute(...)` is added to the query. To access an attribute from a Result, use `getAttribute(Attribute<T> attribute)`.
*    aggregator results - Aggregator results are summaries computed for the search. They are available through `Result.getAggregatorResults` which returns a list of `Aggregator`s in the same order in which they were used in the `Query`.

### Aggregators
Aggregators are added with `query.includeAggregator(\<attribute\>.\<aggregator\>)`.
For example, to find the sum of the age attribute:

    query.includeAggregator(age.sum());

For a complete list of aggregators, refer to the [Aggregators JavaDoc](/apidocs/2.8.5/net/sf/ehcache/search/aggregator/package-frame.html).

### Ordering Results
Query results may be ordered in ascending or descending order by adding an `addOrderBy` clause to the query, which takes
as parameters the attribute to order by and the ordering direction. For example, to order the results by ages in ascending order:

    query.addOrderBy(age, Direction.ASCENDING);


### Grouping Results
With Ehcache 2.6 and higher, query results may be grouped similarly to using an SQL GROUP BY statement. The Ehcache GroupBy feature provides the option to group results according to specified attributes by adding an `addGroupBy` clause to the query, which takes as parameters the attributes to group by. For example, you can group results by department and location like this:

    Query q = cache.createQuery();
    Attribute<String> dept = cache.getSearchAttribute(“dept”);
    Attribute<String> loc = cache.getSearchAttribute(“location”);
    q.includeAttribute(dept);
    q.includeAttribute(loc);
    q.addCriteria(cache.getSearchAttribute(“salary”).gt(100000));
    q.includeAggregator(Aggregators.count());
    q.addGroupBy(dept, loc);


The GroupBy clause groups the results from `includeAttribute()` and allows aggregate functions to be performed on the grouped attributes. To retrieve the attributes that are associated with the aggregator results, you can use:

		String dept = singleResult.getAttribute(dept);
		String loc = singleResult.getAttribute(loc);


####GroupBy Rules
Grouping query results adds another step to the query--first results are returned, and second the results are grouped. This necessitates the following rules and considerations when using GroupBy:

*  In a query with a GroupBy clause, any attribute specified using `includeAttribute()` should also be included in the GroupBy clause.
*  Special KEY or VALUE attributes may not be used in a GroupBy clause. This means that `includeKeys()` and `includeValues()` may not be used in a query that has a GroupBy clause.
*  Adding a GroupBy clause to a query changes the semantics of any aggregators passed in, so that they apply only within each group.
*  As long as there is at least one aggregation function specified in a query, the grouped attributes are not required to be included in the result set, but they are typically requested anyway to make result processing easier.
*  An `addCriteria()` clause applies to all results prior to grouping.
*  If OrderBy is used with GroupBy, the ordering attributes are limited to those listed in the GroupBy clause.


### Limiting the Size of Results

By default a query will return an unlimited number of results. For example the following
query will return all keys in the cache.

    Query query = cache.createQuery();
    query.includeKeys();
    query.execute();

If too many results are returned, it could cause an OutOfMemoryError
The `maxResults` clause is used to limit the size of the results.
For example, to limit the above query to the first 100 elements found:

    Query query = cache.createQuery();
    query.includeKeys();
    query.maxResults(100);
    query.execute();

**Note**: When maxResults is used with GroupBy, it limits the number of groups.

When you are done with the results, call `discard()` to free up resources.
In the distributed implementation with Terracotta, resources may be used to hold results for paging or return.

### Interrogating Results
To determine what was returned by a query, use one of the interrogation methods on `Results`:

* `hasKeys()`
* `hasValues()`
* `hasAttributes()`
* `hasAggregators()`


## Sample Application
We have created [a simple standalone sample application](http://github.com/sharrissf/Ehcache-Search-Sample/downloads/) with few dependencies for you to easily get started with Ehcache Search. You can also check out the source:

    git clone git://github.com/sharrissf/Ehcache-Search-Sample.git

The [Ehcache Test Sources](https://fisheye.terracotta.org/browse/Ehcache/branches/ehcache-2.8.x/ehcache-core/src/test/java/net/sf/ehcache/search) page has further examples
on how to use each Ehcache Search feature.

## Scripting Environments
Ehcache Search is readily amenable to scripting. The following example shows how to use it with BeanShell:

    Interpreter i = new Interpreter();
    //Auto discover the search attributes and add them to the interpreter's context
    Map<String, SearchAttribute> attributes = cache.getCacheConfiguration().getSearchAttributes();
    for (Map.Entry<String, SearchAttribute> entry : attributes.entrySet()) {
    i.set(entry.getKey(), cache.getSearchAttribute(entry.getKey()));
    LOG.info("Setting attribute " + entry.getKey());
    "/>
    //Define the query and results. Add things which would be set in the GUI i.e.
    //includeKeys and add to context
    Query query = cache.createQuery().includeKeys();
    Results results = null;
    i.set("query", query);
    i.set("results", results);
    //This comes from the freeform text field
    String userDefinedQuery = "age.eq(35)";
    //Add on the things that we need
    String fullQueryString = "results = query.addCriteria(" + userDefinedQuery + ").execute()";
    i.eval(fullQueryString);
    results = (Results) i.get("results");
    assertTrue(2 == results.size());
    for (Result result : results.all()) {
    LOG.info("" + result.getKey());
    "/>


## Implementation and Performance

### Ehcache Backed by the Terracotta Server Array
This implementation uses indexes which are maintained on each Terracotta server. In Ehcache EX the index is
on a single active server. In Ehcache FX the cache is sharded across the number of active nodes in the cluster. The index
for each shard is maintained on that shard's server.
Searches are performed using the Scatter-Gather pattern. The query executes on each node and the results are then aggregated
back in the Ehcache that initiated the search.

Search operations perform in O(log n / number of shards) time.
Performance is excellent but can be improved simply by adding more servers to the FX array. Also, because Search results are returned over the network, and the data returned could potentially be very large, techniques to limit return size are recommended. For more information, refer to [Best Practices](#best-practices).

### Standalone Ehcache with BigMemory
As of version 2.6, standalone Ehcache with BigMemory uses a Search index that is maintained at the local node. The index is stored under a directory in the DiskStore and is available whether or not persistence is enabled. Any overflow from the on-heap tier of the cache, whether to the off-heap tier or to the disk tier, is searched using indexes.

Search operations perform in O(log(n)) time. For tips that can aid performance, refer to [Best Practices](#best-practices).

### Standalone Ehcache without BigMemory
For caches that are on-heap only, the standalone Ehcache Search implementation does not use indexes. Instead, it performs a fast iteration of the cache, relying on the very fast access to do the equivalent of a table scan for each query. Each element in the cache is only visited once. Attributes are not extracted ahead of time. They are done during query execution.

Search operations perform in O(n) time. Check out this [Maven-based performance test](http://svn.terracotta.org/svn/forge/offHeap-test/) showing performance of standalone Ehcache without BigMemory. The test shows search performance of an average of representative queries at 4.6 ms for a 10,000 entry cache, and 427 ms for a 1,000,000 entry cache. Accordingly, standalone implementation is suitable for development and testing.

When using standalone Ehcache without BigMemory for production, it is recommended to search only caches that are less than 1 million elements. Performance of different `Criteria` vary. For example, here are some queries and their execute times on a 200,000 element cache. (Note that these results are all faster than the times given above because they execute a single Criteria).

<pre><code>final Query intQuery = cache.createQuery();
  intQuery.includeKeys();
  intQuery.addCriteria(age.eq(35));
  intQuery.end();
Execute Time: 62ms
final Query stringQuery = cache.createQuery();
  stringQuery.includeKeys();
  stringQuery.addCriteria(state.eq("CA"));
  stringQuery.end();
Execute Time: 125ms
final Query iLikeQuery = cache.createQuery();
  iLikeQuery.includeKeys();
  iLikeQuery.addCriteria(name.ilike("H*"));
  iLikeQuery.end();
Execute Time: 180ms
</code></pre>


##Best Practices for Optimizing Searches
1. Construct searches wisely by including only the data that is actually required.
  *  Only use `includeKeys()` and/or `includeAttribute()` if those values are actually required for your application logic.
  *  If you don’t need values or attributes, be careful not to burden your queries with unnecessary work. For example, if `result.getValue()` is not called in the search results, then don't use `includeValues()` in the original query.
  *  Consider if it would be sufficient to get attributes or keys on demand. For example, instead of running a search query with `includeValues()` and then `result.getValue()`, run the query for keys and include `cache.get()` for each individual key.

  **Note**: As of Ehcache 2.6, `includeKeys()` and `includeValues()` have lazy deserialization, which means that keys and values are de-serialized only when `result.getKey()` or `result.getValue()` is called. This provides better latency overall, with a time cost only when the key is needed. However, there is still some time cost with `includeKeys()` and `includeValues()`, so consider carefully when constructing your queries.


2. Searchable keys and values are automatically indexed by default. If you will not be including them in your query, turn off automatic indexing with the following:

        <cache name="cacheName" ...>
          <searchable keys="false" values="false"/>
          ...
          </searchable>
        </cache>

3. Limit the size of the results set with `query.maxResults(int number_of_results)`. Another recommendation for managing the size of the result set is to use a built-in Aggregator function to return a summary statistic (see the `net.sf.ehcache.search.aggregator` package in this <a href="/apidocs/2.8.5/index.html">Javadoc</a>).

4. Make your search as specific as possible. Queries with "ILike" criteria and fuzzy (wildcard) searches may take longer than more specific queries. Also, if you are using a wildcard, try making it the trailing part of the string instead of the leading part (`"321*"` instead of `"*123"`). If you want leading wildcard searches, then you should create a `<searchAttribute>` with the string value reversed in it, so that your query can use the trailing wildcard instead.

5. When possible, use the query criteria "Between" instead of "LessThan" and "GreaterThan", or "LessThanOrEqual" and "GreaterThanOrEqual". For example, instead of using `le(startDate)` and `ge(endDate)`, try `not(between(startDate,endDate))`.  

6. Index dates as integers. This can save time and may even be faster if you have to do a conversion later on.

7. Searches of eventually consistent caches are faster because queries are executed immediately, without waiting for pending transactions at the local node to commit. **Note**: This means that if a thread adds an element into an eventually consistent cache and immediately runs a query to fetch the element, it will not be visible in the search results until the update is published to the server.



### Concurrency Notes
Unlike cache operations which have selectable concurrency control and/or transactions, queries are asynchronous and Search results are eventually consistent with the caches.

#### Index Updating
Although indexes are updated synchronously, their state will lag slightly behind the state of the cache. The only exception is when the updating thread then performs a search.

For caches with concurrency control, an index will not reflect the new state of the cache until:

* The change has been applied to the cluster.
* For a cache with transactions, when `commit` has been called.

#### Query Results
There are several ways unexpected results could present:

*   A search returns an Element reference which no longer exists.
*   Search criteria select an Element, but the Element has been updated and a new Search would no longer match the Element.
*   Aggregators, such as `sum()`, might disagree with the same calculation done by redoing the calculation yourself by re-accessing the cache for each key and repeating the calculation.
*   Because the cache is always updated before the search index, it is possible that a value reference may refer to a value that has been removed from the cache. If this happens, the value will be null but the key and attributes which were supplied by the now stale cache index will be non-null. Because values in Ehcache are also allowed to be null, you cannot tell whether your value is null because it has been removed from the cache since the index was last updated or because it is a null value.

#### Recommendations
Because the state of the cache can change between search executions, the following is recommended:

*	Add all of the aggregators you want for a query at once, so that the returned aggregators are consistent.
*	Use null guards when accessing a cache with a key returned from a search.
