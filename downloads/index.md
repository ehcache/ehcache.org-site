---
layout: page
title: Downloads
visible_title: "Download Ehcache"
permalink: /downloads/
active_menu_id: ehc_mnu_download
---

## Direct/Manual Downloads


#### Ehcache 2.x

> [Ehcache 2.10.1](http://d2zwv9pap9ylyd.cloudfront.net/ehcache-2.10.1-distribution.tar.gz)  .tar.gz


For more information on this release, see the [release notes](http://www.terracotta.org/confluence/display/release/Home).

For JSR107 support with Ehcache 2, use the [ehcache-jcache](https://github.com/ehcache/ehcache-jcache/releases) module.

---

#### Ehcache 3

> [Ehcache 3.0 Release Candidate 3](https://github.com/ehcache/ehcache3/releases/download/v3.0.0.rc3/ehcache-3.0.0.rc3.jar) .jar

More files related to milestone releases of Ehcache 3 are available on the project's [GitHub release page](https://github.com/ehcache/ehcache3/releases).

---


## Maven

### Maven Snippet

#### Ehcache 2

To include Ehcache 2.x in your project, use:

<pre class="prettyprint highlight"><code class="language-xml" data-lang="xml">    &lt;dependency&gt;
      &lt;groupId&gt;net.sf.ehcache&lt;/groupId&gt;
      &lt;artifactId&gt;ehcache&lt;/artifactId&gt;
      &lt;version&gt;2.10.1&lt;/version&gt;
      &lt;type&gt;pom&lt;/type&gt;
    &lt;/dependency&gt;
</code></pre>

_Note: Be sure to substitute the version number above with the version number of Ehcache that you want to use._

#### Ehcache 3

To include Ehcache 3.x in your project, use:

<pre class="prettyprint highlight"><code class="language-xml" data-lang="xml">    &lt;dependency&gt;
      &lt;groupId&gt;org.ehcache&lt;/groupId&gt;
      &lt;artifactId&gt;ehcache&lt;/artifactId&gt;
      &lt;version&gt;3.0.0.rc3&lt;/version&gt;
    &lt;/dependency&gt;
</code></pre>

_Note: Be sure to substitute the version number above with the version number of Ehcache that you want to use._

---

### General Maven Info

#### Releases

_Releases are available on Maven Central_.

Ehcache publishes releases for all modules to the Sonatype Maven repository at: [http://oss.sonatype.org/](http://oss.sonatype.org/)

You can browse the repository <a href="https://oss.sonatype.org/content/repositories/releases/">here &rsaquo;</a> look for Ehcache 2.x under `net/sf/ehcache` and Ehcache 3.x under `org/ehcache`.

From there the releases are immediately synced with the Maven central repository.

#### Snapshots

Ehcache publishes regular snapshots for Ehcache 3.x to the Sonatype Snapshot Maven repository.

Note that snapshots are recommended for developer testing only.

You can browse the snapshot repository <a href="http://oss.sonatype.org/content/repositories/sourceforge-snapshots">here &rsaquo;</a> look for Ehcache 3.x under `org/ehcache`.

To get snapshots you will need to add the following repository to your maven config:

<pre class="prettyprint highlight"><code class="language-xml" data-lang="xml">    &lt;repositories&gt;
      &lt;repository&gt;
        &lt;id&gt;sourceforge</id&gt;
        &lt;url&gt;https://oss.sonatype.org/content/repositories/snapshots/&lt;/url&gt;
        &lt;snapshots&gt;
          &lt;enabled&gt;true&lt;/enabled&gt;
        &lt;/snapshots&gt;
      &lt;/repository&gt;
    ...
    &lt;/repositories&gt;
</code></pre>
