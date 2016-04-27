module PageObjects
  class Document < AePageObjects::Document
    def flash_message(message_type)
      node.find("#flash_messages .alert-#{message_type}").text
    end
  end
end
