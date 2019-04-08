#!/bin/bash

bundle install --deployment --path=vendor/bundle
zip -r web.zip Gemfile Gemfile.lock app web.rb vendor
aws --profile=iqon s3 cp web.zip s3://fashion-check-ranking-production/lambda/web.zip
