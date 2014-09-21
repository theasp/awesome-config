-- TODO:
-- Error checking

local util = require('awful.util')
local pluginManager = require('crappy.pluginManager')
local configManager = require('crappy.configManager')
local functionManager = require('crappy.functionManager')
local default = require('crappy.configManager.default')
local misc = require('crappy.misc')

-- The following need to be global
awful = misc.use('awful')
beautiful = misc.use('beautiful')

local crappy = {}

local ver = tonumber(awesome.version:match('%d.%d'))

crappy.functions = require('crappy.functions')

crappy.config = {}
crappy.config.debug = 1

function crappy.start(file)
   print("Initializing crappy...")

   if file == nil then
      file = util.getdir("config") .. "/crappy.json"
   end

   crappy.config = configManager.load(file)
   pluginManager.loadAllPlugins()

   if crappy.config.settings == nil then
      crappy.config.settings = {}
   end

   default.settings(crappy.config.settings)

   local startupList = {}

   -- Iterate over the list of plugins/functions
   for i, startupDef in ipairs(crappy.config.plugins) do
      if startupDef.enabled == nil or startupDef.enabled then
         if not startupDef.settings then
            startupDef.settings = {}
         end

         if not startupDef.provides then
            startupDef.provides = {}
         end

         if not startupDef.requires then
            startupDef.requires = {}
         end

         if startupDef.plugin then
            local plugin = pluginManager.plugins[startupDef.plugin]
            if plugin then
               if plugin.requires then
                  for k, v in ipairs(plugin.requires) do
                     table.insert(startupDef.requires, v)
                  end
               end

               for k, v in ipairs(plugin.provides) do
                  table.insert(startupDef.provides, v)
               end

               table.insert(startupList, {
                               id = plugin.id,
                               plugin = plugin,
                               name = plugin.name .. " (" .. plugin.id .. ")",
                               requires = startupDef.requires,
                               provides = startupDef.provides,
                               func = plugin.startup,
                               settings = startupDef.settings
               })
            else
               print("Warning: Unable to find startup plugin " .. startupDef.plugin)
            end
         elseif startupDef.func then
            local func = functionManager.getFunction(startupDef.func)
            if func then
               table.insert(startupList, {
                               id = startupDef.func,
                               name = startupDef.func,
                               plugin = plugin,
                               requires = startupDef.requires,
                               provides = startupDef.provides,
                               func = func,
                               settings = startupDef.settings
               })
            else
               print("Warning: Unable to find startup function " .. startupDef.func)
            end
         else
            print("Warning: No startup plugin or function defined")
         end
      end
   end

   local ordered = pluginManager.sortByDependency(startupList)
   pluginManager.simulateLoad(ordered)

   for k, v in pairs(ordered) do
      print("Starting " .. v.name)
      v.func(ver, v.settings)
   end

   print("Done initializing crappy.")
end

return crappy
