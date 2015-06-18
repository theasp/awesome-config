-- TODO:
-- Error checking

local pluginManager = require('crappy.pluginManager')
local configManager = require('crappy.configManager')
local functionManager = require('crappy.functionManager')
local misc = require('crappy.misc')
local lgi = require('lgi')
local log = lgi.log.domain('crappy')

-- The following need to be global
awful = misc.use('awful')
beautiful = misc.use('beautiful')
naughty = misc.use('naughty')
crappy = {}

local ver = tonumber(awesome.version:match('%d.%d'))

crappy.config = {}
crappy.config.debug = 1
crappy.functions = {}
crappy.shared = require('crappy.shared')

function crappy.start(file)
   log.message("Initializing")

   if file == nil then
      file = configManager.getDefaultFilename()
   end

   crappy.config = configManager.load(file)
   pluginManager.loadAllPlugins()

   local enabledPlugins = configManager.getEnabledPlugins(crappy.config)
   local startupList = pluginManager.sortByDependency(enabledPlugins)
   pluginManager.simulateLoad(startupList)

   for k, plugin in ipairs(startupList) do
      if plugin.startup then
         local settings = {}
         if crappy.config.plugins[plugin.id] then
            settings = crappy.config.plugins[plugin.id].settings
         end

         log.message("Starting " .. plugin.name .. " (" .. plugin.id .. ")")
         plugin.startup(ver, settings)
      end
   end

   log.message("Done initializing crappy.")
end

return crappy
