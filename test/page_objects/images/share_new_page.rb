module PageObjects
  module Images
    class ShareNewPage < PageObjects::Document
      path :new_share_image
      path :create_share_image # from failed create

      form_for :share_form do
        element :subject
        element :recipient
        element :content
      end

      def image_url
        node.find('img')[:src]
      end

      def share_image!(subject: nil, recipient: nil, content: nil)
        self.subject.set(subject) if subject.present?
        self.recipient.set(recipient) if recipient.present?
        self.content.set(content) if content.present?
        node.click_button('Share Image')
        window.change_to(IndexPage, self.class)
      end
    end
  end
end
