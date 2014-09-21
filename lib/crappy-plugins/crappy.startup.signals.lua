local plugin = {}

local functionManager = require('crappy.functionManager')
local shared = require('crappy.shared')

plugin.name = 'Signals'
plugin.description = 'Set the signals for clients'
plugin.id = 'crappy.startup.signals'
plugin.provides = {"signals"}

function plugin.settingsDefault(settings)
   if settings.manage == nil then
      settings.manage = "crappy.functions.signals.manage"
   end

   if settings.focus == nil then
      settings.focus = "crappy.functions.signals.focus"
   end

   if settings.unfocus == nil then
      settings.unfocus = "crappy.functions.signals.unfocus"
   end

   return settings
end

function plugin.startup(awesomever, settings)
   plugin.settingsDefault(settings)

   if client.connect_signal then
      client.connect_signal("manage", functionManager.getFunction(settings.manage))
      client.connect_signal("focus", functionManager.getFunction(settings.focus))
      client.connect_signal("unfocus", functionManager.getFunction(settings.unfocus))
   else
      client.add_signal("manage", functionManager.getFunction(settings.manage))
      client.add_signal("focus", functionManager.getFunction(settings.focus))
      client.add_signal("unfocus", functionManager.getFunction(settings.unfocus))
   end
end

return plugin
