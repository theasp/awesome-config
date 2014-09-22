local plugin = {}

local misc = require('crappy.misc')
local shared = require('crappy.shared')

plugin.name = 'Menubar'
plugin.description = 'Set up the menubar, for 3.5+ only'
plugin.id = 'crappy.startup.menubar'
plugin.provides = {"crappy.shared.menubar"}

function plugin.settingsDefault(settings)
   if settings.dirs == nil then
      settings.dirs = { "/usr/share/applications/",
                        "/usr/local/share/applications/",
                        ".local/share/applications/" }
   end

   return settings
end

function plugin.startup(awesomever, settings)
   if awesomever < 3.5 then
      print("Not initializing crappy menubar, not supported in this version")
      return
   end

   shared.menubar = require("menubar")

   shared.menubar.utils.terminal = crappy.config.settings.terminal

   if settings.dirs then
      shared.menubar.menu_gen.all_menu_dirs = settings.dirs
   end

   if settings.categories then
      for category, options in pairs(settings.categories) do
         shared.menubar.menu_gen.all_categories[category] = options
      end
   end
end

return plugin
