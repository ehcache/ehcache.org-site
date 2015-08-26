---
---
# Tomcat Issues and Best Practices <a name="tomcat-issues-and-best-practices"/>

Ehcache is probably used most commonly with Tomcat. This chapter documents some known issues with Tomcat
and recommended practices.
Ehcache's own caching and gzip filter integration tests run against Tomcat 5.5 and Tomcat 6. Tomcat will
continue to be tested against ehcache. Accordingly Tomcat is tier one for ehcache.


### Problem rejoining a cluster after a reload
If I restart/reload a web application in Tomcat that has a CacheManager that is part of a cluster, the CacheManager is unable to rejoin the cluster.
If I set logging for `net.sf.ehcache.distribution` to FINE I see the following exception:

    FINE: Unable to lookup remote cache peer for .... Removing from peer list. Cause was: error unmarshalling return; nested exception is: java.io.EOFException.

The Tomcat and RMI class loaders do not get along that well. Move ehcache.jar to `$TOMCAT_HOME/common/lib`. This fixes the problem. This issue happens with anything that uses RMI, not just ehcache.

### Class-Loader Memory Leak
In development, there appear to be class loader memory leak as I continually redeploy my web application.
There are lots of causes of memory leaks on redeploy. Moving Ehcache out of the WAR and into `$TOMCAT/common/lib fixes this leak`.

### I Get an RMI CacheExceptionx (Problem starting listener for RMICachePeer) 
I get 

    net.sf.ehcache.CacheException: Problem starting listener for RMICachePeer ... java.rmi.UnmarshalException: error unmarshalling arguments; nested exception is: java.net.MalformedURLException: no protocol: Files/Apache. 

What is going on?
This issue occurs to any RMI listener started on Tomcat whenever Tomcat has spaces in its installation path.
It is is a JDK bug which can be worked around in Tomcat.
See [this explanation](http://archives.java.sun.com/cgi-bin/wa?A2=ind0205&L=rmi-users&P=797). The workaround is to remove the spaces in your tomcat installation path.

### Multiple Host Entries in Tomcat's server.xml stops replication from occurring
The presence of multiple &lt;Host> entries in Tomcat's server.xml prevents replication from occuring.
The issue is with adding multiple hosts on a single Tomcat connector. If one of the hosts is localhost and another starts with v,
then the caching between machines when hitting localhost stops working correctly.
The workaround is to use a single &lt;Host> entry or to make sure they don't start with "v".
Why this issue occurs is presently unknown, but it is Tomcat specific. 
 
