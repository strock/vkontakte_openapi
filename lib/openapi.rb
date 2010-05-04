require 'digest/md5'
require 'json'

module VKontakte
	class VKontakteNotAuthorizedException < StandardError
	end

	class OpenAPI
		API_ENDPOINT = "http://api.vkontakte.ru/api.php"

		attr_accessor :app_id
		attr_accessor :app_password
		attr_accessor :cookie

		def initialize cookie, app_id = nil, app_password = nil
			raise VKontakteNotAuthorizedException.new('Not authorized on vkontakte.ru - app cookie doesn\'t exist') unless cookie
			@app_id, @app_password, @cookie = (app_id || Settings.get(:app_id)), (app_password || Settings.get(:app_password)), cookie
		end

		def call_api method, params = {}
			self.class.call_api method, params, @cookie, @app_id
		end

		def method_missing m, *args, &block
			call_api m.to_s.split('_').join('.'), *args
		end

		def self.cookie_signed? cookie, app_password = nil
			cookie['sig'].first == generate_cookie_sign({ 
				:expire => cookie['expire'].first,
				:mid    => cookie['mid'].first,
				:secret => cookie['secret'].first,
				:sid    => cookie['sid'].first,
			}, (app_password || Settings.get(:app_password)))
		end

		def self.call_api method, params, cookie, app_id
			params_to_sign = {
				:method => method,
				:timestamp => Time.now.to_i,
				:random => (rand * 1_000_000_000).to_i.to_s,
				:api_id => app_id,
				:v      => '3.0',
				:format => 'JSON',
			}.merge(params.inject({}) do |hash, keyval|
				hash[keyval.first] = case value = keyval.last
				when Array then
					value.join(',')
				else
					value.to_s
				end
				hash
			end)
			JSON.parse(Net::HTTP.get_response(URI.parse("#{API_ENDPOINT}?#{params_to_sign.to_query}&sig=#{generate_api_sign(cookie, params_to_sign)}&sid=#{cookie['sid'].first}")).body)["response"]
		end

		private

		# WTF: Two different guidelines for query signs

		def self.generate_cookie_sign data, app_password
			Digest::MD5.hexdigest(data.sort{|a, b| a.first.to_s <=> b.first.to_s}.collect{|key, value| "#{key}=#{value}"}.join + app_password)
		end

		def self.generate_api_sign cookie, data
			Digest::MD5.hexdigest(cookie['mid'].first + data.sort{|a, b| a.first.to_s <=> b.first.to_s}.collect{|key, value| "#{key}=#{value}"}.join + cookie['secret'].first)
		end
	end
end

