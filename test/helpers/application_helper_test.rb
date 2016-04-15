require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test 'nav_item' do
    expected_html = <<-HTML.strip
<li class="nav-item active"><a class="nav-link" href="/images">Images</a></li>
    HTML
    assert_equal expected_html, view.nav_item(text: 'Images', path: '/images', is_active: true)

    expected_html = <<-HTML.strip
<li class="nav-item"><a class="nav-link" href="/images">Images</a></li>
    HTML
    assert_equal expected_html, view.nav_item(text: 'Images', path: '/images', is_active: false)
  end
end
