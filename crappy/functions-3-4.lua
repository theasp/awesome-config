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

crappy.functions = {}

crappy.functions.menu = {}
function crappy.functions.menu.toggle()
   crappy.mymainmenu:toggle()
end

crappy.functions.signals = {}
function crappy.functions.signals.manage (c, startup)
   -- Add a titlebar
   if crappy.config.titlebar.enabled then
      awful.titlebar.add(c, { modkey = crappy.config.modkey, height = crappy.config.titlebar.height })
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
end

function crappy.functions.signals.focus(c)
   c.border_color = beautiful.border_focus
end

function crappy.functions.signals.unfocus(c)
   c.border_color = beautiful.border_normal
end


crappy.functions.client = {}
function crappy.functions.client.fullscreen(c)
   c.fullscreen = not c.fullscreen
end

function crappy.functions.client.kill(c)
   c:kill()
end

function crappy.functions.client.swapMaster(c)
   c:swap(awful.client.getmaster())
end

function crappy.functions.client.redraw(c)
   c:redraw()
end

function crappy.functions.client.ontop(c)
   c.ontop = not c.ontop
end

function crappy.functions.client.minimized(c)
   c.minimized = not c.minimized
end

function crappy.functions.client.maximized(c)
   c.maximized_horizontal = not c.maximized_horizontal
   c.maximized_vertical   = not c.maximized_vertical
end

function crappy.functions.client.focus(c)
   client.focus = c
   c:raise()
end

crappy.functions.global = {}
function crappy.functions.global.focusNext()
   awful.client.focus.byidx( 1)

   if client.focus then
      client.focus:raise()
   end
end

function crappy.functions.global.focusPrev()
   awful.client.focus.byidx(-1)

   if client.focus then
      client.focus:raise()
   end
end

function crappy.functions.global.focusPrevHist()
   awful.client.focus.history.previous()
   if client.focus then
      client.focus:raise()
   end
end

function crappy.functions.global.swapNext()
   awful.client.swap.byidx(  1)
end

function crappy.functions.global.swapPrev()
   awful.client.swap.byidx(  -11)
end

function crappy.functions.global.showMenu()
   crappy.mymainmenu:show({keygrabber=true})
end

function crappy.functions.global.focusNextScreen()
   awful.screen.focus_relative( 1)
end

function crappy.functions.global.focusPrevScreen()
   awful.screen.focus_relative( 1)
end

function crappy.functions.global.spawnTerminal()
   awful.util.spawn(crappy.config.terminal)
end

function crappy.functions.global.wmfactInc()
   awful.tag.incmwfact( 0.05)
end

function crappy.functions.global.wmfactDec()
   awful.tag.incmwfact( 0.05)
end

function crappy.functions.global.nmasterInc()
   awful.tag.incnmaster( 1)
end

function crappy.functions.global.nmasterDec()
   awful.tag.incnmaster(-1)
end

function crappy.functions.global.ncolInc() 
   awful.tag.incncol( 1)         
end

function crappy.functions.global.ncolDec() 
   awful.tag.incncol(-1)         
end

function crappy.functions.global.layoutInc() 
   awful.layout.inc(crappy.config.layoutRefs,  1) 
end

function crappy.functions.global.layoutDec() 
   awful.layout.inc(crappy.config.layoutRefs,  -1) 
end

function crappy.functions.global.showRunPrompt() 
   Mypromptbox[mouse.screen]:run() 
end


function crappy.functions.global.showLuaPrompt()
   awful.prompt.run({ prompt = "Run Lua code: " },
      mypromptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
end

crappy.functions.tag = {}
function crappy.functions.tag.show(i)
   local screen = mouse.screen
   if crappy.tags[screen][i] then
      awful.tag.viewonly(crappy.tags[screen][i])
   end
end

function crappy.functions.tag.toggle(i)
   local screen = mouse.screen
   if crappy.tags[screen][i] then
      awful.tag.viewtoggle(crappy.tags[screen][i])
   end
end

function crappy.functions.tag.clientMoveTo(i)
   if client.focus and crappy.tags[client.focus.screen][i] then
      awful.client.movetotag(crappy.tags[client.focus.screen][i])
   end
end

function crappy.functions.tag.clientToggle(i)
   if client.focus and crappy.tags[client.focus.screen][i] then
      awful.client.toggletag(crappy.tags[client.focus.screen][i])
   end
end

return crappy.functions
