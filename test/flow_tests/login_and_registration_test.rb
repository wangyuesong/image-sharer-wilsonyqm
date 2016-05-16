require 'flow_test_helper'

class LoginAndRegistrationTest < FlowTestCase
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
    images_index_page = user_signup_page.create_account!.as_a(PageObjects::Images::IndexPage)
    assert_equal 'Welcome to the Share Image App!', images_index_page.flash_message(:success)
  end

  test 'login and logout' do
    new_user = {
      name: 'newuser',
      email: 'valid@email.com',
      password: '123456',
      password_confirmation: '123456'
    }
    User.create!(new_user)
    images_index_page = PageObjects::Images::IndexPage.visit
    user_login_page = images_index_page.sign_up_or_log_in!
    fail_login = { email: 'invalid', password: ' ' }
    user_login_page = user_login_page.log_in!(fail_login).as_a(PageObjects::LoginPage)
    assert_equal 'Invalid password/username', user_login_page.flash_message(:danger)
    user_login_page.email.set(new_user[:email])
    user_login_page.password.set(new_user[:password])
    images_index_page = user_login_page.log_in!.as_a(PageObjects::Images::IndexPage)
    assert_equal 'Welcome to the Share Image App!', images_index_page.flash_message(:success)
    log_out_index_page = images_index_page.log_out!.as_a(PageObjects::Images::IndexPage)
    assert_equal 'You successfully logged out', log_out_index_page.flash_message(:success)
  end
end
