# Development with Maven and Ant
Development with Maven and Ant
 
With a Distributed Ehcache, there is a Terracotta Server Array. At development time, this necessitates running a server locally.
for integration and/or interactive testing.
There are plugins for Maven and Ant to simplify and automate this process.

## Maven
Terracotta has a Maven plugin available which makes this very simple.

### Setting up for Integration Testing

<pre><code>
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
</code></pre>

### Interactive Testing
To start Terracotta:

<pre><code>
mvn tc:start
</code></pre>

To stop Terracotta:

<pre><code>
mvn tc:stop
</code></pre>

See [http://forge.terracotta.org/releases/projects/tc-maven-plugin/](http://forge.terracotta.org/releases/projects/tc-maven-plugin/) for a complete reference.
