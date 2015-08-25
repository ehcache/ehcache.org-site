---
layout: page
title: Downloads
visible_title: "Download Ehcache"
permalink: /downloads/
active_menu_id: ehc_mnu_download
---

## Direct/Manual Downloads

The ehcache module distribution is the main Ehcache distribution.

[Ehcache 2.10.0](http://ehcache.org/downloads/destination?name=ehcache-2.10.0-distribution.tar.gz&bucket=tcdistributions&file=ehcache-2.10.0-distribution.tar.gz)


For more information on this release, see the [release notes](http://www.terracotta.org/confluence/display/release/Home).

For JSR107 support with Ehcache 2, use the [ehcache-jcache](https://github.com/ehcache/ehcache-jcache/releases) module.

--

Milestone releases of Ehcache 3 are available on the project's [GitHub release page](https://github.com/ehcache/ehcache3/releases).

---

<p><a href="http://sourceforge.net/projects/ehcache/files/" title="">Older Ehcache artifacts on SourceForge &rsaquo;</a></p>

<hr/>

## Maven

#### Releases

Ehcache publishes releases for all modules to the SourceForge Maven repository at:

[http://oss.sonatype.org/](http://oss.sonatype.org/)

You can browse the repo <a href="http://oss.sonatype.org/content/repositories/sourceforge-releases/net/sf/ehcache">here &rsaquo;</a>
From there the releases are immediately synced with the Maven central repository.

#### Snapshots

Ehcache publishes regular snapshots for all modules to the SourceForge Maven repository mentioned above

Note that snapshots are recommended for developer testing only.

You can browse the snapshot repo <a href="http://oss.sonatype.org/content/repositories/sourceforge-snapshots/net/sf/ehcache">here &rsaquo;</a>

To get snapshots you will need to add the following repository to your maven config:

<pre>
&lt;repositories&gt;
  &lt;repository&gt;
    &lt;id&gt;sourceforge&lt;/id&gt;
    &lt;url&gt;http://oss.sonatype.org/content/groups/sourceforge/&lt;/url&gt;
    &lt;releases&gt;
      &lt;enabled&gt;true&lt;/enabled&gt;
    &lt;/releases&gt;
    &lt;snapshots&gt;
      &lt;enabled&gt;true&lt;/enabled&gt;
    &lt;/snapshots&gt;
  &lt;/repository&gt;
...
&lt;/repositories&gt;
</pre>
