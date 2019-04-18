require_relative 'fashion_check_tweet'

require 'twitter'
require 'aws-sdk-dynamodb'
require 'sentry-raven'

class Crawler
  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV['CONSUMER_KEY']
      config.consumer_secret     = ENV['CONSUMER_SECRET']
      config.access_token        = ENV['ACCESS_TOKEN']
      config.access_token_secret = ENV['ACCESS_TOKEN_SECRET']
    end

    @dynamodb = Aws::DynamoDB::Client.new
  end

  def search
    results = @client.search(ENV['SEARCH_KEYWORD'])
    @fashion_check_tweets = results.map { |tweet| FashionCheckTweet.new(tweet) }
  end

  def save
    @fashion_check_tweets.each do |tweet|
      begin
        next unless tweet.valid?
        @dynamodb.put_item(tweet.dynamo_params)
      rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
        puts "DynamoDB put_item failed. url: #{tweet.tweet_url}"
      end
    end
  end
end

def handler(event:, context:)
  Raven.configure { |config| config.dsn = ENV['SENTRY_DSN'] }
  begin
    crawler = Crawler.new
    crawler.search
    crawler.save
  rescue StandardError => exception
    Raven.capture_exception(exception)
  ensure
    { 'statusCode': 200 }
  end
end
