local plugin = {}

local misc = require('crappy.misc')
local pluginManager = require("crappy.pluginManager")

plugin.name = 'Global Functions'
plugin.description = 'Functions that are used globally'
plugin.id = 'crappy.functions.global'
plugin.requires = {"mainmenu", "wibox"}
plugin.provides = {"functions.global"}
plugin.functions = {
   ["crappy.functions.global.focusNext"] = {
      class = "global",
      description = "Focus the next client on the current tag",
   },
   ["crappy.functions.global.focusPrev"] = {
      class = "global",
      description = "Focus the previous client on the current tag",
   },
   ["crappy.functions.global.focusPrevHist"] = {
      class = "global",
      description = "Focus the previous client in history",
   },
   ["crappy.functions.global.swapNext"] = {
      class = "global",
      description = "Swap the next client on the current tag",
   },
   ["crappy.functions.global.swapPrev"] = {
      class = "global",
      description = "Swap the previous client on the current tag",
   },
   ["crappy.functions.global.showMenu"] = {
      class = "global",
      description = "Show the menu",
   },
   ["crappy.functions.global.focusNextScreen"] = {
      class = "global",
      description = "Focus the next screen",
   },
   ["crappy.functions.global.focusPrevScreen"] = {
      class = "global",
      description = "Focus the previous screen",
   },
   ["crappy.functions.global.spawnTerminal"] = {
      class = "global",
      description = "Launch your configured terminal",
   },
   ["crappy.functions.global.wmfactInc"] = {
      class = "global",
      description = "Increase wmfact for the current tag",
   },
   ["crappy.functions.global.wmfactDec"] = {
      class = "global",
      description = "Decrease wmfact for the current tag",
   },
   ["crappy.functions.global.nmasterInc"] = {
      class = "global",
      description = "Increase nmaster for the current tag",
   },
   ["crappy.functions.global.nmasterDec"] = {
      class = "global",
      description = "Decrease nmaster for the current tag",
   },
   ["crappy.functions.global.ncolInc"] = {
      class = "global",
      description = "Increase ncol for the current tag",
   },
   ["crappy.functions.global.ncolDec"] = {
      class = "global",
      description = "Decrease ncol for the current tag",
   },
   ["crappy.functions.global.layoutInc"] = {
      class = "global",
      description = "Switch to the next layout",
   },
   ["crappy.functions.global.layoutDec"] = {
      class = "global",
      description = "Switch to the previous layout",
   },
   ["crappy.functions.global.showRunPrompt"] = {
      class = "global",
      description = "Show the run prompt in the wibox",
   },
   ["crappy.functions.global.showLuaPrompt"] = {
      class = "global",
      description = "Show the lua prompt in the wibox",
   },
   ["crappy.functions.global.toggleMenu"] = {
      class = "global",
      description = "Toggle the main menu",
   },
   ["crappy.functions.menu.toggle"] = {
      class = "global",
      description = "Toggle the main menu (deprecated, see crappy.functions.global.menuToggle)",
   }
}

function plugin.startup(awesomever, settings)
   local beautiful = misc.use('beautiful')
   local wibox = misc.use('wibox')

   function focusNext()
      awful.client.focus.byidx( 1)

      if client.focus then
         client.focus:raise()
      end
   end
   plugin.functions["crappy.functions.global.focusNext"].func = focusNext

   function focusPrev()
      awful.client.focus.byidx(-1)

      if client.focus then
         client.focus:raise()
      end
   end
   plugin.functions["crappy.functions.global.focusPrev"].func = focusPrev

   function focusPrevHist()
      awful.client.focus.history.previous()
      if client.focus then
         client.focus:raise()
      end
   end
   plugin.functions["crappy.functions.global.focusPrevHist"].func = focusPrevHist

   function swapNext()
      awful.client.swap.byidx(  1)
   end
   plugin.functions["crappy.functions.global.swapNext"].func = swapNext

   function swapPrev()
      awful.client.swap.byidx(  -1)
   end
   plugin.functions["crappy.functions.global.swapPrev"].func = swapPrev

   function showMenu()
      shared.mainmenu:show({keygrabber=true})
   end
   plugin.functions["crappy.functions.global.showMenu"].func = showMenu

   function toggleMenu()
      shared.mainmenu:toggle()
   end
   plugin.functions["crappy.functions.global.toggleMenu"].func = toggleMenu
   plugin.functions["crappy.functions.menu.toggle"].func = toggleMenu -- Old name

   function focusNextScreen()
      awful.screen.focus_relative( 1)
   end
   plugin.functions["crappy.functions.global.focusNextScreen"].func = focusNextScreen

   function focusPrevScreen()
      awful.screen.focus_relative( 1)
   end
   plugin.functions["crappy.functions.global.focusPrevScreen"].func = focusPrevScreen

   function spawnTerminal()
      awful.util.spawn(crappy.config.settings.terminal)
   end
   plugin.functions["crappy.functions.global.spawnTerminal"].func = spawnTerminal

   function wmfactInc()
      awful.tag.incmwfact( 0.05)
   end
   plugin.functions["crappy.functions.global.wmfactInc"].func = wmfactInc

   function wmfactDec()
      awful.tag.incmwfact( 0.05)
   end
   plugin.functions["crappy.functions.global.wmfactDec"].func = wmfactDec

   function nmasterInc()
      awful.tag.incnmaster( 1)
   end
   plugin.functions["crappy.functions.global.nmasterInc"].func = nmasterInc

   function nmasterDec()
      awful.tag.incnmaster(-1)
   end
   plugin.functions["crappy.functions.global.nmasterDec"].func = nmasterDec

   function ncolInc()
      awful.tag.incncol( 1)
   end
   plugin.functions["crappy.functions.global.ncolInc"].func = ncolInc

   function ncolDec()
      awful.tag.incncol(-1)
   end
   plugin.functions["crappy.functions.global.ncolDec"].func = ncolDec

   function layoutInc()
      awful.layout.inc(shared.layouts,  1)
   end
   plugin.functions["crappy.functions.global.layoutInc"].func = layoutInc

   function layoutDec()
      awful.layout.inc(shared.layouts,  -1)
   end
   plugin.functions["crappy.functions.global.layoutDec"].func = layoutDec

   function showRunPrompt()
      shared.wibox.promptbox[mouse.screen]:run()
   end
   plugin.functions["crappy.functions.global.showRunPrompt"].func = showRunPrompt

   function showLuaPrompt()
      awful.prompt.run({ prompt = "Run Lua code: " },
         shared.wibox.promptbox[mouse.screen].widget,
         awful.util.eval, nil,
         awful.util.getdir("cache") .. "/history_eval")
   end
   plugin.functions["crappy.functions.global.showLuaPrompt"].func = showLuaPrompt
end

return plugin
