class UserImageFavorite < ActiveRecord::Base
  belongs_to :user
  belongs_to :image
  validates :user, presence: true
  validates :image, presence: true
end
