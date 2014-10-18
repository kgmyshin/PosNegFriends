class AddTweetsToFriends < ActiveRecord::Migration
  def change
    add_column :friends, :tweet1, :string
    add_column :friends, :tweet2, :string
  end
end
