#require 'detector'
#require 'csvdetector'
#require 'jsondetector'
#require 'xmldetector'
#require 'sqldetector'

module I2X
  class Agent 
    attr_accessor :content, :identifier, :publisher, :payload, :templates, :seeds, :cache

    def initialize agent
      begin
        @identifier = agent[:identifier]
        @publisher = agent[:publisher]
        @payload = agent[:payload]
        @cache = agent[:payload][:cache]
        @seeds = agent[:seeds]
      rescue Exception => e
        p "[i2x] unable to initialize agent. #{e}"
      end

    end


    ##
    # => Perform the actual agent monitoring tasks.
    #
    def execute
      @checkup = {}

      case @publisher
      when 'sql'
        begin
          @d = I2X::SQLDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          p "[i2x] error: #{e}"
        end
      when 'csv'
        begin
          @d = I2X::CSVDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          p "[i2x] error: #{e}"
        end
      when 'xml'
        begin
          @d = I2X::XMLDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
         p "[i2x] error: #{e}"
        end
      when 'json'
        begin
          @d = I2X::JSONDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          p "[i2x] error: #{e}"
        end
      end


        # Start checkup
        begin
          unless content.nil? then
            @d.content = content
          end
          @checkup = @d.checkup
        rescue Exception => e
          p "[i2x] error: #{e}"
        end

        # Start detection
        begin
          @d.objects.each do |object|
            @d.detect object
          end
        rescue Exception => e
          p "[i2x] error: #{e}"
        end

        begin
          if @checkup[:status] == 100 then
            process @checkup
          end
        rescue Exception => e
          p "[i2x] error: #{e}"
        end
        response = {:status => @checkup[:status], :message => "[i2x][Checkup][execute] All OK."}     
      end



      ##
      # => Process agent checks.
      #
      def process checkup
        p checkup
      end
    end

  end