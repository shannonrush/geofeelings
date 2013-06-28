class CreateTweets < ActiveRecord::Migration
  def change
    create_table :tweets do |t|
      t.float :sentiment
      t.decimal :lat,precision:9,scale:6
      t.decimal :lng,precision:9,scale:6
      t.string :text
      t.datetime :tweet_date

      t.timestamps
    end
  end
end
