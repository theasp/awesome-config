local plugin = {}

local misc = require('crappy.misc')

plugin.name = 'wibox'
plugin.description = 'Set up the wibox'
plugin.id = 'crappy.startup.wibox'
plugin.requires = {"wibox-widget", "launcher"}
plugin.provides = {"wibox"}

function plugin.settingsDefault(settings)
   if settings.position == nil then
      settings.position = "bottom"
   end

   if settings.widgets == nil then
      settings.widgets = {}
   end

   if settings.widgets.left == nil then
      settings.widgets.left = {
         "widget.launcher",
         "widget.taglist",
         "widget.prompt"
      }
   end

   if settings.widgets.middle == nil then
      settings.widgets.middle = {
         "widget.tasklist"
      }
   end

   if settings.widgets.right == nil then
      settings.widgets.right = {
         "widget.systray",
         "widget.textclock",
         "widget.layout"
      }
   end

   return settings
end


function plugin.startup(awesomever, settings)
   local wibox = misc.use("wibox")
   local ezconfig = require("crappy.ezconfig")
   local shared = require('crappy.shared')

   plugin.settingsDefault(settings)

   widget = {}

   function widget.launcher(s)
      return shared.launcher
   end

   function widget.prompt(s)
      if shared.wibox.promptbox[s] == nil then
         shared.wibox.promptbox[s] = awful.widget.prompt()
      end

      return shared.wibox.promptbox[s]
   end

   function widget.textclock(s)
      return awful.widget.textclock()
   end

   function widget.layout(s)
      local layoutbox = awful.widget.layoutbox(s)
      layoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, crappy.functions.global.layoutInc),
                           awful.button({ }, 3, crappy.functions.global.layoutDec),
                           awful.button({ }, 4, crappy.functions.global.layoutInc),
                           awful.button({ }, 5, crappy.functions.global.layoutDec)))
      return layoutbox
   end

   function widget.systray(s)
      if shared.systray == nil then
         if wibox.widget.systray then
            shared.systray = wibox.widget.systray()
         else
            shared.systray = widget({ type = "systray" })
         end
         return shared.systray
      end

      return nil
   end

   function widget.tasklist(s)
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
                  -- Width is for 3.4, theme is for 3.5+
                  --instance = awful.menu.clients({ width=250, theme = {width = 250} })
                  instance = awful.menu.clients({ theme = {width = 250} })
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

      -- awful.widget.tasklist.filter.currenttags is 3.5+
      if awful.widget.tasklist.filter.currenttags then
         return awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)
      else
         return awful.widget.tasklist(function(c) return awful.widget.tasklist.label.currenttags(c, s)  end, mytasklist.buttons)
      end
   end


   function widget.taglist(s)
      local mytaglist = {}

      -- awful.widget.taglist.filter.all is 3.5+
      if awful.widget.taglist.filter.all then
         mytaglist.buttons = awful.util.table.join(
            awful.button({ }, 1, awful.tag.viewonly),
            awful.button({ ezconfig.modkey }, 1, awful.client.movetotag),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ ezconfig.modkey }, 3, awful.client.toggletag),
            awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
            awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
         )

         return awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)
      else      
         mytaglist.buttons = awful.util.table.join(
            awful.button({ }, 1, awful.tag.viewonly),
            awful.button({ ezconfig.modkey }, 1, awful.client.movetotag),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ ezconfig.modkey }, 3, awful.client.toggletag),
            awful.button({ }, 4, awful.tag.viewnext),
            awful.button({ }, 5, awful.tag.viewprev)
         )

         return awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)
      end
   end


   shared.wibox = {}
   shared.wibox.promptbox = {}

   for s = 1, screen.count() do
      local layouts = {}
      local mywibox = awful.wibox({ position = settings.position, screen = s, bg = settings.bgcolor })

      for x, side in ipairs({"left", "middle", "right"}) do
         local layout = {}

         -- wibox.layout.fixed.horizontal is 3.5
         if wibox.layout.fixed.horizontal then
            layout = wibox.layout.fixed.horizontal()
         end

         if settings.widgets[side] ~= nil then
            for i, widget in ipairs(settings.widgets[side]) do
               f = misc.getFunction(widget)
               if f ~= nil then
                  local w = f(s)
                  if w ~= nil then
                     -- wibox.layout.fixed.horizontal is 3.5+
                     if wibox.layout.fixed.horizontal then
                        layout:add(w)
                     else
                        table.insert(layout, w)
                     end
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

      -- wibox.layout.fixed.horizontal is 3.5+
      if wibox.layout.fixed.horizontal then
         local wiboxlayout = wibox.layout.align.horizontal()
         wiboxlayout:set_left(layouts.left)
         wiboxlayout:set_middle(layouts.middle)
         wiboxlayout:set_right(layouts.right)

         mywibox:set_widget(wiboxlayout)
      else
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
      end
      shared.wibox[s] = mywibox
   end
end

return plugin
