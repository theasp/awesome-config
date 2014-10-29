local functionManager = require('crappy.functionManager')
local plugin = {
   name = 'Signals',
   description = 'Set the signals for clients',
   id = 'crappy.startup.signals',
   requires = {"crappy.functions.signals"},
   provides = {},
   options = {
      {
         name = 'manage',
         label = "_Manage Signal:",
         type = "function",
         class = "signal"
      },
      {
         name = 'focus',
         label = "_Focus Signal:",
         type = "function",
         class = "signal"
      },
      {
         name = 'unfocus',
         label = "_Unfocus Signal:",
         type = "function",
         class = "signal"
      },
   },
   defaults = {
      manage = "crappy.functions.signals.manage",
      focus = "crappy.functions.signals.focus",
      unfocus = "crappy.functions.signals.unfocus"
   }
}

function plugin.startup(awesomever, settings)
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
