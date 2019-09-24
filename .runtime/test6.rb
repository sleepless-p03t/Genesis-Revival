def mname
	"test6"
end
def cmds
	[ "hi", "bye" ]
end
def vars
	{ "greeting" => 1, "parting" => 0 }
end
def use
	[ ]
end
def hi
	# display an error message if variable greeting not set
	if RuntimeStore.get_val_of("greeting") != nil
		# display value of greeting
		puts RuntimeStore.get_val_of("greeting")
		#Output.info_msg("greeting =", RuntimeStore.get_val_of("greeting"))
	else
		Output.err_msg("Variable greeting not set!", "")
	end
end
def bye
	# output value of parting if it is set
	if RuntimeStore.get_val_of("parting") != nil
		puts RuntimeStore.get_val_of("parting")
	end
end
