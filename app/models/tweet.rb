class Tweet < ActiveRecord::Base
  require 'tweetstream'
  require 'debugger'
  require 'htmlentities'
  require 'twitter'
  require 'geocoder'

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
    terms = Tweet.get_terms(results)
    positive = []
    negative = []
    neutral = []
    results.each do |result|
      coordinates = Tweet.get_geo(result)
      tweet_text = HTMLEntities.new.decode(result.text)
      sentiment = Tweet.get_sentiment(tweet_text,terms)
      tweet = {text:tweet_text,lat:coordinates[0],lng:coordinates[1],sentiment:sentiment}
      if sentiment > 0
        positive << tweet
      elsif sentiment < 0 
        negative << tweet
      else
        neutral << tweet
      end
    end
    return {positive:positive,negative:negative,neutral:neutral}
  end

  def self.get_terms(results)
    terms = {}
    all_text = results.collect{|r|HTMLEntities.new.decode(r.text)}.join(" ")
    words = Tweet.text_for_sentiment(all_text).split.uniq
    Term.where(word:words).each{|t|terms[t.word]=t.score}
    return terms
  end

  def self.get_geo(status)
    geo = [nil,nil]
    if status[:geo].present?
      geo = status[:geo][:coordinates]
    elsif status.user.location.present?
      location = Geocoder.search(status.user.location)
      if location.present?
        geo = [location[0].latitude,location[0].longitude]
      end
    end
    return geo
  end

  def self.text_for_sentiment(text)
    text.gsub!(/\?|\.|!|,|#|"|:|;/," ")
    text.downcase!
    return text
  end

  def self.get_sentiment(tweet_text,terms)
    text = Tweet.text_for_sentiment(tweet_text.clone)
    sentiment = 0
    words = text.split
    if terms.any?
      words.each_with_index do |word,index|
        if terms.keys.include?(word)
          word_sentiment = terms[word]
          word_sentiment *= -1 if index > 1 && ["no","not","isn't"].include?(words[index-1])
          sentiment += word_sentiment
        end
      end
    end
    return sentiment
  end

end
