require 'sinatra'
require './app/models/tweet.rb'

get '/' do
  @tweets = Tweet
    .not_deleted
    .order_by_score_desc
    .limit(5)
    .scoped
  erb :index
end
