local startup = {}

-- This table can be modified to allow further modification by the
-- user or other packages.  Uses strings so that it's easily readable
-- to position other startup functions outside of crappy.
startup.functions = {"crappy.startup.theme",
                     "crappy.startup.tags",
                     "crappy.startup.menu",
                     "crappy.startup.signals",
                     "crappy.startup.bindings",
                     "crappy.startup.rules",
                     "crappy.startup.wibox"}

-- Start configuring awesome by iterating over
-- crappy.startup.functions.
function startup.awesome ()
   -- Need to convert the layout functions from strings to actual
   -- functions.  This is used in in the functions to switch between
   -- layouts.
   crappy.layouts = {}

   for i, layoutName in ipairs(crappy.config.layouts) do
      print("Adding layout " .. layoutName)
      crappy.layouts[i] = crappy.misc.getFunction(layoutName)
   end

   -- Iterate over the list of functions ot start
   for i, startupFunction in ipairs(crappy.startup.functions) do
      crappy.misc.getFunction(startupFunction)()
   end
end

-- Initialize beautiful
function startup.theme ()
   print("Initializing crappy theme...")

   beautiful.init(crappy.config.theme.file)

   if crappy.config.theme.font ~= nil then
      awesome.font = crappy.config.theme.font
      beautiful.get().font = crappy.config.theme.font
   end
end

-- Set up the tags table
function startup.tags ()
   print("Initializing crappy tags...")

   crappy.tags = {}

   for s = 1, screen.count() do
      -- Start with the "default" settings
      local screenSettings = crappy.config.screens.default;

      -- If this is the last screen, apply the "last" settings
      if s == screen.count() and (type(crappy.config.screens.last) or false) == "table" then
         screenSettings = crappy.misc.mergeTable(screenSettings, crappy.config.screens.last)
      end

      -- Finally apply the specific screen settings
      if (type(crappy.config.screens[tostring(s)]) or false) == "table" then
         screenSettings = crappy.misc.mergeTable(screenSettings, crappy.config.screens[tostring(s)])
      end

      crappy.tags[s] = awful.tag(screenSettings.tags, s, crappy.misc.getFunction(screenSettings.defaultLayout))

      if screenSettings.tagSettings ~= nil then
         for tagName, tagSettings in pairs(screenSettings.tagSettings) do
            if crappy.tags[s][nagName] ~= nil and tagSettings.layout ~= nil then
               awful.layout.set(crappy.misc.getFunction(tagSettings.layout), crappy.tags[s][tagName])
            end
         end
      end
   end
end

-- Build a menu table for awful to work with
local function buildMenuTable (menu)
   local m = {}

   for i, entry in ipairs(menu) do
      local e = {}

      print("Making menu item " .. entry.name)

      table.insert(e, entry.name)

      if entry.table ~= nil then
         table.insert(e, buildMenuTable(entry.table))
      elseif entry.result ~= nil then
         table.insert(e, crappy.misc.getFunction(entry.result)())
      elseif entry.func ~= nil then
         table.insert(e, crappy.misc.getFunction(entry.func))
      elseif entry.string ~= nil then
         table.insert(e, entry.string)
      else
         print("Unknown menu type!")
         table.insert(e, nil)
      end

      if entry.iconresult ~= nil then
         table.insert(e, crappy.misc.getFunction(entry.iconresult)())
      elseif entry.iconfile ~= nil then
         table.insert(e, entry.iconfile)
      else
         table.insert(e, nil)
      end

      table.insert(m, e)
   end

   return m
end

-- Set up the menu
function startup.menu ()
   print("Initializing crappy menu...")

   local menu = buildMenuTable(crappy.config.menu)
   crappy.mainmenu = awful.menu({ items = menu })

   crappy.launcher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                             menu = crappy.mainmenu })
end

-- Set up the key/mouse bindings
function startup.bindings ()
   print("Initializing crappy bindings...")
   assert(crappy.config.modkey ~= nil)
   assert(crappy.config.terminal ~= nil)
   assert(crappy.mainmenu ~= nil)
   assert(crappy.layouts ~= nil)
   assert(crappy.config.buttons.root ~= nil)
   assert(crappy.config.keys.global ~= nil)
   assert(crappy.config.keys.client ~= nil)
   assert(crappy.config.buttons.client ~= nil)

   local rootButtons = {}
   for k, v in pairs(crappy.config.buttons.root) do
      local f = crappy.misc.getFunction(v)
      if f ~= nil then
         print("Adding root button " .. k .. " -> " .. v)
         table.insert(rootButtons, crappy.ezconfig.btn(k, f, awful.button))
      else
         print("Not adding root button " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   root.buttons(awful.util.table.join(unpack(rootButtons)))

   local globalKeys = {}
   for k, v in pairs(crappy.config.keys.global) do
      local f = crappy.misc.getFunction(v)
      if f ~= nil then
         print("Adding global key " .. k .. " -> " .. v)
         table.insert(globalKeys, crappy.ezconfig.key(k, f, awful.key))
      else
         print("Not adding global key " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   root.keys(awful.util.table.join(unpack(globalKeys)))

   local clientKeys = {}
   for k, v in pairs(crappy.config.keys.client) do
      local f = crappy.misc.getFunction(v)
      if f ~= nil then
         print("Adding client key " .. k .. " -> " .. v)
         table.insert(clientKeys, crappy.ezconfig.key(k, f, awful.key))
      else
         print("Not adding client key " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   crappy.clientkeys = awful.util.table.join(unpack(clientKeys))

   local clientButtons = {}
   for k, v in pairs(crappy.config.buttons.client) do
      local f = crappy.misc.getFunction(v)
      if f ~= nil then
         print("Adding client button " .. k .. " -> " .. v)
         table.insert(clientButtons, crappy.ezconfig.btn(k, f, awful.button))
      else
         print("Not adding client button " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   crappy.clientbuttons = awful.util.table.join(unpack(clientButtons))
end

-- Set up the client rules
function startup.rules ()
   print("Initializing crappy rules...")

   assert(crappy.clientkeys ~= nil)
   assert(crappy.clientbuttons ~= nil)

   local rules = {
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = true,
                       maximized_vertical   = false,
                       maximized_horizontal = false,
                       size_hints_honor = false,
                       keys = crappy.clientkeys,
                       buttons = crappy.clientbuttons } }}

   for i,rule in ipairs(crappy.config.rules) do
      if rule.properties ~= nil then
         -- As we need to find a reference to the tag, use tag and screen
         -- to find it.  If tag is supplied without screen, set it to nil.
         if rule.properties.tag ~= nil then
            if rule.properties.screen ~= nil and crappy.tags[rule.properties.screen] ~= nil then
               rule.properties.tag = crappy.tags[rule.properties.screen][rule.properties.tag]
            else
               rule.properties.tag = nil
            end
         end
      end

      if rule.callback ~= nil then
         rule.callback = crappy.misc.getFunction(rule.callback)
      end

      table.insert(rules, rule)
   end

   awful.rules.rules = rules
end

startup.widget = {}


function startup.widget.launcher(s)
   return crappy.launcher
end

function startup.widget.prompt(s)
   if crappy.wibox.promptbox[s] == nil then
      crappy.wibox.promptbox[s] = awful.widget.prompt()
   end

   return crappy.wibox.promptbox[s]
end

function startup.widget.systray(s)
   if crappy.wibox.systray == nil then
      crappy.wibox.systray = wibox.widget.systray()
      return crappy.wibox.systray
   end

   return nil
end

function startup.widget.textclock(s)
   return awful.widget.textclock()
end

function startup.widget.layout(s)
   local layoutbox = awful.widget.layoutbox(s)
   layoutbox:buttons(awful.util.table.join(
                         awful.button({ }, 1, crappy.functions.global.layoutInc),
                         awful.button({ }, 3, crappy.functions.global.layoutDec),
                         awful.button({ }, 4, crappy.functions.global.layoutInc),
                         awful.button({ }, 5, crappy.functions.global.layoutDec)))
   return layoutbox
end


return startup
