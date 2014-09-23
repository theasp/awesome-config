local plugin = {}

local misc = require('crappy.misc')
local pluginManager = require("crappy.pluginManager")

plugin.name = 'Tag Functions'
plugin.description = 'Functions that act on tags'
plugin.id = 'crappy.functions.tag'
plugin.requires = {}
plugin.provides = {"crappy.functions.tag"}
plugin.functions = {
   ["crappy.functions.tag.show"] = {
      class = "tag",
      description = "Switch to a specific tag",
   },
   ["crappy.functions.signals.toggle"] = {
      class = "tag",
      description = "Toggle displaying a specific tag",
   },
   ["crappy.functions.signals.clientMoveTo"] = {
      class = "tag",
      description = "Move the current client to a specific tag",
   },
   ["crappy.functions.signals.clientToggle"] = {
      class = "tag",
      description = "toggle the current client being a member of a specific tag",
   }
}

function plugin.startup(awesomever, settings)
   if not crappy.functions.tag then
      crappy.functions.tag = {}
   end
   
   function crappy.functions.tag.show(i)
      local screen = mouse.screen
      if crappy.shared.tags[screen][i] then
         awful.tag.viewonly(crappy.shared.tags[screen][i])
      end
   end

   function crappy.functions.tag.toggle(i)
      local screen = mouse.screen
      if crappy.shared.shared.tags[screen][i] then
         awful.tag.viewtoggle(crappy.shared.tags[screen][i])
      end
   end

   function crappy.functions.tag.clientMoveTo(i)
      if client.focus and crappy.shared.tags[client.focus.screen][i] then
         awful.client.movetotag(crappy.shared.tags[client.focus.screen][i])
      end
   end

   function crappy.functions.tag.clientToggle(i)
      if client.focus and crappy.shared.tags[client.focus.screen][i] then
         awful.client.toggletag(crappy.shared.tags[client.focus.screen][i])
      end
   end
end

return plugin
