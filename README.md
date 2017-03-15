This is the source code/files for the ehcache.org website. The files in this repository are source files, some of which 
include templating and other raw bits that need to be "compiled"/"built" in order to have files that are suitable to go 
onto a webserver.

## Instructions for building/previewing

### Contributing

* Clone this repository to your local system (if you're going to contribute content, fork it first, and clone that)
* Create a branch to contribute content - `git checkout -b the_branch_for_the_pull_request`

### Mac

On Mac OS X, install Xcode command line tools by executing: `xcode-select --install`

### Ruby

* Install [rvm](https://rvm.io) for handling Ruby locally, following instructions are designed for that
* Install Ruby 2.2.1 - `rvm install 2.2.1`
* Create a new gemset in that ruby version - `rvm gemset create ehcache`
* Make sure you are using the version and gemset - `rvm use 2.2.1@ehcache`
* Import the gems found in `default.gems` - `rvm gemset import`

### Linking with Ehcache 3 repository

To generate the *full* site including Ehcache 3 docs, you need to link some Ehcache 3 directories in this repository.

You should do it for every version you want to work on.

```bash
cd ${ehcache3_root_directory}
git worktree add ${branch} ehcache.org_root_directory/${version_dir}
cd ${ehcache.org_root_directory}
ln -s $PWD/${version_dir}/docs/src/docs/asciidoc/user documentation/${version}
```

|version|version_dir|branch     |
|-------|-----------|-----------|
|3.0    |\_eh3      |release/3.0|
|3.1    |\_eh31     |release/3.1|
|3.2    |\_eh32     |release/3.2|
|3.3    |\_eh33     |master     |

Of course, if for some reason you want a specific tag for a version, just create a worktree based on the tag instead.

### Linking with Terracotta events repository

The content of the [events menu](http://www.ehcache.org/events/) is coming from another repository. To see it in local, 
just clone the repository and add a link to it.

```bash
git clone `git@github.com:Terracotta-OSS/terracotta.org-site-events.git
ln -s $PWD/terracotta.org-site-events ${ehcache.org_root_directory}/events
```

### Jekyll

The website is rendered by [Jekyll](https://jekyllrb.com/). It is built locally and the result is pushed to the 
[website repository](https://github.com/ehcache/ehcache.github.io).

To generate and view (locally serve) the site `jekyll serve` then point your browser at `http://localhost:4000`.

To simply generate the site use `jekyll build`.

To generate the site including all production elements (ie analytics) `JEKYLL_ENV=production jekyll build`  

**NOTE:** If you used links to include Ehcache 3 documentation, you may see an error about watching the same folder twice - it can be ignored.

---

See the [issue tracker](https://github.com/ehcache/ehcache.org-site) if you are interested in improving the site in general.

---

### Making Changes to the content

If you want to make changes to the website, make them here (in this repository) - as this is where all the source/files for the website are kept.

For instance:

* If there is a new release being made, generated javadoc (from the product build) should be put into the `apidocs` directory
* New official docs should be put into the `documentation` and/or `generated` directories as appropriate
* Pay attention to the content of the `_config.yml` file in the root of this repository as there are properties there that 
control various things just as which exact version of javadoc to show for what (e.g. at the time of this writing we link 
to `2.8.5` javadoc for all `2.8` documentation).
* After making your changes, commit them (remember to do your work in a branch) and create a pull request.

---

### Deploying changes to the live webserver

[ehcache.org](http://www.ehcache.org/) is served/hosted by github. The webserver does NOT serve the content from this 
repository. It serves the exact content of [another repository](https://github.com/ehcache/ehcache.github.io).

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

__IMPORTANT:__ Your content MUST be short! Links, headline, title, that's all.
