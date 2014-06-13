-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

local startup = require("crappy.startup")

function startup.widget.systray(s)
   if crappy.wibox.systray == nil then
      crappy.wibox.systray = widget({ type = "systray" })
      return crappy.wibox.systray
   end

   return nil
end

function startup.widget.tasklist(s)
   local mytasklist = {}
   mytasklist.buttons = awful.util.table.join(
      awful.button({ }, 1, function (c)
            if c == client.focus then
               c.minimized = true
            else
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
               instance = awful.menu.clients({ width=250 })
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

   return awful.widget.tasklist(function(c) return awful.widget.tasklist.label.currenttags(c, s)  end, mytasklist.buttons)
end

function startup.widget.taglist(s)
   local mytaglist = {}
   mytaglist.buttons = awful.util.table.join(
      awful.button({ }, 1, awful.tag.viewonly),
      awful.button({ modkey }, 1, awful.client.movetotag),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ modkey }, 3, awful.client.toggletag),
      awful.button({ }, 4, awful.tag.viewnext),
      awful.button({ }, 5, awful.tag.viewprev)
   )

   return awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
end

function startup.wibox (settings)
   print("Initializing crappy wibox...")

   crappy.default.startup.wibox(settings)

   crappy.wibox = {}
   crappy.wibox.promptbox = {}

   for s = 1, screen.count() do
      local layouts = {}
      local mywibox = awful.wibox({ position = position, screen = s, bg = settings.bgcolor })
      print ("Making wibox on screen " .. s)

      for x, side in ipairs({"left", "middle", "right"}) do
         print("Adding widgets for side " .. side)
         local layout = {}

         if settings.widgets[side] ~= nil then
            for i, widget in ipairs(settings.widgets[side]) do
               f = crappy.misc.getFunction(widget)
               if f ~= nil then
                  print("Adding widget " .. widget)

                  local w = f(s)
                  if w ~= nil then
                     table.insert(layout, w)
                  else
                     print("Can't create widget " .. widget .. ": function returned nil")
                  end
               else
                  print("Can't create widget " .. widget .. ": function not found")
               end
            end
         end
         layouts[side] = layout
      end

      layouts.left.layout = awful.widget.layout.horizontal.leftright

      local wiboxlayout = {}
      table.insert(wiboxlayout, layouts.left)

      for i=#layouts.right, 1, -1 do
         table.insert(wiboxlayout, layouts.right[i])
      end

      for i=#layouts.middle, 1, -1 do
         table.insert(wiboxlayout, layouts.middle[i])
      end

      wiboxlayout.layout = awful.widget.layout.horizontal.rightleft

      mywibox.widgets = wiboxlayout
      crappy.wibox[s] = mywibox
   end
end

function startup.signals (settings)
   print("Initializing crappy signals...")

   crappy.default.startup.signals(settings)

   client.add_signal("manage", crappy.misc.getFunction(settings.manage))
   client.add_signal("focus", crappy.misc.getFunction(settings.focus))
   client.add_signal("unfocus", crappy.misc.getFunction(settings.unfocus))
end

return startup
