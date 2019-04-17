class FashionCheckTweet
  attr_accessor :account_id, :score, :tweet_url, :image_url

  TWEET_TEMPLATE_JP = /あなたのファッションは(\d+)いいねされそうです/
  TWEET_TEMPLATE_EN = /Your style would receive (\d+) likes!/

  def initialize(tweet)
    @tweet = tweet
    parse
  end

  def dynamo_params
    {
      table_name: 'Tweets',
      item: {
        'AccountId': account_id,
        'Score': score,
        'TweetUrl': tweet_url,
        'ImageUrl': image_url,
      },
      condition_expression: 'attribute_not_exists(TweetUrl)'
    }
  end

  def valid?
    return false if account_id.empty?
    return false if tweet_url.empty?
    return false if image_url.empty?
    return false if score.nil? || score.zero?
    true
  end

  private

  def parse
    @account_id = @tweet.user.name
    @tweet_url = @tweet.url.to_s
    @image_url = @tweet.user.profile_image_url.to_s
    score_text = @tweet.text.match(TWEET_TEMPLATE_JP) || @tweet.text.match(TWEET_TEMPLATE_EN)
    @score = score_text.nil? ? nil : score_text[1].to_i
  end
end
