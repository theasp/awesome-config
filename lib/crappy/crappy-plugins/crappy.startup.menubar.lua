local lgi = require('lgi')
local shared = require('crappy.shared')

local plugin = {
   id = 'crappy.startup.menubar',
   name = 'Menubar',
   description = 'Set up the menubar, for 3.5+ only',
   author = 'Andrew Phillips <theasp@gmail.com>',
   requires = {"crappy.shared.settings.terminal"},
   provides = {"crappy.shared.menubar"},
   before = {"crappy.startup.bindings"},
   defaults = {
      categories = {},
      dirs = {
         "/usr/share/applications/",
         "/usr/local/share/applications/",
         ".local/share/applications/"
      }
   }
}

local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   if awesomever < 3.5 then
      print("Not initializing crappy menubar, not supported in this version")
      return
   end

   shared.menubar = require("menubar")

   shared.menubar.utils.terminal = crappy.shared.settings.terminal

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
