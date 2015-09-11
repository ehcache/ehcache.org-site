---
---
# Glassfish How To & FAQ <a name="glassfish-how-to-and-faq"/>



##Introduction
The maintainer uses Ehcache in production with Glassfish. This page explains how to package a sample application using Ehcache and deploy to Glassfish.

## Versions
Ehcache has been tested with and is used in production with Glassfish V1, V2 and V3.
In particular:

* Ehcache 1.4 - 1.7 has been tested with Glassfish 1 and 2.
* Ehcache 2.0 has been tested with Glassfish 3.

## Deployment
Ehcache comes with a sample web application which is used to test the page caching. The page caching is the only area
that is sensitive to the Application Server. For Hibernate and general caching, it is only dependent on your Java version.

You need:

* An Ehcache core installation
* A Glassfish installation
* A `GLASSFISH_HOME` environment variable defined.
* `$GLASSFISH_HOME/bin` added to your `PATH`

Run the following from the Ehcache `core` directory:

<pre><code># To package and deploy to domain1:
ant deploy-default-web-app-glassfish

# Start domain1:
asadmin start-domain domain1

# Stop domain1:
asadmin stop-domain domain1

# Overwrite the config with our own which changes the port to 9080:
ant glassfish-configuration

# Start domain1:
asadmin start-domain domain1
</code></pre>

You can then run the web tests in the web package or point your browser at `http://localhost:9080`.
See [this page](https://glassfish.java.net/downloads/quickstart/index.html) for a quickstart to Glassfish.

## Troubleshooting <a name="glassfish-faq"/>

### How to get around the EJB Container restrictions on thread creation
When Ehcache is running in the EJB Container, for example for Hibernate caching, it is in technical breach of
the EJB rules. Some app servers let you override this restriction.
I am not exactly sure how this in done in Glassfish. For a number of reasons we run Glassfish
without the Security Manager, and we do not have any issues.
In domain.xml ensure that the following is **not** included.

    <jvm-options>-Djava.security.manager</jvm-options>


### Ehcache throws an IllegalStateException in Glassfish
Ehcache page caching versions below Ehcache 1.3 get an IllegalStateException in Glassfish. This issue was fixed in Ehcache 1.3.

### PayloadUtil reports `Could not ungzip. Heartbeat will not be working. Not in GZIP format`
This exception is thrown when using Ehcache with my Glassfish cluster, but Ehcache and Glassfish clustering have nothing to do with each other. The error is caused because Ehcache has received a multicast message from the Glassfish cluster. Ensure that Ehcache clustering has its own unique multicast address (different from Glassfish).
