require 'yaml'
require './app/models/tweet.rb'

Tweet.create_table

hash = YAML.load_file('db/seeds/tweets.yml')
JSON.parse(hash.to_json, symbolize_names: true)
  .values
  .map { |params| Tweet.new(params).save }
