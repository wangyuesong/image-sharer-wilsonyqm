module PageObjects
  module Images
    class ImageCard < AePageObjects::Element
      def url
        node.find('img')[:src]
      end

      def tags
        node.all('.js-image-tag').map(&:text)
      end

      def click_tag!(tag_name)
        node.click_on(tag_name)
        window.change_to(IndexPage)
      end

      def share!
        node.click_on('Share')
        window.change_to(ShareNewPage)
      end
    end
  end
end
