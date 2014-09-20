-- TODO:
-- Error checking

local util = require('awful.util')
local pluginManager = require('crappy.pluginManager')
local configManager = require('crappy.configManager')
local shared = require('crappy.shared')

local crappy = {}

crappy.ezconfig = require('crappy.ezconfig')
crappy.misc = require('crappy.misc')
crappy.default = configManager.default

local ver = awesome.version:match('%d.%d'):gsub('%.', '-')

crappy.startup = require('crappy.startup-' .. ver)
crappy.functions = require('crappy.functions-' .. ver)

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

   crappy.default.settings(crappy.config.settings)

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

   print("Done initializing crappy.")
end

return crappy
