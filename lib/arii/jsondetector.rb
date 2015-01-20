require 'open-uri'
require 'jsonpath'
require 'rest_client'
require 'json'

module ARII

  # = JSONDetector
  #
  # Detect changes in JSON content files (uses JSONPath).
  #
  class JSONDetector < Detector

    public

    ##
    # == Detect the changes
    #
    def detect object
      ARII::Config.log.info(self.class.name) {"Monitoring #{object[:uri]}"} unless object[:uri].nil?

      begin
        if object[:uri] == '' then
          @doc = object[:content]
        else
          url = RestClient.get object[:uri]
          @doc = url.to_str
        end
        JsonPath.on(@doc,object[:query]).each do |element|
          JsonPath.on(element, object[:cache]).each do |c|
            @response = Cashier.verify c, object, c, object[:seed]
          end

           # Process ARII cache response
           @cache = JSON.parse(@response, {:symbolize_names => true})
           unless @cache[:templates].nil? then
            @cache[:templates].each do |t|
              @templates.push t
            end
          end

          ##
          # If not on cache, add to payload for processing
          #
          if @cache[:status] == 100 then
            ARII::Config.log.info(self.class.name) {"Not on cache, generating payload"}
            # add row data to payload from selectors (key => key, value => column name)
            payload = Hash.new
            object[:selectors].each do |selector|
              selector.each do |k,v|
                JsonPath.on(element, v).each do |el|
                  payload[k] = el
                end
              end
            end
            # add payload object to payloads list
            @payloads.push payload
          end

        end
      rescue Exception => e
        ARII::Config.log.error(self.class.name) {"Loading error: #{e}"}
      end
      @cache[:templates]
    end
  end
end