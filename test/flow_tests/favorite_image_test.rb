require 'flow_test_helper'

class FavoriteImageTest < FlowTestCase
  include ImageCreation

  teardown do
    Capybara.current_session.reset!
  end

  test 'favorite-toggle unfavorited image' do
    cute_puppy_url = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_images([
      { url: cute_puppy_url, tag_list: 'puppy, cute', title: 'test1' },
      { url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2' }
    ])

    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit
    image_to_favorite = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end
    assert_unfavorite(image_to_favorite)
    image_to_favorite.favorite_toggle
    assert_favorite(image_to_favorite)
    image_to_favorite.favorite_toggle
    assert_unfavorite(image_to_favorite)

  end

  test 'favorite-toggle favorited image by other user and favorite-toggle unfavorited image by other user' do
    cute_puppy_url = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    images = create_images([
      { url: cute_puppy_url, tag_list: 'puppy, cute', title: 'test1' },
      { url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2' }
    ])
    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_favorite = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end
    UserImageFavorite.create!(user: users(:default_user), image: images[1])
    assert_unfavorite(image_to_favorite)
    image_to_favorite.favorite_toggle
    assert_favorite(image_to_favorite)
    UserImageFavorite.find_by(user: users(:default_user), image: images[1]).destroy!
    image_to_favorite.favorite_toggle
    assert_unfavorite(image_to_favorite)
  end

  test 'favorite-toggle deleted image' do
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    image = create_image(url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2')
    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_favorite = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end

    image.destroy!
    image_to_favorite.favorite_toggle
    assert_equal 'Image does not exist', images_index_page.flash_message(:danger)
  end

  test 'favorite-toggle from two users' do
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_image(url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2')
    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_favorite = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end
    assert_unfavorite(image_to_favorite)
    image_to_favorite.favorite_toggle
    assert_favorite(image_to_favorite)

    images_index_page = PageObjects::Images::IndexPage.visit
    images_index_page.log_out!
    images_index_page = log_in_as(users(:other_user))

    image_to_favorite = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end
    image_to_favorite.favorite_toggle
    assert_favorite(image_to_favorite, '2')
    image_to_favorite.favorite_toggle
    assert_unfavorite(image_to_favorite, '1')
  end

  private

  def assert_favorite(image_to_favorite, count='1')
    assert_equal count, image_to_favorite.favorite_count
    assert image_to_favorite.favorite_status
  end

  def assert_unfavorite(image_to_unfavorite, count='0')
    assert_equal count, image_to_unfavorite.favorite_count
    refute image_to_unfavorite.favorite_status
  end
end
