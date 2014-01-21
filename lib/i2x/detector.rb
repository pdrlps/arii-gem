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
    attr_accessor :identifier, :agent, :objects, :payloads, :content, :templates

    def initialize agent
      begin
        @agent = agent
        @payloads = Array.new
        @objects = Array.new
        @help = I2X::Helper.new
        I2X::Config.log.info(self.class.name) {"Started new #{agent.identifier} detector"}
      rescue Exception => e
        I2X::Config.log.error(self.class.name) {"#{e}"}
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
                I2X::Config.log.error(self.class.name) {"#{e}"}
              end
            when 'sql'
              begin
                @sr = I2X::SQLSeedReader.new(@agent, seed)
              rescue Exception => e
                I2X::Config.log.error(self.class.name) {"#{e}"}
              end
            when 'xml'
              begin
                @sr = I2X::XMLSeedReader.new(@agent, seed)
              rescue Exception => e
                I2X::Config.log.error(self.class.name) {"#{e}"}
              end
            when 'json'
              begin
                @sr = I2X::JSONSeedReader.new(@agent, seed)
              rescue Exception => e
                I2X::Config.log.error(self.class.name) {"#{e}"}
              end
            end
            begin
              @reads = @sr.read
              @reads.each do |read|
                @objects.push read
              end
            rescue Exception => e
              I2X::Config.log.error(self.class.name) {"#{e}"}
            end
          end

        else
          ##
          # no seeds, simply copy agent data
          object = @help.deep_copy @agent.payload 
          object[:identifier] = @agent.identifier
          object[:cache] = @agent.cache
          object[:seed] = object[:identifier]
          object[:selectors] = @agent.selectors
          unless self.content.nil? then
            object[:content] = self.content
          end
          @objects.push object
        end
      rescue Exception => e
        @response = {:status => 404, :message => "[i2x][Detector] failed to load doc, #{e}"}
        I2X::Config.log.error(self.class.name) {"#{e}"}
      end

      begin
        # increase detected events count


        @templates = Array.new
        @response = { :payload => @payloads, :templates => @templates, :status => 100}
      rescue Exception => e
        @response = {:status => 404, :message => "[i2x][Detector] failed to process queries, #{e}"}
        I2X::Config.log.error(self.class.name) {"#{e}"}
      end
      @response
    end
    

  end
end