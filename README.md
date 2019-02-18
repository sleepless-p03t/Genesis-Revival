# Genesis: Revival
## (Genesis6.1)

Genesis at its core is a bare-bones command line interface written in Ruby. Its
functionality is determined by modules and plugins. Although this dynamic approach
to functionality can be used to make Genesis do just about anything, the purpose
of this project is to make genesis a powerful tool for Linux distros like Kali or
Parrot OS.

## Getting Started
```
cd
git clone https://github.com/sleepless-p03t/Genesis-Revival.git
```

### Prerequisites

##### Packages:
* ruby

```
sudo apt get install ruby
```

##### Gems:
* colorize
* rb-readline
* highlander

```
sudo gem install colorize rb-readline highlander
```

### Running Genesis
```
cd Genesis-Revival
ruby genesis
```

### How Genesis Works

Genesis is built around usability and extendability. Not only can functions in
modules be run within Genesis, but they also interact with the tab completion
handler

The core of Genesis has a limited number of predefined commands that the user can
execute, each of which are stored in arrays that are parsed by the completion
handler (rb-readline). Modules contain arrays for things like commands, variables, and
plugins which are then accessed by the core to extend the capabilities of the
completion process, and extend the overall functionality of Genesis.

### Writing Your Own Module or Plugin

Two scripts are included with Genesis: mkmod and mkplug

##### Creating a Module
```
cd ~/Genesis-Revival
bash mkmod module_name
cd module_name
```

The module_name.info file contains info like the module's name, the developer's
name, a brief description of the module, as well as any packages and/or gems that
the module requires

Ex:

```
Developer: Sleepless-P03t
Module Name: Ex
Module Info: Example
Package Dependencies: ruby
Gem Dependencies: colorize
```

The module_name.html file is a formatted webpage skeleton which can be edited to
be added to the Genesis site\*

Now for the actual coding:

```
cd src
```

The module_name.rb script is the most important part of the module. It defines the
module's name, variables, commands, and plugin dependencies for that module.

Any functions named in the command array can be run by Genesis as well

Ex:

```
#!/bin/ruby

def mname
	"Example"
end

def cmds
	[ "testr", "testo" ]
end

# "var0" => 1 means required
# "var1" => 0 means optional
def vars
	{ "testr" => 1, "testo" => 0 }
end

def use
	[ ]
end

def testr
	# testr needs to be set, Genesis does not handle this internally
	if RuntimeStore.get_val_of("testr") != nil
		Output.err_msg("Variable testr not set!", "")
	else
		Output.info_msg("testr =", RuntimeStore.get_val_of("testr"))
	end
end

def testo
	# testo is optional, only does something if it's set
	if RuntimeStore.get_val_of("parting") != nil
		puts RuntimeStore.get_val_of("parting")
	end
end
```

##### Adding the Module to Genesis

```
cd ~/Genesis-Revival
bash mkmod install module_name
```

Running mkmod with the install option will parse through the module's info file
for dependencies and verify that all dependencies are installed. If any
dependencies are missing, mkmod will output how to install them

Once all dependencies are met, mkmod will compress the module's folder into a gmd
archive (tar.bz2) and move it to the modules directory where Genesis will look to
extract its contents (Genesis will need to be restarted if it's already running in
order for new modules to be seen)

##### Creating a Plugin

The script mkplug works very similarly to mkmod

This is still in early development, and plugin support is not yet integrated into
Genesis

### Inspiration

This project is inspired by Metasploit Framework by Rapid7 and by The Social
Engineering Toolkit by TrustedSec
