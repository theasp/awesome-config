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

crappy.config = {}
crappy.config.debug = 1
crappy.functions = {}
crappy.shared = require('crappy.shared')

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

   local startupList = configManager.getStartupDefs(crappy.config)
   startupList = pluginManager.sortByDependency(startupList)
   pluginManager.simulateLoad(startupList)

   for k, v in pairs(startupList) do
      if v.func then
         print("Starting " .. v.name)
         v.func(ver, v.settings)
      end
   end

   print("Done initializing crappy.")
end

return crappy
