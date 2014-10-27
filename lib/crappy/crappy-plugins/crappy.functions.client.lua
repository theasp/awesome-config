local lgi = require('lgi')
local misc = require('crappy.misc')

local plugin = {
   name = 'Client Functions'
   description = 'Functions that handle a client'
   id = 'crappy.functions.client'
   requires = {}
   provides = {}
   functions = {
      ["crappy.functions.client.fullscreen"] = {
         class = "client",
         description = "Toggle a client being fullscreen",
      },
      ["crappy.functions.client.kill"] = {
         class = "client",
         description = "Kill a client",
      },
      ["crappy.functions.client.redraw"] = {
         class = "client",
         description = "Redraw a client",
      },
      ["crappy.functions.client.swapMaster"] = {
         class = "client",
         description = "Swap a client with the master",
      },
      ["crappy.functions.client.ontop"] = {
         class = "client",
         description = "Toggle a client being kept ontop",
      },
      ["crappy.functions.client.minimized"] = {
         class = "client",
         description = "Toggle a client being minimized",
      },
      ["crappy.functions.client.maximized"] = {
         class = "client",
         description = "Toggle a client being maximized",
      },
      ["crappy.functions.client.focus"] = {
         class = "client",
         description = "Focus a client",
      }
   }
}

local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   local beautiful = misc.use('beautiful')
   local wibox = misc.use('wibox')

   if not crappy.functions.client then
      crappy.functions.client = {}
   end

   function crappy.functions.client.fullscreen(c)
      c.fullscreen = not c.fullscreen
   end

   function crappy.functions.client.kill(c)
      c:kill()
   end

   function crappy.functions.client.swapMaster(c)
      c:swap(awful.client.getmaster())
   end

   function crappy.functions.client.redraw(c)
      c:redraw()
   end

   function crappy.functions.client.ontop(c)
      c.ontop = not c.ontop
   end

   function crappy.functions.client.minimized(c)
      c.minimized = not c.minimized
   end

   function crappy.functions.client.maximized(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
   end

   function crappy.functions.client.focus(c)
      client.focus = c
      c:raise()
   end
end

function plugin.buildUi(window, settings)
   return nil
end

return plugin
