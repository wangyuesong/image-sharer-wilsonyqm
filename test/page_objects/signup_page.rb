module PageObjects
  class SignupPage < PageObjects::Document
    path :signup

    form_for :user do
      element :name
      element :email
      element :password
      element :password_confirmation
    end

    def create_account!(name: nil, email: nil, password: nil, password_confirmation: nil)
      self.name.set(name) if name.present?
      self.email.set(email) if email.present?
      self.password.set(password) if password.present?
      self.password_confirmation.set(password_confirmation) if password_confirmation.present?
      node.click_on('Create my account')
      window.change_to(Images::IndexPage, self.class)
    end
  end
end
