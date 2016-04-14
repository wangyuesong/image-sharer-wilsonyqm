module ApplicationHelper
  def nav_item(text:, path:, is_active:)
    classes = ['nav-item']
    classes << 'active' if is_active
    content_tag :li, class: classes do
      link_to text, path, class: 'nav-link'
    end
  end
end
