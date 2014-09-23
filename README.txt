                        ━━━━━━━━━━━━━━━━━━━━━━━
                         AWESOME CONFIGURATION


                            Andrew Phillips
                        ━━━━━━━━━━━━━━━━━━━━━━━


Table of Contents
─────────────────

1 Crappy
.. 1.1 Installation
2 Awesome Config
3 Configuration File
.. 3.1 plugins
.. 3.2 Extending
4 Code Used


This repository includes the following:
• awesome-config - A GUI for manipulating the
• crappy - A library for reading configuration files for Awesome


1 Crappy
════════

  Crappy reads a configuration file to configure Awesome 3.4.x or 3.5.x.
  Specifically tested on 3.4.11 and 3.5.5.  The goal of this is to be
  able to move between multiple versions of Awesome and maintain the
  same basic configuration in a relatively easy to edit file.  JSON was
  chosen to allow for tools to be written in languages other than Lua to
  modify the configuration.


1.1 Installation
────────────────

  Backup your configuration directory:
  ╭────
  │ cp -a ~/.config/awesome ~/.config/awesome.bak-$(date +%F-%T)
  ╰────

  Clone the repository anywhere you want:
  ╭────
  │ git clone https://github.com/theasp/awesome-config.git
  ╰────

  Make a symlink from your awesome config directory to the libraries:
  ╭────
  │ ln -s $(pwd)/awesome-config/lib/* ~/.config/awesome/
  ╰────

  Copy the example `rc.lua' and `crappy.json' to your config directory:
  ╭────
  │ cp awesome-config/examples/{crappy.json,rc.lua} ~/.config/awesome/
  ╰────

  Start awesome.


2 Awesome Config
════════════════

  TODO


3 Configuration File
════════════════════

  Edit `~/.config/awesome/config.json'. as desired.  The configuration
  file is divided into `settings' and `startup'.  You can use your own
  functions in the configuration file by defining or requiring them
  `rc.lua' before starting crappy, or using anonymous functions.

  Note that JSON does not allow comments.


3.1 plugins
───────────

  Plugins is a list of plugins (or psuedo-plugins using functions) and
  their configuration.

  Each entry in the list is labelled with a plugin name which maps to
  information about the plugin, like whether it is enabled or it's
  settings.

  See the contents of the `docs' directory for information about each
  plugin and it's settings.

  Example:
  ╭────
  │ "plugins": {
  │     "crappy.startup.theme": {
  │         "enabled": true,
  │         "settings": {
  │             "file": "/usr/share/awesome/themes/default/theme.lua",
  │             "font": "sans 10"
  │         }
  │     },
  │     ...
  │     "crappy.startup.menubar": {
  │         "enabled": true
  │     }
  │ }
  ╰────


3.2 Extending
─────────────

  TODO


4 Code Used
═══════════

  • crappy by Andrew Phillips <theasp@gmail.com> [GPLv2] includes code
    from:
    • ezconfig.lua by Georgi Valkov <georgi.t.valkov@gmail.com> [GPLv2]
      • [https://raw.githubusercontent.com/gvalkov/dotfiles-awesome/master/ezconfig.lua]
    • JSON Encode/Decode in Pure LUA by Jeffrey Friedl  [CC-BY 3.0]
      • [http://regex.info/blog/lua/json]
    • rc.lua from Awesome by the awesome project [GPLv2]
      • [http://awesome.naquadah.org/]


  [GPLv2] http://www.gnu.org/licenses/gpl-2.0.html

  [CC-BY 3.0] http://creativecommons.org/licenses/by/3.0/
