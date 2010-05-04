module VKontakte
	module Utilities
		def vk_cookie app_id = nil
			CGI.parse(cookies["vk_app_#{app_id || Settings.get(:app_id)}"]) rescue nil
		end

		def openapi_sid app_id = nil
			if cookie = vk_cookie(app_id) then
				cookie['sid'].first
			end
		end

		def openapi_user app_id = nil, app_password = nil
			if cookie = vk_cookie(app_id) then
				if VKontakte::OpenAPI.cookie_signed? cookie, app_password then
					cookie['mid'].first
				end
			end
		end

		def openapi_logout app_id
			cookies["vk_app_#{app_id || Settings.get(:app_id)}"] = nil
		end
	end
end

