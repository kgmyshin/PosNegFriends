class HomeController < BaseController

  before_filter :login_required, :except=> ["login"]

  def index
    if session[:user_id]
      @current_user = User.find_by_id(session[:user_id])
      unless @current_user
        redirect_to home_login_path
      end
    else
      redirect_to home_login_path
    end
  end

  def login
  end

  def pos_rank
   @best_positive_user = ""
   @best_positive_value = -10000
   point_user_dict = get_user_point_dict
   point_user_dict.each_key do |key|
     if @best_positive_value < point_user_dict[key].point
      @best_positive_value = point_user_dict[key].point
      @best_positive_user = point_user_dict[key]
     end
   end
  end

  def neg_rank
    @best_negative_user = ""
    @best_negative_value = 10000
    point_user_dict = get_user_point_dict
    point_user_dict.each_key do |key|
      if @best_negative_value > point_user_dict[key].point
        @best_negative_value = point_user_dict[key].point
        @best_negative_user = point_user_dict[key]
      end
    end
  end


private
  
  def login_required
    if session[:user_id]
      @current_user = User.find(session[:user_id])
    else
      redirect_to home_login_path
    end
  end

  def get_user_point_dict
    user_point_dict = Hash.new
    tweets = get_twitter_client(@current_user).home_timeline({ count: 200 })
    tweets.each do |tweet|
      text = tweet.text
      user = tweet.user.screen_name

      cache = TweetCache.find_by_tw_id(tweet.id)
      pos_neg_point = 0
      if cache
        point = cache.posneg
      else
        point = get_pos_neg_point text
        cache = TweetCache.new
        cache.tw_id = tweet.id
        cache.posneg = point
        cache.save
      end
 
      if user_point_dict.include?(user)
        user_point_dict[user].point = point + user_point_dict[user].point
      else
        friend = Friend.new
        friend.name = tweet.user.screen_name
        friend.img_url = tweet.user.profile_image_url_https
        friend.point = point
        user_point_dict[user] = friend
      end
      
      if user_point_dict[user].tweet1.nil?
        user_point_dict[user].tweet1 = text
        user_point_dict[user].tweet1_link = "https://twitter.com/" + user + "/status/" + tweet.id.to_s
      elsif user_point_dict[user].tweet2.nil?
        user_point_dict[user].tweet2 = text
        user_point_dict[user].tweet2_link = "https://twitter.com/" + user + "/status/" + tweet.id.to_s
      end
      
      puts "negaposi : " + point.to_s
    end
    puts user_point_dict.inspect
    return user_point_dict
  end
  
  def get_pos_neg_point(text)
    begin
      url = URI.escape("https://lr.capio.jp/iminos/webapis/synana_k/1_1/?acckey=RoyGp1hi0VUd6Bsm&mode=tw_mode&sent=" + text)
  
      json = open(url) do |f|
        charset = f.charset # 文字種別を取得
        f.read # htmlを読み込んで変数htmlに渡す
      end

      result = JSON.parse(json)
      spn = result["results"][0]["spn"].to_i
      if spn == 1
        return 2
      elsif spn == 3
        return 1
      elsif spn == 0
        return 0
      elsif spn == 4
        return -1
      else
        return -2
      end
    rescue Exception => e
      puts e.message
      return 0
    end
  end

  def get_twitter_client(user)
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = Settings.twitter.consumer_key
      config.consumer_secret     = Settings.twitter.consumer_secret
      config.access_token        = user.token
      config.access_token_secret = user.secret
    end
  end

end
