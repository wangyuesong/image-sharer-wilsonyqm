module PageObjects
  class LoginPage < PageObjects::Document
    path :login

    form_for :session do
      element :email
      element :password
    end

    def sign_up!
      node.click_on('Sign up now!')
      window.change_to(SignupPage)
    end

    def log_in!(email: nil, password: nil)
      self.email.set(email) if email.present?
      self.password.set(password) if password.present?
      node.click_on('Log in')
      window.change_to(Images::IndexPage, self.class)
    end
  end
end
