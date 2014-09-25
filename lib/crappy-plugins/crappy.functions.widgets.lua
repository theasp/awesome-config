local plugin = {}

local misc = require('crappy.misc')
local pluginManager = require("crappy.pluginManager")

plugin.name = 'Widget Functions'
plugin.description = 'Functions produce widgets for use in a wibox'
plugin.id = 'crappy.functions.widgets'
plugin.requires = {"crappy.shared.launcher", "crappy.shared.tags"}
plugin.provides = {}
plugin.functions = {
   ["crappy.functions.widgets.launcher"] = {
      class = "widget",
      description = "A menu to launch things",
   },
   ["crappy.functions.widgets.prompt"] = {
      class = "widget",
      description = "A prompt to run commands in",
   },
   ["crappy.functions.widgets.textclock"] = {
      class = "widget",
      description = "A digital clock",
   },
   ["crappy.functions.widgets.layout"] = {
      class = "widget",
      description = "A button that switches the layout for the current tag",
   },
   ["crappy.functions.widgets.systray"] = {
      class = "widget",
      description = "A spot for system tray icons to appear",
   },
   ["crappy.functions.widgets.tasklist"] = {
      class = "widget",
      description = "A list of the windows in the current tag",
   },
   ["crappy.functions.widgets.taglist"] = {
      class = "widget",
      description = "A list of the tags on the current screen",
   },
}

function plugin.startup(awesomever, settings)
   local beautiful = misc.use('beautiful')
   local wibox = misc.use('wibox')
   local shared = require('crappy.shared')
   local ezconfig = require("crappy.ezconfig")

   if not crappy.functions.widgets then
      crappy.functions.widgets = {}
   end

   function crappy.functions.widgets.launcher(s)
      return shared.launcher
   end

   function crappy.functions.widgets.prompt(s)
      if shared.wibox.promptbox[s] == nil then
         shared.wibox.promptbox[s] = awful.widget.prompt()
      end

      return shared.wibox.promptbox[s]
   end

   function crappy.functions.widgets.textclock(s)
      return awful.widget.textclock()
   end

   function crappy.functions.widgets.layout(s)
      local layoutbox = awful.widget.layoutbox(s)
      layoutbox:buttons(awful.util.table.join(
                           awful.button({ }, 1, crappy.functions.global.layoutInc),
                           awful.button({ }, 3, crappy.functions.global.layoutDec),
                           awful.button({ }, 4, crappy.functions.global.layoutInc),
                           awful.button({ }, 5, crappy.functions.global.layoutDec)))
      return layoutbox
   end

   function crappy.functions.widgets.systray(s)
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

   function crappy.functions.widgets.tasklist(s)
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


   function crappy.functions.widgets.taglist(s)
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
end

return plugin
