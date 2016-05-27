class ImageFavorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :image, counter_cache: :favorites_count
  validates :user, presence: true
  validates :image, presence: true
end
