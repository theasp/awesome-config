-- Standard awesome library
local awful = require("awful")
--require("awful.autofocus")
awful.rules = require("awful.rules")
-- Theme handling library
local beautiful = require("beautiful")
local wibox = require("wibox")

-- Load Debian menu entries
require("debian.menu")

local functions = {}

functions.menu = {}
function functions.menu.toggle()
   crappy.mymainmenu:toggle()
end

functions.signals = {}
function functions.signals.manage (c, startup)
   -- Enable sloppy focus
   -- c:connect_signal("mouse::enter", function(c)
   --                     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
   --                     and awful.client.focus.filter(c) then
   --                        client.focus = c
   --                     end
   -- end)

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
   if crappy.config.titlebar.enabled and (c.type == "normal" or c.type == "dialog") then
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
   end
end

function functions.signals.focus(c)
   c.border_color = beautiful.border_focus
end

function functions.signals.unfocus(c)
   c.border_color = beautiful.border_normal
end


functions.client = {}
function functions.client.fullscreen(c)
   c.fullscreen = not c.fullscreen
end

function functions.client.kill(c)
   c:kill()
end

function functions.client.swapMaster(c)
   c:swap(awful.client.getmaster())
end

function functions.client.redraw(c)
   c:redraw()
end

function functions.client.ontop(c)
   c.ontop = not c.ontop
end

function functions.client.minimized(c)
   c.minimized = not c.minimized
end

function functions.client.maximized(c)
   c.maximized_horizontal = not c.maximized_horizontal
   c.maximized_vertical   = not c.maximized_vertical
end

function functions.client.focus(c)
   client.focus = c
   c:raise()
end

functions.global = {}
function functions.global.focusNext()
   awful.client.focus.byidx( 1)

   if client.focus then
      client.focus:raise()
   end
end

function functions.global.focusPrev()
   awful.client.focus.byidx(-1)

   if client.focus then
      client.focus:raise()
   end
end

function functions.global.focusPrevHist()
   awful.client.focus.history.previous()
   if client.focus then
      client.focus:raise()
   end
end

function functions.global.swapNext()
   awful.client.swap.byidx(  1)
end

function functions.global.swapPrev()
   awful.client.swap.byidx(  -11)
end

function functions.global.showMenu()
   crappy.mymainmenu:show({keygrabber=true})
end

function functions.global.focusNextScreen()
   awful.screen.focus_relative( 1)
end

function functions.global.focusPrevScreen()
   awful.screen.focus_relative( 1)
end

function functions.global.spawnTerminal()
   awful.util.spawn(crappy.config.terminal)
end

function functions.global.wmfactInc()
   awful.tag.incmwfact( 0.05)
end

function functions.global.wmfactDec()
   awful.tag.incmwfact( 0.05)
end

function functions.global.nmasterInc()
   awful.tag.incnmaster( 1)
end

function functions.global.nmasterDec()
   awful.tag.incnmaster(-1)
end

function functions.global.ncolInc() 
   awful.tag.incncol( 1)         
end

function functions.global.ncolDec() 
   awful.tag.incncol(-1)         
end

function functions.global.layoutInc() 
   awful.layout.inc(crappy.config.layoutRefs,  1) 
end

function functions.global.layoutDec() 
   awful.layout.inc(crappy.config.layoutRefs,  -1) 
end

function functions.global.showRunPrompt() 
   Mypromptbox[mouse.screen]:run() 
end


function functions.global.showLuaPrompt()
   awful.prompt.run({ prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
end

functions.tag = {}
function functions.tag.show(i)
   local screen = mouse.screen
   if crappy.tags[screen][i] then
      awful.tag.viewonly(crappy.tags[screen][i])
   end
end

function functions.tag.toggle(i)
   local screen = mouse.screen
   if crappy.tags[screen][i] then
      awful.tag.viewtoggle(crappy.tags[screen][i])
   end
end

function functions.tag.clientMoveTo(i)
   if client.focus and crappy.tags[client.focus.screen][i] then
      awful.client.movetotag(crappy.tags[client.focus.screen][i])
   end
end

function functions.tag.clientToggle(i)
   if client.focus and crappy.tags[client.focus.screen][i] then
      awful.client.toggletag(crappy.tags[client.focus.screen][i])
   end
end

return functions
