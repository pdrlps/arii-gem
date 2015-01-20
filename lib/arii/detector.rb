#require 'seedreader'
#require 'csvseedreader'
#require 'sqlseedreader'
#require 'xmlseedreader'
#require 'jsonseedreader'


module ARII

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
        @help = ARII::Helper.new
        ARII::Config.log.info(self.class.name) {"Started new #{agent.identifier} detector"}
      rescue Exception => e
        ARII::Config.log.error(self.class.name) {"#{e}"}
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
                @sr = ARII::CSVSeedReader.new(@agent, seed)
              rescue Exception => e
                ARII::Config.log.error(self.class.name) {"#{e}"}
              end
            when 'sql'
              begin
                @sr = ARII::SQLSeedReader.new(@agent, seed)
              rescue Exception => e
                ARII::Config.log.error(self.class.name) {"#{e}"}
              end
            when 'xml'
              begin
                @sr = ARII::XMLSeedReader.new(@agent, seed)
              rescue Exception => e
                ARII::Config.log.error(self.class.name) {"#{e}"}
              end
            when 'json'
              begin
                @sr = ARII::JSONSeedReader.new(@agent, seed)
              rescue Exception => e
                ARII::Config.log.error(self.class.name) {"#{e}"}
              end
            end
            begin
              @reads = @sr.read
              @reads.each do |read|
                @objects.push read
              end
            rescue Exception => e
              ARII::Config.log.error(self.class.name) {"#{e}"}
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
        @response = {:status => 404, :message => "[ARII][Detector] failed to load doc, #{e}"}
        ARII::Config.log.error(self.class.name) {"#{e}"}
      end

      begin
        # increase detected events count


        @templates = Array.new
        @response = { :payload => @payloads, :templates => @templates, :status => 100}
      rescue Exception => e
        @response = {:status => 404, :message => "[ARII][Detector] failed to process queries, #{e}"}
        ARII::Config.log.error(self.class.name) {"#{e}"}
      end
      @response
    end


  end
end