local lgi = require('lgi')
local misc = require("crappy.misc")
local shared = require("crappy.shared")

local plugin = {
   name = 'Settings',
   description = "Settings that don't belong anywhere else",
   id = 'crappy.startup.settings',
   requires = {},
   provides = {"crappy.shared.settings.titlebar", "crappy.shared.settings.sloppyfocus", "crappy.shared.settings.terminal", "crappy.shared.settings.editor", "crappy.shared.settings"}
}
local log = lgi.log.domain(plugin.id)

function plugin.settingsDefault(settings)
   if settings.terminal == nil then
      settings.terminal = "x-terminal-emulator"
   end

   if settings.editor == nil then
      local editor = os.getenv("EDITOR") or "editor"
      settings.editor = settings.terminal .. " -e " .. editor
   end

   if settings.titlebar == nil then
      settings.titlebar = true
   end

   if settings.sloppyfocus == nil then
      settings.sloppyfocus = true
   end

   return settings
end

function plugin.startup(awesomever, settings)
   local beautiful = misc.use("beautiful")

   shared.settings = settings
end

function plugin.buildUi(window, settings)
   local Gtk = lgi.require('Gtk')

   local titlebarCheckButton = Gtk.CheckButton {
      label = 'Show _Titlebar',
      use_underline = true,
   }
   titlebarCheckButton:set_active(settings.titlebar)

   function titlebarCheckButton:on_toggled()
      settings.titlebar = titlebarCheckButton:get_active()
   end

   local sloppyfocusCheckButton = Gtk.CheckButton {
      label = '_Sloppy Focus',
      use_underline = true,
   }

   sloppyfocusCheckButton:set_active(settings.sloppyfocus)

   function sloppyfocusCheckButton:on_toggled()
      settings.sloppyfocus = sloppyfocusCheckButton:get_active()
   end

   local terminalEntry = Gtk.Entry {
      hexpand = true,
   }

   terminalEntry:set_text(settings.terminal)
   function terminalEntry:on_changed()
      settings.terminal = terminalEntry:get_text()
   end

   local editorEntry = Gtk.Entry {
      hexpand = true,
   }

   editorEntry:set_text(settings.editor)

   function editorEntry:on_changed()
      settings.editor = editorEntry:get_text()
   end

   local row = -1;
   local function nextRow()
      row = row + 1
      return row
   end

   return Gtk.Grid {
      row_spacing = 6,
      column_spacing = 6,
      margin = 6,
      expand = true,

      {
         left_attach = 0, top_attach = nextRow(),
         titlebarCheckButton
      },

      {
         left_attach = 0, top_attach = nextRow(),
         sloppyfocusCheckButton
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = 'Te_rminal Emulator:',
            halign = 'END',
            use_underline = true,
            mnemonic_widget = terminalEntry
         },
      },
      {
         left_attach = 1, top_attach = row,
         terminalEntry
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = '_Editor:',
            halign = 'END',
            use_underline = true,
            mnemonic_widget = editorEntry
         },
      },
      {
         left_attach = 1, top_attach = row,
         editorEntry
      },
   }
end

return plugin
