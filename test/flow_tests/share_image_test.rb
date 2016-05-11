require 'flow_test_helper'

class ShareImageTest < FlowTestCase
  include ImageCreation

  test 'share image' do
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    create_image(url: puppy_url_2, tag_list: 'superman, cute', title: 'test1')

    images_index_page = PageObjects::Images::IndexPage.visit

    images_index_page.images[0].share do |share_modal|
      assert_equal puppy_url_2, share_modal.image_url
      share_modal.subject.set('subject')
      share_modal.recipient.set('invalid')
      share_modal.content.set('some content')
      share_modal.share_image
      assert_equal 'is not a valid email address', share_modal.recipient.error_message
      share_modal.recipient.set('valid@email.com')
      share_modal.share_image
    end
    assert_equal 'Shared it!', images_index_page.flash_message(:success)
  end

  test 'share nonexistent image' do
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    image_to_share = create_image(url: puppy_url_2, tag_list: 'superman, cute', title: 'test1')

    images_index_page = PageObjects::Images::IndexPage.visit
    share_modal = images_index_page.images[0].open_share_modal
    assert_equal puppy_url_2, share_modal.image_url
    share_modal.subject.set('subject')
    share_modal.recipient.set('valid@fmail.com')
    share_modal.content.set('some content')
    image_to_share.destroy!
    share_modal.share_image

    images_index_page = AePageObjects.browser.current_window.change_to(PageObjects::Images::IndexPage)
    assert_equal 'Image you want to share does not exist', images_index_page.flash_message(:danger)
    assert_equal 0, images_index_page.images.count
  end

  test 'share on show page' do
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    create_image(url: puppy_url_2, tag_list: 'superman, cute', title: 'test1')
    images_index_page = PageObjects::Images::IndexPage.visit

    image_to_share = images_index_page.images.find do |image|
        image.url == puppy_url_2
    end
    image_show_page = image_to_share.view!

    image_show_page.share do |share_modal|
      assert_equal puppy_url_2, share_modal.image_url
      share_modal.subject.set('subject')
      share_modal.recipient.set('invalid')
      share_modal.content.set('some content')
      share_modal.share_image
      assert_equal 'is not a valid email address', share_modal.recipient.error_message
      share_modal.recipient.set('valid@email.com')
      share_modal.share_image
    end
    assert_equal 'Shared it!', image_show_page.flash_message(:success)
  end

  test 'share image modal is reset on modal close' do
    cute_puppy_url = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    ugly_cat_url = 'http://www.ugly-cat.com/ugly-cats/uglycat041.jpg'
    create_images([
      { url: cute_puppy_url, tag_list: 'puppy, cute', title: 'test1' },
      { url: ugly_cat_url, tag_list: 'cat, ugly', title: 'test2' }
    ])
    images_index_page = PageObjects::Images::IndexPage.visit

    images_index_page.images[0].share do |share_modal|
      assert_equal cute_puppy_url, share_modal.image_url
      share_modal.subject.set('subject')
      share_modal.recipient.set('invalid')
      share_modal.content.set('some content')
      share_modal.share_image
      assert_equal 'is not a valid email address', share_modal.recipient.error_message
      share_modal.close_modal
    end

    images_index_page.images[1].share do |share_modal|
      assert_equal ugly_cat_url, share_modal.image_url
      assert_empty share_modal.recipient.text
      assert_empty share_modal.content.text
      assert_empty share_modal.subject.text
      assert_empty share_modal.recipient.error_message
      share_modal.close_modal
    end
  end
end
