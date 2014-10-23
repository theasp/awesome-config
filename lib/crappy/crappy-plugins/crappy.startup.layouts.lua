local plugin = {}

local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')
local shared = require('crappy.shared')

plugin.name = 'Layouts'
plugin.description = 'Initialize the layouts'
plugin.id = 'crappy.startup.layouts'
plugin.requires = {"crappy.functions.layouts"}
plugin.provides = {"crappy.shared.layouts"}

function plugin.settingsDefault(settings)
   if #settings == 0 then
      local newSettings = {
         "awful.layout.suit.floating",
         "awful.layout.suit.tile",
         "awful.layout.suit.tile.left",
         "awful.layout.suit.tile.bottom",
         "awful.layout.suit.tile.top",
         "awful.layout.suit.fair",
         "awful.layout.suit.fair.horizontal",
         "awful.layout.suit.spiral",
         "awful.layout.suit.spiral.dwindle",
         "awful.layout.suit.max",
         "awful.layout.suit.max.fullscreen",
         "awful.layout.suit.magnifier"
      }

      misc.mergeTable(settings, newSettings)
   end
end

function plugin.startup(awesomever, settings)
   plugin.settingsDefault(settings)

   shared.layouts = {}

   for i, layoutName in ipairs(settings) do
      shared.layouts[i] = functionManager.getFunction(layoutName)
   end
end

function plugin.buildUi(window, settings, log)
   local lgi = require 'lgi'
   local Gtk = lgi.require('Gtk')
   local widgets = require('crappy.gui.widgets')

   plugin.settingsDefault(settings)

   local valid = functionManager.getFunctionsForClass('layout')
   table.sort(valid)

   local layoutsBox = widgets.functionList(valid, settings, true, true)

   return layoutsBox
end


return plugin
