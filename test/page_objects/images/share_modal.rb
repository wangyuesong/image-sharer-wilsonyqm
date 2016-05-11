module PageObjects
  module Images
    class ShareModal < AePageObjects::Element
      form_for :share_form do
        element :subject
        element :recipient
        element :content
      end

      def image_url
        node.find('img')[:src]
      end

      def share_image
        node.click_button('Share')
      end

      def close_modal
        node.click_button('Close')
      end
    end
  end
end
