require 'flow_test_helper'

class ImagesCrudTest < FlowTestCase
  include ImageCreation

  teardown do
    Capybara.current_session.reset!
  end

  test 'add an image' do
    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit
    new_image_page = images_index_page.add_new_image!

    tags = %w(foo bar)
    new_image_page = new_image_page.create_image!(url: 'invalid', tags: '', title: 'title').as_a(PageObjects::Images::NewPage)
    assert_equal "can't be blank", new_image_page.tag_list.error_message
    assert_equal 'not a valid URL', new_image_page.url.error_message

    image_url = 'https://media3.giphy.com/media/EldfH1VJdbrwY/200.gif'
    new_image_page.url.set(image_url)
    new_image_page.tag_list.set(tags.join(', '))
    image_show_page = new_image_page.create_image!
    assert_equal 'You have successfully added an image.', image_show_page.flash_message(:success)

    assert image_show_page.has_url?(image_url)
    assert_equal tags, image_show_page.tags

    images_index_page = image_show_page.go_back_to_index!
    assert images_index_page.is_showing_image?(url: image_url, tags: tags)
  end

  test 'delete an image' do
    cute_puppy_url = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_images([
      { url: cute_puppy_url, tag_list: 'puppy, cute', title: 'test1' },
      { url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2' }
    ])

    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit
    assert_equal 2, images_index_page.images.count
    assert images_index_page.is_showing_image?(url: ugly_cat_url)
    assert images_index_page.is_showing_image?(url: cute_puppy_url)

    image_to_delete = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end
    image_show_page = image_to_delete.view!

    image_show_page.delete do |confirm_dialog|
      assert_equal 'Are you sure?', confirm_dialog.text
      confirm_dialog.dismiss
    end

    images_index_page = image_show_page.delete_and_confirm!
    assert_equal 'Image deleted', images_index_page.flash_message(:success)

    assert_equal 1, images_index_page.images.count
    refute images_index_page.is_showing_image?(url: ugly_cat_url)
    assert images_index_page.is_showing_image?(url: cute_puppy_url)
  end

  test 'try to delete a nonexistent image' do
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    image = create_image(url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2')
    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit

    assert_equal 1, images_index_page.images.count
    assert images_index_page.is_showing_image?(url: ugly_cat_url)
    image_to_delete = images_index_page.images.find do |image|
      image.url == ugly_cat_url
    end
    image_show_page = image_to_delete.view!
    image.destroy!
    images_index_page = image_show_page.delete_and_confirm!
    assert_equal 'Image does not exist', images_index_page.flash_message(:danger)
    assert_equal 0, images_index_page.images.count
    refute images_index_page.is_showing_image?(url: ugly_cat_url)
  end

  test 'view images associated with a tag' do
    puppy_url_1 = 'http://www.pawderosa.com/images/puppies.jpg'
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_images([
      { url: puppy_url_1, tag_list: 'superman, cute', title: 'test1' },
      { url: puppy_url_2, tag_list: 'cute, puppy', title: 'test2' },
      { url: cat_url, tag_list: 'cat, ugly', title: 'test3' }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit
    [puppy_url_1, puppy_url_2, cat_url].each do |url|
      assert images_index_page.is_showing_image?(url: url)
    end

    images_index_page = images_index_page.images[1].click_tag!('cute')

    assert_equal 2, images_index_page.images.count
    refute images_index_page.is_showing_image?(url: cat_url)

    images_index_page = images_index_page.clear_tag_filter!
    assert_equal 3, images_index_page.images.count
  end

  test 'view tags list and click on tag' do
    puppy_url_1 = 'http://www.pawderosa.com/images/puppies.jpg'
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_images([
      { url: puppy_url_1, tag_list: 'puppy, cute', title: 'test1' },
      { url: puppy_url_2, tag_list: 'cute, puppy', title: 'test2' },
      { url: cat_url, tag_list: 'cat, cute', title: 'test3' }
    ])

    images_index_page = PageObjects::Images::IndexPage.visit
    tags_index_page = images_index_page.show_tags_list!

    assert_equal ['cute', 'puppy', 'cat'], tags_index_page.tags.map(&:name)
    tag_to_click = tags_index_page.tags.find do |tag|
      tag.name== 'cute'
    end
    images_index_page = tag_to_click.view!
    assert_equal 3, images_index_page.images.count

    tags_index_page = images_index_page.show_tags_list!
    tag_to_click = tags_index_page.tags.find do |tag|
      tag.name== 'puppy'
    end
    images_index_page = tag_to_click.view!
    assert_equal 2, images_index_page.images.count
    refute images_index_page.is_showing_image?(url: cat_url)
  end

  test 'edit image tags' do
    puppy_url_1 = 'http://www.pawderosa.com/images/puppies.jpg'
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_images([
      { url: puppy_url_1, tag_list: 'superman, cute', title: 'test1' },
      { url: puppy_url_2, tag_list: 'cute, puppy', title: 'test2' },
      { url: cat_url, tag_list: 'cat, ugly', title: 'test3' }
    ])
    log_in_as(users(:default_user))
    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_edit = images_index_page.images.find do |image|
      image.url == cat_url
    end
    image_edit_page = image_to_edit.edit_tags!
    assert_equal 'cat, ugly', image_edit_page.tag_list.value
    assert image_edit_page.has_img?(cat_url), 'Edit page is not showing the correct image'

    image_edit_page = image_edit_page.save_tags!('').as_a(PageObjects::Images::EditPage)
    assert_equal "can't be blank", image_edit_page.tag_list.error_message

    images_show_page = image_edit_page.save_tags!('dog, nice')
    assert_equal 'You successfully change the tags',
                 images_show_page.flash_message(:success)
    assert_equal ['dog', 'nice'], images_show_page.image_card.tags
  end
end
