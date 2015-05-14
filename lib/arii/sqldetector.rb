#require 'helper'
require 'mysql2'
require 'tiny_tds'
requie 'pg'

module ARII

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
      ARII::Config.log.debug(self.class.name) { "Monitoring #{object[:host]}" }
      begin
        case object[:server]
        when 'mysql'
          @client = Mysql2::Client.new(:host => object[:host], :username => object[:username], :password => object[:password], :database => object[:database])
          @client.query(object[:query]).each(:symbolize_keys => false) do |row|
            unless object[:cache].nil? then
              @response = Cashier.verify row[object[:cache]], object, row, object[:seed]
            else
              @response = Cashier.verify row["id"], object, row, object[:seed]
            end

            # Process ARII cache response
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
              # add row data to payload from selectors (key => key, value => column name)
              payload = Hash.new
              object[:selectors].each do |selector|
                selector.each do |k, v|
                  payload[k] = row[v]
                end
              end
              # add payload object to payloads list
              @payloads.push payload
            end
          end
        when 'mssql'
          @client = TinyTds::Client.new username: object[:username], password: object[:password], host: object[:host], database: object[:database], port: object[:port], timeout: 60
          @results = @client.execute(@agent[:payload][:query])
          @results.each(:symbolize_keys => false) do |row|
            unless object[:cache].nil? then
              @response = Cashier.verify row[object[:cache]], object, row, object[:seed]
            else
              @response = Cashier.verify row["id"], object, row, object[:seed]
            end

            # Process ARII cache response
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
              # add row data to payload from selectors (key => key, value => column name)
              payload = Hash.new
              object[:selectors].each do |selector|
                selector.each do |k, v|
                  payload[k] = row[v]
                end
              end
              # add payload object to payloads list
              @payloads.push payload
            end
          end
        when 'postgresql'
          client = PG::Connection.new(:host => object[:host], :user => object[:username], :password => object[:password], :dbname => object[:database])
          client.exec(object[:query]).each do |row|
            unless object[:cache].nil? then
              @response = Cashier.verify row[object[:cache]], object, row, object[:seed]
            else
              @response = Cashier.verify row["id"], object, row, object[:seed]
            end

            # Process ARII cache response
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
              # add row data to payload from selectors (key => key, value => column name)
              payload = Hash.new
              object[:selectors].each do |selector|
                selector.each do |k, v|
                  payload[k] = row[v]
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
      @cache[:templates]
    end
  end
end
