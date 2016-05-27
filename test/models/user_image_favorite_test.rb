require 'test_helper'

class ImageFavoriteTest < ActiveSupport::TestCase
  include ImageCreation

  test 'valid ImageFavorite table' do
    user_image = ImageFavorite.new(user: users(:default_user), image: new_image())
    assert_predicate user_image, :valid?
  end

  test 'invalid ImageFavorite table without image' do
    user_image = ImageFavorite.new(user: users(:default_user))
    assert_predicate user_image, :invalid?
    assert_equal ["can't be blank"], user_image.errors[:image]
  end

  test 'invalid ImageFavorite table without user' do
    user_image = ImageFavorite.new(image: new_image())
    assert_predicate user_image, :invalid?
    assert_equal ["can't be blank"], user_image.errors[:user]
  end
end
