require 'rest_client'

module ARII
  class Client

    ##
    # => Load configuration properties from client/script code
    #
    def initialize config, log
      begin
        @config = config
        ARII::Config.set_access_token config[:server][:api_key]
        ARII::Config.set_host config[:server][:host]
        ARII::Config.set_log log

        ARII::Config.log.info(self.class.name) { 'Configuration loaded successfully.' }
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Failed to load configuration: #{e}" }
      end

    end

    ##
    # => Validate API key.
    #
    def validate
      begin
        ARII::Config.log.info(self.class.name) { 'Launching validation.' }

        out = RestClient.post "#{ARII::Config.host}fluxcapacitor/validate_key.json", {:access_token => ARII::Config.access_token}
        response = {:status => 100, :response => out.to_str}
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Failed validation: #{e}" }
      end
      response
    end

    ##
    # => Start processing agents from configuration properties.
    #
    def process
      ARII::Config.log.info(self.class.name) { 'Starting agent processing.' }
      begin
        @config[:agents].each do |agent|
          a = ARII::Agent.new agent
          a.execute
        end
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Failed agent processing: #{e}" }
      end
    end
  end
end