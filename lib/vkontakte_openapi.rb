require 'settings'
require 'openapi'
require 'utils'
require 'vkontakte_helper'

class ActionController::Base
	include VKontakte::Utilities
end

