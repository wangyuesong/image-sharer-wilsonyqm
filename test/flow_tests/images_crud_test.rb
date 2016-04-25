require 'flow_test_helper'

class ImagesCrudTest < FlowTestCase
  test 'create a new image' do
    title       = 'flowtest'
    invalid_url = 'hn:jfieow'
    valid_url   = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'

    visit(root_path)

    click_link('Insert Image')

    page.assert_selector('#new_image_form')

    fill_in('Title', with: title)
    fill_in('URL', with: invalid_url)

    click_on('Save Image')

    page.assert_selector('#new_image_form')
    page.assert_selector('.help-block', text: 'not a valid URL', count: 1)

    fill_in('Title', with: title)
    fill_in('URL', with: valid_url)

    click_on('Save Image')

    page.assert_current_path(image_path(Image.last))
    page.assert_selector("img[src=\"#{valid_url}\"]", count: 1)
  end

  test 'delete an image' do
    image1 = Image.create!(title: 'delete_test_1', url: 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG')
    image_to_delete = Image.create!(title: 'delete_test_2', url: 'https://upload.wikimedia.org/wikipedia/commons/9/92/Colorful_spring_garden.jpg')
    visit(root_path)
    page.assert_selector("img[src=\"#{image_to_delete.url}\"]", count: 1)
    page.assert_selector("img[src=\"#{image1.url}\"]", count: 1)

    dismiss_confirm('Are you sure') do
      page.find("div[data-image-id=\"#{image_to_delete.id}\"] a[data-method=\"delete\"]").click
    end
    page.assert_selector("img[src=\"#{image_to_delete.url}\"]", count: 1)
    page.assert_no_text('Image deleted')

    accept_confirm('Are you sure') do
      page.find("div[data-image-id=\"#{image_to_delete.id}\"] a[data-method=\"delete\"]").click
    end
    page.assert_current_path(images_path)
    page.assert_selector("img[src=\"#{image_to_delete.url}\"]", count: 0)
    page.assert_selector("img[src=\"#{image1.url}\"]", count: 1)
    page.assert_selector('#flash_messages', count: 1, text: 'Image deleted' )
  end

  test 'delete an not exist image' do
    image_to_delete = Image.create!(title: 'delete_test_2', url: 'https://upload.wikimedia.org/wikipedia/commons/9/92/Colorful_spring_garden.jpg')
    visit(root_path)
    page.assert_selector("img[src=\"#{image_to_delete.url}\"]", count: 1)
    image_to_delete.destroy!
    page.assert_selector("img[src=\"#{image_to_delete.url}\"]", count: 1)
    accept_confirm('Are you sure') do
      page.find("div[data-image-id=\"#{image_to_delete.id}\"] a[data-method=\"delete\"]").click
    end
    page.assert_current_path(images_path)
    page.assert_selector('#flash_messages', text: 'Image does not exist', count: 1 )
    page.assert_selector("img[src=\"#{image_to_delete.url}\"]", count: 0)
  end
end
