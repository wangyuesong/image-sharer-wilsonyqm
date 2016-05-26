class AddUserIdToImages < ActiveRecord::Migration
  def change
    add_reference :images, :user, index: true, foreign_key: true
    change_column_null :images, :user_id, false
  end
end
