class AddNullConstraints < ActiveRecord::Migration
  def change
    change_column_null :images, :title, false
    change_column_null :images, :url, false
    change_column_null :users, :password_digest, false
  end
end
