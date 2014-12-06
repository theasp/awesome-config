local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

local functionManager = require('crappy.functionManager')
local widgets = require('crappy.gui.widgets')

local fallback = {}

function fallback.buildUi(plugin, window, settings)
   local log = lgi.log.domain('crappy.gui.fallback/' .. plugin.id)

   if plugin.options then
      return fallback.buildUiOptions(plugin, window, settings, log)
   else
      -- Can't generate a UI, just show the JSON editor
      return widgets.jsonEditor(window, settings)
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

return fallback
