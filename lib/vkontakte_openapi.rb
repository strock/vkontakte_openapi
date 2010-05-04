require 'settings'
require 'openapi'
require 'utils'
require 'vkontakte_helper'

class ActionController::Base
	include VKontakte::Utilities

	def method_missing_with_vkontakte m, *args, &block
		if m.to_s.starts_with? 'vk_' and vk_cookie then
			VKontakte::OpenAPI.call_api m.to_s.gsub(/^vk_/, '').split('_').join('.'), vk_cookie, *args
		else
			method_missing_without_vkontakte m, *args, &block
		end
	end; alias_method_chain :method_missing, :vkontakte
end

