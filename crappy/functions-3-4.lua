-- Standard awesome library
require("awful")
-- Theme handling library
require("beautiful")

local functions = require("crappy.functions")

function functions.signals.manage (c, startup)
   -- Enable sloppy focus
   if crappy.config.settings.sloppyfocus == true then
      c:add_signal("mouse::enter", function(c)
                      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                      and awful.client.focus.filter(c) then
                         client.focus = c
                      end
      end)
   end

   if not startup then
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- awful.client.setslave(c)

      -- Put windows in a smart way, only if they does not set an initial position.
      if not c.size_hints.user_position and not c.size_hints.program_position then
         awful.placement.no_overlap(c)
         awful.placement.no_offscreen(c)
      end
   end

   -- Add a titlebar
   if crappy.config.settings.titlebar then
      awful.titlebar.add(c, { modkey = crappy.ezconfig.modkey, height = crappy.config.settings.titlebar.height })
   end
end

return functions
