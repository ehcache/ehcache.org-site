---
---
# JRuby and Rails Caching <a name="rails-and-jruby-caching"/>

 


## Introduction
jruby-ehcache is a JRuby Ehcache library which makes a commonly used subset of Ehcache's API available to
JRuby. All of the strength of Ehcache is there, including BigMemory and the ability to cluster with Terracotta.
It can be used directly via its own API, or as a Rails caching provider.

## Installation
### Installation for JRuby
Ehcache JRuby integration is provided by the jruby-ehcache gem.  To install it, simply execute:

    jgem install jruby-ehcache

 Note that you may need to use "sudo" to install gems on your system.
 
### Installation for Rails
 
 If you want Rails caching support, you should also install the correct gem for your Rails version:

    jgem install jruby-ehcache-rails2 # for Rails 2
    jgem install jruby-ehcache-rails3 # for Rails 3

An alternative installation is to simply add the appropriate jruby-ehcache-rails dependency to your Gemfile, and then run a Bundle Install. This will pull in the latest jruby-ehcache gem.

### Dependencies

*   JRuby 1.5 and higher
*   Rails 2 for the jruby-ehcache-rails2
*   Rails 3 for the jruby-ehcache-rails3
*   Ehcache 2.4.6 is the declared dependency, although any version of Ehcache will work. 

The jruby-ehcache gem comes bundled with the ehcache-core.jar. To use a different version of Ehcache, place the Ehcache jar in the same Classpath as JRuby (for standalone JRuby) or in the Rails lib directory (for Rails).

## Configuring Ehcache
 Configuring Ehcache for JRuby is done using the same ehcache.xml file as
 used for native Java Ehcache.  The ehcache.xml file can be placed either
 in your Classpath or, alternatively, can be placed in the same directory as
 the Ruby file in which you create the CacheManager object from your Ruby
 code. For a Rails application, the ehcache.xml file should reside in the
 config directory of the Rails application.

## Using the jruby-ehcache API directly

### Basic Operations
To make Ehcache available to JRuby:

    require 'ehcache'

Note that, because jruby-ehcache is provided as a Ruby Gem, you must
make your Ruby interpreter aware of Ruby Gems in order to load it.  You
can do this by either including -rubygems on your jruby command line, or
you can make Ruby Gems available to JRuby globally by setting
the RUBYOPT environment variable as follows:

<pre><code>export RUBYOPT=rubygems</code></pre>


To create a CacheManager, which you do once when the application starts:

<pre><code>manager = Ehcache::CacheManager.new</code></pre>

To access an existing cache (call it "sampleCache1"):

<pre><code>cache = manager.cache("sampleCache1")</code></pre>

To create a new cache from the defaultCache:

<pre><code>cache = manager.cache</code></pre>

To put into a cache:

<pre><code>cache.put("key", "value", {:ttl => 120})</code></pre>

To get from a cache:

<pre><code>cache.get("key")  # Returns the Ehcache Element object
cache["key"]      # Returns the value of the element directly</code></pre>

To shut down the CacheManager:
This is only when you shut your application down.
It is not necessary to call this if the cache is configured for persistence or is clustered with Terracotta, but
it is always a good idea to do it.

<pre><code>manager.shutdown</code></pre>


### Supported Properties
The following caching options are supported in JRuby:

<table markdown="1">
<tr><th>Property</th><th>Argument Type</th><th>Description</th></tr>
<tr><td> unlessExist, ifAbsent</td><td>boolean

</td><td>If true, use the putIfAbsent method.</td></tr>
<tr><td> elementEvictionData</td><td>ElementEvictionData

</td><td>Sets this element’s eviction data instance.</td></tr>
    
<tr><td>eternal</td><td>boolean

</td><td>Sets whether the element is eternal.</td></tr>

<tr><td>timeToIdle, tti</td><td>int

</td><td>Sets time to idle.</td></tr>
    
<tr><td> timeToLive, ttl, expiresIn</td><td>int

</td><td>Sets time to Live.</td></tr>

<tr><td> version</td><td>long

</td><td>Sets the version attribute of the ElementAttributes object.</td></tr>
</table>


### Example Configuration

<pre><code>class SimpleEhcache
 #Code here
 require 'ehcache'
 manager = Ehcache::CacheManager.new
 cache = manager.cache
 cache.put("answer", "42", {:ttl => 120})
 answer = cache.get("answer")
 puts "Answer: #{answer.value}"
 question = cache["question"] || 'unknown'
 puts "Question: #{question}"
 manager.shutdown
end</code></pre>

As you can see from the example, you create a cache using CacheManager.new, and you can control the "time to live" value of a
cache entry using the :ttl option in cache.put. 


## Using Ehcache from within Rails

### General Overview
#### The ehcache.xml file
Configuration of Ehcache is still done with the ehcache.xml file, but for Rails applications you must place this file in the
config directory of your Rails app.
Also note that you must use JRuby to execute your Rails application, as these gems utilize JRuby's Java integration
to call the Ehcache API.
With this configuration out of the way, you can now use the Ehcache API directly from your Rails controllers and/or models.
You could of course create a new Cache object everywhere you want to use it, but it is better to create a single instance
and make it globally accessible by creating the Cache object in your Rails environment.rb file.
For example, you could add the following lines to config/environment.rb:

<pre><code>require 'ehcache'
EHCACHE = Ehcache::CacheManager.new.cache</code></pre>

By doing so, you make the EHCACHE constant available to all Rails-managed objects in your application.  Using the Ehcache API is
now just like the above JRuby example.
If you are using Rails 3 then you have a better option at your disposal: the built-in Rails 3 caching API.
This API provides an abstraction layer for caching underneath which you can plug in any one of a number of caching providers.
The most common provider to date has been the memcached provider, but now you can also use the Ehcache provider.
Switching to the Ehcache provider requires only one line of code in your Rails environment file
(e.g. development.rb or production.rb):

<pre><code>config.cache_store = :ehcache_store, {
                        :cache_name => 'rails_cache',
                        :ehcache_config => 'ehcache.xml'
                    }</code></pre>

This configuration will cause the Rails.cache API to use Ehcache as its cache store.
The :cache_name and :ehcache_config are both optional parameters, the default values
for which are shown in the above example. The value of the :ehcache_config parameter
can be either an absolute path or a relative path, in which case it is interpreted
relative to the Rails app's config directory.
A very simple example of the Rails caching API is as follows:

<pre><code>Rails.cache.write("answer", "42")
Rails.cache.read("answer")  # => '42'</code></pre>

Using this API, your code can be agnostic about the underlying provider, or even switch providers based on the current environment
(e.g. memcached in development mode, Ehcache in production).
The write method also supports options in the form of a Hash passed as the final parameter. 

See the [Supported Properties](/documentation/2.8/integrations/jruby#supported-properties) table above for the options that are supported. These options are passed to the write method as Hash options using either camelCase or underscore notation,
as in the following example:

<pre><code>Rails.cache.write('key', 'value', :time_to_idle => 60.seconds, :timeToLive => 600.seconds)
caches_action :index, :expires_in => 60.seconds, :unless_exist => true</code></pre>

#### Turn on caching in your controllers
You can also configure Rails to use Ehcache for its automatic action caching
and fragment caching, which is the most common method for caching at the
controller level. To enable this, you must configure Rails to perform
controller caching, and then set Ehcache as the provider in the same way
as for the Rails cache API:

<pre><code>config.action_controller.perform_caching = true
config.action_controller.cache_store = :ehcache_store</code></pre>

### Setting up a Rails Application with Ehcache
Here are the basic steps for configuring a Rails application to use Ehcache:

1. For this example, we will create a new Rails application with the custom template from JRuby.org. The following command creates a "rails-bigmemory" application:

        jruby -S rails new rails-bigmemory -m http://jruby.org/rails3.rb

2. The example application will be a simple address book. Generate a scaffold for the address book application, which will create contacts including a first name, last name, and email address.

        jruby -S rails generate scaffold Contact first_name: string last_name: string email_address: string

3. Add support for caching with Ehcache. There are several ways to do this, but for this example, we will use the Action Controller caching mechanism. Open the ContactsController.rb. Add a call to the Action method to tell it to cache the results of our index and show pages.

        caches_action :index, :show

    To expire items from the cache as appropriate, add calls to expire the results of the caching calls.

    Under create, add the following:

        expire_action :action => 'index'

    Under update, add the following:

         expire_action :action => 'show', :id => params[:id]
         expire_action :action => 'index'
         
    Under destroy, add the following:

          expire_action :action => 'index'

4. Now that the application is configured to support caching, specify Ehcache as its caching provider. Open the Gemfile and declare a dependency on the ehcache-jruby gem. Add the following line:

         gem 'ehcache-jruby-rails3'

5. In the development.rb file, enable caching for the Rails Action Controller mechanism, which is disabled by default in developement mode. (Note that caching must be configured for each environment in which you want to use it.) This file also needs a specification for using Ehcache as the cache store provider. Add the following two lines to the .rb file:

         config.action_controller.perform_caching = true
         config.cache_store = :ehcache_store

6. Run the Bundle Install command. 

         jruby -S bundle install

7. Run the Rake command to create the database and populate the initial schema.

         jruby -S rake db:create db:migrate

8. (Optional) Set up the Ehcache monitor. This involves the following four steps:
    * Install the Ehcache Monitor from [Downloads](http://ehcache.org/downloads/catalog).
    * Start the Ehcache Monitor server.
    * Connect the application to the monitor server by copying the ehcache-probe JAR (bundled with the Ehcache Monitor) to your Rails lib directory.
    * Create an ehcache.xml file in the Rails application config directory. In the ehcache.xml file, add the following:

            <cacheManagerPeerListenerFactory
                class="org.terracotta.ehcachedx.monitor.probe.ProbePeerListenerFactory"
                properties="monitorAddress=localhost, monitorPort=9889, memoryMeasurement=true"/>

Now you are ready to start the application with the following command: 
    
    jruby -S rails server
    
Once the application is started, populate the cache by adding, editing, and deleting contacts. To see the Contacts address book, enter the following in your browser:
    
    http://localhost:3000/contacts
    
To view cache activity and statistics in the Ehcache monitor, enter the following in your browser:

    http://localhost:9889/monitor

For more information about how to use the monitor, refer to the [Ehcache Monitor](/documentation/2.8/operations/monitor) page. 


### Adding BigMemory under Rails
BigMemory provides in-memory data management with a large additional cache located right at the node where your application runs. To upgrade your Ehcache to use BigMemory with your Rails application, follow these steps.

1. Add the ehcache-core-ee.jar to your Rails application lib directory.

2. Modify the ehcache.xml file (in the config directory of your Rails application) by adding the following to each cache where you want to enable BigMemory:

        overflowToOffHeap="true"
        maxBytesLocalOffHeap="1G"

    When `overflowToOffHeap` is set to true, it enables the cache to utilize off-heap memory storage to improve performance. Off-heap memory is not subject to Java GC cycles and has a size limit set by the Java property MaxDirectMemorySize.

    `maxBytesLocalOffHeap` sets the amount of off-heap memory available to the cache, and is in effect only if overflowToOffHeap is true. For more information about sizing caches, refer to [How To Size Caches](/documentation/2.8/configuration/cache-size).

3. Also in the ehcache.xml file, set `maxEntriesLocalHeap` to at least 100 elements when using an off-heap store to avoid performance degradation. Lower values for `maxEntriesLocalHeap` trigger a warning to be logged.

4. Now that your application is configured to use BigMemory, start it with the following commands:


        jruby -J-Dcom.tc.productkey.path=/path/to/key -J-XX:MaxDirectMemorySize=2G -S rails server

    This will configure a system property that points to the location of the license key, and it will set the direct memory size. The `maxDirectMemorySize` must be at least 256M larger than total off-heap memory (the unused portion will still be available for other uses). 

For additional configuration options, refer to the [BigMemory](/documentation/2.8/configuration/bigmemory#advanced-configuration-options) page.

Note that only Serializable cache keys and values can be placed in the store, similar to DiskStore. Serialization and deserialization take place on putting and getting from the store. This is handled automatically by the jruby-ehcache gem.

