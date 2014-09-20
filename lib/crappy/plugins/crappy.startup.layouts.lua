local plugin = {}

local misc = require('crappy.misc')
local shared = require('crappy.shared')

plugin.name = 'Standard Layouts'
plugin.description = 'Initialize the layouts'
plugin.id = 'crappy.startup.layouts'
plugin.provides = {"layouts"}

function plugin.settingsDefault(settings)
   if #settings == 0 then
      settings = {
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
   end
end

function plugin.startup(awesomever, settings)
   print("Initializing crappy layouts...")

   plugin.settingsDefault(settings)
   
   shared.layouts = {}

   for i, layoutName in ipairs(crappy.config.settings.layouts) do
      print("Adding layout " .. layoutName)
      shared.layouts[i] = misc.getFunction(layoutName)
   end
end

return plugin
