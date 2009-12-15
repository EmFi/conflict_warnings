# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')
#require 'abstract_unit'

RequestMock = Struct.new("Request", :request_uri, :protocol, :host_with_port, :env)

class ConflictWarningFormTagHelperTest < ActionView::TestCase
  tests ConflictWarnings::ActionView::Helpers::FormTagHelper

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

  def test_timestamp_tag
    assert_dom_equal "<input id=\"page_rendered_at\" name=\"page_rendered_at\" type=\"hidden\" value=\"#{Time.now.to_i}\" />", timestamp_tag
    assert_dom_equal "<input id=\"timestamp\" name=\"timestamp\" type=\"hidden\" value=\"#{Time.now.to_i}\" />", timestamp_tag( "timestamp")
  end


end