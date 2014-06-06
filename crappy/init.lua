-- Includes stuff from:
-- https://github.com/gvalkov/dotfiles-awesome/blob/master/rc.lua

-- TODO:
-- Error checking

local util = require('awful.util')

local crappy = {}

crappy.json = require('crappy.JSON')
crappy.ezconfig = require('crappy.ezconfig')
crappy.misc = require('crappy.misc')

local ver = awesome.version:match('%d.%d'):gsub('%.', '-')
crappy.init = require('crappy.init-' .. ver)
crappy.functions = require('crappy.functions-' .. ver)
assert(crappy.functions ~= nil)
assert(crappy.init ~= nil)

crappy.config = {}
crappy.config.debug = 1

function crappy.start(file)
   print("Initializing crappy...")

   if file == nil then
      file = util.getdir("config") .. "/crappy.json"
   end

   crappy.setDefaults()
   crappy.loadConfig(file)
   crappy.init.layoutRefs()
   crappy.init.theme()          -- Done
   crappy.init.tags()           -- Done
   crappy.init.menu()
   crappy.init.wibox()
   crappy.init.signals()        -- Done
   crappy.init.bindings()       -- Done
   crappy.init.rules()          -- Done
   print("Done initializing crappy.")
end

function crappy.loadConfig(file)
   print("Loading crappy file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "r"))
   local configJson = f:read("*all")
   f:close()

   local config = crappy.json:decode(configJson)

   crappy.config = crappy.misc.mergeTable(crappy.config, config)

   if config.layouts ~= nil then
      crappy.config.layouts = config.layouts
   end

   if config.screens.default.tags ~= nil then
      crappy.config.screens.default.tags = config.screens.default.tags
   end
end

function crappy.setDefaults()
   print("Setting crappy defaults...")

   crappy.config.theme = {}
   crappy.config.theme.file = "/usr/share/awesome/themes/default/theme.lua"
   crappy.config.theme.font = "sans 10"

   crappy.config.titlebar = {}
   crappy.config.titlebar.enabled = 1
   crappy.config.titlebar.height = 15

   -- This is used later as the default terminal and editor to run.
   crappy.config.terminal = "gnome-terminal"

   local editor = os.getenv("EDITOR") or "editor"
   crappy.config.editor = crappy.config.terminal .. " -e " .. editor

   crappy.config.modkey = "Mod4"

   crappy.config.layouts = {
      "awful.layout.suit.max",
      "awful.layout.suit.tile",
      "awful.layout.suit.tile.left",
      "awful.layout.suit.tile.bottom",
      "awful.layout.suit.tile.top",
      "awful.layout.suit.fair",
      "awful.layout.suit.fair.horizontal",
      "awful.layout.suit.max.fullscreen",
      "awful.layout.suit.floating",
      "awful.layout.suit.spiral",
      "awful.layout.suit.spiral.dwindle",
      "awful.layout.suit.magnifier"
   }

   crappy.config.rules = {}

   crappy.config.screens = {}
   crappy.config.screens.default = {
      tags = {1, 2, 3, 4, 5, 6, 7, 8, 9},
      defaultLayout = "awful.layout.tile.left",
      tagSettings = {},
   }

   crappy.config.buttons = {}
   crappy.config.buttons.root = {}

   crappy.config.signals = {}
   crappy.config.signals.manage = "crappy.functions.signals.manage"
   crappy.config.signals.focus = "crappy.functions.signals.focus"
   crappy.config.signals.unfocus = "crappy.functions.signals.unfocus"
end

return crappy
