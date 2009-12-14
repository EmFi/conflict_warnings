# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')
#require 'abstract_unit'


Bunny = Struct.new(:Bunny, :id)

class Author
  attr_reader :id
  def save; @id = 1 end
  def new_record?; @id.nil? end
  def name
    @id.nil? ? 'new author' : "author ##{@id}"
  end
end

class Article
  attr_reader :id
  attr_reader :author_id
  def save; @id = 1; @author_id = 1 end
  def new_record?; @id.nil? end
  def name
    @id.nil? ? 'new article' : "article ##{@id}"
  end
end

class Author::Nested < Author; end





class ConflictWarningPrototypeHelperBaseTest < ActionView::TestCase

  attr_accessor :template_format, :output_buffer

  def setup
    @template = self
    @controller = Class.new do
      def url_for(options)
        if options.is_a?(String)
          options
        else
          url =  "http://www.example.com/"
          url << options[:action].to_s if options and options[:action]
          url << "?a=#{options[:a]}" if options && options[:a]
          url << "&b=#{options[:b]}" if options && options[:a] && options[:b]
          url << (url.match(/\?/) ? "&" : "?") +  "page_rendered_at=#{Time.now.to_i}"
          url
        end
      end
    end.new
  end

  protected
  def request_forgery_protection_token
    nil
  end

  def protect_against_forgery?
    false
  end

  def create_generator
    block = Proc.new { |*args| yield *args if block_given? }
    JavaScriptGenerator.new self, &block
  end
end

class ConflictWarningPrototypeHelperTest < ConflictWarningPrototypeHelperBaseTest
  tests ConflictWarnings::ActionView::Helpers::PrototypeHelper

  def test_link_to_remote_with_timestamp
    assert_dom_equal %(<a class=\"fine\" href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", { :url => { :action => "whatnot"  }}, { :class => "fine"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true, onComplete:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", :complete => "alert(request.responseText)", :url => { :action => "whatnot"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true, onSuccess:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", :success => "alert(request.responseText)", :url => { :action => "whatnot"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true, onFailure:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", :failure => "alert(request.responseText)", :url => { :action => "whatnot"  })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?a=10&amp;b=20&amp;page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true, onFailure:function(request){alert(request.responseText)}}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", :failure => "alert(request.responseText)", :url => { :action => "whatnot", :a => '10', :b => '20' })
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:false, evalScripts:true}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", :url => { :action => "whatnot" }, :type => :synchronous)
    assert_dom_equal %(<a href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true, insertion:'bottom'}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", :url => { :action => "whatnot" }, :position => :bottom)
  end

  def test_link_to_remote_with_timestamp_html_options
    assert_dom_equal %(<a class=\"fine\" href=\"#\" onclick=\"new Ajax.Request('http://www.example.com/whatnot?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true}); return false;\">Remote outauthor</a>),
    link_to_remote_with_timestamp("Remote outauthor", { :url => { :action => "whatnot"  }, :html => { :class => "fine" } })
  end

  def test_link_to_remote_with_timestamp_url_quote_escaping
    assert_dom_equal %(<a href="#" onclick="new Ajax.Request('http://www.example.com/whatnot\\\'s?page_rendered_at=#{Time.now.to_i}', {asynchronous:true, evalScripts:true}); return false;">Remote</a>),
    link_to_remote_with_timestamp("Remote", { :url => { :action => "whatnot's" } })
  end


  def test_link_to_remote_with_timestamp_and_fallback
    assert_dom_equal link_to_remote_with_timestamp_and_fallback("Remote outauthor", { :url => { :action => "whatnot"  }}, { :class => "fine"  }),
      link_to_remote_with_timestamp("Remote outauthor", {:url => {:action => "whatnot"}}, {:class => "fine", :href => url_for(:action => "whatnot")})
  end
end
