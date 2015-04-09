require 'logger'
require 'arii/cashier'
require 'arii/helper'
require 'arii/detector'
require 'arii/csvdetector'
require 'arii/exceldetector'
require 'arii/jsondetector'
require 'arii/sqldetector'
require 'arii/xmldetector'
require 'arii/agent'
require 'arii/version'
require 'arii/client'

module ARII
  class Config


    def self.set_log log
      @@log = log
    end

    def self.set_host host
      host << '/' unless host.end_with?('/')
      @@host = host
    end

    def self.set_access_token api_key
      @@access_token = api_key
    end

    def self.log
      @@log
    end

    def self.host
      @@host
    end

    def self.access_token
      @@access_token
    end
  end
end
