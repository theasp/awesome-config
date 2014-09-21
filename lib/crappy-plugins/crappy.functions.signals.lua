local plugin = {}

local misc = require('crappy.misc')
local pluginManager = require("crappy.pluginManager")

plugin.name = 'Signal Functions'
plugin.description = 'Functions that handle signals'
plugin.id = 'crappy.functions.signals'
plugin.requires = {"settings.titlebar", "settings.sloppyfocus"}
plugin.provides = {"functions.signals"}
plugin.functions = {
   ["crappy.functions.signals.focus"] = {
      class = "signal",
      description = "Signal for when a client is focused",
   },
   ["crappy.functions.signals.unfocus"] = {
      class = "signal",
      description = "Signal for when a client is focused",
   },
   ["crappy.functions.signals.manage"] = {
      class = "signal",
      description = "Signal for when a client (window) is created",
   }
}

function plugin.initFunctions()
   local beautiful = misc.use('beautiful')
   local wibox = misc.use('wibox')
   
   function focus(c)
      c.border_color = beautiful.border_focus
   end
   plugin.functions["crappy.functions.signals.focus"].func = focus
      
    function unfocus(c)
      c.border_color = beautiful.border_normal
   end
   plugin.functions["crappy.functions.signals.unfocus"].func = unfocus
   
   function manage(c, startup)
      -- Enable sloppy focus
      if crappy.config.settings.sloppyfocus == true then
         if c.connect_signal then
            c:connect_signal("mouse::enter", function(c)
                                if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                                and awful.client.focus.filter(c) then
                                   client.focus = c
                                end
            end)
         else
            c:add_signal("mouse::enter", function(c)
                            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                            and awful.client.focus.filter(c) then
                               client.focus = c
                            end
            end)
         end
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
      if crappy.config.settings.titlebar and (c.type == "normal" or c.type == "dialog") then
         -- VERSION: 3.5 has wibox.layout.fixed.horizontal
         if wibox.layout.fixed.horizontal then
            -- buttons for the titlebar
            local buttons = awful.util.table.join(
               awful.button({ }, 1, function()
                     client.focus = c
                     c:raise()
                     awful.mouse.client.move(c)
               end),
               awful.button({ }, 3, function()
                     client.focus = c
                     c:raise()
                     awful.mouse.client.resize(c)
               end)
            )

            -- Widgets that are aligned to the left
            local left_layout = wibox.layout.fixed.horizontal()
            left_layout:add(awful.titlebar.widget.iconwidget(c))
            left_layout:buttons(buttons)

            -- Widgets that are aligned to the right
            local right_layout = wibox.layout.fixed.horizontal()
            right_layout:add(awful.titlebar.widget.floatingbutton(c))
            right_layout:add(awful.titlebar.widget.maximizedbutton(c))
            right_layout:add(awful.titlebar.widget.stickybutton(c))
            right_layout:add(awful.titlebar.widget.ontopbutton(c))
            right_layout:add(awful.titlebar.widget.closebutton(c))

            -- The title goes in the middle
            local middle_layout = wibox.layout.flex.horizontal()
            local title = awful.titlebar.widget.titlewidget(c)
            title:set_align("center")
            middle_layout:add(title)
            middle_layout:buttons(buttons)

            -- Now bring it all together
            local layout = wibox.layout.align.horizontal()
            layout:set_left(left_layout)
            layout:set_right(right_layout)
            layout:set_middle(middle_layout)

            awful.titlebar(c):set_widget(layout)
         else
            awful.titlebar.add(c, { modkey = ezconfig.modkey })
         end
      end
   end

   plugin.functions["crappy.functions.signals.manage"].func = manage
end

return plugin
