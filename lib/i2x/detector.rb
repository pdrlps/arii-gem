require 'seedreader'
require 'csvseedreader'
require 'sqlseedreader'
require 'xmlseedreader'
require 'jsonseedreader'


module I2X

  ##
  # = Detector
  #
  # Main change detection class, to be inherited by SQL, CSV, JSON and XML detectors (and others to come).
  #
  class Detector
    attr_accessor :identifier, :agent, :objects, :payloads, :content

    def initialize identifier
      begin
        @agent = Agent.find_by! identifier: identifier
        @payloads = Array.new
        @objects = Array.new
        @help = I2X::Helper.new
      rescue Exception => e
        
      end
    end


    ##
    # == Start original source detection process
    #
    def checkup
      # update checkup time
      @agent.update_check_at @help.datetime

      begin

        ##
        # => Process seed data, if available.
        #
        if @agent.seeds.size != 0 then
          @agent.seeds.each do |seed|
            case seed[:publisher]
            when 'csv'
              begin
                @sr = I2X::CSVSeedReader.new(@agent, seed)
              rescue Exception => e
                
              end
            when 'sql'
              begin
                @sr = I2X::SQLSeedReader.new(@agent, seed)
              rescue Exception => e
                
              end
            when 'xml'
              begin
                @sr = I2X::XMLSeedReader.new(@agent, seed)
              rescue Exception => e
                
              end
            when 'json'
              begin
                @sr = I2X::JSONSeedReader.new(@agent, seed)
              rescue Exception => e

              end
            end
            begin
              @reads = @sr.read
              @reads.each do |read|
                @objects.push read
              end
            rescue Exception => e
              
            end
          end

        else
          ##
          # no seeds, simply copy agent data
          object = @help.deep_copy @agent[:payload]
          object[:identifier] = @agent[:identifier]
          object[:seed] = object[:identifier]
          unless self.content.nil? then
            object[:content] = self.content
          end
          @objects.push object
        end
      rescue Exception => e
        @response = {:status => 404, :message => "[i2x][Detector] failed to load doc, #{e}"}
        I2X::Slog.exception e
      end

      begin
        # increase detected events count
        @agent.increment!(:events_count, @payloads.size)
        @response = { :payload => @payloads, :status => 100}
      rescue Exception => e
        @response = {:status => 404, :message => "[i2x][Detector] failed to process queries, #{e}"}
        I2X::Slog.exception e
      end
      @response
    end
    

  end
end