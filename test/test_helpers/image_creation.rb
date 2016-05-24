module ImageCreation
  def create_image(title: 'test_valid_url', url: 'https://hfuehfweui.com', tag_list: 'tag', user: users(:default_user))
    Image.create!(title: title, url: url, tag_list: tag_list, user: user)
  end

  def create_images(image_attributes_list)
    image_attributes_list.map(&method(:create_image))
  end

  def new_image(title: 'test_valid_url', url: 'https://hfuehfweui.com', tag_list: 'tag', user: users(:default_user))
    Image.new(title: title, url: url, tag_list: tag_list, user: user)
  end
end
