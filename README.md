awesome-config
==============

This repository includes the following:
* crappy - A library for reading configuration files for Awesome

Crappy
======

Crappy reads a configuration file to configure Awesome.  Compatible
with Awesome 3.4 or 3.5.

Installation
------------

Backup your configuration directory:

    cp -a ~/.config/awesome ~/.config/awesome.bak-$(date +%F-%T)

Clone the repository anywhere you want:

    git clone https://github.com/theasp/awesome-config.git

Make a symlink from your awesome config directory for the library:

	ln -s $(pwd)/awesome-config/crappy ~/.config/awesome/

Copy the example rc.lua and crappy.json:

	cp awesome-config/{crappy.json,rc.lua} ~/.config/awesome/

Start awesome.

Configuration
-------------

Edit ~/.config/awesome/config.json.

The syntax for keys and mouse buttons is described in the comments for
ezconfig, linked below.  You can use anonymous functions for bindings,
or functions you define in ~/.config/awesome/rc.lua.

Code Used
=========

*  crappy
 *  ezconfig.lua by Georgi Valkov <georgi.t.valkov@gmail.com> (GPLv2)
   *  https://raw.githubusercontent.com/gvalkov/dotfiles-awesome/master/ezconfig.lua
 *  JSON by Jeffrey Friedl (CC-BY)
   *  http://regex.info/blog/lua/json
