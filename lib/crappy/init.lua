-- Includes stuff from:
-- https://github.com/gvalkov/dotfiles-awesome/blob/master/rc.lua

-- TODO:
-- Error checking

local util = require('awful.util')
local despicable = require('despicable')

local crappy = {}

crappy.ezconfig = require('crappy.ezconfig')
crappy.misc = require('crappy.misc')
crappy.default = despicable.default

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

   crappy.config = despicable.load(file)
   crappy.startup.awesome()
   print("Done initializing crappy.")
end

return crappy
