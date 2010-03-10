# Include hook code here
require 'localist'
require 'controller_methods'
require 'helper'

class ActionController::Base
  include LocalistAction::Controller
  helper LocalistAction::Helper
  before_filter :localist
end
