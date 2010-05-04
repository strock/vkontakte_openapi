module VKontakte
    class ConfigFileNotFoundException < StandardError
    end

	class Settings
		unless File.exist?(RAILS_ROOT + '/config/vkontakte.yml')
			raise ConfigFileNotFoundException.new("File RAILS_ROOT/config/vkontakte.yml not found")
		else
			env = ENV['RAILS_ENV'] || RAILS_ENV
			SETTINGS = YAML.load_file(RAILS_ROOT + '/config/vkontakte.yml')[env]
		end

		def self.get field
			SETTINGS[field.to_s]
		end
	end
end
