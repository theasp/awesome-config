local functions  = {}

local misc = require('crappy.misc')
local shared = require('crappy.shared')
local beautiful = misc.use('beautiful')
local wibox = misc.use('wibox')

functions.global = {}

functions.tag = {}
function functions.tag.show(i)
   local screen = mouse.screen
   if shared.tags[screen][i] then
      awful.tag.viewonly(shared.tags[screen][i])
   end
end

function functions.tag.toggle(i)
   local screen = mouse.screen
   if shared.tags[screen][i] then
      awful.tag.viewtoggle(shared.tags[screen][i])
   end
end

function functions.tag.clientMoveTo(i)
   if client.focus and shared.tags[client.focus.screen][i] then
      awful.client.movetotag(shared.tags[client.focus.screen][i])
   end
end

function functions.tag.clientToggle(i)
   if client.focus and shared.tags[client.focus.screen][i] then
      awful.client.toggletag(shared.tags[client.focus.screen][i])
   end
end

return functions
