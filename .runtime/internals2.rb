#!/usr/bin/ruby

require 'json'
require 'colorize'

class RuntimeStore

	def self.setup
		# module name with path
		@hmodules = Hash.new

		# default commands when module = [none]
		@main_cmds = [ 'exit', 'clear', 'cls', 'load', 'list' ]

		@single_cmds = [ 'cls', 'clear', 'exit' ]

		@list_opts = [ 'modules', 'cmds' ]

		# hash of main commands, variables, extensions (use)
		@loaded_module_store = Hash.new

		# required vs optional variable info
		@var_info = Hash.new
		@var_data = Hash.new

		# current module
		@module = ""
	end

	def self.init_module(mod)
		pid = fork do
			Dir["#{File.dirname(__FILE__)}/#{mod}.rb"].each do |f|
				system <<~EOS
					awk '/^def/{flag=1} flag; /^end/{flag=0}' #{f} > #{f}.tmp
					awk '/^class/{flag=1} flag; /^end/{flag=0}' #{f} >> #{f}.tmp
					awk '/^module/{flag=1} flag; /^end/{flag=0}' #{f} >> #{f}.tmp
					mv #{f}.tmp #{f}
				EOS

				m = File.open('.path', 'w')
				m.print f
				m.close

				load(f)
			end

			if defined? mname
				f = File.open('.mname', 'w')
				f.print mname
				f.close
			end
		end
		
		Process.wait(pid)
		mname = parse_string('.mname')
		mpath = parse_string('.path')

		@hmodules["#{mname}"] = "#{mpath}"
	end

	# load specific module
	def self.load_module(mod)
		
		mcmds = [ "unload", "set", "vars", "configs" ]
		mcmds += @main_cmds

		lists = Hash.new

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

		@var_info = vars

		use = parse_array('.use')

		mcmds += cmds

		lists["main"] = mcmds
		lists["set"] = vars.keys
		lists["use"] = use

		@loaded_module_store = lists
		@module = mod
	end

	# remove module data
	def self.unload_module
		@module = ""
		@loaded_module_store = Hash.new
		@var_info = Hash.new
		@var_data = Hash.new
	end
	
	def self.get_module
		return @module
	end

	# get available modules
	def self.get_modules
		return @hmodules.keys
	end

	def self.get_vars
		return @loaded_module_store["set"]
	end

	def self.get_cmds
		if @module == ""
			return @main_cmds
		else
			return @loaded_module_store["main"]
		end
	end

	def self.get_cmds_single
		if @module == ""
			return @single_cmds
		else
			return @loaded_module_store["main"] - [ "set", "list", "load" ]
		end
	end

	def self.get_val_of(var)
		return @var_data["#{var}"]
	end

	def self.list_modules
		puts "Available modules:"
		@hmodules.keys.each { |m| puts m }
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
		puts "Available commands:"
		if @module == ""
			@main_cmds.each { |m| puts m }
		else
			@loaded_module_store["main"].each { |m| puts m }
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

	def self.parse_string(file)
		if File.file?(file)
			data = File.open(file).read
			system("rm #{file}")
		else
			data = ""
		end

		return data
	end

	def self.parse_array(file)
		if File.file?(file)
			data = JSON.parse(File.open(file).read)
			system("rm #{file}")
		else
			data = ""
		end

		return data
	end

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
