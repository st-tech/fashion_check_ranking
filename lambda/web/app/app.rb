require 'sinatra'
require './app/models/tweet.rb'

get '/' do
  @tweets = Tweet.ranking
  erb :index
end
