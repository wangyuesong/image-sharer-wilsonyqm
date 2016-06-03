require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  include ImageCreation

  test 'index with images when not logged in' do
    url1 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    url2 = 'http://images.all-free-download.com/images/graphiclarge/page_90297.jpg'
    url3 = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'
    images = create_images([
      { title: 'image1', url: url1, tag_list: 'mazda6, red' },
      { title: 'image2', url: url2, tag_list: 'mazda6, grey' },
      { title: 'image3', url: url3, tag_list: 'sometag' }
    ])
    get :index
    assert_response :success
    assert_select '#images_list img', count: 3
    assert_select "img[src=\"#{url1}\"]", 1
    assert_select "img[src=\"#{url2}\"]", 1
    assert_select '.js-share-btn', count: 0
    assert_select '.js-edit-tags', count: 0
    assert_select '.js-insert-image', count: 0

    images.each do |image|
      assert_select "div[data-image-id=\"#{image.id}\"] img[src=\"#{image.url}\"]", 1
      assert_select "div[data-image-id=\"#{image.id}\"] .image-detail__tags .btn" do |elements|
        assert_equal image.tag_list, elements.map(&:text)
      end
    end
  end

  test 'index has insert, share and edit button when logged in' do
     log_in(users(:default_user))
     url1 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
     url2 = 'http://images.all-free-download.com/images/graphiclarge/page_90297.jpg'
     url3 = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'
     images = create_images([
       { title: 'image1', url: url1, tag_list: 'mazda6, red' },
       { title: 'image2', url: url2, tag_list: 'mazda6, grey' },
       { title: 'image3', url: url3, tag_list: 'sometag' }
     ])
     get :index
     assert_select '.js-share-btn', count: 3
     assert_select '.js-edit-tags', count: 3
     assert_select '.js-insert-image', count: 1
     assert_select '#images_list img', count: 3
     assert_select "img[src=\"#{url1}\"]", 1
     assert_select "img[src=\"#{url2}\"]", 1

     images.each do |image|
       assert_select "div[data-image-id=\"#{image.id}\"] img[src=\"#{image.url}\"]", 1
       assert_select "div[data-image-id=\"#{image.id}\"] .image-detail__tags .btn" do |elements|
         assert_equal image.tag_list, elements.map(&:text)
       end
     end
  end

  test 'index with tag filter' do
    url1 = 'http://images.mazdausa.com/MusaWeb/musa2/images/vlp/panels/M6G/
            exterior-view/soulred/black/img_vlp_360_m6g_soulred_black_01_lg.jpg'
    url2 = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'
    url3 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    create_images([
      { title: 'image1', url: url1, tag_list: 'mazda6, red' },
      { title: 'image2', url: url2, tag_list: 'mazda6, grey' },
      { title: 'image3', url: url3, tag_list: 'sometag' }
    ])
    get :index, tag: 'mazda6'
    assert_response :success
    assert_select '.js-share-btn', count: 0
    assert_select '.js-edit-tags', count: 0
    assert_select '.js-insert-image', count: 0
    assert_select '#images_list img', count: 2
    assert_select "img[src=\"#{url1}\"]", 1
    assert_select "img[src=\"#{url2}\"]", 1
  end

  test 'index with non-exist tag' do
    url1 = 'http://images.mazdausa.com/MusaWeb/musa2/images/vlp/panels/M6G/
                exterior-view/soulred/black/img_vlp_360_m6g_soulred_black_01_lg.jpg'
    create_image(title: 'image1', url: url1, tag_list: 'mazda6, grey')
    get :index, tag: 'mazda3'
    assert_response :success
    assert_equal "No images are tagged with mazda3", flash[:danger]
    assert_select '#images_list img', count: 0
    assert_select '.image-detail__tags .btn', text: 'mazda6', count: 0
  end

  test 'new' do
    log_in(users(:default_user))
    get :new
    assert_response :success
    assert_select '#new_image_form', 1
  end

  test 'new when not logged in' do
    get :new
    assert_redirected_to_login
  end

  test 'create' do
    log_in(users(:default_user))
    assert_difference -> { Image.count } do
      post :create, image: {
        title: 'some image',
        url: 'http://someawesomeimage.com',
        tag_list: 'create_test'
      }
    end
    assert_redirected_to image_path(Image.last)
  end

  test 'create when not logged in' do
    assert_no_difference -> { Image.count } do
      post :create, image: {
        title: 'some image',
        url: 'http://someawesomeimage.com',
        tag_list: 'create_test'
      }
    end
    assert_redirected_to_login
  end

  test 'create with invalid params' do
    log_in(users(:default_user))
    assert_no_difference -> { Image.count } do
      post :create, image: { title: 'some image', url: 'invalid', tag_list: 'tag' }
    end
    assert_response :unprocessable_entity
    assert_select '#new_image_form', 1
    assert_select '.help-block', text: 'not a valid URL', count: 1
  end

  test 'cannot forge the user_id in create' do
    log_in(users(:default_user))
    assert_difference -> { Image.count } do
      post :create, image: {
        title: 'some image',
        url: 'http://someawesomeimage.com',
        tag_list: 'create_test',
        user_id: users(:other_user).id
      }
    end
    assert_redirected_to image_path(Image.last)
    assert_equal users(:default_user).id, Image.last.user_id
  end

  test 'show' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag1, tag2')

    get :show, id: image
    assert_response :success
    assert_select "#image_show img[src=\"#{image_url}\"]", 1
    assert_select '.image-detail__title', text: 'test3Img'
    assert_select '.js-share-btn', count: 0
    assert_select '.js-edit-tags', count: 0
    assert_select '.js-back-btn', count: 1
    assert_select '.js-delete-btn', count: 0
    assert_select '.image-detail__tags .btn' do |elements|
      assert_equal image.tag_list, elements.map(&:text)
    end
  end

  test 'show has delete, back, share and edit button when logged in as the image owner' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag1, tag2')

    get :show, id: image
    assert_response :success
    assert_select "#image_show img[src=\"#{image_url}\"]", 1
    assert_select '.image-detail__title', text: 'test3Img'
    assert_select '.js-share-btn', count: 1
    assert_select '.js-edit-tags', count: 1
    assert_select '.js-delete-btn', count: 1
    assert_select '.js-back-btn', count: 1
    assert_select '.image-detail__tags .btn' do |elements|
      assert_equal image.tag_list, elements.map(&:text)
    end
  end

  test 'show has no delete button, but has share, edit, back button when logged in as the someone other than the image owner' do
    log_in(users(:other_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag1, tag2')

    get :show, id: image
    assert_response :success
    assert_select "#image_show img[src=\"#{image_url}\"]", 1
    assert_select '.image-detail__title', text: 'test3Img'
    assert_select '.js-share-btn', count: 1
    assert_select '.js-edit-tags', count: 1
    assert_select '.js-delete-btn', count: 0
    assert_select '.js-back-btn', count: 1
    assert_select '.image-detail__tags .btn' do |elements|
      assert_equal image.tag_list, elements.map(&:text)
    end
  end

  test 'delete redirect to index page with one less image' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test4Img', url: image_url, tag_list: 'tag')
    assert_difference 'Image.count', -1 do
      delete :destroy, id: image
    end
    assert_redirected_to images_path
    assert_equal 'Image deleted', flash[:success]
  end

  test 'delete image does not exist' do
    log_in(users(:default_user))
    assert_no_difference 'Image.count' do
      delete :destroy, id: -1
    end
    assert_redirected_to images_path
    assert_equal 'Image does not exist', flash[:danger]
  end

  test 'delete when not logged in' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test4Img', url: image_url, tag_list: 'tag')
    delete :destroy, id: image
    assert_redirected_to_login
  end

  test "cannot delete another user's image" do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test4Img', url: image_url, tag_list: 'tag')
    log_in(users(:other_user))
    assert_no_difference 'Image.count', -1 do
      delete :destroy, id: image
    end
    assert_redirected_to image_path(image)
    assert_equal 'You can not delete this image', flash[:warning]
  end

  test 'edit tags' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test5Img', url: image_url, tag_list: 'tag1, tag2')
    get :edit, id: image

    assert_response :success
    assert_select "img[src=\"#{image_url}\"]", 1
    assert_select '#edit_image_form', 1
    assert_select '.image-detail__title', text: 'test5Img'
  end

  test 'edit tags when not logged in' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test5Img', url: image_url, tag_list: 'tag1, tag2')

    get :edit, id: image

    assert_redirected_to_login
  end

  test 'update tags' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test5Img', url: image_url, tag_list: 'tag1, tag2')
    new_tag_list = 'tag4, tag3, tag1'

    patch :update, id: image, image: { tag_list: new_tag_list }
    image.reload

    assert_redirected_to image_path(image)
    assert_equal 'You successfully change the tags', flash[:success]
    assert_equal ['tag1', 'tag4', 'tag3'], image.tag_list
  end

  test 'update tags to empty' do
    log_in(users(:default_user))
    image_url    = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image        = create_image(title: 'test6Img', url: image_url, tag_list: 'tag1, tag2')
    new_tag_list = ''
    new_url = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'

    patch :update, id: image, image: { tag_list: new_tag_list, url: new_url }
    image.reload

    assert_response :unprocessable_entity
    assert_select '.help-block', text: "can't be blank", count: 1
    assert_select "img[src=\"#{image_url}\"]", 1
    assert_select '#edit_image_form', 1
    assert_select '.image-detail__title', text: 'test6Img'
    assert_equal ['tag1', 'tag2'], image.tag_list
  end

  test 'update tags when not logged in' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test5Img', url: image_url, tag_list: 'tag1, tag2')
    new_tag_list = 'tag4, tag3, tag1'

    patch :update, id: image, image: { tag_list: new_tag_list }
    image.reload

    assert_redirected_to_login
  end

  test 'cannot forge the user_id in update' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test5Img', url: image_url, tag_list: 'tag1, tag2')
    new_tag_list = 'tag4, tag3, tag1'
    patch :update, id: image, image: { user_id: users(:other_user).id, tag_list: new_tag_list }
    image.reload

    assert_redirected_to image_path(image)
    assert_equal ['tag1', 'tag4', 'tag3'], image.tag_list
    assert_equal users(:default_user).id, image.user_id
  end

  test 'share image with valid email' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1    = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')
    params = {
      id: image1,
      share_form: {
        subject: 'some image form',
        recipient: 'some@jief.com',
        content: 'create_test'
      }
    }
    assert_difference 'ActionMailer::Base.deliveries.size' do
      xhr :post, :share, params
    end
    assert_response :success
    email = ActionMailer::Base.deliveries.last
    assert_equal 'some image form', email.subject
    assert_equal ['some@jief.com'], email.to
    assert_includes email.text_part.body.to_s, 'create_test'
  end

  test 'share image user info passed to mailer' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1    = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')
    params = {
      id: image1,
      share_form: {
        subject: 'some image form',
        recipient: 'some@jief.com',
        content: 'create_test'
      }
    }
    ImageMailer.expects(:send_email).with(image1, anything, users(:default_user))
      .returns(mock(:deliver_now))
    xhr :post, :share, params
    assert_response :success
  end

  test 'share image with invalid email' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1 = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')
    params = {
      id: image1,
      share_form: {
        subject: 'some image form',
        recipient: 'someinvalidemail.com',
        content: 'create_test'
      }
    }
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      xhr :post, :share, params
    end
    assert_response :unprocessable_entity
    response = JSON.parse(@response.body)
    form_html = response['form_html']
    assert_includes form_html, 'new_share_form'
    assert_includes form_html, image_url
    assert_includes form_html, 'share_form_subject'
    assert_includes form_html, 'share_form_content'
    assert_includes form_html, 'share_form_recipient'
    assert_includes form_html, 'is not a valid email address'
  end

  test 'share nonexistent image' do
    log_in(users(:default_user))
    params = {
      id: -1,
      share_form: {
        subject: 'some image form',
        recipient: 'someinvalidemail.com',
        content: 'create_test'
      }
    }
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      xhr :post, :share, params
    end
    assert_response :not_found
    assert_equal 'Image you want to share does not exist', flash[:danger]
  end

  test 'share when not logged in' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image1    = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')
    params = {
      id: image1,
      share_form: {
        subject: 'some image form',
        recipient: 'some@jief.com',
        content: 'create_test'
      }
    }
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      xhr :post, :share, params
    end
    assert_response :unauthorized
    assert_equal 'Please log in first', flash[:warning]
  end

  test 'favorite unfavorited image' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')
    params = { id: image, desire_favorite_state: 'true' }

    refute ImageFavorite.exists?(image: image, user: users(:default_user))

    xhr :post, :toggle_favorite, params

    assert_response :success
    assert ImageFavorite.exists?(image: image, user: users(:default_user))
    response = JSON.parse(@response.body)
    assert_equal 1, response['count']
    assert response['desire_favorite_state'], 'The desire favorite state should be true'
    assert_equal image.id, response['image_id']
  end


  test 'favorite image when not logged in' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')

    params = { id: image, desire_favorite_state: 'true' }
    xhr :post, :toggle_favorite, params

    assert_response :unauthorized
    assert_equal 'Please log in first', flash[:warning]
  end

  test 'favorite deleted image' do
    log_in(users(:default_user))
    params = { id: -1, desire_favorite_state: 'true' }
    xhr :post, :toggle_favorite, params

    assert_response :not_found
    assert_equal 'Image does not exist', flash[:danger]
  end

  test 'unfavorite favorited image' do
    log_in(users(:default_user))
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')
    params = { id: image, desire_favorite_state: 'false' }
    ImageFavorite.create!(user: users(:default_user), image: image)

    assert ImageFavorite.exists?(image: image, user: users(:default_user))

    xhr :post, :toggle_favorite, params

    assert_response :success
    refute ImageFavorite.exists?(image: image, user: users(:default_user))
    response = JSON.parse(@response.body)
    assert_equal 0, response['count']
    refute response['desire_favorite_state'], 'The desire favorite state should be false'
    assert_equal image.id, response['image_id']
  end

  test 'unfavorite image when not logged in' do
    image_url = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    image = create_image(title: 'test3Img', url: image_url, tag_list: 'tag')

    params = { id: image, desire_favorite_state: 'false' }
    xhr :post, :toggle_favorite, params

    assert_response :unauthorized
    assert_equal 'Please log in first', flash[:warning]
  end

  test 'unfavorite delted image' do
    log_in(users(:default_user))
    params = { id: -1, desire_favorite_state: 'false' }
    xhr :post, :toggle_favorite, params

    assert_response :not_found
    assert_equal 'Image does not exist', flash[:danger]
  end

  private

  def log_in(user)
    session[:user_id] = user.id
  end

  def assert_redirected_to_login
    assert_redirected_to login_path
    assert_equal 'Please log in first', flash[:warning]
  end
end
