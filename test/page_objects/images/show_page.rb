module PageObjects
  module Images
    class ShowPage < PageObjects::Document
      path :image

      def has_url?(url)
        #TODO
      end

      def tags
        #TODO
      end

      def delete
        #TODO
        yield node.driver.browser.switch_to.alert
      end

      def delete_and_confirm!
        #TODO
        alert = node.driver.browser.switch_to.alert
        alert.accept
        window.change_to(IndexPage)
      end

      def go_back_to_index!
        #TODO
      end
    end
  end
end
