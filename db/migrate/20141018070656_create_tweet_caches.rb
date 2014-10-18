class CreateTweetCaches < ActiveRecord::Migration
  def change
    create_table :tweet_caches do |t|
      t.integer :tw_id
      t.integer :posneg

      t.timestamps
    end
  end
end
