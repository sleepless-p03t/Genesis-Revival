#!/usr/bin/ruby

# This is a complete overhaul of Genesis core

require 'json'
require 'colorize'

class RuntimeStore

	def self.setup
		# module name with path hash
		@hmodules = Hash.new

		# default commands when module = [none]
		@main_cmds = [ 'exit', 'clear', 'cls', 'load', 'list' ]
		
		# commands that take no arguments
		@single_cmds = [ 'cls', 'clear', 'exit' ]

		# default list options
		@list_opts = [ 'modules', 'cmds' ]

		# hash of main commands, variables, extensions (use)
		@loaded_module_store = Hash.new

		# required vs optional variable info
		@var_info = Hash.new
		# vars with their values
		@var_data = Hash.new

		# current module
		@module = ""
	end

	# retrieves module names from modules
	def self.init_module(mod)
		# keeps modules from remaining in memory
		pid = fork do
			Dir["#{File.dirname(__FILE__)}/#{mod}.rb"].each do |f|
				# security measure: removes anything that isn't a require, function, class, or module from script
				system <<~EOS
					grep 'require' #{f} > #{f}.tmp
					echo '' >> #{f}.tmp
					awk '/^def/{flag=1} flag; /^end/{flag=0}' #{f} >> #{f}.tmp
					awk '/^class/{flag=1} flag; /^end/{flag=0}' #{f} >> #{f}.tmp
					awk '/^module/{flag=1} flag; /^end/{flag=0}' #{f} >> #{f}.tmp
					mv #{f}.tmp #{f}
				EOS
				
				# get module path
				m = File.open('.path', 'w')
				m.print f
				m.close

				load(f)
			end
			
			# get module name from module
			if defined? mname
				f = File.open('.mname', 'w')
				f.print mname
				f.close
			end
		end
		
		# wait for name to be retrieved
		Process.wait(pid)
		mname = parse_string('.mname')
		mpath = parse_string('.path')
		
		# store module name and path
		@hmodules["#{mname}"] = "#{mpath}"
	end

	# load specific module
	def self.load_module(mod)
		
		mcmds = [ "unload", "set", "vars", "configs" ]
		mcmds += @main_cmds

		lists = Hash.new
		
		# get commands, variables, and plugins from the module
		mpath = @hmodules[mod]
		pid = fork do
			load(mpath)

			if defined? cmds
				f = File.open('.cmds', 'w')
				f.print cmds
				f.close
			end

			if defined? vars
				f = File.open('.vars', 'w')
				f.print vars
				f.close
			end

			if defined? use
				f = File.open('.use', 'w')
				f.print use
				f.close
			end
		end

		Process.wait(pid)
		cmds = parse_array('.cmds')
		vars = parse_hash('.vars')

		# store variables
		@var_info = vars
		use = parse_array('.use')

		mcmds += cmds

		lists["main"] = mcmds
		lists["set"] = vars.keys
		lists["use"] = use
		
		# store cmds, variables, and plugins
		@loaded_module_store = lists
		# set the module name
		@module = mod
	end

	# remove module data
	def self.unload_module
		@module = ""
		@loaded_module_store = Hash.new
		@var_info = Hash.new
		@var_data = Hash.new
	end
	
	# get the current module
	def self.get_module
		return @module
	end

	# get available modules
	def self.get_modules
		return @hmodules.keys
	end
	
	# get variables
	def self.get_vars
		return @loaded_module_store["set"]
	end
	
	# get cmds
	def self.get_cmds
		if @module == ""
			return @main_cmds
		else
			return @loaded_module_store["main"]
		end
	end

	# get single cmds
	def self.get_cmds_single
		if @module == ""
			return @single_cmds
		else
			return @loaded_module_store["main"] - [ "set", "list", "load" ]
		end
	end

	# get value of a variable
	def self.get_val_of(var)
		return @var_data["#{var}"]
	end

	# list modules
	def self.list_modules
		puts "Available modules:".light_blue
		@hmodules.keys.each do |m|
			print "* ".light_white
			puts "#{m}".light_blue.bold
		end
	end

	def self.list_vars
		@var_info.each do |k, v|
			if !@var_data.keys.include?(k) && v == 1
				print "[".light_red
				print "-".light_red.bold
				print "] ".light_red
				puts "#{k}".light_red.bold
			elsif !@var_data.keys.include?(k) && v == 0
				print "[".light_yellow
				print "-".light_yellow.bold
				print "] ".light_yellow
				puts "#{k}".light_yellow.bold
			else
				print "[".light_white
				print "*".light_blue.bold
				print "] ".light_white
				print "#{k} ".light_green.bold
				print "=> ".light_white
				puts "#{@var_data[k]}".light_blue.bold
			end
		end
	end

	def self.get_list_opts
		if @module == ""
			return @list_opts
		else
			return @list_opts + [ "vars" ]
		end
	end

	def self.list_commands
		puts "Available commands:".light_blue
		if @module == ""
			@main_cmds.each do |m| 
				print "* ".light_white
				puts "#{m}".light_blue.bold
			end
		else
			@loaded_module_store["main"].each do |m|
				print "* ".light_white
				puts "#{m}".light_blue.bold
			end
		end
	end

	# set_var
	def self.set_var(var, val)
		if var == "" || var == nil
			print "[".light_red
			print "!".light_red.bold
			print "] ".light_red
			puts "No variable specified".light_red.bold
		elsif val == "" || val == nil
			print "[".light_red
			print "!".light_red.bold
			print "] ".light_red
			puts "No value specified for #{var}".light_red.bold
			
		elsif !@var_info.keys.include?(var)
			print "[".light_red
			print "!".light_red.bold
			print "] ".light_red
			puts "Unknown variable #{var}".light_red.bold
		else
			@var_data["#{var}"] = val
			print "[".light_white
			print "+".light_blue.bold
			print "] ".light_white
			print "#{var} ".light_green.bold
			print "=> ".light_white
			puts "#{val}".light_blue.bold
		end
	end

	# execute module functions if they exist
	def self.exec_module(func)
		if !@loaded_module_store["main"].include?(func)
			print "[".light_red
			print "!".light_red.bold
			print "] ".light_red
			puts "No function \"#{func}\" in #{@module}\"".light_red.bold
			return
		end

		pid = fork do
			load(@hmodules["#{@module}"])
			send("#{func}")
		end
		Process.wait(pid)
	end

	private
	# read file as string and delete the file
	def self.parse_string(file)
		if File.file?(file)
			data = File.open(file).read
			system("rm #{file}")
		else
			data = ""
		end

		return data
	end

	# read file as array and delete the file
	def self.parse_array(file)
		if File.file?(file)
			data = JSON.parse(File.open(file).read)
			system("rm #{file}")
		else
			data = ""
		end

		return data
	end

	# read file as hash and delete the file
	def self.parse_hash(file)
		if File.file?(file)
			data = eval(File.open(file).read)
			system("rm #{file}")
		else
			data = nil
		end

		return data
	end
end
