require 'test_helper'

class ImageTest < ActiveSupport::TestCase
  test 'Image is valid' do
    valid_urls = ['https://hfuehfweui.com', 'http://hfuehfweui.com', 'http://hfuehfweui.com.gov.cn', 'http://www.foo.bar/baz/qux.png']
    valid_urls.each do |valid_url|
      assert_predicate Image.new(title: 'test_valid_url', url: valid_url), :valid?
    end
  end

  test 'Image URL is not valid' do
    image = Image.new(title: 'valid title', url: '')
    assert_predicate image, :invalid?
    assert_equal ["can't be blank"], image.errors[:url]

    invalid_urls = %w(
      ht://hfuehfweui.com jfoei.com http:omeurl http:/someurl http//someurl
    )
    invalid_urls.each do |invalid_url|
      image = Image.new(title: 'valid title', url: invalid_url)
      assert_predicate image, :invalid?
      assert_equal ['not a valid URL'], image.errors[:url]
    end
  end

  test 'Image title is present' do
    image_titles = ['', nil]
    image_titles.each do |image_title|
      image = Image.new(title: image_title, url: 'https://hfuehfweui.com')
      assert_predicate image, :invalid?
      assert_includes image.errors[:title], "can't be blank"
    end
  end

  test 'Image title is too short' do
    image = Image.new(title: 'a', url: 'https://hfuehfweui.com')
    assert_predicate image, :invalid?
    assert_equal ['is too short (minimum is 2 characters)'], image.errors[:title]
  end
end
