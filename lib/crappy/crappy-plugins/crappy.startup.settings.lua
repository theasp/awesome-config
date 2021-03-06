local configManager = require("crappy.configManager")
local shared = require("crappy.shared")

local plugin = {
   id = 'crappy.startup.settings',
   name = 'Settings',
   description = "Settings that don't belong anywhere else",
   author = 'Andrew Phillips <theasp@gmail.com>',
   requires = {},
   provides = {"crappy.shared.settings.titlebar", "crappy.shared.settings.sloppyfocus", "crappy.shared.settings.terminal", "crappy.shared.settings.editor", "crappy.shared.settings"},
   options = {
      {
         name = 'terminal',
         label = "Te_rminal Emulator:",
         type = "string"
      },
      {
         name = 'editor',
         label = "_Editor:",
         type = "string"
      },
      {
         name = 'titlebar',
         label = "Show _Titlebar",
         type = "boolean"
      },
      {
         name = 'sloppyfocus',
         label = "_Sloppy Focus",
         type = "boolean"
      }
   },
   defaults = {
      terminal = "x-terminal-emulator",
      titlebar = true,
      sloppyfocus = true
   }
}

function plugin.mergeDefaults(settings)
   configManager.mergeSettings(settings, plugin.defaults)

   if settings.editor == nil then
      local editor = os.getenv("EDITOR") or "editor"
      settings.editor = settings.terminal .. " -e " .. editor
   end

   return settings
end

function plugin.startup(awesomever, settings)
   shared.settings = settings
end

return plugin
