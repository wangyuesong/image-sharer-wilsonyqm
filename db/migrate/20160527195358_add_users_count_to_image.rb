class AddUsersCountToImage < ActiveRecord::Migration
  def change
    add_column :images, :favorites_count, :integer, default: 0
  end
end
