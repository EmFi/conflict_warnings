# Include hook code here
require File.dirname(__FILE__) + '/lib/conflict_warnings'
ActionView::Helpers::UrlHelper.send :include, ConflictWarnings::ActionView::Helpers::UrlHelper
ActionController::Base.send :include, ConflictWarnings::ActionController::Base
ActionView::Helpers::PrototypeHelper.send :include, ConflictWarnings::ActionView::Helpers::PrototypeHelper
ActionView::Helpers::FormHelper.send :include, ConflictWarnings::ActionView::Helpers::FormHelper

ActionView::Helpers::FormTagHelper.send :include, ConflictWarnings::ActionView::Helpers::FormTagHelper

ActionView::Helpers::FormBuilder.send :include, ConflictWarnings::ActionView::Helpers::FormBuilder 


