---
---
# Tomcat Issues and Best Practices <a name="tomcat-issues-and-best-practices"/>

 

## Introduction
Ehcache is probably used most commonly with Tomcat. This page documents some known issues with Tomcat
and recommended practices.
Ehcache's own caching and gzip filter integration tests run against Tomcat 5.5 and Tomcat 6. Tomcat will
continue to be tested against Ehcache. Accordingly, Tomcat is tier one for Ehcache.


## Problem rejoining a cluster after a reload
If I restart/reload a web application in Tomcat that has a CacheManager that is part of a cluster, the CacheManager is unable to rejoin the cluster.
If I set logging for `net.sf.ehcache.distribution` to FINE I see the following exception:

    FINE: Unable to lookup remote cache peer for .... Removing from peer list. Cause was: error unmarshalling return; nested exception is: java.io.EOFException.

The Tomcat and RMI class loaders do not get along that well. Move ehcache.jar to `$TOMCAT_HOME/common/lib`. This fixes the problem. This issue happens with anything that uses RMI, not just Ehcache.

## Class-loader memory leak
In development, there appears to be class loader memory leak as I continually redeploy my web application.
There are lots of causes of memory leaks on redeploy. Moving Ehcache out of the WAR and into `$TOMCAT/common/lib fixes this leak`.

## RMI CacheException - problem starting listener for RMICachePeer 
I get the following error: 

    net.sf.ehcache.CacheException: Problem starting listener for RMICachePeer ... java.rmi.UnmarshalException: error unmarshalling arguments; nested exception is: java.net.MalformedURLException: no protocol: Files/Apache. 

What is going on?
This issue occurs to any RMI listener started on Tomcat whenever Tomcat has spaces in its installation path.
It can be worked around in Tomcat. The workaround is to remove the spaces in your Tomcat installation path.

## Multiple host entries in Tomcat's server.xml stops replication from occurring
The presence of multiple &lt;Host> entries in Tomcat's server.xml prevents replication from occuring.
The issue is with adding multiple hosts on a single Tomcat connector. If one of the hosts is localhost and another starts with v,
then the caching between machines when hitting localhost stops working correctly.
The workaround is to use a single &lt;Host> entry or to make sure they don't start with "v".
Why this issue occurs is presently unknown, but it is Tomcat-specific. 
 
