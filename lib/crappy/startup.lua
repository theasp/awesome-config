local pluginManager = require('crappy.pluginManager')

local startup = {}
local shared = require('crappy.shared')

startup.widget = {}


function startup.widget.launcher(s)
   return shared.launcher
end

function startup.widget.prompt(s)
   if crappy.wibox.promptbox[s] == nil then
      crappy.wibox.promptbox[s] = awful.widget.prompt()
   end

   return crappy.wibox.promptbox[s]
end

function startup.widget.textclock(s)
   return awful.widget.textclock()
end

function startup.widget.layout(s)
   local layoutbox = awful.widget.layoutbox(s)
   layoutbox:buttons(awful.util.table.join(
                         awful.button({ }, 1, crappy.functions.global.layoutInc),
                         awful.button({ }, 3, crappy.functions.global.layoutDec),
                         awful.button({ }, 4, crappy.functions.global.layoutInc),
                         awful.button({ }, 5, crappy.functions.global.layoutDec)))
   return layoutbox
end

return startup
