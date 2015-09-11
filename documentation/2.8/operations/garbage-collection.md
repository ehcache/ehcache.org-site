---
---
# Tuning Garbage Collection



## Introduction
Applications that use Ehcache can be expected to use large heaps. Some Ehcache applications have heap sizes greater than 6 GB.
Ehcache works well at this scale. However, large heaps or long held objects, which is what a cache is composed of, can place strain on the
default Garbage Collector (GC). With Ehcache 2.3 and higher, this problem can be solved with [BigMemory](/documentation/2.8/configuration/bigmemory.html) in-memory data management, which provides an additional store outside
of the heap.

## Detecting Garbage Collection Problems

A full garbage collection event pauses all threads in the JVM. Nothing happens during the pause.  If this pause takes more than a few seconds, it will
become noticeable.

The clearest way to see if this is happening is to run `jstat`. The following command will produce a log of garbage collection statistics, updated
every ten seconds.

~~~
jstat -gcutil <pid> 10 1000000
~~~

The thing to watch for is the Full Garbage Collection Time. The difference between the total time for each reading is the amount of time the system was
paused. A jump of more than a few seconds will not be acceptable in most application contexts.

## Garbage Collection Tuning

Tuning suggestion for virtual machines with large heaps using caching:

~~~
java ... -XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC
-XX:NewSize=<1/4 of total heap size> -XX:SurvivorRatio=16
~~~

Note that it is better to use `-XX:+DisableExplicitGC`, instead of calling `System.gc()`. It also helps to use the low pause collector `-XX:+UseConcMarkSweepGC`.

## Distributed Caching Garbage Collection Tuning

Some users have reported that enabling distributed caching causes a full garbage collection each minute. This is an issue with remote method invocation (RMI) generally, which can be worked around by increasing the interval for garbage collection. The effect RMI has is similar to a user application calling `System.gc()`
each minute. The setting above disables explicit GC calls, but it does not disable the full GC initiated by RMI.
The default in JDK 6 was increased to 1 hour. The following system properties control the interval.

~~~
-Dsun.rmi.dgc.client.gcInterval=60000
-Dsun.rmi.dgc.server.gcInterval=60000
~~~

Increase the interval as required in your application.
