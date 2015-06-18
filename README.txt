                        ━━━━━━━━━━━━━━━━━━━━━━━
                         AWESOME CONFIGURATION


                            Andrew Phillips
                        ━━━━━━━━━━━━━━━━━━━━━━━


Table of Contents
─────────────────

1 Crappy
.. 1.1 Installation from Git
.. 1.2 Installation from APT on Ubuntu
2 Configuration
.. 2.1 Awesome Config GUI
.. 2.2 Manual Configuration
3 Plugin API
4 Code Used


This repository includes the following:
• awesome-config - A GUI for manipulating the
• crappy - A library for reading configuration files for Awesome


1 Crappy
════════

  Crappy reads a configuration file to configure Awesome 3.4.x or 3.5.x.
  Specifically tested on 3.4.11 and 3.5.5+.  The goal of this is to be
  able to move between multiple versions of Awesome and maintain the
  same basic configuration in a relatively easy to edit file.


1.1 Installation from Git
─────────────────────────

  Clone the repository anywhere you want:
  ┌────
  │ git clone https://github.com/theasp/awesome-config.git
  └────

  Backup your configuration directory:
  ┌────
  │ cp -a ~/.config/awesome ~/.config/awesome.bak-$(date +%F-%T)
  └────

  Make a symlink from your awesome config directory to the libraries:
  ┌────
  │ ln -s $(pwd)/awesome-config/lib/* ~/.config/awesome/
  └────

  Copy the example `rc.lua' and `crappy-config.lua' to your config
  directory:
  ┌────
  │ cp awesome-config/examples/{crappy-config.lua,rc.lua} ~/.config/awesome/
  └────

  Start awesome.


1.2 Installation from APT on Ubuntu
───────────────────────────────────

  For the released version:
  ┌────
  │ sudo add-apt-repository ppa:theasp/awesome-config
  └────

  For the latest snapshot version:
  ┌────
  │ sudo add-apt-repository ppa:theasp/awesome-config-snapshot
  └────

  Then run:
  ┌────
  │ sudo apt-get update
  │ sudo apt-get install awesome-config
  └────

  Backup your configuration directory:
  ┌────
  │ cp -a ~/.config/awesome ~/.config/awesome.bak-$(date +%F-%T)
  └────

  Copy the example `rc.lua' and `crappy-config.lua' to your config
  directory:
  ┌────
  │ cp /usr/share/doc/awesome-config/examples/{crappy-config.lua,rc.lua} ~/.config/awesome/
  └────

  Start awesome.


2 Configuration
═══════════════

  You can use your own functions with crappy by defining or requiring
  them `rc.lua' before starting crappy, or using anonymous functions.


2.1 Awesome Config GUI
──────────────────────

  Run `awesome-config' to start the configuration GUI.


2.2 Manual Configuration
────────────────────────

  Edit `.config/awesome/crappy-config.lua' as desired.

  A more detailed description of the configuration file is provided in
  the `docs/config' directory.


3 Plugin API
════════════

  See the plugin API documentation in `docs/plugins'.


4 Code Used
═══════════

  • crappy by Andrew Phillips <theasp@gmail.com> [GPLv2] includes code
    from:
    • ezconfig.lua by Georgi Valkov <georgi.t.valkov@gmail.com> [GPLv2]
      • [https://raw.githubusercontent.com/gvalkov/dotfiles-awesome/master/ezconfig.lua]
    • JSON Encode/Decode in Pure LUA by Jeffrey Friedl  [CC-BY 3.0]
      • [http://regex.info/blog/lua/json]
    • Serpent by Paul Kulchenko [MIT]
      • [https://github.com/pkulchenko/serpent]
    • rc.lua from Awesome by the awesome project [GPLv2]
      • [http://awesome.naquadah.org/]


  [GPLv2] http://www.gnu.org/licenses/gpl-2.0.html

  [CC-BY 3.0] http://creativecommons.org/licenses/by/3.0/

  [MIT] http://opensource.org/licenses/MIT
