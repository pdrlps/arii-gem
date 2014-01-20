require 'rest_client'
require 'open-uri'


module I2X
  class Cashier


    public
    
    ##
    # = Verify
    # => Verify if items have already been seen in the past (on the cache).
    #
    # == Params
    # - *memory*: the key identifier to be verified
    # - *payload*: the value for matching/verification
    # - *agent*: the agent performing the verification
    # - *seed*: seed data (if available)
    #
    def self.verify memory, agent, payload, seed
      puts "[i2x][Cashier] verifying\n\taccess token: #{I2X::Config.access_token}\n\thost: #{I2X::Config.host}\n\tmemory: #{memory}\n\tagent: #{agent}\n\tpayload: #{payload}\n\tseed: #{seed}"
      begin
        out = RestClient.post "#{I2X::Config.host}fluxcapacitor/verify.json", {:access_token => I2X::Config.access_token, :agent => agent[:identifier], :memory => memory, :payload => payload, :seed => seed}
        reponse = out[:cache]
      rescue Exception => e
        response = {:status => 400}
      end

      response
    end
  end
end