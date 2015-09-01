---
---
# Hello, Ehcache



## Introduction
Ehcache is a cache library introduced in 2003 to improve performance by reducing the load on underlying resources. Ehcache is not for both general-purpose caching and caching Hibernate (second-level cache), data access objects, security credentials, and web pages. It can also be used for SOAP and RESTful server caching, application persistence, and distributed caching.

## Definitions

* **cache**: Wiktionary defines a cache as "a store of things that will be required in future, and can be retrieved rapidly." A cache is a collection of temporary data that either duplicates data located elsewhere or is the result of a computation. Data that is already in the cache can be repeatedly accessed with minimal costs in terms of time and resources.

* **cache-hit**: <a name="cache-hit"></a>When a data element is requested of the cache and the element exists for
the given key, it is referrred to as a cache hit (or simply 'hit').

* **cache-miss**: <a name="cache-miss"></a>When a data element is requested of the cache and the element does not
exist for the given key, it is referred to as a cache miss (or simply
'miss').

* **system-of-record**:<a name="system-of-record"></a> The authoritative source of truth for the data.  This is often referred to as a [system-of-record (SOR)](http://en.wikipedia.org/wiki/System_of_record). The cache acts as a local copy of data retrieved from or stored to the system-of-record. This is often a traditional database, although it might be a specialized file system or some other reliable long-term storage. For the purposes of using Ehcache, the SOR is assumed to be a database.

* **SOR**: <a name="SOR"></a>See [system-of-record](#system-of-record).


## Why caching works

### Locality of Reference

While Ehcache concerns itself with Java objects, caching is used throughout computing, from CPU caches to the internet Domain Name System (DNS) system.
  Why? Because many computer systems exhibit "locality of reference". Data that is near other data or has recently been used
is more likely to be used again.

### The Long Tail

Chris Anderson, of Wired Magazine, coined the term "The Long Tail" to refer to e-commerce systems: a small
number of items can make up the bulk of sales, a small number of blogs can get the most hits, and there is a long "tail" of less popular ones.

![Ehcache Image](/images/documentation/longtail.png)
<br>

The Long Tail is an example of a Power Law probability distribution, such as the Pareto distribution or 80:20 rule. If 20% of objects are used 80% of the time and a way can be found to reduce the
cost of obtaining that 20%, system performance will improve.

## Will an Application Benefit from Caching?

Often the answer is yes, especially if the application is I/O bound. If an application is I/O bound and depends on the rate at which data can be obtained. If it is
CPU bound, then the time taken principally depends on the speed of the CPU and main memory. Caching can improving performance and also reduce the load on a web server.

### Speeding up CPU-bound Applications

CPU bound applications are often sped up by:

* improving algorithm performance
* parallelizing the computations across multiple CPUs (SMP) or multiple machines (clusters).
* upgrading the CPU speed.

A cache can temporarily store computations for reuse, including but not limited to:

 * large web pages that have a high rendering cost
 * authentication status, where authentication requires cryptographic transforms

### Speeding up I/O-bound Applications

Many applications are I/O bound, either by disk or network operations. In the case of databases they can be limited
by both.

There is no Moore's law for hard disks. A 10,000 RPM disk was fast 10 years ago and is still fast. Hard disks are
speeding up by using their own caching of blocks into memory.

Network operations can be bound by a number of factors:

* time to set up and tear down connections
* latency, or the minimum round trip time
* throughput limits
* overhead for marshalling and unmarshalling

The caching of data can often help a lot with I/O bound applications. Some examples of Ehcache uses are:

* Data Access Object caching for Hibernate
* Web page caching, for pages generated from databases

### Increased Application Scalability

The corrolary to increased performance is increased scalability. Suppose you have a database that can perform up to 100 expensive
queries per second. Beyond that threshold, the database backs up and if addition connections occur, the database slowly dies.

In this case, caching is likely to reduce the workload. If caching can cause 90% of that 100 to be cache hits and not impact the database, the database can scale 10 times higher.

## How much will an application speed up with Caching?

In applications that are I/O bound, which is most business applications, most of the response time is getting data
from a database. In a system where each piece of data is used only one time, there is no benefit. In a system where a high proportion of the data are reused, the speed
up is large.

### Applying Amdahl's Law

[Amdahl's law](http://en.wikipedia.org/wiki/Amdahl's_law) finds the total system speed up from a speed up in part of the system.

<pre>
1 / ((1 - Proportion Sped Up) + Proportion Sped Up / Speed up)
</pre>

The following examples show how to apply Amdahl's law to common situations. In the interests of simplicity,
we assume:

* a single server
* a system with a single thing in it, which when cached, gets 100% cache hits and lives forever.

#### Persistent Object Relational Caching

A Hibernate `Session.load()` for a single object is about 1000 times faster from cache than from a database.

A typical Hibernate query will return a list of IDs from the database, and then attempt to load each. If `Session.iterate()`
is used, Hibernate goes back to the database to load each object.

Imagine a scenario where we execute a query against the database tha returns a hundred IDs and then load each one.
The query takes 20% of the time and the roundtrip loading takes the rest (80%). The database query itself is 75% of
the time that the operation takes. The proportion being sped up is thus 60% (75% * 80%).

The expected system speedup is thus:

<pre>
1 / ((1 - .6) + .6 / 1000)
= 1 / (.4 + .0006)
= 2.5 times system speedup
</pre>

#### Web Page Caching

An observed speed up from caching a web page is 1000 times. Ehcache can retrieve a page from its `SimplePageCachingFilter`
in a few milliseconds.

Because the web page is the result of a computation, it has a proportion of 100%.

The expected system speedup is thus:

<pre>
   1 / ((1 - 1) + 1 / 1000)
    = 1 / (0 + .0001)
    = 1000 times system speedup
</pre>

#### Web Page Fragment Caching

Caching the entire page is a big win. Sometimes the liveness requirements vary in different parts of the page.
Here the `SimplePageFragmentCachingFilter` can be used.

Let's say we have a 1000 fold improvement on a page fragment that taking 40% of the page render time.

The expected system speedup is thus:

<pre>
   1 / ((1 - .4) + .4 / 1000)
    = 1 / (.6 + .0004)
    = 1.6 times system speedup
</pre>

### Cache Efficiency

Cache entrie do not live forever. Some examples that come close are:

 * "static" web pages or web page fragments, like page footers
 * database reference data, such as the currencies in the world

Factors that affect the efficiency of a cache are:

* **liveness**&mdash;how live the data needs to be. The less live, the more it can be cached
* **proportion of data cached**&mdash;what proportion of the data can fit into the resource limits of the machine. For 32-bit Java
  systems, there was a hard limit of 2 GB of address space. 64-bit systems do not have that constraint, but garbage collection issues often make it impractical to have the Java heap be large. Various eviction algorithms are used to evict excess entries.
* **Shape of the usage distribution**&mdash;If only 300 out of 3000 entries can be cached, but the Pareto (80/20 rule) distribution applies,
  it might be that 80% of the time, those 300 will be the ones requested. This drives up the average request lifespan.
* **Read/Write ratio**&mdash;The proportion of times data is read compared with how often it is written. Things such as the
  number of empty rooms in a hotel change often, and will be written to frequently. However the details of a room, such as number of beds, are immutable, and therefore a maximum write of 1 might have thousands of reads.

Ehcache keeps these statistics for each Cache and each element, so they can be measured directly rather than estimated.

### Cluster Efficiency
Assume a round robin load balancer where each hit goes to the next server.
The cache has one entry which has a variable lifespan of requests, say caused by a time to live (TTL) setting. The following
table shows how that lifespan can affect hits and misses.

<pre>
Server 1    Server 2   Server 3    Server 4
 M             M           M           M
 H             H           H           H
 H             H           H           H
 H             H           H           H
 H             H           H           H
 ...           ...         ...         ...
</pre>

The cache hit ratios for the system as a whole are as follows:

<pre>
Entry
Lifespan  Hit Ratio   Hit Ratio  Hit Ratio   Hit Ratio
in Hits   1 Server    2 Servers  3 Servers   4 Servers
2          1/2           0/2         0/2         0/2
4          3/4           2/4         1/4         0/4
10         9/10          8/10        7/10        6/10
20         19/20         18/20       17/20       16/10
50         49/50         48/50       47/20       46/50
</pre>

The efficiency of a cluster of standalone caches is generally:

<pre>
(Lifespan in requests - Number of Standalone Caches) / Lifespan in requests
</pre>

Where the lifespan is large relative to the number of standalone caches, cache efficiency is not much affected.
However when the lifespan is short, cache efficiency is dramatically affected.
(To solve this problem, Ehcache supports distributed caching -- available with [Terracotta BigMemory Max](http://terracotta.org/products/bigmemorymax) -- where an entry put in a local cache is propagated
to other servers in the cluster.)

### A cache version of Amdahl's law
   Applying Amdahl's law to caching, we now have:

<pre>
1 / ((1 - Proportion Sped Up * effective cache efficiency) +
(Proportion Sped Up  * effective cache efficiency)/ Speed up)
effective cache efficiency = (cache efficiency) * (cluster efficiency)
</pre>

### Web Page example
Applying this formula to the earlier web page cache example where we have cache efficiency of 35% and average request lifespan of 10 requests
 and two servers:

<pre>
 cache efficiency = .35
 cluster efficiency = .(10 - 1) / 10
                = .9
 effective cache efficiency = .35 * .9
                        = .315
    1 / ((1 - 1 * .315) + 1 * .315 / 1000)
    = 1 / (.685 + .000315)
    = 1.45 times system speedup
</pre>

If the cache efficiency is 70% (two servers):

<pre>
 cache efficiency = .70
 cluster efficiency = .(10 - 1) / 10
                = .9
 effective cache efficiency = .70 * .9
                            = .63
    1 / ((1 - 1 * .63) + 1 * .63 / 1000)
    = 1 / (.37 + .00063)
    = 2.69 times system speedup
</pre>

If the cache efficiency is 90% (two servers):

<pre>
 cache efficiency = .90
 cluster efficiency = .(10 - 1) / 10
                = .9
 effective cache efficiency = .9 * .9
                            = .81
    1 / ((1 - 1 * .81) + 1 * .81 / 1000)
    = 1 / (.19 + .00081)
    = 5.24 times system speedup
</pre>

The benefigt is dramatic because Amdahl's law is most sensitive to the proportion of the system that is sped up.
