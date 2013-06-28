class Tweet < ActiveRecord::Base
  require 'tweetstream'
  require 'debugger'

  def self.get_tweets
    TweetStream::Client.new.sample do |status|
      if status.lang == "en"
        geo = Tweet.get_geo(status)
        if geo.present?
          clean_text = Tweet.text_for_sentiment(status.text)
          sentiment = Tweet.get_sentiment(clean_text)
          Tweet.create(lat:geo[0],lng:geo[1],text:status.text,tweet_date:status.created_at,sentiment:sentiment)
        end
      end
    end
  end

  def self.get_geo(status)
    # check for coordinates
    if status[:geo].present?
      return status[:geo][:coordinates]
    else
      return nil
    end
  end

  def self.text_for_sentiment(text)
    text.gsub!(/\?\.!,#"'/)
    text.downcase!
    return text
  end

  def self.get_sentiment(text)
    sentiment = 0
    words = text.split
    words.each_with_index do |word,index|
      all_senses = Term.where(word:word)
      if all_senses.any?
        word_sentiment = (all_senses.collect{|t|t.pos_score-t.neg_score}.sum)/all_senses.length
        word_sentiment *= -1 if index > 1 && ["not","isn't"].include?(words[index-1])
        sentiment += word_sentiment
      end
    end
    return sentiment
  end

end
