-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")

local startup = require("crappy.startup")

function startup.wibox ()
   print("Initializing crappy wibox...")

   crappy.wibox = {}

   --  Wibox
   -- Create a textclock widget
   -- mytextclock = awful.widget.textclock({ align = "right" })

   -- Create a systray
   -- mysystray = widget({ type = "systray" })

   -- Create a wibox for each screen and add it
   local mywibox = {}
   crappy.wibox.promptbox = {}
   local mylayoutbox = {}
   local mytaglist = {}
   mytaglist.buttons = awful.util.table.join(
      awful.button({ }, 1, awful.tag.viewonly),
      awful.button({ crappy.config.modkey }, 1, awful.client.movetotag),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ crappy.config.modkey }, 3, awful.client.toggletag),
      awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
   )
   local mytasklist = {}
   mytasklist.buttons = awful.util.table.join(
      awful.button({ }, 1, function (c)
            if c == client.focus then
               c.minimized = true
            else
               -- Without this, the following
               -- :isvisible() makes no sense
               c.minimized = false
               if not c:isvisible() then
                  awful.tag.viewonly(c:tags()[1])
               end
               -- This will also un-minimize
               -- the client, if needed
               client.focus = c
               c:raise()
            end
      end),
      awful.button({ }, 3, function ()
            if instance then
               instance:hide()
               instance = nil
            else
               instance = awful.menu.clients({
                     theme = { width = 250 }
               })
            end
      end),
      awful.button({ }, 4, function ()
            awful.client.focus.byidx(1)
            if client.focus then client.focus:raise() end
      end),
      awful.button({ }, 5, function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
   end))

   for s = 1, screen.count() do
      -- Create a promptbox for each screen
      crappy.wibox.promptbox[s] = awful.widget.prompt()
      -- Create an imagebox widget which will contains an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      mylayoutbox[s] = awful.widget.layoutbox(s)
      mylayoutbox[s]:buttons(awful.util.table.join(
                                awful.button({ }, 1, crappy.functions.global.layoutInc),
                                awful.button({ }, 3, crappy.functions.global.layoutDec),
                                awful.button({ }, 4, crappy.functions.global.layoutInc),
                                awful.button({ }, 5, crappy.functions.global.layoutDec)))
      -- Create a taglist widget
      mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

      -- Create a tasklist widget
      mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

      -- Create the wibox
      -- TODO: wibox position, bg
      mywibox[s] = awful.wibox({ position = "bottom", screen = s, bg = "#000000" })

      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(crappy.launcher)
      left_layout:add(mytaglist[s])
      left_layout:add(crappy.wibox.promptbox[s])

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      --if s == 1 then right_layout:add(wibox.widget.systray()) end
      --right_layout:add(mytextclock)
      right_layout:add(mylayoutbox[s])

      -- Now bring it all together (with the tasklist in the middle)
      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_middle(mytasklist[s])
      layout:set_right(right_layout)

      mywibox[s]:set_widget(layout)
   end
end


function startup.signals ()
   print("Initializing crappy signals...")
   assert(crappy.config.modkey ~= nil)
   assert(crappy.config.titlebar.height ~= nil)
   assert(crappy.config.signals.manage ~= nil)
   assert(crappy.config.signals.focus ~= nil)
   assert(crappy.config.signals.unfocus ~= nil)

   client.connect_signal("manage", crappy.misc.getFunction(crappy.config.signals.manage))
   client.connect_signal("focus", crappy.misc.getFunction(crappy.config.signals.focus))
   client.connect_signal("unfocus", crappy.misc.getFunction(crappy.config.signals.unfocus))
end

return startup
