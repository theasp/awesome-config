local pluginManager = require('crappy.pluginManager')

local startup = {}

local shared = require('crappy.shared')

-- Start configuring awesome by iterating over
-- crappy.startup.functions.
function startup.awesome(awesomever)
   pluginManager.loadAllPlugins()

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
      if startupDef.enabled == nil or startupDef.enabled then
         if not startupDef.settings then
            startupDef.settings = {}
         end

         if startupDef.plugin then
            local plugin = pluginManager.plugins[startupDef.plugin]
            if plugin then
               plugin.startup(awesomever, startupDef.settings)
            else
               print("Warning: Unable to find startup plugin " .. startupDef.plugin)
            end
         elseif startupDef.func then
            local func = crappy.misc.getFunction(startupDef.func)
            if func then
               crappy.misc.getFunction(startupDef.func)(startupDef.settings)
            else
               print("Warning: Unable to find startup function " .. startupDef.func)
            end
         else
            print("Warning: No startup plugin or function defined")
         end
      end
   end
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
            if rule.properties.screen ~= nil and shared.tags[rule.properties.screen] ~= nil then
               rule.properties.tag = shared.tags[rule.properties.screen][rule.properties.tag]
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
   return shared.launcher
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
