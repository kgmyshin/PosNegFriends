class AddInfoToFriends < ActiveRecord::Migration
  def change
    add_column :friends, :name, :string
    add_column :friends, :img_url, :string
  end
end
