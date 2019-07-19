---
---

# Gladstone Technology Preview Documentation

The Gladstone Technology Preview program is now over. The Technology Preview introduced the following new features:

* **Terracotta Management Console** - 
The Terracotta Management Console (TMC) is a web-based administration and monitoring application providing with a wealth of advantages, including:

    * [Multilevel security architecture](https://documentation.softwareag.com/onlinehelp/Rohan/terracotta_437/bigmemory-max/webhelp/index.html#page/bigmemory-max-webhelp%2Fto-sec_setting_up_security.html%23), with end-to-end SSL secure connections available
    * Feature-rich and easy-to-use in-browser interface
    * Remote management capabilities requiring only a web browser and network connection
    * Cross-platform deployment
    * Role-based authentication
    * Aggregates statistics from multiple nodes
    * Flexible deployment model plugs into both development environments and secure production architectures


The TMC can monitor standalone Ehcache version 2.6.0 nodes. For more information, see the file README.txt under the /tmc directory in the Ehcache ee-2.6 kit. 

*  **Fast Restartability** - Standalone Enterprise Ehcache now has complete fault tolerance and fast restart capability. For more information, refer to the [Fast Restartability](/documentation/2.7/configuration/fast-restart) page. 

*  **Search Improvements**:

    *  Searchable Ehcache is faster, almost as fast as Ehcache without Search.

    *  All Search features are available for BigMemory in standalone Ehcache.

    *  The option to group search results is now available. For more information, refer to [Query with GroupBy](/documentation/2.7/apis/search#grouping-results). 
    
*  **Terracotta Cluster Security** &ndash; Add [SSL security](http://terracotta.org/documentation/2.7/bigmemorymax/terracotta-server-array/tsa-security) to the Terracotta Server Array (server-server connections) and all client connections.

## Release Notes
The release notes for the current release are available [here](http://www.terracotta.org/confluence/display/release/Home). 

