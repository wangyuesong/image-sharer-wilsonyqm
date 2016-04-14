require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'index with images' do
    image_url_1 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image_url_2 = 'http://images.all-free-download.com/images/graphiclarge/page_90297.jpg'
    Image.create!(title: 'test1Img', url: image_url_1)
    Image.create!(title: 'test2Img', url: image_url_2)

    get :index
    assert_response :success
    assert_select 'tr', count: 3
    assert_select 'img', count: 2
    assert_select "img[src=\"#{image_url_1}\"]", 1
    assert_select "img[src=\"#{image_url_2}\"]", 1

  end

  test 'new' do
    get :new
    assert_response :success
    assert_select '#new_image_form', 1
  end

  test 'create' do
    assert_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'http://someawesomeimage.com' }
    end
    assert_redirected_to image_path(assigns(:image))
  end

  test 'create with invalid params' do
    assert_no_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'invalid' }
    end
    assert_response :unprocessable_entity
    assert_select '#new_image_form', 1
    assert_select '.error', {text: 'not a valid URL', count: 1}
  end

  test 'show' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = Image.create!(title: 'test3Img', url: image_url)

    get :show, id: image
    assert_response :success
    assert_select "img[src=\"#{image_url}\"]", 1
    assert_select '#image_title', text: 'test3Img'
  end
end
