# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')
#require 'abstract_unit'

RequestMock = Struct.new("Request", :request_uri, :protocol, :host_with_port, :env)



class ConflictWarningUrlHelperTest < ActionView::TestCase
  tests ConflictWarnings::ActionView::Helpers::UrlHelper

  def setup
    @controller = Class.new do
      attr_accessor :url, :request
      def url_for(options)
        url
      end
    end
    @controller = @controller.new
    @controller.url = "http://www.example.com?page_rendered_at=#{Time.now.to_i}"
  end

  def test_link_tag_with_straight_url
    assert_dom_equal "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\">Hello</a>", link_to_with_timestamp("Hello", "http://www.example.com")
  end

  def test_link_tag_without_host_option
    ActionController::Base.class_eval { attr_accessor :url }
    url = {:controller => 'weblog', :action => 'show'}
    @controller = ActionController::Base.new
    @controller.request = ActionController::TestRequest.new
    @controller.url = ActionController::UrlRewriter.new(@controller.request, url)
    assert_dom_equal(%Q|<a href="/weblog/show?page_rendered_at=#{Time.now.to_i}">Test Link</a>|, link_to_with_timestamp('Test Link', url))
  end

  def test_link_tag_with_host_option
    ActionController::Base.class_eval { attr_accessor :url }
    url = {:controller => 'weblog', :action => 'show', :host => 'www.example.com'}
    @controller = ActionController::Base.new
    @controller.request = ActionController::TestRequest.new
    @controller.url = ActionController::UrlRewriter.new(@controller.request, url)
    assert_dom_equal(%Q|<a href="http://www.example.com/weblog/show?page_rendered_at=#{Time.now.to_i}">Test Link</a>|, link_to_with_timestamp('Test Link', url))
  end

  def test_link_tag_with_query
    assert_dom_equal "<a href=\"http://www.example.com?q1=v1&amp;q2=v2&amp;page_rendered_at=#{Time.now.to_i}\">Hello</a>", link_to_with_timestamp("Hello", "http://www.example.com?q1=v1&amp;q2=v2")
  end

  def test_link_tag_with_query_and_no_name
    assert_dom_equal "<a href=\"http://www.example.com?q1=v1&amp;q2=v2&amp;page_rendered_at=#{Time.now.to_i}\">http://www.example.com?q1=v1&amp;q2=v2&amp;page_rendered_at=#{Time.now.to_i}</a>", link_to_with_timestamp(nil, "http://www.example.com?q1=v1&amp;q2=v2")
  end

  def test_link_tag_with_back
    @controller.request = RequestMock.new("http://www.example.com/weblog/show", nil, nil, {'HTTP_REFERER' => 'http://www.example.com/referer'})
    assert_raise(ArgumentError){ link_to_with_timestamp('go back', :back)}
  end

  def test_link_tag_with_back_and_no_referer
    @controller.request = RequestMock.new("http://www.example.com/weblog/show", nil, nil, {})
    assert_raise(ArgumentError){ link_to_with_timestamp('go back', :back)}
  end
 
  def test_link_tag_with_img
    assert_dom_equal "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\"><img src='/favicon.jpg' /></a>", link_to_with_timestamp("<img src='/favicon.jpg' />", "http://www.example.com")
  end

  def test_link_with_nil_html_options
    assert_dom_equal "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\">Hello</a>", link_to_with_timestamp("Hello", {:action => 'myaction'}, nil)
  end

  def test_link_tag_with_custom_onclick
    assert_dom_equal "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"alert('yay!')\">Hello</a>", link_to_with_timestamp("Hello", "http://www.example.com", :onclick => "alert('yay!')")
  end

  def test_link_tag_with_javascript_confirm
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"return confirm('Are you sure?');\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :confirm => "Are you sure?")
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"return confirm('You can\\'t possibly be sure, can you?');\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :confirm => "You can't possibly be sure, can you?")
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"return confirm('You can\\'t possibly be sure,\\n can you?');\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :confirm => "You can't possibly be sure,\n can you?")
    )
  end

  def test_link_tag_with_popup
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"window.open(this.href);return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :popup => true)
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"window.open(this.href);return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :popup => 'true')
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"window.open(this.href,'window_name','width=300,height=300');return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :popup => ['window_name', 'width=300,height=300'])
    )
  end

  def test_link_tag_with_popup_and_javascript_confirm
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"if (confirm('Fo\\' sho\\'?')) { window.open(this.href); };return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", { :popup => true, :confirm => "Fo' sho'?" })
    )
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"if (confirm('Are you serious?')) { window.open(this.href,'window_name','width=300,height=300'); };return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", { :popup => ['window_name', 'width=300,height=300'], :confirm => "Are you serious?" })
    )
  end

  def test_link_tag_using_post_javascript
    assert_dom_equal(
      "<a href='http://www.example.com?page_rendered_at=#{Time.now.to_i}' onclick=\"var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;f.submit();return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :method => :post)
    )
  end

  def test_link_tag_using_delete_javascript
    assert_dom_equal(
      "<a href='http://www.example.com?page_rendered_at=#{Time.now.to_i}' onclick=\"var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;\">Destroy</a>",
      link_to_with_timestamp("Destroy", "http://www.example.com", :method => :delete)
    )
  end

  def test_link_tag_using_delete_javascript_and_href
    assert_dom_equal(
      "<a href='\#' onclick=\"var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = 'http://www.example.com?page_rendered_at=#{Time.now.to_i}';var m = document.createElement('input'); m.setAttribute('type', 'hidden'); m.setAttribute('name', '_method'); m.setAttribute('value', 'delete'); f.appendChild(m);f.submit();return false;\">Destroy</a>",
      link_to_with_timestamp("Destroy", "http://www.example.com", :method => :delete, :href => '#')
    )
  end

  def test_link_tag_using_post_javascript_and_confirm
    assert_dom_equal(
      "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\" onclick=\"if (confirm('Are you serious?')) { var f = document.createElement('form'); f.style.display = 'none'; this.parentNode.appendChild(f); f.method = 'POST'; f.action = this.href;f.submit(); };return false;\">Hello</a>",
      link_to_with_timestamp("Hello", "http://www.example.com", :method => :post, :confirm => "Are you serious?")
    )
  end

  def test_link_tag_using_post_javascript_and_popup
    assert_raise(ActionView::ActionViewError) { link_to_with_timestamp("Hello", "http://www.example.com", :popup => true, :method => :post, :confirm => "Are you serious?") }
  end

  def test_link_tag_using_block_in_erb
    __in_erb_template = ""

    link_to_with_timestamp("http://example.com") { concat("Example site") }

    assert_equal %Q|<a href="http://example.com?page_rendered_at=#{Time.now.to_i}">Example site</a>|, output_buffer
  end

  def test_link_to_with_timestamp_unless
    assert_equal "Showing", link_to_with_timestamp_unless(true, "Showing", :action => "show", :controller => "weblog")
    assert_dom_equal "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\">Listing</a>", link_to_with_timestamp_unless(false, "Listing", :action => "list", :controller => "weblog")
    assert_equal "Showing", link_to_with_timestamp_unless(true, "Showing", :action => "show", :controller => "weblog", :id => 1)
    assert_equal "<strong>Showing</strong>", link_to_with_timestamp_unless(true, "Showing", :action => "show", :controller => "weblog", :id => 1) { |name, options, html_options|
      "<strong>#{name}</strong>"
    }
    assert_equal "<strong>Showing</strong>", link_to_with_timestamp_unless(true, "Showing", :action => "show", :controller => "weblog", :id => 1) { |name|
      "<strong>#{name}</strong>"
    }
    assert_equal "test", link_to_with_timestamp_unless(true, "Showing", :action => "show", :controller => "weblog", :id => 1) {
      "test"
    }
  end

  def test_link_to_with_timestamp_if
    assert_equal "Showing", link_to_with_timestamp_if(false, "Showing", :action => "show", :controller => "weblog")
    assert_dom_equal "<a href=\"http://www.example.com?page_rendered_at=#{Time.now.to_i}\">Listing</a>", link_to_with_timestamp_if(true, "Listing", :action => "list", :controller => "weblog")
    assert_equal "Showing", link_to_with_timestamp_if(false, "Showing", :action => "show", :controller => "weblog", :id => 1)
  end

  
  def protect_against_forgery?
    false
  end
end
