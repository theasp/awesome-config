local plugin = {}

local misc = require('crappy.misc')
local pluginManager = require("crappy.pluginManager")

plugin.name = 'Global Functions'
plugin.description = 'Functions that are used globally'
plugin.id = 'crappy.functions.global'
plugin.requires = {}
plugin.provides = {}
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
   local crappy = require('crappy')

   if not crappy.functions.global then
      crappy.functions.global = {}
   end

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
      awful.client.swap.byidx(  -1)
   end

   function crappy.functions.global.showMenu()
      crappy.shared.mainmenu:show({keygrabber=true})
   end

   function crappy.functions.global.toggleMenu()
      crappy.shared.mainmenu:toggle()
   end

   -- Old name
   if not crappy.functions.menu then
      crappy.functions.menu = {}
   end
   crappy.functions.menu.toggle = crappy.functions.global.toggleMenu

   function crappy.functions.global.focusNextScreen()
      awful.screen.focus_relative( 1)
   end

   function crappy.functions.global.focusPrevScreen()
      awful.screen.focus_relative( 1)
   end

   function crappy.functions.global.spawnTerminal()
      awful.util.spawn(crappy.shared.settings.terminal)
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
      awful.layout.inc(crappy.shared.layouts,  1)
   end

   function crappy.functions.global.layoutDec()
      awful.layout.inc(crappy.shared.layouts,  -1)
   end

   function crappy.functions.global.showRunPrompt()
      crappy.shared.wibox.promptbox[mouse.screen]:run()
   end

   function crappy.functions.global.showLuaPrompt()
      awful.prompt.run({ prompt = "Run Lua code: " },
         crappy.shared.wibox.promptbox[mouse.screen].widget,
         awful.util.eval, nil,
         awful.util.getdir("cache") .. "/history_eval")
   end
end

return plugin
