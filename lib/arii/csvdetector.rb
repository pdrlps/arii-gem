require 'csv'
require 'open-uri'

module ARII

  ##
  # = CSVDetector
  #
  # Detect changes in CSV files (using column numbers).
  #
  class CSVDetector < Detector

    public
    ##
    # == Detect the changes
    #
    def detect object

      ARII::Config.log.debug(self.class.name) {"Monitoring #{object[:uri]}"}
      CSV.new(open(object[:uri]), :headers => :first_row).each do |row|
        begin
          unless object[:cache].nil? then
            @response = Cashier.verify row[object[:cache].to_i], object, row, object[:seed]
          else
            @response = Cashier.verify row[0], object, row, object[:seed]
          end
        rescue Exception => e
          ARII::Config.log.error(self.class.name) {"Loading error: #{e}"}
        end

        begin

          # Process ARIIcache response
          @cache = JSON.parse(@response, {:symbolize_names => true})
          unless @cache[:templates].nil? then
            @cache[:templates].each do |t|
              @templates.push t
            end
          end
          # The actual processing
          #
          if @cache[:cache][:status] == 100 then
            ARII::Config.log.info(self.class.name) {"Not on cache, generating payload"}

            payload = Hash.new

            object[:selectors].each do |selector|
              selector.each do |k,v|
                payload[k] = row[v.to_i]
              end
            end
            # add payload object to payloads list
            @payloads.push payload
          end

        rescue Exception => e
          ARII::Config.log.error(self.class.name) {"Processing error: #{e}"}
        end
        @cache[:templates]
      end
    end
  end
end