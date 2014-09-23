local pluginManager = require('crappy.pluginManager')

local configManager = {}

configManager.configver = 0.2

configManager.json = require('crappy.configManager.JSON')

function configManager.new()
   return {
      configver = configManager.configver,
      plugins = {}
   }
end

function configManager.load(file)
   print("Loading configManager file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "r"), "Unable to open file: " .. file)
   local configJson = f:read("*all")
   f:close()

   local config = configManager.json:decode(configJson)

   -- Stupid numbers!
   if tonumber(config.configver) ~= tonumber(configManager.configver) then
      if config.configver then
         print("The configuration in " .. file .. " is not a supported, version " .. config.configver .. ", using default")
      else
         print("The configuration in " .. file .. " is not a supported, using default")
      end
      config = configManager.new()
   end

   return config
end

function configManager.show(config)
   print("JSON:\n" .. configManager.json:encode_pretty(config))
end

function configManager.save(file, config)
   print("Saving configManager file " .. file .. "...")

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
   --local startupList = {}

   -- Loop over the plugins in the config to detect missing plugins,
   -- and generate function based plugins.
   for pluginId, pluginDef in pairs(config.plugins) do
      if not pluginManager.plugins[pluginId] then
         if not config.type or config.type == 'plugin' then
            print("Warning: Mssing plugin " .. pluginId)
         elseif config.type == 'func' then
            pluginManager.makePluginFromFunc(pluginId, pluginDef)
         else
            print("Warning: Unknown plugin type " .. startupDef.type)
         end
      end
   end

end

function configManager.getEnabledPlugins(config)
   local enabledPlugins = {}

   for pluginId, plugin in pairs(pluginManager.plugins) do
      if not (config.plugins[pluginId] and config.plugins[pluginId].enabled and config.plugins[pluginId].enabled == false) then
         table.insert(enabledPlugins, plugin)
      end
   end

   return enabledPlugins
end

return configManager
