module PageObjects
  module Images
    class EditPage < PageObjects::Document
      path :edit_image
      path :image

      element :form, locator: '#edit_image_form'
      form_for :image do
        element :tag_list
      end

      def save_tags!(tags)
        self.tag_list.set(tags)
        node.click_button('Save Tags')
        window.change_to do |query|
          query.matches(ShowPage) { |show_page| show_page.tag_elements.present? }
          query.matches(self.class) { |edit_page| edit_page.form.present? }
        end
      end

      def has_img?(url)
        node.find("img[src=\"#{url}\"]").present?
      end
    end
  end
end
