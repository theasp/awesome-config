local startup = {}

-- Start configuring awesome by iterating over
-- crappy.startup.functions.
function startup.awesome()
   -- Need to convert the layout functions from strings to actual
   -- functions.  This is used in in the functions to switch between
   -- layouts.

   print(crappy.misc.dump(crappy.config))
   
   if crappy.config.settings == nil then
      crappy.config.settings = {}
   end

   crappy.default.settings(crappy.config.settings)

   crappy.layouts = {}

   for i, layoutName in ipairs(crappy.config.settings.layouts) do
      print("Adding layout " .. layoutName)
      crappy.layouts[i] = crappy.misc.getFunction(layoutName)
   end

   -- Iterate over the list of functions of start
   for i, startupDef in ipairs(crappy.config.startup) do
      if startupDef.enabled == nil or startupDef then
         if (startupDef.func ~= nil) then
            if (startupDef.settings == nil) then
               startupDef.settings = {}
            end
   
            crappy.misc.getFunction(startupDef.func)(startupDef.settings)
         else
            print("Warning: No startup function defined")
         end
      end
   end
end

-- Initialize beautiful
function startup.theme(settings)
   print("Initializing crappy theme...")

   crappy.default.startup.theme(settings)

   beautiful.init(settings.file)

   if settings.font ~= nil then
      awesome.font = settings.font
      beautiful.get().font = settings.font
   end
end

-- Set up the tags table
function startup.tags(settings)
   print("Initializing crappy tags...")
   
   crappy.default.startup.tags(settings)

   crappy.tags = {}

   for s = 1, screen.count() do
      -- Start with the "default" settings
      local screenSettings = settings.default;

      -- If this is the last screen, apply the "last" settings
      if s == screen.count() and settings.last ~= nil then
         screenSettings = crappy.misc.mergeTable(screenSettings, settings.last)
      end

      -- Finally apply the specific screen settings
      if settings[tostring(s)] ~= nil then
         screenSettings = crappy.misc.mergeTable(screenSettings, settings[tostring(s)])
      end

      crappy.tags[s] = awful.tag(screenSettings.tags, s, crappy.misc.getFunction(screenSettings.layout))

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
local function buildMenuTable(menu)
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
function startup.menu(settings)
   print("Initializing crappy menu...")

   crappy.default.startup.menu(settings)

   local menu = buildMenuTable(settings)
   crappy.mainmenu = awful.menu({ items = menu })

   crappy.launcher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                             menu = crappy.mainmenu })
end

-- Set up the key/mouse bindings
function startup.bindings(settings)
   print("Initializing crappy bindings...")

   settings = crappy.default.startup.bindings(settings)

   assert(crappy.config.settings.terminal ~= nil)
   assert(crappy.mainmenu ~= nil)
   assert(crappy.layouts ~= nil)

   crappy.ezconfig.modkey = settings.modkey

   local rootButtons = {}
   for k, v in pairs(settings.buttons.root) do
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
   for k, v in pairs(settings.keys.global) do
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
   for k, v in pairs(settings.keys.client) do
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
   for k, v in pairs(settings.buttons.client) do
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
function startup.rules(settings)
   print("Initializing crappy rules...")

   crappy.default.startup.rules(settings)

   assert(crappy.clientkeys ~= nil)
   assert(crappy.clientbuttons ~= nil)

   local rules = {
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       maximized_vertical   = false,
                       maximized_horizontal = false,
                       size_hints_honor = false,
                       keys = crappy.clientkeys,
                       buttons = crappy.clientbuttons } }}

   for i,rule in ipairs(settings) do
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
