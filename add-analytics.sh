#!/usr/bin/env bash

# This script should only be used for building the production copy of the site

if [ -z "$2" ] ; then
  echo "Usage: $0 SOURCE_DIR TARGET_DIR"
  echo "  target dir can be the same as source"
  exit 3
fi
SOURCE=$1
TARGET=$2

# Manual post-processing - add tracking code to javadoc where it's easy to do
# for Javadoc for 3.x
for s in $TARGET/apidocs/*/script.js ; do
    echo "Adding analytics to $s"
    cat $SOURCE/_includes/analytics.js >> $s
done

# for Javadoc for 2.x
echo "Adding Analytics to apidocs/2.x"
echo -e "<!--Added by publisher -->\\n<script>$(cat $SOURCE/_includes/analytics.js)\\n</script>" > $SOURCE/_includes/analytics.html
for foo in $(find $TARGET/apidocs/2.* -name '*.html') ; do sed -i -e "/<HEAD>/r $SOURCE/_includes/analytics.html" $foo ; done
rm $SOURCE/_includes/analytics.html
