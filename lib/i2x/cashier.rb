require 'rest_client'

module I2X
  class Cashier
    public
    
    ##
    # = Verify
    # => Verify if items have already been seen in the past (on the cache).
    #
    # == Params
    # - *cache*: the key identifier to be verified
    # - *payload*: the value for matching/verification
    # - *agent*: the agent performing the verification
    # - *seed*: seed data (if available)
    #
    def self.verify cache, agent, payload, seed
      I2X::Config.log.info(self.class.name) {"Verifying\n\taccess token: #{I2X::Config.access_token}\n\thost: #{I2X::Config.host}\n\tcache: #{cache}\n\tagent: #{agent}\n\tpayload: #{payload}\tseed: #{seed}"}
      begin
        response = RestClient.post "#{I2X::Config.host}fluxcapacitor/verify.json", {:access_token => I2X::Config.access_token, :agent => agent[:identifier], :cache => cache, :payload => payload, :seed => seed}
      rescue Exception => e
        I2X::Config.log.error(self.class.name) {"#{e}"}
        response = {:status => 400, :error => e}
      end
      response
    end
  end
end