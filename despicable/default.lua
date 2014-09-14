local default = {}

function default.settings(s)
   if s.terminal == nil then
      s.terminal = "x-terminal-emulator"
   end

   if s.editor == nil then
      local editor = os.getenv("EDITOR") or "editor"
      s.editor = s.terminal .. " -e " .. editor
   end

   if s.titlebar == nil then
      s.titlebar = true
   end

   if s.sloppyfocus == nil then
      s.sloppyfocus = true
   end

   if s.layouts == nil then
      s.layouts = {
         "awful.layout.suit.floating",
         "awful.layout.suit.tile",
         "awful.layout.suit.tile.left",
         "awful.layout.suit.tile.bottom",
         "awful.layout.suit.tile.top",
         "awful.layout.suit.fair",
         "awful.layout.suit.fair.horizontal",
         "awful.layout.suit.spiral",
         "awful.layout.suit.spiral.dwindle",
         "awful.layout.suit.max",
         "awful.layout.suit.max.fullscreen",
         "awful.layout.suit.magnifier"
      }
   end

   return s
end

default.startup = {}

function default.startup.theme(s)
   if (s.file == nil) then
      s.file = "/usr/share/awesome/themes/default/theme.lua"
   end

   return s
end

function default.startup.tags(s)
   if s.default == nil then
      s.default = {}
   end

   if s.default.tags == nil then
      s.default.tags = {1, 2, 3, 4, 5, 6, 7, 8, 9}
   end

   if s.default.layout == nil then
      s.default.layout = "awful.layout.suit.fair"
   end

   return s
end

function default.startup.menu(s)
   if #s == 0 then
      s = {
         {
            ["name"] = "awesome",
            ["iconresult"] = "function() return beautiful.awesome_icon end",
            ["table"] = {
               {
                  ["name"] = "manual",
                  ["result"] = "function() return crappy.config.settings.terminal .. \" -e man awesome\" end"
               },
               {
                  ["name"] ="edit config",
                  ["result"] = "function() return crappy.config.settings.editor .. ' ' .. awful.util.getdir('config') .. '/rc.lua' end"
               },
               {
                  ["name"] = "restart",
                  ["func"] = "awesome.restart"
               },
               {
                  ["name"] = "quit",
                  ["func"] = "awesome.quit"
               }
            }
         },
         {
            ["name"] = "open terminal",
            ["result"] = "function() return crappy.config.settings.terminal end"
         },
         {
            ["name"] = "firefox",
            ["string"] = "firefox"
         }
      }
   end

   return s
end

function default.startup.bindings(s)
   if s.modkey == nil then
      s.modkey = "Mod4"
   end

   if s.altkey == nil then
      s.altkey = "Mod1"
   end

   if s.buttons == nil then
      s.buttons = {}
   end

   if s.buttons.root == nil then 
      s.buttons.root = {
         ["3"] = "crappy.functions.menu.toggle",
         ["4"] = "awful.tag.viewnext",
         ["5"] = "awful.tag.viewprev"
      }
   end

   if s.buttons.client == nil then
      s.buttons.client = {
         ["1"] = "crappy.functions.client.focus",
         ["2"] = "crappy.functions.client.focus",
         ["3"] = "crappy.functions.client.focus",
         ["M-1"] = "awful.mouse.client.move",
         ["M-3"] = "awful.mouse.client.resize"
      }
   end

   if s.keys == nil then
      s.keys = {}
   end

   if s.keys.global == nil then
      s.keys.global = {
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

   if s.keys.client == nil then
      s.keys.client = {
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

   return s
end

function default.startup.wibox(s)
   if s.position == nil then
      s.position = "bottom"
   end

   if s.widgets == nil then
      s.widgets = {}
   end

   if s.widgets.left == nil then
      s.widgets.left = {
         "crappy.startup.widget.launcher",
         "crappy.startup.widget.taglist",
         "crappy.startup.widget.prompt"
      }
   end

   if s.widgets.middle == nil then
      s.widgets.middle = {
         "crappy.startup.widget.tasklist"
      }
   end

   if s.widgets.right == nil then
      s.widgets.right = {
         --"crappy.startup.widget.systray",
         --"crappy.startup.widget.textclock",
         "crappy.startup.widget.layout"
      }
   end

   return s
end

function default.startup.signals(s)
   if s.manage == nil then
      s.manage = "crappy.functions.signals.manage"
   end

   if s.focus == nil then
      s.focus = "crappy.functions.signals.focus"
   end

   if s.unfocus == nil then
      s.unfocus = "crappy.functions.signals.unfocus"
   end

   return s
end

function default.startup.rules(s)
   if #s == 0 then
      s =  {
         {
            ["rule"] = {
               ["class"] = "MPlayer"
            },
            ["properties"] = {
               ["floating"] = true
            }
         },
         {
            ["rule"] = {
               ["class"] = "pinentry"
            },
            ["properties"] = {
               ["floating"] = true
            }
         }
      }
   end
   
   return s
end

function default.config()
   local settings = default.settings({})
   local startup = {
      {
         ["func"] = "crappy.startup.tags",
         ["settings"] = default.startup.tags({})
      },
      {
         ["func"] = "crappy.startup.theme",
         ["settings"] = default.startup.theme({})
      },
      {
         ["func"] = "crappy.startup.menu",
         ["settings"] = default.startup.menu({})
      },
      {
         ["func"] = "crappy.startup.bindings",
         ["settings"] = default.startup.theme({})
      },
      {
         ["func"] = "crappy.startup.rules",
         ["settings"] = default.startup.signals({})
      },
      {
         ["func"] = "crappy.startup.signals",
         ["settings"] = default.startup.signals({})
      },
      {
         ["func"] = "crappy.startup.wibox",
         ["settings"] = default.startup.wibox({})
      },
   }

   local config = {
      ["settings"] = settings,
      ["startup"] = startup
   }

   return config
end


return default
