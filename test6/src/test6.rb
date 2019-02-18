#!/bin/ruby

def mname
	"test6"
end

# any functions not listed here are not recognized by genesis
# they can only be accessed by this module
def cmds
	[ "hi", "bye" ]
end

# "var0" => 1 means required
# "var1" => 0 means optional
def vars
	{ "greeting" => 1, "parting" => 0 }
end

# add plugins to this list
def use
	[ ]
end

# a function genesis can run
def hi
	# display an error message if variable greeting not set
	if RuntimeStore.get_val_of("greeting") != nil
		Output.err_msg("Variable greeting not set!", "")
	else
		# display value of greeting
		Output.info_msg("greeting =", RuntimeStore.get_val_of("testr"))
	end
end

# another function genesis can run
def bye
	# output value of parting if it is set
	if RuntimeStore.get_val_of("parting") != nil
		puts RuntimeStore.get_val_of("parting")
	end
end
