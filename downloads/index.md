---
layout: page
title: Downloads
visible_title: "Download Ehcache"
permalink: /downloads/
active_menu_id: ehc_mnu_download
---

## Direct/Manual Downloads


#### Ehcache 2.x

> [Ehcache 2.10.0](http://s3.amazonaws.com/tcdistributions/ehcache-2.10.0-distribution.tar.gz)  .tar.gz


For more information on this release, see the [release notes](http://www.terracotta.org/confluence/display/release/Home).

For JSR107 support with Ehcache 2, use the [ehcache-jcache](https://github.com/ehcache/ehcache-jcache/releases) module.

---

#### Ehcache 3

> [Ehcache 3.0 Milestone 2](https://github.com/ehcache/ehcache3/releases/download/v3.0.0.m2/ehcache-3.0.0.m2.jar) .jar

More files related to milestone releases of Ehcache 3 are available on the project's [GitHub release page](https://github.com/ehcache/ehcache3/releases).

---


## Maven

### Maven Snippet

#### Ehcache 2

To include Ehcache 2.x in your project, use:


    <dependency>
      <groupId>net.sf.ehcache</groupId>
      <artifactId>ehcache</artifactId>
      <version>2.3.1</version>
      <type>pom</type>
    </dependency>

_Note: Be sure to substitute the version number above with the version number of Ehcache that you want to use._

#### Ehcache 3

To include Ehcache 3.x in your project, use:

    <dependency>
      <groupId>org.ehcache</groupId>
      <artifactId>ehcache</artifactId>
      <version>3.0.0.m2</version>
    </dependency>

_Note: Be sure to substitute the version number above with the version number of Ehcache that you want to use._

---

### General Maven Info

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


    <repositories>
      <repository>
        <id>sourceforge</id>
        <url>http://oss.sonatype.org/content/groups/sourceforge/</url>
        <releases>
          <enabled>true</enabled>
        </releases>
        <snapshots>
          <enabled>true</enabled>
        </snapshots>
      </repository>
    ...
    </repositories>
