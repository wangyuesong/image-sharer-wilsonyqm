require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test 'new' do
    get :new
    assert_response :success
    assert_select '#new_user', 1
  end

  test 'new when logged in' do
    user_logged_in = User.create!(
      name: 'user1',
      email: 'user@some.com',
      password: '123456',
      password_confirmation: '123456'
    )
    log_in(user_logged_in)
    get :new
    assert_redirected_to images_path
    assert_equal 'Please log out before you sign up', flash[:danger]
    assert_equal user_logged_in.id, session[:user_id]
  end

  test 'create' do
    user_form = {
      name: 'user',
      email: 'user@some.com',
      password: '123456',
      password_confirmation: '123456'
    }
    assert_difference 'User.count', 1 do
      post :create, user: user_form
    end
    assert_redirected_to images_path
    assert_equal 'Welcome to the Share Image App!', flash[:success]
    assert_equal User.last.id, session[:user_id]
  end

  test 'create when logged in' do
    user_logged_in = User.create!(
      name: 'user1',
      email: 'user@some.com',
      password: '123456',
      password_confirmation: '123456'
    )
    log_in(user_logged_in)
    user_form = {
      name: 'user2',
      email: 'user2@some.com',
      password: '123456',
      password_confirmation: '123456'
    }
    assert_no_difference 'User.count' do
      post :create, user: user_form
    end
    assert_redirected_to images_path
    assert_equal 'Please log out before you sign up', flash[:danger]
    assert_equal user_logged_in.id, session[:user_id]
  end

  test 'create with invalid input' do
    user_form = {
      name: 'user',
      email: 'user@some.com',
      password: '1234567',
      password_confirmation: '123456'
    }
    assert_no_difference 'User.count' do
      post :create, user: user_form
    end
    assert_response :unprocessable_entity
    assert_select '#new_user', 1
    assert_select '.help-block', text: "doesn't match Password", count: 1
  end

  private
  def log_in(user)
    session[:user_id] = user.id
  end
end

