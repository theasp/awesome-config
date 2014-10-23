local plugin = {}

local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')

plugin.name = 'wibox'
plugin.description = 'Set up the wibox'
plugin.id = 'crappy.startup.wibox'
plugin.requires = {"crappy.functions.widgets", "crappy.shared.launcher", "crappy.functions.global", "crappy.startup.theme"}
plugin.provides = {"crappy.shared.wibox"}

function plugin.settingsDefault(settings)
   if settings.position == nil then
      settings.position = "bottom"
   end

   if settings.widgets == nil then
      settings.widgets = {}
   end

   if settings.widgets.left == nil then
      settings.widgets.left = {
         "crappy.functions.widgets.launcher",
         "crappy.functions.widgets.taglist",
         "crappy.functions.widgets.prompt"
      }
   end

   if settings.widgets.middle == nil then
      settings.widgets.middle = {
         "crappy.functions.widgets.tasklist"
      }
   end

   if settings.widgets.right == nil then
      settings.widgets.right = {
         "crappy.functions.widgets.systray",
         "crappy.functions.widgets.textclock",
         "crappy.functions.widgets.layout"
      }
   end

   return settings
end


function plugin.startup(awesomever, settings)
   local wibox = misc.use("wibox")
   local shared = require('crappy.shared')

   plugin.settingsDefault(settings)

   shared.wibox = {}
   shared.wibox.promptbox = {}

   for s = 1, screen.count() do
      local layouts = {}
      local mywibox = awful.wibox({ position = settings.position, screen = s, bg = settings.bgcolor })

      for x, side in ipairs({"left", "middle", "right"}) do
         local layout = {}

         -- wibox.layout.fixed.horizontal is 3.5
         if wibox.layout.fixed.horizontal then
            layout = wibox.layout.fixed.horizontal()
         end

         if settings.widgets[side] ~= nil then
            for i, widget in ipairs(settings.widgets[side]) do
               f = functionManager.getFunction(widget)
               if f ~= nil then
                  local w = f(s)
                  if w ~= nil then
                     -- wibox.layout.fixed.horizontal is 3.5+
                     if wibox.layout.fixed.horizontal then
                        layout:add(w)
                     else
                        table.insert(layout, w)
                     end
                  else
                     print("Can't create widget " .. widget .. ": function returned nil")
                  end
               else
                  print("Can't create widget " .. widget .. ": function not found")
               end
            end
         end
         layouts[side] = layout
      end

      -- wibox.layout.fixed.horizontal is 3.5+
      if wibox.layout.fixed.horizontal then
         local wiboxlayout = wibox.layout.align.horizontal()
         wiboxlayout:set_left(layouts.left)
         wiboxlayout:set_middle(layouts.middle)
         wiboxlayout:set_right(layouts.right)

         mywibox:set_widget(wiboxlayout)
      else
         layouts.left.layout = awful.widget.layout.horizontal.leftright

         local wiboxlayout = {}
         table.insert(wiboxlayout, layouts.left)

         for i=#layouts.right, 1, -1 do
            table.insert(wiboxlayout, layouts.right[i])
         end

         for i=#layouts.middle, 1, -1 do
            table.insert(wiboxlayout, layouts.middle[i])
         end

         wiboxlayout.layout = awful.widget.layout.horizontal.rightleft

         mywibox.widgets = wiboxlayout
      end
      shared.wibox[s] = mywibox
   end
end

function plugin.buildUi(window, settings, log)
   local lgi = require('lgi')
   local Gtk = lgi.require('Gtk')
   local widgets = require('crappy.gui.widgets')

   plugin.settingsDefault(settings)

   local positionRadioButton = Gtk.RadioButton {
      label = 'Position:'
   }

   local posComboBox = Gtk.ComboBoxText {
   }
   posComboBox:append("top", "Top")
   posComboBox:append("bottom", "Bottom")
   posComboBox:set_active_id(settings.position)

   function posComboBox:on_changed()
      settings.position = posComboBox:get_active_id()
   end

   local valid = functionManager.getFunctionsForClass('widget')
   table.sort(valid)

   local leftWidgets = widgets.functionList(valid, settings.widgets.left, true, true)
   local middleWidgets = widgets.functionList(valid, settings.widgets.middle, true, true)
   local rightWidgets = widgets.functionList(valid, settings.widgets.right, true, true)

   return Gtk.Box {
      orientation = 'VERTICAL',
      spacing = 6,
      margin = 6,
      Gtk.Box {
         orientation = 'HORIZONTAL',
         spacing = 4,
         Gtk.Label {
            halign = 'START',
            label = 'Position:'
         },
         posComboBox,
      },
      Gtk.Frame {
         label = "Widgets:",
         Gtk.Notebook {
            margin = 6,
            { tab_label = "Left", leftWidgets },
            { tab_label = "Middle" , middleWidgets },
            { tab_label = "Right", rightWidgets }
         }
      }
   }
end

return plugin
