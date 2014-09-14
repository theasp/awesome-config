local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')
local json = require('despicable.JSON')

local fallback = {}

function fallback.buildUi(settings)
   local settingsJson = json:encode_pretty(settings)
   local buffer = Gtk.TextBuffer {}
   buffer.text = settingsJson

   local textview = Gtk.TextView {
      buffer = buffer,
   }
   textview:override_font(Pango.font_description_from_string('Monospace'))

   local undoButton = Gtk.Button {
      use_stock = true,
      label = Gtk.STOCK_UNDO,
   }

   function undoButton:on_clicked()
      buffer.text = settingsJson
      disableButtons()
   end

   local applyButton = Gtk.Button {
      use_stock = true,
      label = Gtk.STOCK_APPLY,
   }

   function applyButton:on_clicked()
      newSettings = json:decode(buffer.text)

      if newSettings then
         -- Clear the settings table, we want to keep the same
         -- reference
         for k in pairs(settings) do
            settings[k] = nil
         end

         for k, v in pairs(newSettings) do
            settings[k] = v
         end

         settingsJson = json:encode_pretty(settings)
         buffer.text = settingsJson
         disableButtons()
      end
   end

   function disableButtons()
      undoButton:set_sensitive(false)
      applyButton:set_sensitive(false)
   end

   function enableButtons()
      undoButton:set_sensitive(true)
      applyButton:set_sensitive(true)
   end

   function buffer:on_changed(modifed)
      enableButtons()
   end

   disableButtons()

   return Gtk.ScrolledWindow {
      shadow_type = 'ETCHED_IN',
      expand = true,
      Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         margin = 6,
         expand = true,
         Gtk.ScrolledWindow {
            shadow_type = 'ETCHED_IN',
            expand = true,
            textview
         },
         Gtk.Box {
            orientation = 'HORIZONTAL',
            spacing = 6,
            halign = 'END',
            undoButton,
            applyButton
         }
      }
   }
end

return fallback
