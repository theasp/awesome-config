local lgi = require('lgi')
local misc = require('crappy.misc')

local plugin = {
   name = 'Tag Functions',
   description = 'Functions that act on tags',
   id = 'crappy.functions.tag',
   requires = {},
   provides = {},
   options = {},
   functions = {
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
}

local log = lgi.log.domain(plugin.id)

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
