local plugin = {}

plugin.name = 'Beautiful Theme'
plugin.description = 'Set the theme used by beautiful'
plugin.id = 'crappy.startup.theme'
plugin.provides = {"theme"}

function plugin.settingsDefault(settings)
   if settings.file == nil then
      settings.file = "/usr/share/awesome/themes/default/theme.lua"
   end

   if settings.font == nil then
      settings.font = ''
   end

   return settings
end

function plugin.startup(awesomever, settings)
   local beautifulTmp
   if (awesomever == 3.4) then
      require("beautiful")
      beautifulTmp = beautiful
   else
      beautifulTmp = require("beautiful")
   end
   local beautiful = beautifulTmp

   plugin.settingsDefault(settings)

   beautiful.init(settings.file)

   if settings.font ~= '' then
      awesome.font = settings.font
      beautiful.get().font = settings.font
   end
end

function plugin.buildUi(window, settings)
   local lgi = require 'lgi'
   local Gtk = lgi.require('Gtk')

   local log = lgi.log.domain('awesome-config.startup/plugin/' .. plugin.id)
   
   local fileEntry = Gtk.Entry {
      text = settings.file,
      expand = true
   }

   function fileEntry:on_changed()
      settings.file = fileEntry:get_text()
   end

   local fontEntry = Gtk.Entry {
      text = settings.font,
      expand = true
   }

   function fontEntry:on_changed()
      settings.font = fontEntry:get_text()
   end


   local row = -1;
   local function nextRow()
      row = row + 1
      return row
   end

   return Gtk.ScrolledWindow {
      shadow_type = 'ETCHED_IN',
      expand = true,

      Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         expand = true,
         valign = 'START',
         
         Gtk.Grid {
            row_spacing = 6,
            column_spacing = 6,
            margin = 6,
            expand = true,

            {
               left_attach = 0, top_attach = nextRow(),
               Gtk.Label {
                  label = '_Theme File:',
                  use_underline = true,
                  mnemonic_widget = fileEntry
               },
            },
            {
               left_attach = 1, top_attach = row,
               fileEntry
            },
            {
               left_attach = 0, top_attach = nextRow(),
               Gtk.Label {
                  label = '_Font Override:',
                  use_underline = true,
                  mnemonic_widget = fontEntry
               },
            },
            {
               left_attach = 1, top_attach = row,
               fontEntry
            }

         }
      }
   }
end

return plugin
