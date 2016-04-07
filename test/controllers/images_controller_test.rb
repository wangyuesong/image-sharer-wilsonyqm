require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  test 'index' do
    get :index
    assert_response :success
    assert_select '#hello_world', 1
  end
end
