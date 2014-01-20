require 'detector'
require 'csvdetector'
require 'jsondetector'
require 'xmldetector'
require 'sqldetector'

module I2X
  class Agent 
    attr_accessor :content
    attr_accessor :identifier
    attr_accessor :publisher
    attr_accessor :payload
    attr_accessor :templates

    def initialize agent
      identifier = agent[:identifier]
      publisher = agent[:publisher]
      payload = agent[:payload]
      templates = agent[:template]
    end


  ##
  # => Perform the actual agent monitoring tasks.
  #
  def execute
    @checkup = {}
   

    case publisher
    when 'sql'
      begin
        @d = I2X::SQLDetector.new(identifier)
      rescue Exception => e
        
        @response = {:status => 400, :error => e}
      end
    when 'csv'
      begin
        @d = I2X::CSVDetector.new(identifier)
      rescue Exception => e
        
        @response = {:status => 400, :error => e}
      end
    when 'xml'
      begin
        @d = I2X::XMLDetector.new(identifier)
      rescue Exception => e
        
        @response = {:status => 400, :error => e}
      end
    when 'json'
      begin
        @d = I2X::JSONDetector.new(identifier)
      rescue Exception => e
        
        @response = {:status => 400, :error => e}
      end
    end


      # Start checkup
      begin
        unless content.nil? then
          @d.content = content
        end
        update_check_at Time.now
        @checkup = @d.checkup
      rescue Exception => e
        
      end

      # Start detection
      begin
        @d.objects.each do |object|
          @d.detect object
        end
      rescue Exception => e
        
      end

      begin
        if @checkup[:status] == 100 then
         
          process @checkup
        else
        end
      rescue Exception => e
        
      end
      response = {:status => @checkup[:status], :message => "[i2x][Checkup][execute] All OK."}     
    end
    

  ##
  # => Finish agent processing to perform delivery
  #
  def process checkup
    

    begin
          integration.templates.each do |t|
            I2X::Slog.debug({:message => "Sending #{identifier} for delivery by #{t.identifier}", :module => "Agent", :task => "process", :extra => {:agent => identifier, :template => t.identifier}})
            checkup[:payload].each do |payload|
              response = RestClient.post "#{ENV["APP_HOST"]}postman/deliver/#{t.identifier}.js", payload
              case response.code
              when 200
                @event = Event.new({:payload => payload, :status => 100, :agent => self})
                @event.save
              else
                I2X::Slog.warn({:message => "Delivery failed for #{identifier} in #{t.identifier}", :module => "Agent", :task => "process", :extra => {:agent => identifier, :template => t.identifier}})
              end              
            end
          end
        end
      end
    rescue Exception => e
      I2X::Slog.exception e
    end
    
  end
end
end