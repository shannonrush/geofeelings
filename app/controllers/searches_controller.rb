class SearchesController < ApplicationController
  def create
    tweet_results = Tweet.search_tweets(params[:term],params[:max_id])
    render :json => tweet_results 
  end
end
