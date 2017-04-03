#!/usr/bin/env bash

set -v

bundle exec htmlproofer --only-4xx --empty-alt-ignore --check-html --checks-to-ignore "ImageCheck" --file-ignore "/apidocs/,/generated/" --log-level debug _site
