local plugin = {}

local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')
local shared = require('crappy.shared')

plugin.name = 'Bindings'
plugin.description = 'Build standards keybindings'
plugin.id = 'crappy.startup.bindings'
plugin.requires = {"crappy.shared.mainmenu", "crappy.shared.layouts", "crappy.functions.client", "crappy.functions.global"}
plugin.provides = {"crappy.shared.clientkeys", "crappy.shared.clientbuttons"}

function plugin.settingsDefault(settings)
   if settings.modkey == nil then
      settings.modkey = "Mod4"
   end

   if settings.altkey == nil then
      settings.altkey = "Mod1"
   end

   if settings.buttons == nil then
      settings.buttons = {}
   end

   if settings.buttons.root == nil then
      settings.buttons.root = {
         ["3"] = "crappy.functions.menu.toggle",
         ["4"] = "awful.tag.viewnext",
         ["5"] = "awful.tag.viewprev"
      }
   end

   if settings.buttons.client == nil then
      settings.buttons.client = {
         ["1"] = "crappy.functions.client.focus",
         ["2"] = "crappy.functions.client.focus",
         ["3"] = "crappy.functions.client.focus",
         ["M-1"] = "awful.mouse.client.move",
         ["M-3"] = "awful.mouse.client.resize"
      }
   end

   if settings.keys == nil then
      settings.keys = {}
   end

   if settings.keys.global == nil then
      settings.keys.global = {
         ["M-<Left>"] = "awful.tag.viewprev",
         ["M-<Right>"] = "awful.tag.viewnext",
         ["M-<Escape>"] = "awful.tag.history.restore",

         ["M-j"] = "crappy.functions.global.focusNext",
         ["M-k"] = "crappy.functions.global.focusPrev",
         ["M-w"] = "crappy.functions.global.showMenu",
         ["M-<Tab>"] = "crappy.functions.global.focusNext",
         ["M-`"] = "crappy.functions.global.focusPrevHist",

         ["M-S-j"] = "crappy.functions.global.swapNext",
         ["M-S-k"] = "crappy.functions.global.swapPrev",
         ["M-C-j"] = "crappy.functions.global.focusNextScreen",
         ["M-C-k"] = "crappy.functions.global.focusPrevScreen",
         ["M-u"] = "awful.client.urgent.jumpto",

         ["M-<Return>"] = "crappy.functions.global.spawnTerminal",
         ["M-x"] = "crappy.functions.global.spawnTerminal",
         ["M-S-x"] = "crappy.functions.global.spawnTerminal",
         ["M-C-r"] = "awesome.restart",
         ["M-S-q"] = "awesome.quit",

         ["M-l"] = "crappy.functions.global.wmfactInc",
         ["M-h"] = "crappy.functions.global.wmfactDec",
         ["M-S-h"] = "crappy.functions.global.nmasterInc",
         ["M-S-l"] = "crappy.functions.global.nmasterDec",
         ["M-C-h"] = "crappy.functions.global.ncolInc",
         ["M-C-l"] = "crappy.functions.global.ncolDec",
         ["M-<space>"] = "crappy.functions.global.layoutInc",
         ["M-S-<space>"] = "crappy.functions.global.layoutDec",

         ["M-r"] = "crappy.functions.global.showRunPrompt",
         ["M-C-x"] = "crappy.functions.global.showLuaPrompt",

         ["M-<F1>"] = "function() crappy.functions.tag.show(1) end",
         ["M-<F2>"] = "function() crappy.functions.tag.show(2) end",
         ["M-<F3>"] = "function() crappy.functions.tag.show(3) end",
         ["M-<F4>"] = "function() crappy.functions.tag.show(4) end",
         ["M-<F5>"] = "function() crappy.functions.tag.show(5) end",
         ["M-<F6>"] = "function() crappy.functions.tag.show(6) end",
         ["M-<F7>"] = "function() crappy.functions.tag.show(7) end",
         ["M-<F8>"] = "function() crappy.functions.tag.show(8) end",
         ["M-<F9>"] = "function() crappy.functions.tag.show(9) end",

         ["M-C-<F1>"] = "function() crappy.functions.tag.toggle(1) end",
         ["M-C-<F2>"] = "function() crappy.functions.tag.toggle(2) end",
         ["M-C-<F3>"] = "function() crappy.functions.tag.toggle(3) end",
         ["M-C-<F4>"] = "function() crappy.functions.tag.toggle(4) end",
         ["M-C-<F5>"] = "function() crappy.functions.tag.toggle(5) end",
         ["M-C-<F6>"] = "function() crappy.functions.tag.toggle(6) end",
         ["M-C-<F7>"] = "function() crappy.functions.tag.toggle(7) end",
         ["M-C-<F8>"] = "function() crappy.functions.tag.toggle(8) end",
         ["M-C-<F9>"] = "function() crappy.functions.tag.toggle(9) end",

         ["M-S-<F1>"] = "function() crappy.functions.tag.clientMoveTo(1) end",
         ["M-S-<F2>"] = "function() crappy.functions.tag.clientMoveTo(2) end",
         ["M-S-<F3>"] = "function() crappy.functions.tag.clientMoveTo(3) end",
         ["M-S-<F4>"] = "function() crappy.functions.tag.clientMoveTo(4) end",
         ["M-S-<F5>"] = "function() crappy.functions.tag.clientMoveTo(5) end",
         ["M-S-<F6>"] = "function() crappy.functions.tag.clientMoveTo(6) end",
         ["M-S-<F7>"] = "function() crappy.functions.tag.clientMoveTo(7) end",
         ["M-S-<F8>"] = "function() crappy.functions.tag.clientMoveTo(8) end",
         ["M-S-<F9>"] = "function() crappy.functions.tag.clientMoveTo(9) end",

         ["M-S-C-<F1>"] = "function() crappy.functions.tag.clientToggle(1) end",
         ["M-S-C-<F2>"] = "function() crappy.functions.tag.clientToggle(2) end",
         ["M-S-C-<F3>"] = "function() crappy.functions.tag.clientToggle(3) end",
         ["M-S-C-<F4>"] = "function() crappy.functions.tag.clientToggle(4) end",
         ["M-S-C-<F5>"] = "function() crappy.functions.tag.clientToggle(5) end",
         ["M-S-C-<F6>"] = "function() crappy.functions.tag.clientToggle(6) end",
         ["M-S-C-<F7>"] = "function() crappy.functions.tag.clientToggle(7) end",
         ["M-S-C-<F8>"] = "function() crappy.functions.tag.clientToggle(8) end",
         ["M-S-C-<F9>"] = "function() crappy.functions.tag.clientToggle(9) end"
      }
   end

   if settings.keys.client == nil then
      settings.keys.client = {
         ["M-f"] = "crappy.functions.client.fullscreen",
         ["M-S-c"] = "crappy.functions.client.kill",
         ["M-C-<space>"] = "awful.client.floating.toggle",
         ["M-C-<Return>"] = "crappy.functions.client.swapMaster",
         ["M-o"] = "awful.client.movetoscreen",
         ["M-r"] = "crappy.functions.client.redraw",
         ["M-t"] = "crappy.functions.client.ontop",
         ["M-n"] = "crappy.functions.client.minimized",
         ["M-m"] = "crappy.functions.client.maximized"
      }
   end

   return settings
end


function plugin.startup(awesomever, settings)
   local misc = require('crappy.misc')
   local shared = require('crappy.shared')
   local ezconfig = require("crappy.ezconfig")
   local awful = misc.use('awful')

   plugin.settingsDefault(settings)

   assert(crappy.shared.settings.terminal ~= nil)
   assert(shared.mainmenu ~= nil)
   assert(shared.layouts ~= nil)

   ezconfig.modkey = settings.modkey
   ezconfig.altkey = settings.altkey

   local rootButtons = {}
   for k, v in pairs(settings.buttons.root) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --print("Adding root button " .. k .. " -> " .. v)
         table.insert(rootButtons, ezconfig.btn(k, f, awful.button))
      else
         print("Not adding root button " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   root.buttons(awful.util.table.join(unpack(rootButtons)))

   local globalKeys = {}
   for k, v in pairs(settings.keys.global) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --print("Adding global key " .. k .. " -> " .. v)
         table.insert(globalKeys, ezconfig.key(k, f, awful.key))
      else
         print("Not adding global key " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   root.keys(awful.util.table.join(unpack(globalKeys)))

   local clientKeys = {}
   for k, v in pairs(settings.keys.client) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --print("Adding client key " .. k .. " -> " .. v)
         table.insert(clientKeys, ezconfig.key(k, f, awful.key))
      else
         print("Not adding client key " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   shared.clientkeys = awful.util.table.join(unpack(clientKeys))

   local clientButtons = {}
   for k, v in pairs(settings.buttons.client) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --print("Adding client button " .. k .. " -> " .. v)
         table.insert(clientButtons, ezconfig.btn(k, f, awful.button))
      else
         print("Not adding client button " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   shared.clientbuttons = awful.util.table.join(unpack(clientButtons))
end

return plugin
