local pluginManager = require('crappy.pluginManager')

local configManager = {}

configManager.configver = 0.2

configManager.json = require('crappy.configManager.JSON')
configManager.default = require('crappy.configManager.default')

function configManager.new()
   local config = configManager.default.config()
   config.configver = configManager.configver
   return config
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
      config = configManager.default.config()
      config.configver = configManager.configver
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

function configManager.getStartupDefs(config)
   local startupList = {}

   -- Iterate over the list of plugins/functions
   for i, startupDef in ipairs(config.plugins) do
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

   return startupList
end

return configManager
