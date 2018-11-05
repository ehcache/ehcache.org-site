#!/usr/bin/env bash

# This script should only be used for building the production copy of the site

# Manual post-processing - add tracking code to javadoc where it's easy to do
# for Javadoc for 3.x
for s in apidocs/*/script.js ; do
    echo "Adding analytics to $s"
    cat _includes/analytics.js >> $s
done

# for Javadoc for 2.x
echo "Adding Analytics to apidocs/2.x"
echo -e "<!--Added by publisher -->\\n<script>$(cat _includes/analytics.js)\\n</script>" > _includes/analytics.html
for foo in $(find apidocs/2.* -name '*.html') ; do sed -i -e '/<HEAD>/r _includes/analytics.html' $foo ; done
rm _includes/analytics.html
