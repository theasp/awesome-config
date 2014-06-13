-- Includes stuff from:
-- https://github.com/gvalkov/dotfiles-awesome/blob/master/rc.lua

-- TODO:
-- Error checking

local util = require('awful.util')

local crappy = {}

crappy.configver = 0.1

crappy.json = require('crappy.JSON')
crappy.ezconfig = require('crappy.ezconfig')
crappy.misc = require('crappy.misc')
crappy.default = require('crappy.default')

local ver = awesome.version:match('%d.%d'):gsub('%.', '-')

crappy.startup = require('crappy.startup-' .. ver)
crappy.functions = require('crappy.functions-' .. ver)

crappy.config = {}
crappy.config.debug = 1

function crappy.start(file)
   print("Initializing crappy...")

   if file == nil then
      file = util.getdir("config") .. "/crappy.json"
   end

   config = crappy.load(file)

   if config.configver ~= crappy.configver then
      print("The configuration in " .. file .. " is not a supported, using default")
      config = crappy.default.config()
   end

   crappy.config = config

   crappy.startup.awesome()

   print("Done initializing crappy.")

   --print(crappy.json:encode_pretty(crappy.config))
end

function crappy.load(file)
   print("Loading crappy file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "r"), "Unable to open file: " .. file)
   local configJson = f:read("*all")
   f:close()

   return crappy.json:decode(configJson)
end

function crappy.json:onDecodeError(message, text, location, etc)
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

return crappy
