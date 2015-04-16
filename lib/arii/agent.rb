require 'rest_client'

module ARII
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
        ARII::Config.log.debug(self.class.name) { "Agent #{@identifier} initialized" }
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Unable to initialize agent. #{e}" }
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
          @d = ARII::SQLDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          ARII::Config.log.error(self.class.name) { "#{e}" }
        end
      when 'csv'
        begin
          @d = ARII::CSVDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          ARII::Config.log.error(self.class.name) { "#{e}" }
        end
      when 'excel'
        begin
          @d = ARII::ExcelDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          ARII::Config.log.error(self.class.name) { "#{e}" }
        end
      when 'xml'
        begin
          @d = ARII::XMLDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          ARII::Config.log.error(self.class.name) { "#{e}" }
        end
      when 'json'
        begin
          @d = ARII::JSONDetector.new(self)
        rescue Exception => e
          @response = {:status => 400, :error => e}
          ARII::Config.log.error(self.class.name) { "#{e}" }
        end
      end


      # Start checkup
      begin
        unless content.nil? then
          @d.content = content
        end
        @checkup = @d.checkup
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Checkup error: #{e}" }
      end

      # Start detection
      begin
        @d.objects.each do |object|
          @d.detect object
        end

        @checkup[:templates] = @d.templates.uniq
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Detection error: #{e}\n\t#{e.backtrace}" }
      end

      begin
        if @checkup[:status] == 100 then
          process @checkup
        end
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Process error: #{e}" }
      end
      response = {:status => @checkup[:status], :message => "[ARII][Checkup][execute] All OK."}
    end


    ##
    # => Process agent checks.
    #
    def process checkup
      begin
        checkup[:templates].each do |template|
          ARII::Config.log.info(self.class.name) { "Delivering to #{template} template." }
          checkup[:payload].each do |payload|
            ARII::Config.log.debug(self.class.name) { "Processing #{payload}." }

            response = RestClient::Request.execute(:method => 'post', :url => "#{ARII::Config.host}postman/deliver/#{template}.js", :payload => payload ,:verify_ssl => OpenSSL::SSL::VERIFY_NONE )

            case response.code
            when 200
              ARII::Config.log.debug(self.class.name) { "Delivered to #{template}." }
            else
              ARII::Config.log.warn(self.class.name) { "unable to deliver \"#{payload}\" to \"#{template}\"" }
            end
          end
        end
      rescue Exception => e
        ARII::Config.log.error(self.class.name) { "Processing error: #{e}" }
      end

    end
  end

end
