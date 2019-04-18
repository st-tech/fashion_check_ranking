require './app/models/dynamo_db_client_wrapper.rb'

class Tweet
  attr_accessor :account_id, :score, :tweet_url, :image_url, :delete_flag

  TABLE_NAME = 'Tweets'.freeze

  class << self
    def ranking
      order_by_score_desc
        .reject { |t| t.delete_flag }
        .take(30)
    end

    def all
      params = {
        table_name: TABLE_NAME,
        select: 'ALL_ATTRIBUTES',
      }

      db.scan(params)
        .map { |attrs| self.new(parse(attrs)) }
    end

    def order_by_score_desc
      all.sort_by { |t| t.score }.reverse!
    end

    def create_table
      db.create_table table_schema
    end

    private

    def db
      @db ||= self.new.db
    end

    def parse(attributes)
      {
        account_id: attributes['AccountId'],
        score: attributes['Score'],
        tweet_url: attributes['TweetUrl'],
        image_url: attributes['ImageUrl'],
        delete_flag: attributes['DeleteFlag'],
      }
    end

    def table_schema
      {
        attribute_definitions: [
          {
            attribute_name: 'AccountId',
            attribute_type: 'S',
          }
        ],
        key_schema: [
          {
            attribute_name: 'AccountId',
            key_type: 'HASH',
          }
        ],
        provisioned_throughput: {
          read_capacity_units: 5,
          write_capacity_units: 5,
        },
        table_name: TABLE_NAME,
      }
    end
  end

  def initialize(params={})
    @account_id = params[:account_id]
    @score = params[:score]
    @tweet_url = params[:tweet_url]
    @image_url = params[:image_url]
    @delete_flag = params[:delete_flag]
  end

  def score
    @score.to_i
  end

  def save
    valid? || raise('record invalid')

    db.put_item table_name: TABLE_NAME, item: unparse
  end

  def valid?
    account_id.is_a?(String) &&
      score.is_a?(Integer) &&
      tweet_url.is_a?(String) &&
      image_url.is_a?(String)
  end

  def db
    @db ||= DynamoDBClientWrapper.new
  end

  private

  def unparse
    {
      AccountId: account_id,
      Score: score,
      TweetUrl: tweet_url,
      ImageUrl: image_url,
      DeleteFlag: delete_flag,
    }
  end
end
