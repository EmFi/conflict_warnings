# Include hook code here
require File.dirname(__FILE__) + '/lib/conflict_warnings'
ActionView::Helpers::UrlHelper.send :include, ConflictWarnings::ActionView::Helpers::UrlHelper
ActionController::Base.send :include, ConflictWarnings::ActionController::Base
ActionView::Helpers::PrototypeHelper.send :include, ConflictWarnings::ActionView::Helpers::PrototypeHelper
