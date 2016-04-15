require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'index with images' do
    url1 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    url2 = 'http://images.all-free-download.com/images/graphiclarge/page_90297.jpg'
    image_attributes = [
      {title: 'image1', url: url1, tag_list: 'tag1, tag2'},
      {title: 'image2', url: url2, tag_list: 'tag3, tag4'}
    ]
    images = image_attributes.map { |attributes| Image.create!(attributes) }

    get :index
    assert_response :success
    assert_select 'img', count: 2
    assert_select "img[src=\"#{url1}\"]", 1
    assert_select "img[src=\"#{url2}\"]", 1

    images.each do |image|
      assert_select "div[data-image-id=\"#{image.id}\"] img[src=\"#{image.url}\"]", 1
      assert_select "div[data-image-id=\"#{image.id}\"] .test-tags", text: "Tags: #{image.tag_list}"
    end
  end

  test 'new' do
    get :new
    assert_response :success
    assert_select '#new_image_form', 1
  end

  test 'create' do
    assert_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'http://someawesomeimage.com', tag_list: 'create_test' }
    end
    assert_redirected_to image_path(assigns(:image))
  end

  test 'create with invalid params' do
    assert_no_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'invalid' }
    end
    assert_response :unprocessable_entity
    assert_select '#new_image_form', 1
    assert_select '.help-block', {text: 'not a valid URL', count: 1}
  end

  test 'show' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = Image.create!(title: 'test3Img', url: image_url, tag_list: 'tag1, tag2')

    get :show, id: image
    assert_response :success
    assert_select "img[src=\"#{image_url}\"]", 1
    assert_select '#image_title', text: 'test3Img'
    assert_select '#image_tags', text: 'tag1, tag2'
  end

  test 'show with empty tags' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1 = Image.create!(title: 'test3Img', url: image_url, tag_list: '')
    get :show, id: image1
    assert_response :success
    assert_select '#image_tags', text: ''
  end
end
