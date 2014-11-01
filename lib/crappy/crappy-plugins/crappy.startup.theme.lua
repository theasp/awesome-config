local lgi = require('lgi')
local misc = require("crappy.misc")

local plugin = {
   id = 'crappy.startup.theme',
   name = 'Theme',
   description = 'Set the theme used by beautiful',
   author = 'Andrew Phillips <theasp@gmail.com>',
   provides = {},
   options = {
      {
         name = 'file',
         label = "_Theme File:",
         type = "string"
      },
      {
         name = 'font',
         label = "Font _Override:",
         type = "string"
      },
   },
   defaults = {
      file = "/usr/share/awesome/themes/default/theme.lua",
      font = ''
   }
}

local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   local beautiful = misc.use("beautiful")

   beautiful.init(settings.file)

   if settings.font ~= '' then
      awesome.font = settings.font
      beautiful.get().font = settings.font
   end
end

return plugin
