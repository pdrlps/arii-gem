require 'rest_client'

module I2X
	class Client

		##
		# => Load configuration properties from client/script code
		#
		def initialize config
			begin
				@config = config
				p '[i2x] loaded configuration'
			rescue Exception => e
				p '[i2x] Failed to load configuration' + e.to_str
			end
			
		end

		##
		# => Validate API key.
		#
		def validate
			begin
				p '[i2x] launching validation.'
				@config[:server][:host] << '/' unless @config[:server][:host].ends_with?('/')
				out = RestClient.post "#{@config[:server][:host]}fluxcapacitor/validate_key.json", {:access_token => @config[:server][:api_key]}	
				response = {:status => 100, :response => out.to_str}
			rescue Exception => e
				p '[i2x] validation failed. ' + e.to_str
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
					p "Agent #{a.payload}"
				end
			rescue Exception => e
				p '[i2x] agent processing failed. ' + e.to_str
			end
		end
	end
end