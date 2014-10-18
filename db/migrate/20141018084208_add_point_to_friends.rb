class AddPointToFriends < ActiveRecord::Migration
  def change
    add_column :friends, :point, :integer
  end
end
