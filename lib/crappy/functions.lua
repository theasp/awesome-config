local functions  = {}

local shared = require('crappy.shared')

functions.menu = {}
function functions.menu.toggle()
   shared.mainmenu:toggle()
end

functions.signals = {}
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
   awful.client.swap.byidx(  -1)
end

function functions.global.showMenu()
   shared.mainmenu:show({keygrabber=true})
end

function functions.global.focusNextScreen()
   awful.screen.focus_relative( 1)
end

function functions.global.focusPrevScreen()
   awful.screen.focus_relative( 1)
end

function functions.global.spawnTerminal()
   awful.util.spawn(crappy.config.settings.terminal)
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
   awful.layout.inc(shared.layouts,  1)
end

function functions.global.layoutDec()
   awful.layout.inc(shared.layouts,  -1)
end

function functions.global.showRunPrompt()
   shared.wibox.promptbox[mouse.screen]:run()
end


function functions.global.showLuaPrompt()
   awful.prompt.run({ prompt = "Run Lua code: " },
      shared.wibox.promptbox[mouse.screen].widget,
      awful.util.eval, nil,
      awful.util.getdir("cache") .. "/history_eval")
end

functions.tag = {}
function functions.tag.show(i)
   local screen = mouse.screen
   if shared.tags[screen][i] then
      awful.tag.viewonly(shared.tags[screen][i])
   end
end

function functions.tag.toggle(i)
   local screen = mouse.screen
   if shared.tags[screen][i] then
      awful.tag.viewtoggle(shared.tags[screen][i])
   end
end

function functions.tag.clientMoveTo(i)
   if client.focus and shared.tags[client.focus.screen][i] then
      awful.client.movetotag(shared.tags[client.focus.screen][i])
   end
end

function functions.tag.clientToggle(i)
   if client.focus and shared.tags[client.focus.screen][i] then
      awful.client.toggletag(shared.tags[client.focus.screen][i])
   end
end

return functions
