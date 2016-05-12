require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  include ImageCreation

  test 'index with all tags listed' do
    url1 = 'http://images.mazdausa.com/MusaWeb/musa2/images/vlp/panels/M6G/
            exterior-view/soulred/black/img_vlp_360_m6g_soulred_black_01_lg.jpg'
    url2 = 'http://carphotos.cardomain.com/images/0004/43/95/4053459.JPG'
    url3 = 'http://www.horniman.info/DKNSARC/SD04/IMAGES/D4P1570C.JPG'
    create_images([
      { title: 'image1', url: url1, tag_list: 'mazda6, red, amazon' },
      { title: 'image2', url: url2, tag_list: 'mazda6, grey, amazon' },
      { title: 'image3', url: url3, tag_list: 'mazda6, red, amazon' }
    ])
    get :index
    assert_response :success
    assert_select '.heading', text: 'Listing of Tags', count: 1
    assert_select '#tags_list', count: 1
    assert_select '.js-tag .js-tag-btn' do |elements|
      assert_equal ['amazon', 'mazda6', 'red', 'grey'], elements.map(&:text)
    end
    assert_select '.js-tag .js-tag-count' do |elements|
      assert_equal ['Count: 3', 'Count: 3', 'Count: 2', 'Count: 1'], elements.map(&:text)
    end
  end
end
