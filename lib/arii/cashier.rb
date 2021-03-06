require 'rest_client'

module ARII
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
      #ARII::Config.log.info(self.class.name) {"Verifying\n\taccess token: #{ARII::Config.access_token}\n\thost: #{ARII::Config.host}\n\tcache: #{cache}\n\tagent: #{agent}\n\tpayload: #{payload}\n\tseed: #{seed}"}
      begin
        response = RestClient::Request.execute(:method => 'post', :url => "#{ARII::Config.host}fluxcapacitor/verify.json", :payload => {:access_token => ARII::Config.access_token, :agent => agent[:identifier], :cache => cache, :payload => payload, :seed => seed} ,:verify_ssl => OpenSSL::SSL::VERIFY_NONE )
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Cache verification error: #{e}\n#{e.backtrace}" }
        response = {:status => 400, :error => e}
      end
      response
    end
  end
end
