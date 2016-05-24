require 'flow_test_helper'

class LoginAndRegistrationTest < FlowTestCase
  include ImageCreation

  teardown do
    Capybara.current_session.reset!
  end

  test 'sign up' do
    images_index_page = PageObjects::Images::IndexPage.visit
    user_signup_page = images_index_page.sign_up_or_log_in!.sign_up!
    new_user = {
      name: 'newuser',
      email: 'invalid',
      password: '123456',
      password_confirmation: '1234567'
    }

    user_signup_page = user_signup_page.create_account!(new_user).as_a(PageObjects::SignupPage)
    assert_equal 'is not a valid email address', user_signup_page.email.error_message
    assert_equal "doesn't match Password", user_signup_page.password_confirmation.error_message
    user_signup_page.email.set('valid@email.com')
    user_signup_page.password.set('123456')
    user_signup_page.password_confirmation.set('123456')
    images_index_page = user_signup_page.create_account!
    assert_equal 'Welcome to the Share Image App!', images_index_page.flash_message(:success)
  end

  test 'login and logout' do
    images_index_page = PageObjects::Images::IndexPage.visit
    user_login_page = images_index_page.sign_up_or_log_in!

    fail_login = { email: 'invalid', password: ' ' }
    user_login_page = user_login_page.log_in!(fail_login).as_a(PageObjects::LoginPage)
    assert_equal 'Invalid password/username', user_login_page.flash_message(:danger)

    images_index_page = user_login_page.log_in!(email: users(:default_user)[:email], password: 'password')
    assert_equal 'Welcome to the Share Image App!', images_index_page.flash_message(:success)

    log_out_index_page = images_index_page.log_out!
    assert_equal 'You successfully logged out', log_out_index_page.flash_message(:success)
  end

  test 'login from new page redirect to login page and return to new page after login' do
    puppy_url_2 = 'http://ghk.h-cdn.co/assets/16/09/980x490/landscape-1457107485-gettyimages-512366437.jpg'
    create_image(url: puppy_url_2, tag_list: 'superman, cute', title: 'test1')

    user_login_page = nil
    Capybara.using_wait_time(0) do
      begin
        PageObjects::Images::NewPage.visit
      rescue AePageObjects::LoadingPageFailed
        user_login_page = AePageObjects.browser.current_window.change_to(PageObjects::LoginPage)
      end
    end

    assert_equal 'Please log in first', user_login_page.flash_message(:warning)
    fail_login = { email: 'invalid', password: ' ' }
    user_login_page = user_login_page.log_in!(fail_login).as_a(PageObjects::LoginPage)
    assert_equal 'Invalid password/username', user_login_page.flash_message(:danger)

    image_new_page = user_login_page.log_in!(
      email: users(:default_user)[:email],
      password: 'password'
    ).as_a(PageObjects::Images::NewPage)
    assert_equal 'Welcome to the Share Image App!', image_new_page.flash_message(:success)
    images_index_page = image_new_page.log_out!
    assert_equal 'You successfully logged out', images_index_page.flash_message(:success)
  end
end
