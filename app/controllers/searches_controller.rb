class SearchesController < ApplicationController
  def create
    tweet_results = Tweet.search_tweets(params[:term])
    render :json => tweet_results 
  end
end
