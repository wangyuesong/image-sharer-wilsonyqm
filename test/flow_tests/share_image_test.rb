require 'flow_test_helper'

class ShareImageTest < FlowTestCase
  include ImageCreation

  test 'share image' do
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    create_image(url: puppy_url_2, tag_list: 'superman, cute', title: 'test1')

    images_index_page = PageObjects::Images::IndexPage.visit
    image_share_page = images_index_page.images[0].share!
    assert_equal image_share_page.image_url, puppy_url_2
    image_share_page = image_share_page.share_image!(
      subject: 'subject',
      recipient: 'invalid',
      content: 'some content'
    ).as_a(PageObjects::Images::ShareNewPage)
    assert_equal 'is not a valid email address', image_share_page.recipient.error_message
    image_share_page.recipient.set('valid@email.com')
    images_index_page = image_share_page.share_image!
    assert_equal 'Shared it!', images_index_page.flash_message(:success)
  end

  test 'share nonexistent image' do
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    image_to_share = create_image(url: puppy_url_2, tag_list: 'superman, cute', title: 'test1')
    images_index_page = PageObjects::Images::IndexPage.visit
    image_share_page = images_index_page.images[0].share!
    assert_equal image_share_page.image_url, puppy_url_2
    image_to_share.destroy!
    images_index_page = image_share_page.share_image!(
      subject:   'subject',
      recipient: 'valid@email.com',
      content:   'some content'
    )
    assert_equal 'Image you want to share does not exist', images_index_page.flash_message(:danger)
  end
end
