#require 'seedreader'
#require 'csvseedreader'
#require 'sqlseedreader'
#require 'xmlseedreader'
#require 'jsonseedreader'


module I2X

  ##
  # = Detector
  #
  # Main change detection class, to be inherited by SQL, CSV, JSON and XML detectors (and others to come).
  #
  class Detector
    attr_accessor :identifier, :agent, :objects, :payloads, :content

    def initialize agent
      begin
        @agent = agent
        @payloads = Array.new
        @objects = Array.new
        @help = I2X::Helper.new
        puts "Loaded new detector: #{agent.identifier}"
      rescue Exception => e
        
      end
    end


    ##
    # == Start original source detection process
    #
    def checkup

      begin


        ##
        # => Process seed data, if available.
        #
        unless @agent.seeds.nil? then
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
              p "[i2x] error: #{e}"
            end
          end

        else
          ##
          # no seeds, simply copy agent data
          #object = @help.deep_copy @agent[:payload]
          object = @help.deep_copy @agent.payload 
          #object[:identifier] = @agent[:identifier]
          object[:identifier] = @agent.identifier
          object[:cache] = @agent.cache
          object[:seed] = object[:identifier]
          unless self.content.nil? then
            object[:content] = self.content
          end
          @objects.push object
        end
      rescue Exception => e
        @response = {:status => 404, :message => "[i2x][Detector] failed to load doc, #{e}"}
        p "[i2x] error: #{e}"
      end

      begin
        # increase detected events count
        
        @response = { :payload => @payloads, :status => 100}
      rescue Exception => e
        @response = {:status => 404, :message => "[i2x][Detector] failed to process queries, #{e}"}
        p "[i2x] error: #{e}"
      end
      @response
    end
    

  end
end