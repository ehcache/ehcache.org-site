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

* To generate and view the site "jekyll serve -w"   ( then point your browser at http://localhost:4000" )
* To generate the site "jekyll build"  

---


### TODOS:

* "About" -> "Features" page:
  * could still use some love, but isn't so bad anymore


