---
---
# Java Requirements and Dependencies

## Java Requirements <a name="Java-Requirements"/>
* Current Ehcache releases require Java 1.5 and 1.6 at runtime.
* Ehcache 1.5 requires Java 1.4.
* The ehcache-monitor module, which provides management and monitoring, will work with Ehcache 1.2.3 but only for Java 1.5 or higher.

## Mandatory Dependencies
* Ehcache core 1.6 through to 1.7.0 has no dependencies.
* Ehcache core 1.7.1 depends on SLF4J ([http://www.slf4j.org](http://www.slf4j.org)), an increasingly commonly used logging framework
which provides a choice of concrete logging implementation. See the chapter on Logging for configuration details.

Other modules have dependencies as specified in their maven poms.

## Maven Snippet

To include Ehcache in your project use:

<pre>
  &lt;dependency&gt;
    &lt;groupId&gt;net.sf.ehcache&lt;/groupId&gt;
    &lt;artifactId&gt;ehcache&lt;/artifactId&gt;
    &lt;version&gt;2.3.1&lt;/version&gt;
    &lt;type&gt;pom&lt;/type&gt;
  &lt;/dependency&gt;
</pre>
