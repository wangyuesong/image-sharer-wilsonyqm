require 'test_helper'

class UserImageFavoriteTest < ActiveSupport::TestCase
  include ImageCreation

  test 'valid UserImageFavorite table' do
    user_image = UserImageFavorite.new(user: users(:default_user), image: new_image())
    assert_predicate user_image, :valid?
  end

  test 'invalid UserImageFavorite table without image' do
    user_image = UserImageFavorite.new(user: users(:default_user))
    assert_predicate user_image, :invalid?
    assert_equal ["can't be blank"], user_image.errors[:image]
  end

  test 'invalid UserImageFavorite table without user' do
    user_image = UserImageFavorite.new(image: new_image())
    assert_predicate user_image, :invalid?
    assert_equal ["can't be blank"], user_image.errors[:user]
  end
end
