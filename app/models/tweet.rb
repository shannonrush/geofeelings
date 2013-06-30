class Tweet < ActiveRecord::Base
  require 'tweetstream'
  require 'debugger'
  require 'htmlentities'
  require 'net/http'
  require 'twitter'

  def self.get_tweets
    TweetStream::Client.new.sample do |status|
      if status.lang == "en"
        geo = Tweet.get_geo(status)
        text = HTMLEntities.new.decode(status.text)          
        clean_text = Tweet.text_for_sentiment(text.clone)
        sentiment = Tweet.get_sentiment(clean_text)
        Tweet.create(lat:geo[0],lng:geo[1],text:text,tweet_date:status.created_at,sentiment:sentiment)
      end
    end
  end

  def self.search_tweets(term)
    results = Twitter.search(term, :lang => "en", :count => 100).results
    positive = []
    negative = []
    neutral = []
    results.each do |result|
      coordinates = Tweet.get_geo(result)
      sentiment = Tweet.get_sentiment(result.text)
      tweet = {text:HTMLEntities.new.decode(result.text),lat:coordinates[0],lng:coordinates[1],sentiment:sentiment}
      if sentiment > 0
        positive << tweet
      elsif sentiment < 0 
        negative << tweet
      else
        neutral << tweet
      end
    end
    debugger
    puts "tweets"
  end

  def self.get_geo(status)
    geo = [nil,nil]
    if status[:geo].present?
      geo = status[:geo][:coordinates]
    elsif status.user.location.present?
      location = JSON.parse(Net::HTTP.get(URI.parse("http://open.mapquestapi.com/geocoding/v1/address?key=Fmjtd%7Cluub2g01nl%2C8l%3Do5-9ub500&location=#{URI::encode(status.user.location)}")))
      if location["info"]["statuscode"] == 0 && location["results"][0]["locations"].any?
        coords = location["results"][0]["locations"][0]["latLng"]
        geo = [coords["lat"],coords["lng"]]
      end
    end
    return geo
  end

  def self.text_for_sentiment(text)
    text.gsub!(/\?|\.|!|,|#|"/," ")
    text.downcase!
    return text
  end

  def self.get_sentiment(tweet_text)
    text = Tweet.text_for_sentiment(tweet_text.clone)
    sentiment = 0
    words = text.split
    words.each_with_index do |word,index|
      term = Term.where(word:word).first
      if term.present?
        word_sentiment = term.score
        word_sentiment *= -1 if index > 1 && ["no","not","isn't"].include?(words[index-1])
        sentiment += word_sentiment
      end
    end
    return sentiment
  end

end
