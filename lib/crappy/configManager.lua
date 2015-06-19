local lgi = require 'lgi'
local Gio = lgi.require('Gio')

local misc = require('crappy.misc')
local serpent = require('crappy.serpent')
local pluginManager = require('crappy.pluginManager')

local log = lgi.log.domain('crappy.configManager')

local configManager = {}

configManager.configver = 1

function configManager.getDefaultFilename()
   local HOME = os.getenv('HOME')
   return HOME .. "/.config/awesome/crappy-config.lua"
end

function configManager.new()
   return {
      configver = configManager.configver,
      plugins = {}
   }
end

function configManager.load(fileName)
   -- TODO: Error handling
   local f = Gio.File.new_for_path(fileName)
   local configText = f:load_contents()

   return configManager.parse(tostring(configText))
end

function configManager.parse(configText)
   -- TODO: Error handling
   local config = configManager.new()
   local ok, res = serpent.load(configText)

   if ok and type(res) == 'table' then
      -- Stupid numbers!
      if tonumber(res.configver) ~= tonumber(configManager.configver) then
         log.warning("The configuration is not a supported, using default")
      else
         config = res
      end
   else
      log.warning("Error parsing configuration, using default: " .. res)
   end

   return config
end

function configManager.show(config)
   log.message("Config:\n" .. serpent.block(config, {comment=false}))
end

function configManager.save(file, config)
   -- TODO: Error handling
   local f = assert(io.open(file, "w"), "Unable to open file: " .. file)
   f:write(serpent.block(config, {comment=false}))
   f:close()

   return true
end

function configManager.buildFunctionPlugins(config)
   -- Loop over the plugins in the config to detect missing plugins,
   -- and generate function based plugins.
   for pluginId, pluginDef in pairs(config.plugins) do
      if pluginDef.type and pluginDef.type == 'func' then
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

      if plugin.mergeDefaults then
         plugin.mergeDefaults(config.plugins[pluginId].settings)
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
