local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')
local json = require('despicable.JSON')

local fallback = {}

function fallback.buildUi(settings)
   local settingsJson = json:encode_pretty(settings)
   local buffer = Gtk.TextBuffer {}
   local iter = buffer:get_iter_at_offset(0)
   buffer:insert(iter, settingsJson, -1)
   local textview = Gtk.TextView {
      buffer = buffer,
   }
   textview:override_font(Pango.font_description_from_string('Monospace'))

   local applyButton = Gtk.Button {
      use_stock = true,
      label = Gtk.STOCK_APPLY,
   }

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
            applyButton
         }
      }
   }
end

return fallback
