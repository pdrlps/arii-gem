module I2X
	class Client

		def initialize agent
			@agent = agent
		end

		def ping 
			p "PONGING #{@agent}"
		end
	end
end