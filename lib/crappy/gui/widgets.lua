local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')
local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')
local Pango = lgi.require('Pango')
local json = require('crappy.JSON')

local widgets = {}

function widgets.simpleListItemDialog(valid)
   assert(valid)

   local validColumn = {
      NAME = 1,
      DESC = 2
   }

   local validListStore = Gtk.ListStore.new {
      [validColumn.NAME] = GObject.Type.STRING,
      [validColumn.DESC] = GObject.Type.STRING
   }

   for i, v in ipairs(valid) do
      if v ~= '' then
         local funcDef = functionManager.functions[v]
         local iter = validListStore:append()
         validListStore[iter][validColumn.NAME] = funcDef.id
         validListStore[iter][validColumn.DESC] = funcDef.description
      end
   end

   local validNameCellRenderer = Gtk.CellRendererText { }
   local validDescCellRenderer = Gtk.CellRendererText { }

   local validNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Name',
      expand = true,
      {
         validNameCellRenderer, { text = validColumn.NAME }
      }
   }

   local validDescTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Description',
      expand = true,
      {
         validDescCellRenderer, { text = validColumn.DESC }
      }
   }

   local validTreeView = Gtk.TreeView {
      model = validListStore,
      reorderable = reorderable,
      expand = true,
      validNameTreeViewColumn,
      validDescTreeViewColumn
   }

   local validSelection = validTreeView:get_selection()
   validSelection.mode = 'SINGLE'

   local functionEntry = Gtk.Entry {
      expand = true,
      id = 'function'
   }

   function validSelection:on_changed()
      local model, iter = validSelection:get_selected()
      if iter then
         local id = validListStore[iter][validColumn.NAME]
         functionEntry:set_text(id)
      end
   end


   local content = Gtk.Box {
      orientation = 'VERTICAL',
      spacing = 6,
      border_width = 6,
      Gtk.ScrolledWindow {
         shadow_type = 'ETCHED_IN',
         validTreeView,
      },
      Gtk.Box {
         orientation = 'HORIZONTAL',
         spacing = 4,
         vexpand = false,
         Gtk.Label {
            label = 'Function name:'
         },
         functionEntry
      }
   }

   local dialog = Gtk.Dialog {
      title = 'Add Function',
      transient_for = window,
      default_width = 600,
      default_height = 400,
      buttons = {
         { Gtk.STOCK_CANCEL, Gtk.ResponseType.CLOSE },
         { Gtk.STOCK_ADD, Gtk.ResponseType.OK },
      },
   }

   dialog:get_content_area():add(content)

   functionEntry:set_activates_default(true)
   dialog:set_default_response(Gtk.ResponseType.OK)

   function dialog:on_response(response)
      if response == Gtk.ResponseType.OK then
         result = functionEntry:get_text()
      end

      dialog:destroy()
   end

   dialog:show_all()
   dialog:run()

   return result
end

function widgets.functionList(valid, current, reorderable)
   assert(valid)
   assert(current)
   assert(reorderable ~= nil)

   local currentColumn = {
      NAME = 1,
      DESC = 2
   }

   local currentListStore = Gtk.ListStore.new {
      [currentColumn.NAME] = GObject.Type.STRING,
      [currentColumn.DESC] = GObject.Type.STRING
   }

   local function appendCurrent(id)
      local funcDef = functionManager.functions[id]
      local iter = currentListStore:append()

      if funcDef then
         currentListStore[iter][currentColumn.NAME] = funcDef.id
         currentListStore[iter][currentColumn.DESC] = funcDef.description
      else
         currentListStore[iter][currentColumn.NAME] = id
         currentListStore[iter][currentColumn.DESC] = '(Custom)'
      end
   end

   for i, v in ipairs(current) do
      if v ~= '' then
         appendCurrent(v)
      end
   end

   local currentNameCellRenderer = Gtk.CellRendererText { }
   local currentDescCellRenderer = Gtk.CellRendererText { }

   local currentNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Function',
      expand = true,
      {
         currentNameCellRenderer, { text = currentColumn.NAME }
      }
   }

   local currentDescTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Description',
      expand = true,
      {
         currentDescCellRenderer, { text = currentColumn.DESC }
      }
   }

   local currentTreeView = Gtk.TreeView {
      model = currentListStore,
      reorderable = reorderable,
      expand = true,
      currentNameTreeViewColumn,
      currentDescTreeViewColumn
   }

   local currentSelection = currentTreeView:get_selection()
   currentSelection.mode = 'SINGLE'

   local buttonBox = Gtk.Box {
      orientation = 'HORIZONTAL',
      spacing = 4,
      homogeneous = true,
   }

   local function updateCurrent()
      for k, v in ipairs(current) do
         current[k] = nil
      end

      local iter = currentListStore:get_iter_first()
      while iter do
         val = currentListStore[iter][currentColumn.NAME]

         if val ~= "" then
            table.insert(current, val)
         end
         iter = currentListStore:next(iter)
      end
   end

   currentListStore.on_row_deleted = updateCurrent
   currentListStore.on_row_changed = updateCurrent

   if (reorderable) then
      local upButton = Gtk.Button {
         id = 'up',
         use_stock = true,
         label = Gtk.STOCK_GO_UP,
      }

      function upButton:on_clicked()
         local model, iter = currentSelection:get_selected()
         if model and iter then
            local path = currentListStore:get_path(iter)

            if path:prev() then
               local prevIter = currentListStore:get_iter(path)
               if prevIter then
                  currentListStore:swap(iter, prevIter)
               end
            end
         end
         updateCurrent()
      end

      buttonBox:add(upButton)

      local downButton = Gtk.Button {
         id = 'down',
         use_stock = true,
         label = Gtk.STOCK_GO_DOWN,
      }

      function downButton:on_clicked()
         local model, iter = currentSelection:get_selected()
         if model and iter then
            local path = currentListStore:get_path(iter)

            -- This works differently than prev()
            path:next()
            if path then
               local nextIter = currentListStore:get_iter(path)
               if nextIter then
                  currentListStore:swap(iter, nextIter)
               end
            end
         end
         updateCurrent()
      end

      buttonBox:add(downButton)
   end

   local addButton = Gtk.Button {
      id = 'add',
      use_stock = true,
      label = Gtk.STOCK_ADD,
   }

   function addButton:on_clicked()
      local new = widgets.simpleListItemDialog(valid)
      if new and new ~= '' then
         appendCurrent(new)
         updateCurrent()
      end
   end

   buttonBox:add(addButton)

   local removeButton = Gtk.Button {
      use_stock = true,
      label = Gtk.STOCK_REMOVE,
   }

   local result

   function removeButton:on_clicked()
      local model, iter = currentSelection:get_selected()
      if model and iter then
         model:remove(iter)
      end
   end

   buttonBox:add(removeButton)

   return Gtk.Box {
      orientation = 'VERTICAL',
      margin = 6,
      spacing = 6,

      Gtk.ScrolledWindow {
         shadow_type = 'ETCHED_IN',
         currentTreeView
      },
      buttonBox
   }
end

function widgets.functionComboBox(valid, current)
   local comboBox = Gtk.ComboBoxText {
      has_entry = true,
      entry_text_column = 1,
      hexpand = true,
   }

   comboBox:append(current, "Current value")

   for i, v in ipairs(valid) do
      if v ~= '' then
         local funcDef = functionManager.functions[v]
         comboBox:append(v, funcDef.description)
      end
   end

   comboBox:set_active_id(current)

   return comboBox
end

function widgets.jsonEditor(window, settings, applyCallback)
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
         if applyCallback then
            applyCallback()
         end
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

return widgets
