#!/bin/bash

docker run -v `pwd`:`pwd` -w `pwd` -i -t lambci/lambda:build-ruby2.5 bundle install --deployment
zip -r crawler.zip Gemfile Gemfile.lock crawler.rb fashion_check_tweet.rb vendor
aws --profile=vasily s3 cp crawler.zip s3://fashion-check-ranking-production/lambda/crawler.zip
