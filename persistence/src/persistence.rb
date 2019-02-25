#!/usr/bin/ruby

require 'fileutils'

def pname
	"persistence"
end

# add list options to tab completion for this plugin
def list_opts
	[ ]
end

# "var0" => 1 means required
# "var1" => 0 means optional

# define any variables that are required for this plugin
def vars
	{ }
end

# add any functions/classes/modules here that can be used in modules

class Persistence

	def self.store(varname, val)
		
	end

	def self.capture_output(varname)
		value = yield
		fp = "#{ENV['GENESIS_HOME']}/.persistence/"
		FileUtils.mkdir_p "#{fp}"
		persist = File.open("#{fp}/persistent", 'w')
		persist.puts "#{varname} = #{value.split("\n")}"
		persist.close

	end

end


Persistence.capture_output("Variable") { `grep 'if' ~/genesis_revival/genesis` }
