local plugin = {}

local misc = require('crappy.misc')
local shared = require('crappy.shared')

plugin.name = 'Standard Layouts'
plugin.description = 'Initialize the layouts'
plugin.id = 'crappy.startup.layouts'
plugin.provides = {"layouts"}

function plugin.settingsDefault(settings)
   if #settings == 0 then
      settings = {
         "awful.layout.suit.floating",
         "awful.layout.suit.tile",
         "awful.layout.suit.tile.left",
         "awful.layout.suit.tile.bottom",
         "awful.layout.suit.tile.top",
         "awful.layout.suit.fair",
         "awful.layout.suit.fair.horizontal",
         "awful.layout.suit.spiral",
         "awful.layout.suit.spiral.dwindle",
         "awful.layout.suit.max",
         "awful.layout.suit.max.fullscreen",
         "awful.layout.suit.magnifier"
      }
   end
end

function plugin.startup(awesomever, settings)
   plugin.settingsDefault(settings)

   shared.layouts = {}

   for i, layoutName in ipairs(crappy.config.settings.layouts) do
      shared.layouts[i] = misc.getFunction(layoutName)
   end
end

function plugin.buildUi(window, settings)
   local lgi = require 'lgi'
   local Gtk = lgi.require('Gtk')
   local GObject = lgi.require('GObject')

   local log = lgi.log.domain('awesome-config.startup/plugin/' .. plugin.id)

   local layoutsColumns = {
      FUNCTION = 1,
   }

   local layoutsListStore = Gtk.ListStore.new {
      [layoutsColumns.FUNCTION] = GObject.Type.STRING
   }

   layoutsListStore:clear()
   for i, func in ipairs(settings) do
      iter = layoutsListStore:append()
      layoutsListStore[iter][layoutsColumns.FUNCTION] = func

      log.message("Added function %s", func)
   end

   local function updateLayouts()
      settings = {}

      local iter = layoutsListStore:get_iter_first()
      while iter do
         val = layoutsListStore[iter][layoutsColumns.FUNCTION]

         if val ~= "" then
            table.insert(settings, val)
         end
         iter = layoutsListStore:next(iter)
      end
   end

   function layoutsListStore:on_row_deleted()
      updateLayouts()
   end

   -- As inserts are done without values this is used for new rows too
   function layoutsListStore:on_row_changed()
      updateLayouts()
   end

   local layoutsNameCellRenderer = Gtk.CellRendererText { }

   local layoutsNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Layout',
      expand = true,
      {
         layoutsNameCellRenderer, { text = layoutsColumns.FUNCTION }
      }
   }

   local layoutsTreeView = Gtk.TreeView {
      model = layoutsListStore,
      id = 'settings.layouts',
      reorderable = true,
      expand = true,
      layoutsNameTreeViewColumn
   }

   local layoutsSelection = layoutsTreeView:get_selection()
   layoutsSelection.mode = 'SINGLE'

   local upButton = Gtk.Button {
      id = 'up',
      use_stock = true,
      label = Gtk.STOCK_GO_UP,
   }

   function upButton:on_clicked()
      local model, iter = layoutsSelection:get_selected()
      if model and iter then
         local path = layoutsListStore:get_path(iter)

         if path:prev() then
            local prevIter = layoutsListStore:get_iter(path)
            if prevIter then
               layoutsListStore:swap(iter, prevIter)
            end
         end
      end
      updateLayouts()
   end

   local downButton = Gtk.Button {
      id = 'down',
      use_stock = true,
      label = Gtk.STOCK_GO_DOWN,
   }

   function downButton:on_clicked()
      local model, iter = layoutsSelection:get_selected()
      if model and iter then
         local path = layoutsListStore:get_path(iter)

         -- This works differently than prev()
         path:next()
         if path then
            local nextIter = layoutsListStore:get_iter(path)
            if nextIter then
               layoutsListStore:swap(iter, nextIter)
            end
         end
      end
      updateLayouts()
   end

   local addButton = Gtk.Button {
      id = 'add',
      use_stock = true,
      label = Gtk.STOCK_ADD,
   }

   function addButton:on_clicked()
      local functionEntry = Gtk.Entry {
         id = 'function'
      }

      local content = Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         border_width = 6,
         Gtk.Label {
            label = 'Enter function name'
         },
         functionEntry
      }

      local dialog = Gtk.Dialog {
         title = 'Add Layout Function',
         transient_for = window,
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
            local func = functionEntry:get_text()

            if func ~= '' then
               local iter

               local model, selectedIter = layoutsSelection:get_selected()
               if model and selectedIter then
                  iter = layoutsListStore:insert_after(selectedIter)
               else
                  iter = layoutsListStore:append()
               end

               layoutsListStore[iter][layoutsColumns.FUNCTION] = func

               log.message("Added function %s", func)
            end
         end

         dialog:destroy()
      end

      dialog:show_all()
      dialog:run()
      updateLayouts()
   end

   local removeButton = Gtk.Button {
      id = 'remove',
      use_stock = true,
      label = Gtk.STOCK_REMOVE,
   }

   function removeButton:on_clicked()
      local model, iter = layoutsSelection:get_selected()
      if model and iter then
         model:remove(iter)
      end
      updateLayouts()
   end

   return Gtk.ScrolledWindow {
      shadow_type = 'ETCHED_IN',

      Gtk.Box {
         orientation = 'VERTICAL',
         margin = 6,
         spacing = 6,
         
         Gtk.ScrolledWindow {
            shadow_type = 'ETCHED_IN',
            layoutsTreeView
         },

         Gtk.Box {
            orientation = 'HORIZONTAL',
            spacing = 4,
            homogeneous = true,
            upButton,
            downButton,
            addButton,
            removeButton
         }
      }
   }
end


return plugin
