class AddLinksToFriends < ActiveRecord::Migration
  def change
    add_column :friends, :tweet1_link, :string
    add_column :friends, :tweet2_link, :string
  end
end
