-- TODO:
-- Error checking

local util = require('awful.util')
local pluginManager = require('crappy.pluginManager')
local configManager = require('crappy.configManager')
local default = require('crappy.configManager.default')
local misc = require('crappy.misc')

-- The following need to be global
awful = misc.use('awful')

local crappy = {}

local ver = awesome.version:match('%d.%d'):gsub('%.', '-')

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

   default.settings(crappy.config.settings)

   -- Iterate over the list of functions of start
   for i, startupDef in ipairs(crappy.config.startup) do
      if startupDef.enabled == nil or startupDef.enabled then
         if not startupDef.settings then
            startupDef.settings = {}
         end

         if startupDef.plugin then
            local plugin = pluginManager.plugins[startupDef.plugin]
            if plugin then
               print("Initializing plugin: " .. plugin.name .. " (" .. plugin.id .. ")")
               plugin.startup(ver, startupDef.settings)
            else
               print("Warning: Unable to find startup plugin " .. startupDef.plugin)
            end
         elseif startupDef.func then
            local func = misc.getFunction(startupDef.func)
            if func then
               print("Initializing function: " .. startupDef.func)
               func(startupDef.settings)
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
