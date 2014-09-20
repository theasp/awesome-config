local configManager = {}

configManager.configver = 0.1

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

return configManager
