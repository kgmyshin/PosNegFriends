class AddTweetToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tweet1, :string
    add_column :users, :tweet2, :string
  end
end
