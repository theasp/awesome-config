-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Load Debian menu entries
require("debian.menu")

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
      awful.button({ }, 4, awful.tag.viewnext),
      awful.button({ }, 5, awful.tag.viewprev)
   )
   local mytasklist = {}
   mytasklist.buttons = awful.util.table.join(
      awful.button({ }, 1, function (c)
            if not c:isvisible() then
               awful.tag.viewonly(c:tags()[1])
            end
            client.focus = c
            c:raise()
      end),
      awful.button({ }, 3, function ()
            if instance then
               instance:hide()
               instance = nil
            else
               instance = awful.menu.clients({ width=250 })
            end
      end),
      awful.button({ }, 4, crappy.functions.global.focusNext),
      awful.button({ }, 5, crappy.functions.global.focusPrev))

   for s = 1, screen.count() do
      -- Create a promptbox for each screen
      crappy.wibox.promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
      -- Create an imagebox widget which will contains an icon indicating which layout we're using.
      -- We need one layoutbox per screen.
      mylayoutbox[s] = awful.widget.layoutbox(s)
      mylayoutbox[s]:buttons(awful.util.table.join(
                                awful.button({ }, 1, crappy.functions.global.layoutInc),
                                awful.button({ }, 3, crappy.functions.global.layoutDec),
                                awful.button({ }, 4, crappy.functions.global.layoutInc),
                                awful.button({ }, 5, crappy.functions.global.layoutDec)))
      -- Create a taglist widget
      mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

      -- Create a tasklist widget
      mytasklist[s] = awful.widget.tasklist(function(c) return awful.widget.tasklist.label.currenttags(c, s)  end, mytasklist.buttons)

      -- Create the wibox
      mywibox[s] = awful.wibox({ position = "bottom", screen = s, bg = "#000000" })
      -- Add widgets to the wibox - order matters
      mywibox[s].widgets = {
         {
            crappy.mylauncher,
            mytaglist[s],
            crappy.wibox.promptbox[s],
            layout = awful.widget.layout.horizontal.leftright
         },
         crappy.mylauncher,
         mylayoutbox[s],
         -- mytextclock,
         -- s == 1 and mysystray or nil,
         mytasklist[s],
         layout = awful.widget.layout.horizontal.rightleft
      }
   end
end


function startup.signals ()
   print("Initializing crappy signals...")
   assert(crappy.config.modkey ~= nil)
   assert(crappy.config.titlebar.height ~= nil)
   assert(crappy.config.signals.manage ~= nil)
   assert(crappy.config.signals.focus ~= nil)
   assert(crappy.config.signals.unfocus ~= nil)

   client.add_signal("manage", crappy.misc.getFunction(crappy.config.signals.manage))
   client.add_signal("focus", crappy.misc.getFunction(crappy.config.signals.focus))
   client.add_signal("unfocus", crappy.misc.getFunction(crappy.config.signals.unfocus))
end

return startup
