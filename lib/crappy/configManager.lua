local lgi = require 'lgi'
local misc = require('crappy.misc')
local pluginManager = require('crappy.pluginManager')

local log = lgi.log.domain('crappy.configManager')

local configManager = {}

configManager.configver = 0.2

configManager.json = require('crappy.JSON')

function configManager.new()
   return {
      configver = configManager.configver,
      plugins = {}
   }
end

function configManager.load(file)
   -- TODO: Error handling
   local f = assert(io.open(file, "r"), "Unable to open file: " .. file)
   local configJson = f:read("*all")
   f:close()

   local config = configManager.json:decode(configJson)
   if not config then
      config = {}
   end

   -- Stupid numbers!
   if tonumber(config.configver) ~= tonumber(configManager.configver) then
      if config.configver then
         log.warning("The configuration in " .. file .. " is not a supported, version " .. config.configver .. ", using default")
      else
         log.warning("The configuration in " .. file .. " is not a supported, using default")
      end
      config = configManager.new()
   end

   return config
end

function configManager.show(config)
   log.message("JSON:\n" .. configManager.json:encode_pretty(config))
end

function configManager.save(file, config)
   -- TODO: Error handling
   local f = assert(io.open(file, "w"), "Unable to open file: " .. file)
   f:write(configManager.json:encode_pretty(config))
   f:close()
end

function configManager.json:onDecodeError(message, text, location, etc)
   if text then
      if location then
         message = string.format("Error reading JSON at char %d: %s", location, message)
      else
         message = string.format("Error reading JSON: %s", message)
      end
   end

   if etc ~= nil then
      message = message .. " (" .. OBJDEF:encode(etc) .. ")"
   end

   if self.assert then
      self.assert(false, message)
   else
      assert(false, message)
   end
end

function configManager.buildFunctionPlugins(config)
   -- Loop over the plugins in the config to detect missing plugins,
   -- and generate function based plugins.
   for pluginId, pluginDef in pairs(config.plugins) do
      if config.type and config.type == 'func' then
         pluginManager.makePluginFromFunc(pluginId, pluginDef)
      end
   end

   return config
end

function configManager.makeFullConfig(config)
   configManager.buildFunctionPlugins(config)

   for pluginId, plugin in pairs(pluginManager.plugins) do
      if not config.plugins[pluginId] then
         config.plugins[pluginId] = {}
      end

      if config.plugins[pluginId].enabled == nil then
         config.plugins[pluginId].enabled = true
      end

      if config.plugins[pluginId].settings == nil then
         config.plugins[pluginId].settings = {}
      end

      if plugin.settingsDefault then
         plugin.settingsDefault(config.plugins[pluginId].settings)
      else
         if plugin.defaults then
            configManager.mergeSettings(config.plugins[pluginId].settings, plugin.defaults)
         end
      end
   end

   return config
end

function configManager.getEnabledPlugins(config)
   local enabledPlugins = {}

   configManager.makeFullConfig(config)

   for pluginId, plugin in pairs(pluginManager.plugins) do
      if config.plugins[pluginId].enabled then
         enabledPlugins[pluginId] = plugin
      end
   end

   return enabledPlugins
end

function configManager.mergeSettings(t1, t2)
   for k, v in pairs(t2) do
      if t1[k] == nil then
         if (type(v) == "table") and (type(t1[k] or false) == "table") then
            misc.mergeTable(t1[k], t2[k])
         else
            t1[k] = v
         end
      end
   end
   return t1
end

return configManager
