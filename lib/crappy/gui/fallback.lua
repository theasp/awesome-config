local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')
local json = require('crappy.JSON')

local fallback = {}

function fallback.buildUi(window, settings, log)
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
      local ok = true
      local errstr

      function json:assert(state, message)
      end

      function json:onDecodeError(message, text, location, etc)
         if text then
            if location then
               message = string.format("%s at char %d", message, location)
            else
               message = string.format("%s", message)
            end
         end

         if etc ~= nil then
            message = message .. " (" .. OBJDEF:encode(etc) .. ")"
         end

         errstr = message
         ok = false

         if self.assert then
            self.assert(false, message)
         else
            assert(false, message)
         end
      end

      newSettings = json:decode(buffer.text)
      print(newSettings)

      if ok and type(newSettings) == 'table' then
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
      else
         if not errstr then
            errstr = "Unkown error decoding JSON"
         end

         log.message("Error: %s", errstr)
         if errstr then
            local dialog = Gtk.MessageDialog {
               transient_for = window,
               destroy_with_parent = true,
               message_type = 'ERROR',
               buttons = 'CLOSE',
               text = "Error:\n" .. errstr,
               on_response = Gtk.Widget.destroy
            }
            dialog:show_all()
         end
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
