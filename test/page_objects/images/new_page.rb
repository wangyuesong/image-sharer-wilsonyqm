module PageObjects
  module Images
    class NewPage < PageObjects::Document
      path :new_image
      path :images #from failed create

      form_for :image do
        element :title
        element :url
        element :tag_list
      end

      def create_image!(title: nil, url: nil, tags: nil)
        self.url.set(url) if url.present?
        self.tag_list.set(tags) if tags.present?
        self.title.set(title) if title.present?
        node.click_button('Save Image')
        window.change_to(ShowPage, self.class)
      end
    end
  end
end
