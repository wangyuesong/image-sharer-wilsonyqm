require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_select '#hello_world', 1
  end

  test 'new' do
    get :new
    assert_response :success
    assert_select '#new_image_form', 1
  end

  test 'create' do
    assert_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'http://someawesomeimage' }
    end
    assert_redirected_to image_path(assigns(:image))
  end

  test 'show' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = Image.create!(title: 'test1Img', url: image_url)

    get :show, id: image
    assert_response :success
    assert_select "img[src=\"#{image_url}\"]", 1
    assert_select '#image_title', text: 'test1Img'
  end
end
