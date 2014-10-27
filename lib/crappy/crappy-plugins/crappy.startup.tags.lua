local lgi = require('lgi')
local functionManager = require('crappy.functionManager')

local plugin = {
   name = 'Tags'
   description = 'Tags'
   id = 'crappy.startup.tags'
   provides = {'crappy.shared.tags', 'crappy.startup.tags'}
}
local log = lgi.log.domain(plugin.id)

function plugin.settingsDefault(settings)
   if settings.default == nil then
      settings.default = {}
   end

   if settings.default.tags == nil then
      settings.default.tags = {1, 2, 3, 4, 5, 6, 7, 8, 9}
   end

   if settings.default.layout == nil then
      settings.default.layout = 'awful.layout.suit.fair'
   end

   return s
end

-- Set up the tags table
function plugin.startup(awesomever, settings)
   local misc = require('crappy.misc')
   local shared = require('crappy.shared')
   local awful = misc.use('awful')

   shared.tags = {}

   for s = 1, screen.count() do
      sName = tostring(s)
      -- Start with the "default" settings
      local screenSettings = {}
      misc.mergeTable(screenSettings, settings.default);

      -- If this is the last screen, apply the "last" settings
      if s == screen.count() and settings.last then
         screenSettings = misc.mergeTable(screenSettings, settings.last)
      end

      -- Finally apply the specific screen settings, using the number
      -- or string to deal with how it is stored in the config
      for k, v in pairs(settings) do
         if tostring(k) == sName then
            screenSettings = misc.mergeTable(screenSettings, v)
         end
      end

      shared.tags[s] = awful.tag(screenSettings.tags, s, functionManager.getFunction(screenSettings.layout))

      if screenSettings.tagLayout then
         for tagName, tagLayout in pairs(screenSettings.tagLayout) do
            -- Lua is weird with strings being numbers and tables
            local tagNum = tonumber(tagName)
            tagName = tostring(tagName)
            if shared.tags[s][tagNum] then
               tagName = tagNum
            end

            if shared.tags[s][tagName] then
               awful.layout.set(functionManager.getFunction(tagLayout), shared.tags[s][tagName])
            end
         end
      end
   end
end

return plugin
