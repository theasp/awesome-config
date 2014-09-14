local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local Pango = lgi.require('Pango')
local json = require('despicable.JSON')

local fallback = {}

function fallback.buildUi(settings)
   local settingsJson = json:encode_pretty(settings)

   print("Settings:\n" .. settingsJson)

   local buffer = Gtk.TextBuffer {}

   local iter = buffer:get_iter_at_offset(0)
   buffer:insert(iter, settingsJson, -1)

   local textview = Gtk.TextView {
      buffer = buffer,
   }

   textview:override_font(Pango.font_description_from_string('Monospace'))

   return textview
end

return fallback
