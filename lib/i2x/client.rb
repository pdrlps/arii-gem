require 'rest_client'

module I2X
	class Client

		##
		# => Load configuration properties from client/script code
		#
		def initialize config
			begin
				@config = config
				I2X::Config.set_access_token @config[:server][:api_key]
				I2X::Config.set_host @config[:server][:host]
				p '[i2x] loaded configuration'
			rescue Exception => e
				puts "[i2x] Failed to load configuration: #{e}"
			end
			
		end

		##
		# => Validate API key.
		#
		def validate
			begin
				p '[i2x] launching validation.'
				out = RestClient.post "#{I2X::Config.host}fluxcapacitor/validate_key.json", {:access_token => I2X::Config.access_token}	
				response = {:status => 100, :response => out.to_str}
			rescue Exception => e
				p "[i2x] Failed validation: #{e}"
			end
			response
		end

		##
		# => Start processing agents from configuration properties.
		#
		def process
			begin
				@config[:agents].each do |agent|
					a = I2X::Agent.new agent
					a.execute
				end
			rescue Exception => e
				p "[i2x] Failed agent processing: #{e}"
			end
		end
	end
end