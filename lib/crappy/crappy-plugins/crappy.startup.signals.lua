local lgi = require('lgi')
local functionManager = require('crappy.functionManager')
local shared = require('crappy.shared')

local plugin = {
   name = 'Signals',
   description = 'Set the signals for clients',
   id = 'crappy.startup.signals',
   requires = {"crappy.functions.signals"},
   provides = {}
}

local log = lgi.log.domain(plugin.id)

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

function plugin.buildUi(window, settings)
   local Gtk = lgi.require('Gtk')
   local widgets = require('crappy.gui.widgets')

   local valid = functionManager.getFunctionsForClass('signal')
   table.sort(valid)

   local manageComboBox = widgets.functionComboBox(valid, settings.manage)
   function manageComboBox:on_changed()
      local entry = self:get_child()
      settings.manage = entry:get_text()
   end

   local focusComboBox = widgets.functionComboBox(valid, settings.focus)
   function focusComboBox:on_changed()
      local entry = self:get_child()
      settings.focus = entry:get_text()
   end

   local unfocusComboBox = widgets.functionComboBox(valid, settings.unfocus)
   function unfocusComboBox:on_changed()
      local entry = self:get_child()
      settings.unfocus = entry:get_text()
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
         Gtk.Label {
            label = '_Manage Signal:',
            halign = 'END',
            use_underline = true,
            mnemonic_widget = manageComboBox
         },
      },
      {
         left_attach = 1, top_attach = row,
         manageComboBox
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = '_Focus Signal:',
            halign = 'END',
            use_underline = true,
            mnemonic_widget = focusComboBox
         },
      },
      {
         left_attach = 1, top_attach = row,
         focusComboBox
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = '_Unfocus Signal:',
            halign = 'END',
            use_underline = true,
            mnemonic_widget = unfocusComboBox
         },
      },
      {
         left_attach = 1, top_attach = row,
         unfocusComboBox
      },
   }
end


return plugin
