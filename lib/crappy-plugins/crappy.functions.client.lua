local plugin = {}

local misc = require('crappy.misc')
local pluginManager = require("crappy.pluginManager")

plugin.name = 'Client Functions'
plugin.description = 'Functions that handle a client'
plugin.id = 'crappy.functions.client'
plugin.requires = {}
plugin.provides = {"functions.client"}
plugin.functions = {
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

function plugin.startup(awesomever, settings)
   local beautiful = misc.use('beautiful')
   local wibox = misc.use('wibox')

   function fullscreen(c)
      c.fullscreen = not c.fullscreen
   end
   plugin.functions["crappy.functions.client.fullscreen"].func = fullscreen

   function kill(c)
      c:kill()
   end
   plugin.functions["crappy.functions.client.kill"].func = kill

   function swapMaster(c)
      c:swap(awful.client.getmaster())
   end
   plugin.functions["crappy.functions.client.swapMaster"].func = swapMaster

   function redraw(c)
      c:redraw()
   end
   plugin.functions["crappy.functions.client.redraw"].func = redraw

   function ontop(c)
      c.ontop = not c.ontop
   end
   plugin.functions["crappy.functions.client.ontop"].func = ontop

   function minimized(c)
      c.minimized = not c.minimized
   end
   plugin.functions["crappy.functions.client.minimized"].func = minimized

   function maximized(c)
      c.maximized_horizontal = not c.maximized_horizontal
      c.maximized_vertical   = not c.maximized_vertical
   end
   plugin.functions["crappy.functions.client.maximized"].func = maximized

   function focus(c)
      client.focus = c
      c:raise()
   end
   plugin.functions["crappy.functions.client.focus"].func = focus
end

return plugin
