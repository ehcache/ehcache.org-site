
This is the source code/files for the ehcache.org website.  The files in this repository are source files, some of which include templating and other raw bits that need to be "compiled"/"built" in order to have files that are suitable to go onto a webserver.

### Instructions for building/previewing

* On Mac OS X, install Xcode command line tools by executing: `xcode-select --install`
* Install the toolchain
  * (Recommended) Use [rvm](https://rvm.io) for handling Ruby locally, following instructions are designed for that.
  * Install Ruby 2.2.1 - `rvm install 2.2.1`
  * Create a new gemset in that ruby version - `rvm gemset create <name>`
  * Make sure you are using the version and gemset - `rvm use 2.2.1@<name>`
  * Import the gems found in default.gems - `rvm gemset import`
* Clone this repository to your local system (if you're going to contribute content, fork it first, and clone that)
  * Create a branch to contribute content
* To generate the *full* site including Ehcache 3 docs, you need to do the following:
  * the contents of ehcache3 repository needs to be linked/or copied as `_eh3`
  * the contents of ehcache3 repository's docs/src/docs/asciidoc/user folder needs to be linked/or copied as `documentation/3.0`
* To generate and view (locally serve) the site `jekyll serve` then point your browser at `http://localhost:4000`
* To simply generate the site `jekyll build`

NOTE: if you used links to include Ehcache 3 documentation, you may see an error about watching the same folder twice - it can be ignored.

---

See the issue tracker if you are interested in improving the site in general.

---

### Making Changes to the content

If you want to make changes to the website, make them here (in this repository) - as this is where all the source/files for the website are kept.

For instance:

* If there is a new release being made, generated javadoc (from the product build) should be put into the `apidocs` directory
* New official docs should be put into the `documentation` and/or `generated` directories as appropriate
* Pay attention to the content of the _config.yml file in the root of this repository as there are properties there that control various things just as which exact version of javadoc to show for what (e.g. at the time of this writing we link to `2.8.5` javadoc for all `2.8` documentation).


* After making your changes, commit them (remember to do your work in a branch) and create a pull request.

---

### Deploying changes to the live webserver

ehcache.org is served/hosted by github.   The webserver does NOT serve the content from this repository.  It serves the exact content of [another repository](https://github.com/ehcache/ehcache.github.io).

Once your pull request has been merged, the site is deployed automatically.

### Contributing a blog post

1. Ensure you first edit `_data/authors.yml` to add you information
2. Create a new ASCII Doc file under `_posts/blog`. The file should be named with the following format: `yyyy-MM-DD-title-in-lowercase.adoc`
3. Add a header in your file. Modify the fields according to your post, especially for the title, headline, tags, authors and date
```
---
layout: post
title: "Your blog post title"
headline: "Your blo post headline"
categories: blog
hidden: false
author: your_author_key
tags: [ehcache, website]
date: 2016-05-04T18:00:00-05:00
modified:
---
```
4. Send your pull request :+1:

### Contributing an external resource

Same rules apply as above, except that you have to put your file into `_posts/resources` and add a header like this one:

```
---
title: "Ehcache 3: JSR-107 on steroids"
headline: "Ehcache 3: JSR-107 on steroids at Devoxx Morocco by Louis Jacomet"
categories: resources
date: 2015-11-18T00:00:00-00:00
---
```

__IMPORTANT:__ Yout content MUST be short! Links, headline, title, that's all.
