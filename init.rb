# Include hook code here
require File.dirname(__FILE__) + '/lib/conflict_warnings'
ActionView::Base.send :include, ConflictWarnings::ActionView::Base
ActionController::Base.send :include, ConflictWarnings::ActionController::Base
