local startup = {}

function startup.layoutRefs ()
   crappy.config.layoutRefs = {}

   for i, layoutName in ipairs(crappy.config.layouts) do
      print("Adding layout " .. layoutName)
      crappy.config.layoutRefs[i] = crappy.misc.getFunction(layoutName)
   end
end

function startup.theme ()
   print("Initializing crappy theme...")

   beautiful.init(crappy.config.theme.file)

   awesome.font = crappy.config.theme.font
   beautiful.get().font = crappy.config.theme.font
end

function startup.tags ()
   print("Initializing crappy tags...")

   crappy.tags = {}

   for s = 1, screen.count() do
      local screenSettings = crappy.config.screens.default;

      if (type(crappy.config.screens[tostring(s)]) or false) == "table" then
         screenSettings = crappy.misc.mergeTable(screenSettings, crappy.config.screens[tostring(s)])
      end

      if s == screen.count() and (type(crappy.config.screens.last) or false) == "table" then
         screenSettings = crappy.misc.mergeTable(screenSettings, crappy.config.screens.last)
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

function startup.menu ()
   print("Initializing crappy menu...")

   local myawesomemenu = {
      { "manual", crappy.config.terminal .. " -e man awesome" },
      { "edit config", crappy.config.editor .. " " .. awful.util.getdir("config") .. "/rc.lua" },
      { "restart", awesome.restart },
      { "quit", awesome.quit }
   }

   crappy.mainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                       { "Debian", debian.menu.Debian_menu.Debian },
                                       { "open terminal", crappy.config.terminal }
   }
                                 })

   crappy.launcher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                               menu = crappy.mainmenu })
end

function startup.bindings ()
   print("Initializing crappy bindings...")
   assert(crappy.config.modkey ~= nil)
   assert(crappy.config.terminal ~= nil)
   assert(crappy.mainmenu ~= nil)
   assert(crappy.config.layoutRefs ~= nil)
   assert(crappy.config.buttons.root ~= nil)
   assert(crappy.config.keys.global ~= nil)
   assert(crappy.config.keys.client ~= nil)
   assert(crappy.config.buttons.client ~= nil)

   local rootButtons = {}
   for k, v in pairs(crappy.config.buttons.root) do
      table.insert(rootButtons, crappy.ezconfig.btn(k, crappy.misc.getFunction(v), awful.button))
   end
   root.buttons(awful.util.table.join(unpack(rootButtons)))

   local globalKeys = {}
   for k, v in pairs(crappy.config.keys.global) do
      table.insert(globalKeys, crappy.ezconfig.key(k, crappy.misc.getFunction(v), awful.key))
   end
   root.keys(awful.util.table.join(unpack(globalKeys)))

   local clientKeys = {}
   for k, v in pairs(crappy.config.keys.client) do
      table.insert(clientKeys, crappy.ezconfig.btn(k, crappy.misc.getFunction(v), awful.key))
   end
   crappy.clientkeys = awful.util.table.join(unpack(clientKeys))

   local clientButtons = {}
   for k, v in pairs(crappy.config.buttons.client) do
      table.insert(clientButtons, crappy.ezconfig.btn(k, crappy.misc.getFunction(v), awful.button))
   end
   crappy.clientbuttons = awful.util.table.join(unpack(clientButtons))
end

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
                       keys = crappy.clientkeys,
                       size_hints_honor = false,
                       buttons = crappy.clientbuttons } }}

   table.foreach(crappy.config.rules, function(i,v) table.insert(rules,v) end)

   awful.rules.rules = rules
end

return startup
