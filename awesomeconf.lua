#!/usr/bin/lua

local json = require("crappy.JSON")
local default = require("crappy.default")

function loadConfig(file)
   print("Loading crappy file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "r"), "Unable to open file: " .. file)
   local configJson = f:read("*all")
   f:close()

   return json:decode(configJson)
end


local config = loadConfig("/net/whx/home/phillipsa/.config/awesome/crappy.json")
--local config = loadConfig("~/.config/awesome/crappy.json")

assert(config ~= nil)

print(json:encode_pretty(config))


function json:onDecodeError(message, text, location, etc)
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
