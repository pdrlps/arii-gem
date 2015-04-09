require 'open-uri'

module ARII

  # = XMLDetector
  #
  # Detect changes in XML files (uses XPath).
  #
  class XMLDetector < Detector

    public
    ##
    # == Detect the changes
    #
    def detect object
      ARII::Config.log.info(self.class.name) { "Monitoring #{object[:uri]}" } unless object[:uri].nil?
      begin
        if object[:uri] == '' then
          @doc = Nokogiri::XML(object[:content])
        else
          @doc = Nokogiri::XML(open(object[:uri]))
        end
        @doc.remove_namespaces!
        @doc.xpath(object[:query]).each do |element|
          element.xpath(object[:cache]).each do |c|
            @response = Cashier.verify c.content, object, c.content, object[:seed]
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
          if @cache[:cache][:status] == 100 then
            ARII::Config.log.info(self.class.name) { "Not on cache, generating payload" }
            # add row data to payload from selectors (key => key, value => column name)
            payload = Hash.new
            object[:selectors].each do |selector|

              selector.each do |k, v|
                element.xpath(v).each do |el|
                  payload[k] = el.content
                end
              end
            end
            # add payload object to payloads list
            @payloads.push payload

          end
        end
      end
    rescue Exception => e
      ARII::Config.log.error(self.class.name) { "Processing error: #{e}" }
    end
  end
end