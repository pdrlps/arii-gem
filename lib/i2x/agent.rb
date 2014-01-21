require 'rest_client'

module I2X
  class Agent 
    attr_accessor :content, :identifier, :publisher, :payload, :templates, :seeds, :cache, :selectors

    def initialize agent
      begin
        @identifier = agent[:identifier]
        @publisher = agent[:publisher]
        @payload = agent[:payload]
        @cache = agent[:payload][:cache]
        @seeds = agent[:seeds]
        @selectors = agent[:payload][:selectors]
        I2X::Config.log.debug(self.class.name) {"Agent #{@identifier} initialized"}
      rescue Exception => e
        I2X::Config.log.error(self.class.name) {"Unable to initialize agent. #{e}"}
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
          I2X::Config.log.error(self.class.name) {"#{e}"}
        end
      when 'csv'
        begin
          @d = I2X::CSVDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          I2X::Config.log.error(self.class.name) {"#{e}"}
        end
      when 'xml'
        begin
          @d = I2X::XMLDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          I2X::Config.log.error(self.class.name) {"#{e}"}
        end
      when 'json'
        begin
          @d = I2X::JSONDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          I2X::Config.log.error(self.class.name) {"#{e}"}
        end
      end


        # Start checkup
        begin
          unless content.nil? then
            @d.content = content
          end
          @checkup = @d.checkup
        rescue Exception => e
          I2X::Config.log.error(self.class.name) {"Checkup error: #{e}"}
        end

        # Start detection
        begin
          @d.objects.each do |object|
            @d.detect object
          end

          @checkup[:templates] = @d.templates.uniq
        rescue Exception => e
          I2X::Config.log.error(self.class.name) {"Detection error: #{e}"}
        end

        begin
          if @checkup[:status] == 100 then
            process @checkup
          end
        rescue Exception => e
          I2X::Config.log.error(self.class.name) {"Process error: #{e}"}
        end
        response = {:status => @checkup[:status], :message => "[i2x][Checkup][execute] All OK."}     
      end



      ##
      # => Process agent checks.
      #
      def process checkup
        begin
          checkup[:templates].each do |template|
            I2X::Config.log.info(self.class.name) {"Delivering to #{template} template."}
            checkup[:payload].each do |payload|
              I2X::Config.log.debug(self.class.name) {"Processing #{payload}."}
              response = RestClient.post "#{I2X::Config.host}postman/deliver/#{template}.js", payload
              case response.code
              when 200

              else
                I2X::Config.log.warn(self.class.name) {"unable to deliver \"#{payload}\" to \"#{template}\""}
              end
            end
          end
        rescue Exception => e
          I2X::Config.log.error(self.class.name) {"Processing error: #{e}"}
        end
        
      end
    end

  end