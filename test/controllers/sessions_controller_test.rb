require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include SessionUtilities

  test 'new' do
    get :new
    assert_response :success
    assert_select '#session_form', 1
  end

  test 'create' do
    username = 'username@email.com'
    password = 'passwd'
    user = User.create!(email: username, password: password, name: 'name')

    post :create, session: { email: username, password: password }
    assert_redirected_to images_path
    assert_equal user.id, session[:user_id]
    assert_equal 'Welcome to the Share Image App!', flash[:success]
  end

  test 'create with invalid password' do
    username = 'username@email.com'
    password = 'passwd'
    User.create!(email: username, password: password, name: 'name')

    post :create, session: { email: username, password: 'invalid' }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select '#session_form', 1
    assert_equal 'Invalid password/username', flash[:danger]
  end

  test 'create with nonexistent user' do
    username = 'username@email.com'
    password = 'passwd'

    post :create, session: { email: username, password: password }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select '#session_form', 1
    assert_equal 'Invalid password/username', flash[:danger]
  end

  test 'create with missing email' do
    password = 'passwd'
    post :create, session: { email: '', password: password }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select '#session_form', 1
    assert_equal 'Invalid password/username', flash[:danger]
  end

  test 'create with missing password' do
    username = 'username'
    post :create, session: { email: username, password: '' }
    assert_response :unprocessable_entity
    assert_nil session[:user_id]
    assert_select '#session_form', 1
    assert_equal 'Invalid password/username', flash[:danger]
  end

  test 'create when already logged in' do
    user_logged_in = User.create!(
      name: 'user1',
      email: 'user@some.com',
      password: '123456',
      password_confirmation: '123456'
    )
    assert_nil session[:user_id]
    log_in(user_logged_in)
    assert_equal user_logged_in.id, session[:user_id]
    user_form = { email: 'user@some.com', password: '123456' }
    post :create, session: user_form
    assert_redirected_to images_path
    assert_equal 'You are already logged in', flash[:info]
  end

  test 'destroy' do
    username = 'username@email.com'
    password = 'passwd'
    user = User.create!(email: username, password: password, name: 'name')
    session[:user_id] = user.id
    post :destroy
    assert_redirected_to images_path
    assert_nil session[:user_id]
    assert_equal 'You successfully logged out', flash[:success]
  end

  test 'destroy non-existing session' do
    session[:user_id] = nil
    post :destroy
    assert_redirected_to images_path
    assert_equal 'You are already logged out', flash[:info]
    assert_nil session[:user_id]
  end

  test 'remember me' do
    username = 'username@email.com'
    password = 'passwd'
    user = User.create!(email: username, password: password, name: 'name')
    post :create, session: { email: username, password: password, remember_me: '1' }
    assert_redirected_to images_path
    session.delete(:user_id).present?
    assert_equal user.id, cookies.signed[:user_id]
    assert_not_nil current_user
  end
end
