local lgi = require('lgi')
local functionManager = require('crappy.functionManager')
local shared = require('crappy.shared')

local plugin = {
   id = 'crappy.startup.layouts',
   name = 'Layouts',
   author = 'Andrew Phillips <theasp@gmail.com>',
   description = 'Initialize the layouts',
   requires = {"crappy.functions.layouts"},
   provides = {"crappy.shared.layouts"},
   defaults = {
      layouts = {
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
   }
}

function plugin.startup(awesomever, settings)
   shared.layouts = {}

   for i, layoutName in ipairs(settings.layouts) do
      shared.layouts[i] = functionManager.getFunction(layoutName)
   end
end

function plugin.buildUi(window, settings)
   local Gtk = lgi.require('Gtk')
   local widgets = require('crappy.gui.widgets')

   local valid = functionManager.getFunctionsForClass('layout')
   table.sort(valid)

   local layoutsBox = widgets.functionList(valid, settings.layouts, true, true)

   return layoutsBox
end

return plugin
