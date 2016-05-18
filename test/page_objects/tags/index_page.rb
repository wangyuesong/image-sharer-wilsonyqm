module PageObjects
  module Tags
    class IndexPage < PageObjects::Document
      path :tags
      collection :tags, locator: '#tags_list', item_locator: '.js-tag' do
        def name
          node.find('.js-tag-btn').text
        end

        def view!
          node.find('.js-tag-btn').click
          window.change_to(Images::IndexPage)
        end
      end
    end
  end
end
