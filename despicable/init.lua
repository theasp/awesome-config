local despicable = {}

despicable.configver = 0.1

despicable.json = require('despicable.JSON')
despicable.default = require('despicable.default')

function despicable.new()
   local config = despicable.default.config()
   config.configver = despicable.configver
   return config
end

function despicable.load(file)
   print("Loading despicable file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "r"), "Unable to open file: " .. file)
   local configJson = f:read("*all")
   f:close()

   local config = despicable.json:decode(configJson)

   -- Stupid numbers!
   if tonumber(config.configver) ~= tonumber(despicable.configver) then
      if config.configver then
         print("The configuration in " .. file .. " is not a supported, version " .. config.configver .. ", using default")
      else
         print("The configuration in " .. file .. " is not a supported, using default")
      end
      config = despicable.default.config()
      config.configver = despicable.configver
   end

   return config
end

function despicable.show(config)
   print("JSON:\n" .. despicable.json:encode_pretty(config))
end

function despicable.save(file, config)
   print("Saving despicable file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "w"), "Unable to open file: " .. file)
   f:write(despicable.json:encode_pretty(config))
   f:close()
end

function despicable.json:onDecodeError(message, text, location, etc)
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

return despicable
