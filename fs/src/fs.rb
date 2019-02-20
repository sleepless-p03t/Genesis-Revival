#!/usr/bin/ruby

require 'colorize'

def pname
	"fs"
end

# add list options to tab completion for this plugin
def list_opts
	[ "types", "locations" ]
end

def vars
	{ "filetype" => 0, "location" => 0 }
end

# add any functions/classes/modules here that can be used in modules
# list function convention
def list_types
	loc = "#{Dir.home}/genesis_revival/.pers_store/.ft_refs"
	if File.file?(loc)
		arr = `awk -F':' '{ print $1 }' #{loc}`.to_s.split("\n").uniq
		puts "Current filetypes:".light_white

		arr.each do |k|
			print '* '.light_white
			puts "#{k}".light_blue
		end
	else
		puts 'No stored filetypes'.light_red
	end
end

def list_locations
	loc = "#{Dir.home}/genesis_revival/.pers_store/.fs_list"
	if File.file?(loc)
		File.open(loc, 'r').each do |line|
			
		end
	end

end

class FS
	def self.add_dir(dir)
		system <<~EOS
			croot=`pwd`
			root="$HOME/genesis_revival/"
			
			cd $root
			if [ ! -d .pers_store ]; then
				mkdir .pers_store
			fi

			cd .pers_store
			
			if [ ! -f .fs_list ]; then
				touch .fs_list
			fi
			
			if ! grep -q '#{dir}' .fs_list; then
				echo #{dir} >> .fs_list
			fi

			cd $croot
		EOS

		Output.info_msg("Added #{dir} to FS persistent memory", "")
	end

	def self.add_filetype_ref(dir, filetype)
		system <<~EOS
			croot=`pwd`
			root="$HOME/genesis_revival/"
			
			cd $root

			if [ ! -d .pers_store ]; then
				mkdir .pers_store
			fi

			cd .pers_store

			if [ ! -f .ft_refs ]; then
				touch .ft_refs
			fi
			
			if ! grep -q '#{filetype} : #{dir}' .ft_refs; then
				echo "#{filetype} : #{dir}" >> .ft_refs
			fi

			cd $croot
		EOS

		Output.info_msg("Added reference for:", filetype)
	end

	def self.get_filetype_ref(filetype)
		loc = "#{Dir.home}/genesis_revival/.pers_store/.ft_refs"
		if File.file?(loc)
			search = `grep '#{filetype}' #{loc}`.to_s
			if search != nil || search != ""
				return search.split("\n")
			else
				Output.err_msg("Could not find", filetype)
				return nil
			end
		else
			Output.err_msg("No reference file found", "")
			return nil
		end			
	end
end
