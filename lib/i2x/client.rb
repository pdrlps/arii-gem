require 'rest_client'

module I2X
	class Client

		##
		# => Load configuration properties from client/script code
		#
		def initialize config, log
			begin
				@config = config
				I2X::Config.set_access_token config[:server][:api_key]
				I2X::Config.set_host config[:server][:host]
				I2X::Config.set_log log

				I2X::Config.log.info(self.class.name) {'Configuration loaded successfully.'}
			rescue Exception => e
				I2X::Config.log.error(self.class.name) {"Failed to load configuration: #{e}"}
			end
			
		end

		##
		# => Validate API key.
		#
		def validate
			begin
				I2X::Config.log.info(self.class.name) {'Launching validation.'}

				out = RestClient.post "#{I2X::Config.host}fluxcapacitor/validate_key.json", {:access_token => I2X::Config.access_token}	
				response = {:status => 100, :response => out.to_str}
			rescue Exception => e
				I2X::Config.log.error(self.class.name) {"Failed validation: #{e}"}
			end
			response
		end

		##
		# => Start processing agents from configuration properties.
		#
		def process
			I2X::Config.log.info(self.class.name) {'Starting agent processing.'}
			begin
				@config[:agents].each do |agent|
					a = I2X::Agent.new agent
					a.execute
				end
			rescue Exception => e				
				I2X::Config.log.error(self.class.name) {"Failed agent processing: #{e}"}
			end
		end
	end
end