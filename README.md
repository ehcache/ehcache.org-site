
This is the source code/files for the ehcache.org website.  The files in this repository are source files, some of which include templating and other raw bits that need to be "compiled"/"built" in order to have files that are suitable to go onto a webserver.

### Instructions for building/previewing

* Install Jekyll if you have not - follow instructions on the Jekyll home page (after first installing Ruby)
[http://jekyllrb.com/](http://jekyllrb.com/)

* After installing jekyll, install some gems:
  * nokogiri : "gem install nokogiri"
  * asciidoctor: " gem install jasciidoctor"
  * jekyll-asciidoc: " gem install jekyll-asciidoc"

* Clone this repository to your local system (if you're going to contribute content, fork it first, and clone that)
* cd into the "ehcache.github.io" directory
* "git checkout ehcache.org" to switch to this branch


* To generate the *full* site including Ehcache 3 docs, you need to do the following:
  * within the root your clone of this repository, the contents of ehcache3 repository needs to be linked/or copied as "_eh3"
  * within the root your clone of this repository, the contents of ehcache3 repository's docs/src/docs/asciidoc/user folder needs to be linked/or copied as "documentation/3.0"

* To generate and view (locally serve) the site "jekyll serve -w"   ( then point your browser at http://localhost:4000" )
* To simply generate the site "jekyll build"  

---


### TODOS:

* "About" -> "Features" page:
  * could still use some love, but isn't so bad anymore

---

### Deploying changes to the live webserver

ehcache.org is served/hosted by github.   The webserver does NOT serve the content from this repository.  It serves the exact content of the repository at:  https://github.com/ehcache/ehcache.github.io

* Build the site content according to the directions above (using the source files from this (ehcache.org-site) repository)
* After the site content is built, it will be in the _site directory
* Clone a local copy (or if you have one already, pull in all updates) of the ehcache.github.io repository
* Create a branch for your updates, and switch to (checkout) that branch
* Copy all content from the _site directory you just built from this repository into the root of your new branch of the other repository
* Commit your changes and make a pull request to get the content of that branch into the master branch of the ehcache.github.io repository (which will then make it "live").


