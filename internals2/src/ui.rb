#!/usr/bin/ruby

require 'io/console'
require 'colorize'

# This script handles the icon display

class String
	# converts file to 2D character array
	def to_2d
		a = self.split("\n")
		b = []
		a.each do |i|
			b.push(i.split(//))
		end

		b
	end
end

class Color

	def self.RED
		"\033[0;31m"
	end

	def self.LIGHT_RED
		"\033[1;31m"
	end

	def self.GREEN
		"\033[0;32m"
	end

	def self.LIGHT_GREEN
		"\033[1;32m"
	end

	def self.YELLOW
		"\033[0;33m"
	end

	def self.LIGHT_YELLOW
		"\033[1;33m"
	end

	def self.BLUE
		"\033[0;34m"
	end

	def self.LIGHT_BLUE
		"\033[1;34m"
	end

	def self.PURPLE
		"\033[0;35m"
	end

	def self.LIGHT_PURPLE
		"\033[1;35m"
	end

	def self.CYAN
		"\033[0;36m"
	end

	def self.LIGHT_CYAN
		"\033[1;36m"
	end

	def self.WHITE
		"\033[0;37m"
	end

	def self.LIGHT_WHITE
		"\033[1;37m"
	end

	def self.DEFAULT
		"\033[0m"
	end

	def self.HIDDEN
		"\033[8m"
	end

	def self.UNHIDDEN
		"\033[28m"
	end

	def self.RANDOM
		"\033[1;3#{rand(1..7)}m"
	end
end

# This class handles output rules for the icon displays
class Rules

	@rules = Hash.new
	def self.make_rule(char, color)
		@rules["#{char}"] = to_attributed_char(char, color)
	end

	private
	def self.to_attributed_char(char, color)
		if color == Color.HIDDEN
			attrib = "#{color}#{char}#{Color.UNHIDDEN}#{Color.DEFAULT}"
		else
			attrib = "#{color}#{char}#{Color.DEFAULT}"
		end
		attrib
	end

	public
	def self.get_rule(char)
		if @rules.key?("#{char}")
			return @rules["#{char}"]
		else
			return "#{char}"
		end
	end
end

# This handles animating a typewriter style animation for icon display
class Animation

	@@alphabet = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789`~!@\#$%^&*()-_=+[{]}\\|:;'\",<.>/?".split(//)

	def initialize(file)
		@file = file
		@contents = File.open(file).read.to_2d
	end

	def add_rule(char, color)
		if char.start_with?("!")
			@@alphabet.each do |a|
				if a != char[-1]
					Rules.make_rule(a, color)
				end
			end
		else
			Rules.make_rule(char, color)
		end
	end

	def display
		@contents.each do |r|
			r.each do |c|
				print Rules.get_rule("#{c}")
			end
			puts
		end
	end
	
	# this function centers icons in the terminal window and outputs them
	def animate(color, style)
		puts `tput civis`
		system("stty -icanon -echo")
		@contents.each do |r|

			center = `tput cols`.to_i
			center /= 2
			align = 1
			if @file == "icon7"
				align = 21
			end
			for i in 0..(center - r.length / 2) - align
				if i > 0
					print "\b #{color}>\033[0m"
				else
					print "#{color}>\033[0m"
				end
				if style != "static"
					sleep 0.023
				end
			end
			r.each do |c|
				print "\b"
				print Rules.get_rule("#{c}")
				print "#{color}>\033[0m"
				if style != "static"
					sleep 0.023
				end
			end
			print "\b "
			puts
		end
		puts `tput cnorm`
		system("stty -icanon echo")
		$stdin.iflush
	end
end

# The output suppression function was found somewhere on GitHub, not my own function
class Output
	
	def self.suppress_output
		begin
			original_stderr = $stderr.clone
			original_stdout = $stdout.clone
			$stderr.reopen(File.new('/dev/null', 'w'))
			$stdout.reopen(File.new('/dev/null', 'w'))
			retval = yield
		rescue Exception => e
			$stderr.reopen(original_stderr)
			$stdout.reopen(original_stdout)
			raise e
		ensure
			$stderr.reopen(original_stderr)
			$stdout.reopen(original_stdout)
		end
		retval
	end

	# output a colorized info message
	def self.info_msg(msg, var)
		print "[".light_white.bold
		print "+".light_green.bold
		print "] ".light_white.bold
		print "#{msg} "
		puts "#{var}".light_blue.bold
	end

	# output a colorized error message
	def self.err_msg(msg, var)
		print "[".light_red
		print "!".light_red.bold
		print "] ".light_red
		print "#{msg} ".light_red.bold
		puts "#{var}".light_red.bold.underline
	end
end
