#require 'helper'
require 'mysql2'

module I2X

  ##
  # = SQLDetector
  #
  # Detec changes in SQL databases. MySQL support only.
  #
  class SQLDetector < Detector

    public
    ##
    # == Detect the changes
    #
    def detect object
      I2X::Config.log.debug(self.class.name) {"Monitoring #{object[:host]}"}
      begin
        @client = Mysql2::Client.new(:host => object[:host], :username => object[:username] , :password => object[:password] , :database => object[:database])
        @client.query(@agent[:payload][:query]).each(:symbolize_keys => false) do |row|
          unless object[:cache].nil? then
            @response = Cashier.verify row[object[:cache]], object, row, object[:seed]
          else
            @response = Cashier.verify row["id"], object, row, object[:seed]
          end

          # Process i2x cache response
          @cache = JSON.parse(@response, {:symbolize_names => true})
          unless @cache[:templates].nil? then
            @cache[:templates].each do |t|
              @templates.push t
            end
          end

          # The actual processing
          #
          if @cache[:status] == 100 then
           I2X::Config.log.info(self.class.name) {"Not on cache, generating payload"}
            # add row data to payload from selectors (key => key, value => column name)
            payload = Hash.new
            object[:selectors].each do |selector|
              selector.each do |k,v|
                payload[k] = row[v]
              end
            end
            # add payload object to payloads list
            @payloads.push payload
          end
        end
      rescue Exception => e
        I2X::Config.log.error(self.class.name) {"Processing error: #{e}"}
      end
      @cache[:templates]
    end
  end
end