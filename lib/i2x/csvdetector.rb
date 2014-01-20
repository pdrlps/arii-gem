#require 'helper'
require 'csv'
require 'open-uri'
#require 'seedreader'
#require 'csvseedreader'
#require 'sqlseedreader'
#require 'xmlseedreader'
#require 'jsonseedreader'

module I2X

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
      begin
        p "[i2x][CSV] Testing #{object[:uri]}"
        CSV.new(open(object[:uri]), :headers => :first_row).each do |row|
          unless object[:cache].nil? then
            p "[i2x][CSV] no cache, verifying"
            @cache = Cashier.verify row[object[:cache].to_i], object, row, object[:seed]
          else

            p "[i2x][CSV] with cache, verifying"
            @cache = Cashier.verify row[0], object, row, object[:seed]
            p @cache
          end
          # The actual processing
          #
          if @cache[:status] == 100 then

            # add row data to payload from selectors (key => key, value => column name)
            payload = Hash.new
            JSON.parse(object[:selectors]).each do |selector|
              selector.each do |k,v|
                payload[k] = row[v.to_i]
              end
            end
            # add payload object to payloads list
            @payloads.push payload
          end
        end
      rescue Exception => e
        p "[i2x] error: #{e}"
      end
    end
    
  end
end