require 'flow_test_helper'

class ImagesCrudTest < FlowTestCase
  test 'create a new image' do
    title       = 'flowtest'
    invalid_url = 'hn:jfieow'
    valid_url   = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'

    visit(root_path)

    click_link('Insert New Images')

    page.assert_selector('#new_image_form')

    fill_in('Title', with: title)
    fill_in('Url', with: invalid_url)

    click_on('Save Image')

    page.assert_selector('#new_image_form')
    page.assert_selector('.error', text: 'not a valid URL', count: 1)

    fill_in('Title', with: title)
    fill_in('Url', with: valid_url)

    click_on('Save Image')

    page.assert_current_path(image_path(Image.last))
    page.assert_selector("img[src=\"#{valid_url}\"]")
  end
end
