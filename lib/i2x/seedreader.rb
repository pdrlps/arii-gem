#require 'helper'

module I2X

  ##
  # = Seed Reader
  #
  # Main seed reading class, passing data for seeds to agent, to be inherited by SQL, File and URL templates
  #
  class SeedReader
  	 attr_accessor :seed, :objects, :agent

  	 def initialize agent, seed
  	 	@agent = agent
  	 	@help = I2X::Helper.new
  	 	@seed = seed
  	 	@objects = Array.new
  	 	puts "\t\tSeed: #{@seed[:identifier]}"
  	 end
  end
end