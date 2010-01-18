# Include hook code here
require File.dirname(__FILE__) + '/lib/conflict_warnings'
ActionView::Base.send :include, ConflictWarnings::ActionView::Helpers::UrlHelper
ActionController::Base.send :include, ConflictWarnings::ActionController::Base
ActionView::Base.send :include, ConflictWarnings::ActionView::Helpers::PrototypeHelper
ActionView::Base.send :include, ConflictWarnings::ActionView::Helpers::FormHelper

ActionView::Base.send :include, ConflictWarnings::ActionView::Helpers::FormTagHelper

ActionView::Base.send :include, ConflictWarnings::ActionView::Helpers::FormBuilder 


