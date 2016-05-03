require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'index with images' do
    url1 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    url2 = 'http://images.all-free-download.com/images/graphiclarge/page_90297.jpg'
    url3 = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'
    images = Image.create!([
      { title: 'image1', url: url1, tag_list: 'mazda6, red' },
      { title: 'image2', url: url2, tag_list: 'mazda6, grey' },
      { title: 'image3', url: url3, tag_list: 'sometag' }
    ])
    get :index
    assert_response :success
    assert_select 'img', count: 3
    assert_select "img[src=\"#{url1}\"]", 1
    assert_select "img[src=\"#{url2}\"]", 1

    images.each do |image|
      assert_select "div[data-image-id=\"#{image.id}\"] img[src=\"#{image.url}\"]", 1
      assert_select "div[data-image-id=\"#{image.id}\"] .image-detail__tags .btn" do |elements|
        assert_equal image.tag_list, elements.map(&:text)
      end
    end
  end

  test 'index with tags' do
    url1 = 'http://images.mazdausa.com/MusaWeb/musa2/images/vlp/panels/M6G/
            exterior-view/soulred/black/img_vlp_360_m6g_soulred_black_01_lg.jpg'
    url2 = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'
    url3 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    Image.create!([
      { title: 'image1', url: url1, tag_list: 'mazda6, red' },
      { title: 'image2', url: url2, tag_list: 'mazda6, grey' },
      { title: 'image3', url: url3, tag_list: 'sometag' }
    ])
    get :index, tag: 'mazda6'
    assert_response :success
    assert_select 'img', count: 2
    assert_select "img[src=\"#{url1}\"]", 1
    assert_select "img[src=\"#{url2}\"]", 1
  end

  test 'index with non-exist tag' do
    url1 = 'http://images.mazdausa.com/MusaWeb/musa2/images/vlp/panels/M6G/
                exterior-view/soulred/black/img_vlp_360_m6g_soulred_black_01_lg.jpg'
    Image.create!(title: 'image1', url: url1, tag_list: 'mazda6, grey')
    get :index, tag: 'mazda3'
    assert_response :success
    assert_equal "No images are tagged with mazda3", flash[:danger]
    assert_select 'img', count: 0
    assert_select '.image-detail__tags .btn', text: 'mazda6', count: 0
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
    assert_redirected_to image_path(Image.last)
  end

  test 'create with invalid params' do
    assert_no_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'invalid' }
    end
    assert_response :unprocessable_entity
    assert_select '#new_image_form', 1
    assert_select '.help-block', text: 'not a valid URL', count: 1
  end

  test 'show' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = Image.create!(title: 'test3Img', url: image_url, tag_list: 'tag1, tag2')

    get :show, id: image
    assert_response :success
    assert_select "img[src=\"#{image_url}\"]", 1
    assert_select '.image-detail__title', text: 'test3Img'
    assert_select '.image-detail__tags .btn' do |elements|
      assert_equal image.tag_list, elements.map(&:text)
    end
  end

  test 'show with empty tags' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1    = Image.create!(title: 'test3Img', url: image_url, tag_list: '')
    get :show, id: image1
    assert_response :success
    assert_select '.image-detail__tags', text: ''
  end

  test 'delete redirect to index page with one less image' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image     = Image.create!(title: 'test4Img', url: image_url, tag_list: '')
    assert_difference 'Image.count', -1 do
      delete :destroy, id: image
    end
    assert_redirected_to images_path
    assert_equal 'Image deleted', flash[:success]
  end

  test 'delete image does not exist' do
    assert_no_difference 'Image.count' do
      delete :destroy, id: -1
    end
    assert_redirected_to images_path
    assert_equal 'Image does not exist', flash[:danger]
  end

  test 'new share image test' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1    = Image.create!(title: 'test3Img', url: image_url, tag_list: '')
    get :new_share, id: image1
    assert_response :success
    assert_select '#new_share_form', 1
    assert_select "img[src=\"#{image_url}\"]", 1
  end

  test 'create share image valid email test' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1 = Image.create!(title: 'test3Img', url: image_url, tag_list: '')
    params = {
      id: image1,
      share_form: {
        subject: 'some image form',
        recipient: 'some@jief.com',
        content: 'create_test'
      }
    }
    assert_difference 'ActionMailer::Base.deliveries.size' do
      post :create_share, params
    end
    assert_equal 'Shared it!', flash[:success]
    assert_redirected_to images_path
    email = ActionMailer::Base.deliveries.last
    assert_equal 'some image form', email.subject
    assert_equal ['some@jief.com'], email.to
    assert_includes email.text_part.body.to_s, 'create_test'
  end

  test 'create share image invalid email test' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1 = Image.create!(title: 'test3Img', url: image_url, tag_list: '')
    params = {
      id: image1,
      share_form: {
        subject: 'some image form',
        recipient: 'someinvalidemail.com',
        content: 'create_test'
      }
    }
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :create_share, params
    end
    assert_response :unprocessable_entity
    assert_select '#new_share_form', 1
    assert_select '.help-block', text: 'is not a valid email address', count: 1
    assert_select "img[src=\"#{image_url}\"]", 1
  end

  test 'share nonexistent image' do
    params = {
      id: -1,
      share_form: {
        subject: 'some image form',
        recipient: 'someinvalidemail.com',
        content: 'create_test'
      }
    }
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post :create_share, params
    end
    assert_equal 'Image you want to share does not exist', flash[:danger]
    assert_redirected_to images_path
  end
end
