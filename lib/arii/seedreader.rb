#require 'helper'

module ARII

  ##
  # = Seed Reader
  #
  # Main seed reading class, passing data for seeds to agent, to be inherited by SQL, File and URL templates
  #
  class SeedReader
  	 attr_accessor :seed, :objects, :agent

  	 def initialize agent, seed
  	 	@agent = agent
  	 	@help = ARII::Helper.new
  	 	@seed = seed
  	 	@objects = Array.new
  	 	puts "\t\tSeed: #{@seed[:identifier]}"
  	 end
  end
end