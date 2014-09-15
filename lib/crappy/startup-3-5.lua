-- Standard awesome library
local gears = require("gears")
awful = require("awful") -- Needs to be global
awful.rules = require("awful.rules")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
menubar = require("menubar") -- Needs to be global
menubar.menu_gen.all_menu_dirs = { "/usr/share/applications/", "/usr/local/share/applications", "~/.local/share/applications" }


local startup = require("crappy.startup")

function startup.widget.systray(s)
   if crappy.wibox.systray == nil then
      crappy.wibox.systray = wibox.widget.systray()
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

   return awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
end

function startup.widget.taglist(s)
   local mytaglist = {}
   mytaglist.buttons = awful.util.table.join(
      awful.button({ }, 1, awful.tag.viewonly),
      awful.button({ crappy.ezconfig.modkey }, 1, awful.client.movetotag),
      awful.button({ }, 3, awful.tag.viewtoggle),
      awful.button({ crappy.ezconfig.modkey }, 3, awful.client.toggletag),
      awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
      awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
   )

   return awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
end

function startup.wibox(settings)
   print("Initializing crappy wibox...")

   crappy.default.startup.wibox(settings)

   crappy.wibox = {}
   crappy.wibox.promptbox = {}

   for s = 1, screen.count() do
      local layouts = {}
      local mywibox = awful.wibox({ position = settings.position, screen = s, bg = settings.bgcolor })
      print ("Making wibox on screen " .. s)

      for x, side in ipairs({"left", "middle", "right"}) do
         print("Adding widgets for side " .. side)
         local layout = wibox.layout.fixed.horizontal()

         if settings.widgets[side] ~= nil then
            for i, widget in ipairs(settings.widgets[side]) do
               f = crappy.misc.getFunction(widget)
               if f ~= nil then
                  print("Adding widget " .. widget)

                  local w = f(s)
                  if w ~= nil then
                     layout:add(w)
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

      local wiboxlayout = wibox.layout.align.horizontal()
      wiboxlayout:set_left(layouts.left)
      wiboxlayout:set_middle(layouts.middle)
      wiboxlayout:set_right(layouts.right)

      mywibox:set_widget(wiboxlayout)
      crappy.wibox[s] = mywibox
   end
end


function startup.signals(settings)
   print("Initializing crappy signals...")

   crappy.default.startup.signals(settings)

   client.connect_signal("manage", crappy.misc.getFunction(settings.manage))
   client.connect_signal("focus", crappy.misc.getFunction(settings.focus))
   client.connect_signal("unfocus", crappy.misc.getFunction(settings.unfocus))
end

--table.insert(startup.functions, "crappy.startup.menubar")
function startup.menubar(settings)
   print("Initializing crappy menubar...")
   menubar.utils.terminal = crappy.config.settings.terminal

   if settings.dirs then
      print("Setting dirs")
      menubar.menu_gen.all_menu_dirs = settings.dirs
   end

   if settings.categories then
      for category, options in pairs(settings.categories) do
         menubar.menu_gen.all_categories[category] = options
      end
   end
end

return startup
