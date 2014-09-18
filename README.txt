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
.. 3.1 settings
.. 3.2 startup
..... 3.2.1 crappy.startup.theme
..... 3.2.2 crappy.startup.tags
..... 3.2.3 crappy.startup.menu
..... 3.2.4 crappy.startup.bindings
..... 3.2.5 crappy.startup.signals
..... 3.2.6 crappy.startup.rules
..... 3.2.7 crappy.startup.wibox
..... 3.2.8 crappy.startup.menubar
.. 3.3 Extending
4 Code Used


This repository includes the following:
• crappy - A library for reading configuration files for Awesome
• awesome-config - A GUI for manipulating the


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
  │ ln -s $(pwd)/awesome-config/lib/crappy ~/.config/awesome/
  │ ln -s $(pwd)/awesome-config/lib/despicable ~/.config/awesome/
  │ ln -s $(pwd)/awesome-config/lib/awesome-config ~/.config/awesome/
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


3.1 settings
────────────

  • `terminal' - The command to run for a terminal
  • `sloppyfocus' - A boolean which controls whether the focus will
    follow the mouse
  • `titlebar' (boolean) - A boolean which controls whether Windows
    should have titlebars
  • `layouts' (list of strings) - A list of strings naming the enabled
    layout functions

  Example:
  ╭────
  │ "settings": {
  │     "terminal": "x-terminal-emulator",
  │     "sloppyfocus": true,
  │     "titlebar": true,
  │     "layouts": [
  │         "awful.layout.suit.floating",
  │         "awful.layout.suit.tile",
  │         "awful.layout.suit.tile.left",
  │         "awful.layout.suit.tile.bottom",
  │         "awful.layout.suit.tile.top",
  │         "awful.layout.suit.fair",
  │         "awful.layout.suit.fair.horizontal",
  │         "awful.layout.suit.spiral",
  │         "awful.layout.suit.spiral.dwindle",
  │         "awful.layout.suit.max",
  │         "awful.layout.suit.max.fullscreen",
  │         "awful.layout.suit.magnifier"
  │     ]
  │ }
  ╰────


3.2 startup
───────────

  Startup is an array of functions and their settings which will be
  called in order during startup.

  Each function is defined by having a element called `func' which names
  the function, `enabled' which controls if it is enabled or not and
  settings which is a hash that is passed to the function.

  As the order does matter, some startup functions create widgets used
  by others, the preferred order is as they appear in this document. You
  can intermix your own functions wherever you like though.  If a
  function cannot be found, a message will be printed, but crappy will
  continue on to the next.

  Example:
  ╭────
  │ "startup": [
  │     {
  │         "func": "crappy.startup.theme",
  │         "enabled": true,
  │         "settings": {
  │             "file": "/usr/share/awesome/themes/default/theme.lua",
  │             "font": "sans 10"
  │         }
  │     },
  │     ...
  │     {
  │         "func": "crappy.startup.menubar",
  │         "enabled": true
  │     }
  │ ]
  ╰────


3.2.1 crappy.startup.theme
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Set up the theme using beautiful.

  Settings:
  • `file' (string) - Theme file passed to beautiful
  • `font' (string) - Override the font in the theme file

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.theme",
  │     "enabled": true,
  │     "settings": {
  │         "file": "/usr/share/awesome/themes/default/theme.lua",
  │         "font": "sans 10"
  │     }
  │ }
  ╰────


3.2.2 crappy.startup.tags
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Build the tags table for each screen and assign their default layouts.

  The top level of the settings refers to the screen, and are applied in
  the order listed:
  • `default' - Settings inside are applied to all screens.
  • `last' - Settings inside are applied to the last screen.
  • `<#>' - Settings inside are applied to the screen number given.

  Each of the above, allows the following:
  • `layout' - The name of the default layout function.
  • `tags' - The names of each of the tags for the screen.
  • `tagLayouts' - A hash mapping a tag name to a named layout function

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.tags",
  │     "enabled": true,
  │     "settings": {
  │         "default": {
  │         "layout": "awful.layout.suit.fair",
  │             "tags": ["1", "2", "3", "4", "5", "6", "7", "8", "9"]
  │         },
  │         "last": {
  │             "layout": "awful.layout.suit.max",
  │             "tagLayout": {
  │                 "2": "awful.layout.suit.tile"
  │             }
  │         }
  │     }
  │ }
  ╰────


3.2.3 crappy.startup.menu
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Build the menu used for the launcher on the wibox or the menu on the
  root window.

  The settings is an array of menu items, which can be nested.  Each
  element of the array has the following hash:
  • `name' - Name of the menu item
  • `icon' - Path to the icon
  • `iconresult' - A function that returns the name of the icon
  • `table' - An array of the same form for a submenu
  • `result' - A function that returns the command to run, or a table of
    menu items using the standard used by awful
  • `func' - A function to run instead of a command
  • `string' - A command to run

  You should only apply one of `table', `result', `func' and `string',
  as well one of `icon' and `iconresult'.

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.menu",
  │     "enabled": true,
  │     "settings": [
  │         { "name": "awesome",
  │           "iconresult": "function() return beautiful.awesome_icon end",
  │           "table": [
  │               {
  │                   "name": "manual",
  │                   "result": "function() return crappy.config.settings.terminal .. \" -e man awesome\" end"
  │               },
  │               {
  │                   "name":"edit config",
  │                   "result": "function() return crappy.config.settings.editor .. ' ' .. awful.util.getdir('config') .. '/rc.lua' end"
  │               },
  │               {
  │                   "name": "restart",
  │                   "func": "awesome.restart"
  │               },
  │               {
  │                   "name": "quit",
  │                   "func": "awesome.quit"
  │               }
  │           ]
  │         },
  │         {
  │             "name": "Debian",
  │             "result": "function() return debian.menu.Debian_menu.Debian end"
  │         },
  │         {
  │             "name": "open terminal",
  │             "result": "function() return crappy.config.settings.terminal end"
  │         },
  │         {
  │             "name": "firefox",
  │             "string": "firefox"
  │         }
  │     ]
  │ }
  ╰────


3.2.4 crappy.startup.bindings
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Assign keyboard and mouse buttons to functions.  Uses the ezconfig
  library by Georgi Valkov to describe the binding using a string.  The
  modifiers `M' (modkey), `A' (alt), `S' (shift) and `C' (control) can
  be combined using a `-' with a key name for a key or mouse button
  combination.

  Settings:
  • `modkey' - The name of the key to use for "M", defaults to Mod4
    (windows key).
  • `modkey' - The name of the key to use for "A", defaults to Mod1 (Alt
    key).
  • `buttons' - The mapping of mouse buttons to functions
    • `root' - Mouse buttons that apply to the root window
    • `client' - Mouse buttons that apply to client windows.  The
      functions are called with the client as an argument.
  • `keys' - The mapping of keyboard keys to functions
    • `global' - Keys that work everywhere
    • `client' - Keys that work on client windows.  The functions are
      called with the client as an argument.

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.bindings",
  │     "enabled": true,
  │     "settings": {
  │         "modkey": "Mod4",
  │         "altkey": "Mod1",
  │         "buttons": {
  │             "root": {
  │                 "3": "crappy.functions.menu.toggle",
  │                 "4": "awful.tag.viewnext",
  │                 "5": "awful.tag.viewprev"
  │             },
  │             "client": {
  │                 "1": "crappy.functions.client.focus",
  │                 "2": "crappy.functions.client.focus",
  │                 "3": "crappy.functions.client.focus",
  │                 "M-1": "awful.mouse.client.move",
  │                 "M-3": "awful.mouse.client.resize"
  │             }
  │         },
  │         "keys": {
  │             "global": {
  │                 "M-<Left>": "awful.tag.viewprev",
  │                 "M-<Right>": "awful.tag.viewnext",
  │                 "M-<Escape>": "awful.tag.history.restore",
  │ 
  │                 "M-j": "crappy.functions.global.focusNext",
  │                 "M-k": "crappy.functions.global.focusPrev",
  │                 "M-w": "crappy.functions.global.showMenu",
  │                 "M-<Tab>": "crappy.functions.global.focusNext",
  │                 "M-`": "crappy.functions.global.focusPrevHist",
  │ 
  │                 ...
  │ 
  │                 "M-p": "menubar.show"
  │             },
  │             "client": {
  │                 "M-f": "crappy.functions.client.fullscreen",
  │                 "M-S-c": "crappy.functions.client.kill",
  │                 "M-C-<space>": "awful.client.floating.toggle",
  │                 "M-C-<Return>": "crappy.functions.client.swapMaster",
  │                 "M-o": "awful.client.movetoscreen",
  │                 "M-r": "crappy.functions.client.redraw",
  │                 "M-t": "crappy.functions.client.ontop",
  │                 "M-n": "crappy.functions.client.minimized",
  │                 "M-m": "crappy.functions.client.maximized"
  │             }
  │         }
  │     }
  │ }
  ╰────


3.2.5 crappy.startup.signals
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Set the functions to handle signals.

  Settings:
  • `manage' - The name of the function to run when clients are managed
  • `focus' - The name of the function to run when clients gain focus
  • `unfocus' - The name of the function to run when clients lose focus

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.signals",
  │     "enabled": true,
  │     "settings": {
  │         "manage": "crappy.functions.signals.manage",
  │         "focus": "crappy.functions.signals.focus",
  │         "unfocus": "crappy.functions.signals.unfocus"
  │     }
  │ }
  ╰────


3.2.6 crappy.startup.rules
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Rules map to the same structure as in a normal rc.lua.  See the wiki
  page on rules for more information:
  [http://awesome.naquadah.org/wiki/Understanding_Rules]

  Crappy has the following differences:
  • `tag' - To have a client moved to a specific tag you need to
    specify `screen' and `tag'.  If the tag doesn't exist, it is not
    applied.
  • `callback' - Callback cannot be an array, if you wish to use
    multiple callbacks, use an anonymous function to call them.

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.rules",
  │     "enabled": true,
  │     "settings": [
  │         {
  │             "rule": {
  │                 "class": "MPlayer"
  │             },
  │             "properties": {
  │                 "floating": true
  │             }
  │         },
  │         {
  │             "rule": {
  │                 "class": "pinentry"
  │             },
  │             "properties": {
  │                 "floating": true
  │             }
  │         }
  │     ]
  │ }
  ╰────


3.2.7 crappy.startup.wibox
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Set up the wibox for each screen.

  Settings:
  • `position' - Where the wibox is positioned, top or bottom.
  • `bgcolor' - Set background color, or null to use the theme's color.
  • `widgets' - A list of the three possible positions of widgets.
    • `left' - A list of named functions which should return a widget
      that can be added to an alignment, which will be aligned to the
      left.
    • `middle' - Widgets aligned to the middle, or aligned right on
      3.4.x.
    • `right' - Widgets aligned to the right.

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.wibox",
  │     "enabled": true,
  │     "settings": {
  │         "position": "top",
  │         "bgcolor": null,
  │         "widgets": {
  │             "left": [
  │                 "crappy.startup.widget.launcher",
  │                 "crappy.startup.widget.taglist",
  │                 "crappy.startup.widget.prompt"
  │             ],
  │             "middle": [
  │                 "crappy.startup.widget.tasklist"
  │             ],
  │             "right": [
  │                 "crappy.startup.widget.systray",
  │                 "crappy.startup.widget.textclock",
  │                 "crappy.startup.widget.layout"
  │             ]
  │         }
  │     }
  │ }
  ╰────


3.2.8 crappy.startup.menubar
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  Enable the menubar provided in Awesome 3.5.

  Settings:
  • `dirs' - Directories to look for menu entries in
  • `categories' - An array of additional categories to look for.  Each
    entry points to a table with the following:
    • `app_type' - The category in the menu item
    • `name' - The name of the category to be displayed
    • `icon_name' - The name of the file to use for the category icon
    • `use' - Show the category or not

  Example:
  ╭────
  │ {
  │     "func": "crappy.startup.menubar",
  │     "enabled": true
  │     "settings": {
  │         "dirs": [
  │             "/usr/share/applications/",
  │             "/usr/local/share/applications/",
  │             ".local/share/applications/",
  │             ".local/share/applications/andrew/"
  │         ],
  │         "categories": {
  │             "andrew": {
  │                 "app_type": "Andrew",
  │                 "name": "Andrew",
  │                 "icon_name": "applications-accessories.png",
  │                 "use": true
  │             }
  │         }
  │     }
  │ }
  ╰────


3.3 Extending
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