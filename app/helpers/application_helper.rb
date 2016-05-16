module ApplicationHelper
  def nav_item(text: nil, path:, is_active: true, method: nil, alignment: nil)
    classes = ['nav-item']
    classes << 'active' if is_active
    classes << 'pull-xs-right' if alignment == :right
    content_tag :li, class: classes do
      if text.present?
        link_to text, path, class: 'nav-link', method: method
      else
        link_to path, class: 'nav-link', method: method do
          yield
        end
      end
    end
  end
end
