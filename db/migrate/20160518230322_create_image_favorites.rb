class CreateImageFavorites < ActiveRecord::Migration
  def change
    create_table :image_favorites do |t|
      t.references :user, null: false
      t.references :image, null: false
      t.timestamps null: false
      t.index [:user_id, :image_id], unique: true
    end
  end
end
