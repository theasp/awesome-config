local plugin = {}

local misc = require('crappy.misc')
local shared = require('crappy.shared')

plugin.name = 'Standard Signals'
plugin.description = 'Set the signals for clients'
plugin.id = 'crappy.startup.signals'
plugin.provides = {"signals"}

function plugin.settingsDefault(settings)
   if settings.manage == nil then
      settings.manage = "crappy.functionsettings.signalsettings.manage"
   end

   if settings.focus == nil then
      settings.focus = "crappy.functionsettings.signalsettings.focus"
   end

   if settings.unfocus == nil then
      settings.unfocus = "crappy.functionsettings.signalsettings.unfocus"
   end

   return settings
end

function plugin.startup(awesomever, settings)
   plugin.settingsDefault(settings)

   if client.connect_signal then
      client.connect_signal("manage", misc.getFunction(settings.manage))
      client.connect_signal("focus", misc.getFunction(settings.focus))
      client.connect_signal("unfocus", misc.getFunction(settings.unfocus))
   else
      client.add_signal("manage", misc.getFunction(settings.manage))
      client.add_signal("focus", misc.getFunction(settings.focus))
      client.add_signal("unfocus", misc.getFunction(settings.unfocus))
   end
end

return plugin
