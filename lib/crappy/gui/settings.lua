local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

local configManager = require('crappy.configManager')

local log = lgi.log.domain('awesome-config/settings')

local settings = {}

function settings.buildUi(window, config)
   configManager.default.settings(config.settings)

   local titlebarCheckButton = Gtk.CheckButton {
      label = 'Show _Titlebar',
      use_underline = true,
   }
   titlebarCheckButton:set_active(config.settings.titlebar)

   function titlebarCheckButton:on_toggled()
      config.settings.titlebar = titlebarCheckButton:get_active()
   end

   local sloppyfocusCheckButton = Gtk.CheckButton {
      label = '_Sloppy Focus',
      use_underline = true,
   }

   sloppyfocusCheckButton:set_active(config.settings.sloppyfocus)

   function sloppyfocusCheckButton:on_toggled()
      config.settings.sloppyfocus = sloppyfocusCheckButton:get_active()
   end

   local terminalEntry = Gtk.Entry {
      hexpand = true,
   }

   terminalEntry:set_text(config.settings.terminal)
   function terminalEntry:on_changed()
      config.settings.terminal = terminalEntry:get_text()
   end

   local editorEntry = Gtk.Entry {
      hexpand = true,
   }

   editorEntry:set_text(config.settings.editor)

   function editorEntry:on_changed()
      config.settings.editor = editorEntry:get_text()
   end


   local row = -1;
   local function nextRow()
      row = row + 1
      return row
   end

   return Gtk.ScrolledWindow {
      shadow_type = 'ETCHED_IN',
      margin = 6,
      expand = true,

      Gtk.Grid {
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
               use_underline = true,
               mnemonic_widget = editorEntry
            },
         },
         {
            left_attach = 1, top_attach = row,
            editorEntry
         },
      }
   }
end

return settings
