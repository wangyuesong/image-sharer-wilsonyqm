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

    expected_html = <<-HTML.strip
<li class="nav-item pull-xs-right"><a class="nav-link" rel="nofollow" data-method="delete" href="/logout"><span class="fa fa-sign-out"></span> Log Out</a></li>
    HTML
    actual_html = view.nav_item(path: '/logout',
                  is_active: false,
                  method: :delete,
                  alignment: :right) do
      '<span class="fa fa-sign-out"></span> Log Out'.html_safe
    end
    assert_equal expected_html, actual_html
  end
end
