# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/test_helper')
#require 'abstract_unit'

RequestMock = Struct.new("Request", :request_uri, :protocol, :host_with_port, :env)
silence_warnings do
  Post = Struct.new(:title, :author_name, :body, :secret, :written_on, :cost)
  Post.class_eval do
    alias_method :title_before_type_cast, :title unless respond_to?(:title_before_type_cast)
    alias_method :body_before_type_cast, :body unless respond_to?(:body_before_type_cast)
    alias_method :author_name_before_type_cast, :author_name unless respond_to?(:author_name_before_type_cast)
    alias_method :secret?, :secret

    def new_record=(boolean)
      @new_record = boolean
    end

    def new_record?
      @new_record
    end

    attr_accessor :author
    def author_attributes=(attributes); end

    attr_accessor :comments
    def comments_attributes=(attributes); end
  end

  class Comment
    attr_reader :id
    attr_reader :post_id
    def initialize(id = nil, post_id = nil); @id, @post_id = id, post_id end
    def save; @id = 1; @post_id = 1 end
    def new_record?; @id.nil? end
    def to_param; @id; end
    def name
      @id.nil? ? "new #{self.class.name.downcase}" : "#{self.class.name.downcase} ##{@id}"
    end
  end

  class Author < Comment
    attr_accessor :post
    def post_attributes=(attributes); end
  end
end

class ConflictWarningFormHelperTest < ActionView::TestCase
  tests ConflictWarnings::ActionView::Helpers::FormHelper

  def setup
    @post = Post.new
    @comment = Comment.new
    def @post.errors()
      Class.new{
        def on(field); "can't be empty" if field == "author_name"; end
        def empty?() false end
        def count() 1 end
        def full_messages() [ "Author name can't be empty" ] end
      }.new
    end
    def @post.id; 123; end
    def @post.id_before_type_cast; 123; end
    def @post.to_param; '123'; end

    @post.title       = "Hello World"
    @post.author_name = ""
    @post.body        = "Back to the hill and over it again!"
    @post.secret      = 1
    @post.written_on  = Date.new(2004, 6, 15)

    @controller = Class.new do
      attr_reader :url_for_options
      def url_for(options)
        @url_for_options = options
        "http://www.example.com"
      end
    end
    @controller = @controller.new
  end

  def test_timestamp
    assert_dom_equal "<input id=\"page_rendered_at\" name=\"page_rendered_at\" type=\"hidden\" value=\"#{Time.now.to_i}\" />", timestamp("post")
    assert_dom_equal "<input id=\"timestamp\" name=\"timestamp\" type=\"hidden\" value=\"#{Time.now.to_i}\" />", timestamp( "post", "timestamp")
  end

   def test_form_for
    form_for(:post, @post, :html => { :id => 'create-post' }) do |f|
      concat f.label(:title)
      concat f.text_field(:title)
      concat f.text_area(:body)
      concat f.check_box(:secret)
      concat f.timestamp(:timestamp)
      concat f.submit('Create post')
    end

    expected =
      "<form action='http://www.example.com' id='create-post' method='post'>" +
      "<label for='post_title'>Title</label>" +
      "<input name='post[title]' size='30' type='text' id='post_title' value='Hello World' />" +
      "<textarea name='post[body]' id='post_body' rows='20' cols='40'>Back to the hill and over it again!</textarea>" +
      "<input name='post[secret]' type='hidden' value='0' />" +
      "<input name='post[secret]' checked='checked' type='checkbox' id='post_secret' value='1' />" +
      "<input id=\"timestamp\" name=\"timestamp\" type=\"hidden\" value=\"#{Time.now.to_i}\" />" +
      "<input name='commit' id='post_submit' type='submit' value='Create post' />" +
      "</form>"

    assert_dom_equal expected, output_buffer
  end

  def test_form_for_with_method
    form_for(:post, @post, :html => { :id => 'create-post', :method => :put }) do |f|
      concat f.text_field(:title)
      concat f.text_area(:body)
      concat f.timestamp
    end

    expected =
      "<form action='http://www.example.com' id='create-post' method='post'>" +
      "<div style='margin:0;padding:0;display:inline'><input name='_method' type='hidden' value='put' /></div>" +
      "<input name='post[title]' size='30' type='text' id='post_title' value='Hello World' />" +
      "<textarea name='post[body]' id='post_body' rows='20' cols='40'>Back to the hill and over it again!</textarea>" +      
      "<input id=\"page_rendered_at\" name=\"page_rendered_at\" type=\"hidden\" value=\"#{Time.now.to_i}\" />" +
      "</form>"

    assert_dom_equal expected, output_buffer
  end


end
