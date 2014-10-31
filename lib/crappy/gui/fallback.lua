local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')
local json = require('crappy.JSON')

local functionManager = require('crappy.functionManager')
local widgets = require('crappy.gui.widgets')

local fallback = {}

function fallback.buildUi(plugin, window, settings)
   local log = lgi.log.domain('crappy.gui.fallback/' .. plugin.id)

   if plugin.options then
      return fallback.buildUiOptions(plugin, window, settings, log)
   else
      return fallback.buildUiJson(window, settings, log)
   end
end

function fallback.buildUiOptions(plugin, window, settings, log)
   local grid = Gtk.Grid {
      row_spacing = 6,
      column_spacing = 6,
      margin = 6,
      expand = true,
   }

   local row = -1;
   local function nextRow()
      row = row + 1
      return row
   end

   for i, def in ipairs(plugin.options) do
      if def.type == 'string' then
         local entry = Gtk.Entry {
            hexpand = true,
         }

         entry:set_text(settings[def.name])

         local label = Gtk.Label {
            label = def.label,
            halign = 'END',
            use_underline = true,
            mnemonic_widget = entry
         }

         function entry:on_changed()
            settings[def.name] = entry:get_text()
         end

         grid:attach(label, 0, nextRow(), 1, 1)
         grid:attach(entry, 1, row, 1, 1)
      end

      if def.type == 'function' then
         local valid = functionManager.getFunctionsForClass(def.class)
         table.sort(valid)

         local comboBox = widgets.functionComboBox(valid, settings[def.name])

         local label = Gtk.Label {
            label = def.label,
            halign = 'END',
            use_underline = true,
            mnemonic_widget = comboBox
         }

         function comboBox:on_changed()
            settings[def.name] = self:get_active_text()
         end

         grid:attach(label, 0, nextRow(), 1, 1)
         grid:attach(comboBox, 1, row, 1, 1)
      end

      if def.type == 'boolean' then
         local checkButton = Gtk.CheckButton {
            label = def.label,
            use_underline = true,
         }

         checkButton:set_active(settings[def.name])

         function checkButton:on_toggled()
            settings[def.name] = checkButton:get_active()
         end

         grid:attach(checkButton, 0, nextRow(), 2, 1)
      end
   end

   -- If there are no options, return nil so a tab isn't created
   if row == -1 then
      return nil
   end

   return grid
end

function fallback.buildUiJson(window, settings, log)
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

   local applyButton = Gtk.Button {
      use_stock = true,
      label = Gtk.STOCK_APPLY,
   }

   local function disableButtons()
      undoButton:set_sensitive(false)
      applyButton:set_sensitive(false)
   end

   local function enableButtons()
      undoButton:set_sensitive(true)
      applyButton:set_sensitive(true)
   end

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

   function buffer:on_changed(modifed)
      enableButtons()
   end

   function undoButton:on_clicked()
      buffer.text = settingsJson
      disableButtons()
   end

   disableButtons()

   return Gtk.Box {
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
end

return fallback
