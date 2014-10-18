class User < ActiveRecord::Base

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.screen_name = auth['info']['nickname']
      user.name = auth['info']['name']
      user.token = auth['credentials']['token']
      user.secret = auth['credentials']['secret']
    end
  end
 
  def self.get_twitter_client
    client = Twitter::Streaming::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
  end

end
