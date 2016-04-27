module PageObjects
  module Images
    class IndexPage < PageObjects::Document
      path :images

      collection :images, locator: '#images_list', item_locator: '.js-image-card', contains: ImageCard do
        def view!
          node.find('.image-detail__title').click
          window.change_to(ShowPage)
        end
      end

      def add_new_image!
        node.click_on('Insert Image')
        window.change_to(NewPage)
      end

      def is_showing_image?(url:, tags: nil)
        images.any? do |image|
          result = image.url == url
          tags.present? ? (result && image.tags == tags) : result
        end
      end

      def clear_tag_filter!
        node.click_on('ImageList')
        window.change_to(IndexPage)
      end
    end
  end
end
