---
---
# Building and Testing Ehcache

 

## Introduction
This page is intended for those who want to create their own Ehcache or distributed Ehcache build rather than use the packed kit.

## Building from Source <a name="building-from-source}

These instructions work for each of the modules, except for JMS Replication, which requires installation of a message queue. See that module for details.


### Building an Ehcache distribution from source <a name="building-an-ehcache-distribution-from-source}

To build Ehcache from source:

1. Check the source out from the [subversion repository](http://svn.terracotta.org/svn/ehcache/).
1. Ensure you have a valid JDK and Maven 2 installation.
1. From within the ehcache/core directory, type `mvn -Dmaven.test.skip=true install`


### Running Tests for Ehcache <a name="running-tests-for-ehcache}

To run the test suite for Ehcache:

1. Check the source out from the subversion repository.
1. Ensure you have a valid JDK and Maven 2 installation.
1. From within the ehcache/core directory, type `mvn test`
1. If some performance tests fail, add a `-D net.sf.ehcache.speedAdjustmentFactor=x` System property to your command line, where x is how many times your machine is slower than the reference machine. Try setting it to 5 for a start.


## Java Requirements and Dependencies

### Java Requirements <a name="Java-Requirements}
* Current Ehcache releases require Java 1.5 and 1.6 at runtime.
* Ehcache 1.5 requires Java 1.4. Java 1.4 is not supported with Terracotta distributed Ehcache.
* The ehcache-monitor module, which provides management and monitoring, will work with Ehcache 1.2.3 but only for Java 1.5 or higher.

### Mandatory Dependencies
* Ehcache core 1.6 through to 1.7.0 has no dependencies.
* Ehcache core 1.7.1 depends on SLF4J ([http://www.slf4j.org](http://www.slf4j.org)), an increasingly commonly used logging framework
which provides a choice of concrete logging implementation. See the page on [Logging](/documentation/operations/logging) for configuration details.

Other modules have dependencies as specified in their maven POMs.

### Maven Snippet

To include Ehcache in your project, use:

    <dependency>
      <groupId>net.sf.ehcache</groupId>
      <artifactId>ehcache</artifactId>
      <version>2.3.1</version>
      <type>pom</type>
    </dependency>


Note: Be sure to substitute the version number above with the version number of Ehcache that you want to use.

If using Terracotta Distributed Ehcache, also add:

    <dependency>
      <groupId>org.terracotta</groupId>
      <artifactId>terracotta-toolkit-1.4-runtime</artifactId>
      <version>4.0.0</version>
    </dependency>

    <repositories>
      <repository>
        <id>terracotta-repository</id>
        <url>http://www.terracotta.org/download/reflector/releases</url>
        <releases>
          <enabled>true</enabled>
        </releases>
      </repository>
    </repositories>

Be sure to check the dependency versions for compatibility. Versions released in a single kit are guaranteed compatible.


## Distributed Cache Development with Maven and Ant

With a Distributed Ehcache, there is a Terracotta Server Array. At development time, this necessitates running a server locally for integration and/or interactive testing.
There are plugins for Maven and Ant to simplify and automate this process.

For Maven, Terracotta has a  plugin available which makes this very simple.

#### Setting up for Integration Testing

    <pluginRepositories>
       <pluginRepository>
           <id>terracotta-snapshots</id>
           <url>http://www.terracotta.org/download/reflector/maven2</url>
           <releases>
               <enabled>true</enabled>
           </releases>
           <snapshots>
               <enabled>true</enabled>
           </snapshots>
       </pluginRepository>
    </pluginRepositories>
    <plugin>
       <groupId>org.terracotta.maven.plugins</groupId>
       <artifactId>tc-maven-plugin</artifactId>
       <version>1.5.1</version>
       <executions>
           <execution>
               <id>run-integration</id>
               <phase>pre-integration-test</phase>
               <goals>
                   <goal>run-integration</goal>
               </goals>
           </execution>
           <execution>
               <id>terminate-integration</id>
               <phase>post-integration-test</phase>
               <goals>
                   <goal>terminate-integration</goal>
               </goals>
           </execution>
       </executions>
    </plugin>

Note: Be sure to substitute the version number above with the current version number.

#### Interactive Testing
To start Terracotta:

    mvn tc:start

To stop Terracotta:

    mvn tc:stop

See the [Terracotta Forge](http://forge.terracotta.org/releases/projects/tc-maven-plugin/) for a complete reference.
