module PageObjects
  class Document < AePageObjects::Document
    def flash_message(message_type)
      node.find("#flash_messages .alert-#{message_type}").text
    end

    def sign_up_or_log_in!
      node.click_on('Log In / Sign Up')
      window.change_to(LoginPage)
    end

    def log_out!
      node.click_on('Log Out')
      window.change_to(Images::IndexPage)
    end

    def show_tags_list!
      node.click_on('All Tags')
      window.change_to(Tags::IndexPage)
    end
  end
end
