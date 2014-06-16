awesome-config
==============

This repository includes the following:
* crappy - A library for reading configuration files for Awesome

Crappy
======

Crappy reads a configuration file to configure Awesome.  Compatible
with Awesome 3.4.x or 3.5.x.  Specifically tested on 3.4.11 and 3.5.5.

Installation
------------

Backup your configuration directory:

    cp -a ~/.config/awesome ~/.config/awesome.bak-$(date +%F-%T)

Clone the repository anywhere you want:

    git clone https://github.com/theasp/awesome-config.git

Make a symlink from your awesome config directory to the library:

	ln -s $(pwd)/awesome-config/crappy ~/.config/awesome/

Copy the example "rc.lua" and "crappy.json" to your config directory:

	cp awesome-config/{crappy.json,rc.lua} ~/.config/awesome/

Start awesome.

Configuration
-------------

Edit crappy.json as desired.  The configuration file is divided into
"settings" and "startup".  You can use your own functions in the
configuration file by defining or requiring them rc.lua before
starting crappy, or using anonymous functions.

Note that JSON does not allow comments.

### settings

* terminal - The command to run for a terminal
* sloppyfocus - A boolean which controls whether the focus will follow
  the mouse
* titlebar (boolean) - A boolean which controls whether Windows should
  have titlebars
* layouts (list of strings) - A list of strings naming the enabled
   layout functions

### startup

Startup is an array of functions and their settings which will be
called in order during startup.

Each function is defined by having a element called "func" which names
the function, "enabled" which controls if it is enabled or not and
settings which is a hash that is passed to the function.

As the order does matter, some startup functions create widgets used
by others, the preferred order is as they appear in this document.
You can intermix your own functions wherever you like though.

#### crappy.startup.theme

Set up the theme using beautiful.

Settings:
* file (string) - Theme file passed to beautiful
* font (string) - Override the font in the theme file

Example:
	{
		"func": "crappy.startup.theme",
		"enabled": true,
		"settings": {
			"file": "/usr/share/awesome/themes/default/theme.lua",
			"font": "sans 10"
		}
	}

#### crappy.startup.tags

Build the tags table for each screen and assign their default layouts.

The top level of the settings refers to the screen, and are applied in
the order listed:
* default - Settings inside are applied to all screens.
* last - Settings inside are applied to the last screen.
* <#> - Settings inside are applied to the screen number given.

Each of the above, allows the following:
* layout - The name of the default layout function.
* tags - The names of each of the tags for the
  screen.
* tagLayouts - A hash mapping a tag name to a named layout function

Example:
	{
		"func": "crappy.startup.tags",
		"enabled": true,
		"settings": {
			"default": {
			"layout": "awful.layout.suit.fair",
				"tags": ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
			},
			"last": {
				"layout": "awful.layout.suit.max",
				"tagLayout": {
					"2": "awful.layout.suit.tile"
				}
			}
        }
    }

#### crappy.startup.menu

Build the menu used for the launcher on the wibox or the menu on the
root window.

The settings is an array of menu items, which can be nested.  Each element of the array has the following hash:
* name - Name of the menu item
* icon - Path to the icon
* iconresult - A function that returns the name of the icon
* table - An array of the same form for a submenu
* result - A function that returns the command to run
* func - A function to run instead of a command
* string - A command to run

You should only apply one of table, result, func and string, as well one of icon and iconresult.

Example:
        {
            "func": "crappy.startup.menu",
            "enabled": true,
            "settings": [
                { "name": "awesome",
                  "iconresult": "function() return beautiful.awesome_icon end",
                  "table": [
                      {
                          "name": "manual",
                          "result": "function() return crappy.config.settings.terminal .. \" -e man awesome\" end"
                      },
                      {
                          "name":"edit config",
                          "result": "function() return crappy.config.settings.editor .. ' ' .. awful.util.getdir('config') .. '/rc.lua' end"
                      },
                      {
                          "name": "restart",
                          "func": "awesome.restart"
                      },
                      {
                          "name": "quit",
                          "func": "awesome.quit"
                      }
                  ]
                },
                {
                    "name": "open terminal",
                    "result": "function() return crappy.config.settings.terminal end"
                },
                {
                    "name": "firefox",
                    "string": "firefox"
                }
            ]
        },

#### crappy.startup.menu

#### crappy.startup.bindings

#### crappy.startup.signals

#### crappy.startup.rules

#### crappy.startup.wibox

#### crappy.startup.menubar

Enable the menubar provided in Awesome 3.5.

Example:
	{
		"func": "crappy.startup.menubar",
		"enabled": true
	}

awesomeconf
===========

This is a program to manipulate the configuration file.  It currently
does nothing useful.  Please ignore.

Configuration
-------------

Edit "~/.config/awesome/config.json".

The syntax for keys and mouse buttons is described in the comments for
ezconfig, linked below.  You can use anonymous functions for bindings,
or functions you define in "~/.config/awesome/rc.lua".

Code Used
=========

*  crappy
  *  ezconfig.lua by Georgi Valkov <georgi.t.valkov@gmail.com> (GPLv2)
    *  https://raw.githubusercontent.com/gvalkov/dotfiles-awesome/master/ezconfig.lua
  *  JSON by Jeffrey Friedl (CC-BY)
    *  http://regex.info/blog/lua/json
  *  rc.lua from Awesome by the awesome project (GPLv2)
    *  http://awesome.naquadah.org/
