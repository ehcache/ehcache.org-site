---
---
# Using Coldfusion and BigMemory Go

 

##Introduction
ColdFusion ships with BigMemory Go's Ehcache. The ColdFusion community has actively engaged with Ehcache and have put out lots of great blogs. Here are three to get you
started.
For a short introduction, see [Raymond Camden's blog](http://www.coldfusionjedi.com/index.cfm/2009/7/18/ColdFusion-9-and-Caching-Enhancements).
For more in-depth analysis, see [Rob Brooks-Bilson's nine-part Blog Series](http://www.brooks-bilson.com/blogs/rob/index.cfm/2009/7/21/Caching-Enhancements-in-ColdFusion-9--Part-1-Why-Cache) or [14 days of ColdFusion caching](http://www.aaronwest.net/blog/index.cfm/2009/11/17/14-Days-of-ColdFusion-9-Caching-Day-1--Caching-a-Full-Page), by Aaron West, covering a different topic each day.


## Example Integration
To integrate BigMemory Go with ColdFusion, first add the BigMemory Go jars to your web application lib directory.

The following code demonstrates how to call Ehcache from ColdFusion.
It will cache a CF object in Ehcache and the set expiration time to 30 seconds. If you refresh the page many times within 30 seconds, you will see the data from cache. After 30 seconds, you will see a cache miss, then the code will generate a new object and put in cache again.

    <CFOBJECT type="JAVA" class="net.sf.ehcache.CacheManager" name="cacheManager">
    <cfset cache=cacheManager.getInstance().getCache("MyBookCache")>
    <cfset myBookElement=#cache.get("myBook")#>
    <cfif IsDefined("myBookElement")>
       <cfoutput>
        myBookElement: #myBookElement#<br />
       </cfoutput>
       <cfif IsStruct(myBookElement.getObjectValue())>
               <strong>Cache Hit</strong><p/>
               <!-- Found the object from cache -->
               <cfset myBook = #myBookElement.getObjectValue()#>
       </cfif>
    </cfif>
    <cfif IsDefined("myBook")>
    <cfelse>
    <strong>Cache Miss</strong>
       <!-- object not found in cache, go ahead create it -->
       <cfset myBook = StructNew()>
       <cfset a = StructInsert(myBook, "cacheTime", LSTimeFormat(Now(), 'hh:mm:sstt'), 1)>
       <cfset a = StructInsert(myBook, "title", "EhCache Book", 1)>
       <cfset a = StructInsert(myBook, "author", "Greg Luck", 1)>
       <cfset a = StructInsert(myBook, "ISBN", "ABCD123456", 1)>
       <CFOBJECT type="JAVA" class="net.sf.ehcache.Element" name="myBookElement">
       <cfset myBookElement.init("myBook", myBook)>
       <cfset cache.put(myBookElement)>
    </cfif>
    <cfoutput>
    Cache time: #myBook["cacheTime"]#<br />
    Title: #myBook["title"]#<br />
    Author: #myBook["author"]#<br />
    ISBN: #myBook["ISBN"]#
    </cfoutput>

