require 'rubyXL'
require 'spreadsheet'
require 'open-uri'

module ARII

  ##
  # = ExcelDetector
  #
  # Detect changes in excel files .
  #
  class ExcelDetector < Detector

    public
    ##
    # == Detect the changes
    #
    def detect object

      ARII::Config.log.debug(self.class.name) { "Monitoring #{object[:uri]}" }

      # update headers default behaviour
      begin
        if object[:headers] == ''
          object[:headers] = 0
        end
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Processing error on errors: #{e}" }
      end



      # different gems and implementation for XLSX and XLS
      if object[:uri].end_with? 'xlsx'
        ARII::Config.log.debug(self.class.name) { "Loading RubyXL for #{object[:uri]}" }
        book = RubyXL::Parser.parse(open(object[:uri]))


        begin
          if object[:sheet] != ''
            sheet = book[object[:sheet]]
          else
            sheet = book[0]
          end
        rescue Exception => e
          ARII::Config.log.error(self.class.name) { "Processing error on sheet selection: #{e}" }
        end

        ARII::Config.log.debug(self.class.name) { "Initiating data extraction" }
        sheet.extract_data.drop(object[:headers].to_i).each do |row|


          begin
            unless object[:cache].nil?
              @response = Cashier.verify row[object[:cache].to_i], object, row, object[:seed]
            else
              @response = Cashier.verify row[0], object, row, object[:seed]
            end
          rescue Exception => e
            ARII::Config.log.error(self.class.name) { "Processing error on cache verification: #{e}" }
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
              ARII::Config.log.info(self.class.name) { "Not on cache, generating payload" }

              payload = Hash.new

              object[:selectors].each do |selector|
                selector.each do |k, v|
                  payload[k] = row[v.to_i]
                end
              end

              # add payload object to payloads list
              @payloads.push payload
            end

          rescue Exception => e
            ARII::Config.log.error(self.class.name) { "Processing error: #{e}\n#{e.backtrace}" }
          end
        end
      end


      if object[:uri].end_with? 'xls'
        Spreadsheet.client_encoding = 'UTF-8'
        book = Spreadsheet.open(open(object[:uri]))

        if object[:sheet] != ''
          sheet = book.worksheet [object[:sheet]]
        else
          sheet = book.worksheet 0
        end



        sheet.each object[:headers].to_i do |row|
          unless object[:cache].nil?
            @response = Cashier.verify row[object[:cache].to_i], object, row, object[:seed]
          else
            @response = Cashier.verify row[0], object, row, object[:seed]
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
              ARII::Config.log.info(self.class.name) { "Not on cache, generating payload" }

              payload = Hash.new

              object[:selectors].each do |selector|
                selector.each do |k, v|
                  payload[k] = row[v.to_i]
                end
              end

              # add payload object to payloads list
              @payloads.push payload
            end

          rescue Exception => e
            ARII::Config.log.error(self.class.name) { "Processing error: #{e}\n#{e.backtrace}" }
          end


        end
      end

      @cache[:templates]
    end
  end
end
