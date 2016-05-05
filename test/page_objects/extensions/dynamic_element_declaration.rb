module PageObjects
  module Extensions
    module DynamicElementDeclaration
      def element(options_or_locator)
        options = if options_or_locator.is_a?(Hash)
                    options_or_locator.symbolize_keys
                  else
                    { locator: options_or_locator }
                  end

        element_class = options.delete(:is) || AePageObjects::Element

        AePageObjects::ElementProxy.new(element_class, self, options)
      end
    end
  end
end
