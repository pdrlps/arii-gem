require 'logger'
require 'i2x/cashier'
require 'i2x/helper'
require 'i2x/detector'
require 'i2x/csvdetector'
require 'i2x/jsondetector'
require 'i2x/sqldetector'
require 'i2x/xmldetector'
require 'i2x/agent'
require 'i2x/version'
require 'i2x/client'

module I2X
	class Config



		def self.set_log log
			@@log = log
		end

		def self.set_host host
			host << '/' unless host.end_with?('/')
			@@host = host
		end

		def self.set_access_token api_key
			@@access_token = api_key
		end

		def self.log
			@@log
		end

		def self.host
			@@host
		end

		def self.access_token
			@@access_token
		end
	end
end
