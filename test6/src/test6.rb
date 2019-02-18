#!/bin/ruby

def mname
	"test6"
end

def cmds
	[ "hi", "bye" ]
end

# "var0" => 1 means required
# "var1" => 0 means optional
def vars
	{ "greeting" => 1, "parting" => 0 }
end

def use
	[ ]
end

#def generate(vhash)
#
#end

def hi
	puts RuntimeStore.get_val_of("greeting")
end

def bye
	if RuntimeStore.get_val_of("parting") != nil
		puts RuntimeStore.get_val_of("parting")
	end
end
