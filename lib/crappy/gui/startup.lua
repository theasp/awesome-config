local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')

local despicable = require('despicable')
local pluginManager = require('despicable.pluginManager')
local fallback = require('crappy.gui.startup.fallback')
local theme = require('crappy.gui.startup.theme')

local log = lgi.log.domain('awesome-config/startup')

local startup = {}

function startup.buildUi(window, config)
   local settingsRefs = {}
   local settingsCount = 0

   local function storeSettings(settings)
      settingsCount = settingsCount + 1
      settingsRefs[settingsCount] = settings

      return settingsCount
   end

   local function removeSettings(settingsId)
      table.remove(settingsRefs, settingsId)
   end

   local startupFuncsColumns = {
      ENABLED = 1,
      NAME = 2,
      SETTINGSID = 3,
      TYPE = 4,
      FUNC = 5,
      PLUGIN = 6,
   }

   local startupFuncsListStore = Gtk.ListStore.new {
      [startupFuncsColumns.ENABLED] = GObject.Type.BOOLEAN,
      [startupFuncsColumns.NAME] = GObject.Type.STRING,
      [startupFuncsColumns.SETTINGSID] = GObject.Type.UINT,
      [startupFuncsColumns.TYPE] = GObject.Type.STRING,
      [startupFuncsColumns.FUNC] = GObject.Type.STRING,
      [startupFuncsColumns.PLUGIN] = GObject.Type.STRING,
   }

   for i, startupDef in ipairs(config.startup) do
      iter = startupFuncsListStore:append()

      if startupDef.plugin then
         startupFuncsListStore[iter][startupFuncsColumns.NAME] = startupDef.plugin
         startupFuncsListStore[iter][startupFuncsColumns.PLUGIN] = startupDef.plugin
         startupFuncsListStore[iter][startupFuncsColumns.TYPE] = 'plugin'
      else
         startupFuncsListStore[iter][startupFuncsColumns.NAME] = startupDef.func
         startupFuncsListStore[iter][startupFuncsColumns.FUNC] = startupDef.func
         startupFuncsListStore[iter][startupFuncsColumns.TYPE] = 'func'
      end

      startupFuncsListStore[iter][startupFuncsColumns.ENABLED] = startupDef.enabled
      startupFuncsListStore[iter][startupFuncsColumns.SETTINGSID] = storeSettings(startupDef.settings)

      log.message("Added %s", startupFuncsListStore[iter][startupFuncsColumns.NAME])
   end

   local function updateStartupFuncs()
      config.startup = {}

      local iter = startupFuncsListStore:get_iter_first()
      while iter do
         local name = startupFuncsListStore[iter][startupFuncsColumns.NAME]
         local enabled = startupFuncsListStore[iter][startupFuncsColumns.ENABLED]
         local settingsId = startupFuncsListStore[iter][startupFuncsColumns.SETTINGSID]
         local startupType = startupFuncsListStore[iter][startupFuncsColumns.TYPE]
         local val

         if startupType == 'plugin' then
            local plugin = startupFuncsListStore[iter][startupFuncsColumns.PLUGIN]
            if plugin then
               val = {
                  plugin = plugin,
                  enabled = enabled,
                  settings = settingsRefs[settingsId]
               }
            end
         else
            local func = startupFuncsListStore[iter][startupFuncsColumns.FUNC]
            if func then
               val = {
                  func = func,
                  enabled = enabled,
                  settings = settingsRefs[settingsId]
               }
            end
         end

         if val then
            log.message("Updating %s", name)
            table.insert(config.startup, val)
         end

         iter = startupFuncsListStore:next(iter)
      end
   end

   function startupFuncsListStore:on_row_deleted()
      updateStartupFuncs()
   end

   -- As inserts are done without values this is used for new rows too
   function startupFuncsListStore:on_row_changed()
      updateStartupFuncs()
   end

   local startupFuncsNameCellRenderer = Gtk.CellRendererText { }

   local startupFuncsNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Name',
      expand = false,
      {
         startupFuncsNameCellRenderer, { text = startupFuncsColumns.NAME }
      }
   }

   local startupFuncsEnabledCellRenderer = Gtk.CellRendererToggle {
      activatable = true
   }

   function startupFuncsEnabledCellRenderer:on_toggled(path, text)
      local iter = startupFuncsListStore:get_iter(Gtk.TreePath.new_from_string(path))
      startupFuncsListStore[iter][startupFuncsColumns.ENABLED] = not startupFuncsListStore[iter][startupFuncsColumns.ENABLED]
   end

   local startupFuncsEnabledTreeViewColumn = Gtk.TreeViewColumn {
      expand = false,
      {
         startupFuncsEnabledCellRenderer, { active = startupFuncsColumns.ENABLED }
      }
   }

   local startupFuncsTreeView = Gtk.TreeView {
      model = startupFuncsListStore,
      id = 'settings.startupFuncs',
      reorderable = true,
      activate_on_single_click = true,
      startupFuncsEnabledTreeViewColumn,
      startupFuncsNameTreeViewColumn
   }

   local settingsBox = Gtk.Box {
      margin = 0,
      spacing = 0,
      expand = true,
   }

   local settingsUi = nil

   local startupFuncsSelection = startupFuncsTreeView:get_selection()
   startupFuncsSelection.mode = 'SINGLE'

   function startupFuncsSelection:on_changed()
      if settingsUi then
         settingsUi:destroy()
      end

      local model, iter = startupFuncsSelection:get_selected()
      if iter then
         local startupType = startupFuncsListStore[iter][startupFuncsColumns.TYPE]
         local settingsId = startupFuncsListStore[iter][startupFuncsColumns.SETTINGSID]
         local settings = settingsRefs[settingsId]

         if startupType == 'plugin' then
            local pluginId = startupFuncsListStore[iter][startupFuncsColumns.PLUGIN]
            local plugin = pluginManager.plugins[pluginId]

            if plugin.buildUi then
               settingsUi = plugin.buildUi(window, settings)
            else
               settingsUi = fallback.buildUi(window, settings)
            end
         else
            settingsUi = fallback.buildUi(window, settings)
         end

         if settingsUi then
            settingsBox:add(settingsUi)
            settingsUi:show_all()
         end
      end
   end

   local upButton = Gtk.Button {
      id = 'up',
      use_stock = true,
      label = Gtk.STOCK_GO_UP,
   }

   function upButton:on_clicked()
      local model, iter = startupFuncsSelection:get_selected()
      if model and iter then
         local path = startupFuncsListStore:get_path(iter)

         if path:prev() then
            local prevIter = startupFuncsListStore:get_iter(path)
            if prevIter then
               startupFuncsListStore:swap(iter, prevIter)
            end
         end
      end
   end

   local downButton = Gtk.Button {
      id = 'down',
      use_stock = true,
      label = Gtk.STOCK_GO_DOWN,
   }

   function downButton:on_clicked()
      local model, iter = startupFuncsSelection:get_selected()
      if model and iter then
         local path = startupFuncsListStore:get_path(iter)

         -- This works differently than prev(), for reasons.
         path:next()
         if path then
            local nextIter = startupFuncsListStore:get_iter(path)
            if nextIter then
               startupFuncsListStore:swap(iter, nextIter)
            end
         end
      end
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
         title = 'Add Startup Function',
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

               local model, selectedIter = startupFuncsSelection:get_selected()
               if model and selectedIter then
                  iter = startupFuncsListStore:insert_after(selectedIter)
               else
                  iter = startupFuncsListStore:append()
               end

               startupFuncsListStore[iter][startupFuncsColumns.NAME] = func
               startupFuncsListStore[iter][startupFuncsColumns.FUNC] = func
               startupFuncsListStore[iter][startupFuncsColumns.ENABLED] = true
               startupFuncsListStore[iter][startupFuncsColumns.SETTINGSID] = storeSettings({})

               log.message("Added function %s", func)
            end
         end

         dialog:destroy()
      end

      dialog:show_all()
      dialog:run()
   end

   local removeButton = Gtk.Button {
      id = 'remove',
      use_stock = true,
      label = Gtk.STOCK_REMOVE,
   }

   function removeButton:on_clicked()
      local model, iter = startupFuncsSelection:get_selected()
      if model and iter then
         model:remove(iter)
      end
   end

   return Gtk.Box {
      spacing = 6,
      margin = 6,
      expand = true,
      orientation = 'HORIZONTAL',

      Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         hexpand = false,
         vexpand = true,

         Gtk.ScrolledWindow {
            shadow_type = 'ETCHED_IN',
            hexpand = false,
            vexpand = true,
            startupFuncsTreeView
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
      },
      settingsBox
   }
end

return startup
