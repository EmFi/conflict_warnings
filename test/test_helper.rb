ENV["RAILS_ENV"] = "test"
$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'rubygems'
require 'active_record'
require 'active_record/version'
require 'active_record/fixtures'
require 'action_controller'
require 'action_controller/test_process'
require 'action_controller/test_case'
require 'action_view'
require 'action_view/test_case'
require 'test/unit'
require 'shoulda'
#require 'active_support/core_ext/module'

require File.dirname(__FILE__) + '/../init.rb'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/db/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite3mem'])
ActiveRecord::Migration.verbose = false
load(File.dirname(__FILE__) + "/db/schema.rb")
Fixtures.create_fixtures(File.dirname(__FILE__) + '/fixtures', ActiveRecord::Base.connection.tables)

ActionController::Routing::Routes.reload rescue nil

class Time
  @@new_now = Time.now
  def self.now_with_stub
    @@new_now || Time.now_without_stub
  end
  class << self
    alias_method :now_without_stub, :now
    alias_method :now, :now_with_stub
  end
end

