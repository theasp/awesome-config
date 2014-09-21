local plugin = {}

plugin.name = 'Tags'
plugin.description = 'Tags'
plugin.id = 'crappy.startup.tags'
plugin.provides = {'tags'}

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

   plugin.settingsDefault(settings)

   shared.tags = {}

   for s = 1, screen.count() do
      -- Start with the "default" settings
      local screenSettings = settings.default;

      -- If this is the last screen, apply the "last" settings
      if s == screen.count() and settings.last ~= nil then
         screenSettings = misc.mergeTable(screenSettings, settings.last)
      end

      -- Finally apply the specific screen settings
      if settings[tostring(s)] ~= nil then
         screenSettings = misc.mergeTable(screenSettings, settings[tostring(s)])
      end

      shared.tags[s] = awful.tag(screenSettings.tags, s, misc.getFunction(screenSettings.layout))
      if screenSettings.tagLayouts ~= nil then
         for tagName, tagLayout in pairs(screenSettings.tagLayouts) do
            if shared.tags[s][tostring(tagName)] ~= nil and tagLayout ~= nil then
               awful.layout.set(misc.getFunction(tagLayout), shared.tags[s][tostring(tagName)])
            end
         end
      end
   end
end

return plugin
