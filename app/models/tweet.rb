class Tweet < ActiveRecord::Base
  require 'tweetstream'
  require 'htmlentities'
  require 'net/http'
  require 'twitter'
  
  include Terms

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

  def self.search_tweets(term,max_id=nil)
    max = max_id.nil? ? nil : max_id.to_i-1
    results = Twitter.search(term, max_id:max, lang:"en", count:20, result_type:"recent").results
    positive = []
    negative = []
    neutral = []
    results.each do |result|
      coordinates = Tweet.get_geo(result)
      unless coordinates.nil?
        tweet_text = HTMLEntities.new.decode(result.text)
        sentiment = Tweet.get_sentiment(tweet_text)
        tweet = {text:tweet_text,lat:coordinates[0],lng:coordinates[1],sentiment:sentiment}
        if sentiment > 0
          positive << tweet
        elsif sentiment < 0 
          negative << tweet
        else
          neutral << tweet
        end
      end
    end
    return {max_id:results.last.id,positive:positive,negative:negative,neutral:neutral}
  end

  def self.get_geo(status)
    geo = nil
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
    text.downcase!
    text = text.split.reject{|w| w.start_with?("rt","@","http")}.join(" ")
    text.gsub!(/\?|\.|!|,|#|"|:|;|\/|\(|\)/," ")
    return text.split
  end

  def self.get_sentiment(tweet_text)
    words = Tweet.text_for_sentiment(tweet_text.clone)
    sentiment = 0
    words.each_with_index do |word,index|
      if TERMS.keys.include?(word)
        word_sentiment = TERMS[word]
        word_sentiment *= -1 if index > 1 && ["no","not","isn't"].include?(words[index-1])
        sentiment += word_sentiment
      end
    end
    return sentiment
  end

end
