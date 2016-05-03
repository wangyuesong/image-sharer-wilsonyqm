require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'Image is valid' do
    valid_urls = ['https://hfuehfweui.com', 'http://hfuehfweui.com', 'http://hfuehfweui.com.gov.cn', 'http://www.foo.bar/baz/qux.png']
    valid_urls.each do |valid_url|
      assert_predicate new_image(url: valid_url), :valid?
    end
  end

  test 'Image URL is not valid' do
    image = new_image(url: '')
    assert_predicate image, :invalid?
    assert_equal ["can't be blank"], image.errors[:url]

    invalid_urls = %w(
      ht://hfuehfweui.com jfoei.com http:omeurl http:/someurl http//someurl
    )
    invalid_urls.each do |invalid_url|
      image = new_image(url: invalid_url)
      assert_predicate image, :invalid?
      assert_equal ['not a valid URL'], image.errors[:url]
    end
  end

  test 'Image title is present' do
    image_titles = ['', nil]
    image_titles.each do |image_title|
      image = new_image(title: image_title)
      assert_predicate image, :invalid?
      assert_includes image.errors[:title], "can't be blank"
    end
  end

  test 'Image title is too short' do
    image = new_image(title: 'a')
    assert_predicate image, :invalid?
    assert_equal ['is too short (minimum is 2 characters)'], image.errors[:title]
  end

  test 'image with tags' do
    img = new_image(tag_list: 'tag1, tag2')
    assert_equal %w(tag1 tag2), img.tag_list

    img.tag_list = 'tag3'
    assert_equal %w(tag3), img.tag_list
  end

  test 'image with empty tags' do
    image = new_image(tag_list: '')
    assert_predicate image, :invalid?
    assert_equal ["can't be blank"], image.errors[:tag_list]
  end

  private

  def new_image(title: 'test_valid_url', url: 'https://hfuehfweui.com', tag_list: 'tag')
    Image.new(title: title, url: url, tag_list: tag_list)
  end
end
