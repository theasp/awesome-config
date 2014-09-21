local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')

local pluginManager = require('crappy.pluginManager')
local fallback = require('crappy.gui.fallback')

local log = lgi.log.domain('awesome-config/plugins')

local plugins = {}

function plugins.buildUi(window, config)
   local settingsRefs = {}
   local settingsCount = 0

   local function storeSettings(settings)
      if settings == nil then
         settings = {}
      end

      settingsCount = settingsCount + 1
      settingsRefs[settingsCount] = settings

      return settingsCount
   end

   local function removeSettings(settingsId)
      table.remove(settingsRefs, settingsId)
   end

   local pluginsFuncsColumns = {
      ENABLED = 1,
      NAME = 2,
      SETTINGSID = 3,
      TYPE = 4,
      FUNC = 5,
      PLUGIN = 6,
   }

   local pluginsFuncsListStore = Gtk.ListStore.new {
      [pluginsFuncsColumns.ENABLED] = GObject.Type.BOOLEAN,
      [pluginsFuncsColumns.NAME] = GObject.Type.STRING,
      [pluginsFuncsColumns.SETTINGSID] = GObject.Type.UINT,
      [pluginsFuncsColumns.TYPE] = GObject.Type.STRING,
      [pluginsFuncsColumns.FUNC] = GObject.Type.STRING,
      [pluginsFuncsColumns.PLUGIN] = GObject.Type.STRING,
   }

   for i, pluginDef in ipairs(config.plugins) do
      iter = pluginsFuncsListStore:append()

      if pluginDef.plugin then
         local name
         local plugin = pluginManager.plugins[pluginDef.plugin]
         if pluginManager.plugins[pluginDef.plugin] then
            name = pluginManager.plugins[pluginDef.plugin].name
            if pluginManager.plugins[pluginDef.plugin].buildUi == nil then
               name = name .. ' (No UI)'
            end

            if pluginDef.settings == nil then
               pluginDef.settings = {}
            end
            plugin.settingsDefault(pluginDef.settings)
         else
            name = pluginDef.plugin .. ' (Plugin not loaded)'
         end

         pluginsFuncsListStore[iter][pluginsFuncsColumns.NAME] = name
         pluginsFuncsListStore[iter][pluginsFuncsColumns.PLUGIN] = pluginDef.plugin
         pluginsFuncsListStore[iter][pluginsFuncsColumns.TYPE] = 'plugin'
      else
         pluginsFuncsListStore[iter][pluginsFuncsColumns.NAME] = pluginDef.func .. ' (Custom)'
         pluginsFuncsListStore[iter][pluginsFuncsColumns.FUNC] = pluginDef.func
         pluginsFuncsListStore[iter][pluginsFuncsColumns.TYPE] = 'func'
      end

      pluginsFuncsListStore[iter][pluginsFuncsColumns.ENABLED] = pluginDef.enabled
      pluginsFuncsListStore[iter][pluginsFuncsColumns.SETTINGSID] = storeSettings(pluginDef.settings)

      log.message('Added %s', pluginsFuncsListStore[iter][pluginsFuncsColumns.NAME])
   end

   local function updatePluginsFuncs()
      config.plugins = {}

      local iter = pluginsFuncsListStore:get_iter_first()
      while iter do
         local name = pluginsFuncsListStore[iter][pluginsFuncsColumns.NAME]
         local enabled = pluginsFuncsListStore[iter][pluginsFuncsColumns.ENABLED]
         local settingsId = pluginsFuncsListStore[iter][pluginsFuncsColumns.SETTINGSID]
         local pluginsType = pluginsFuncsListStore[iter][pluginsFuncsColumns.TYPE]
         local val

         if pluginsType == 'plugin' then
            local plugin = pluginsFuncsListStore[iter][pluginsFuncsColumns.PLUGIN]
            if plugin then
               val = {
                  plugin = plugin,
                  enabled = enabled,
                  settings = settingsRefs[settingsId]
               }
            end
         else
            local func = pluginsFuncsListStore[iter][pluginsFuncsColumns.FUNC]
            if func then
               val = {
                  func = func,
                  enabled = enabled,
                  settings = settingsRefs[settingsId]
               }
            end
         end

         if val then
            log.message('Updating %s', name)
            table.insert(config.plugins, val)
         end

         iter = pluginsFuncsListStore:next(iter)
      end
   end

   function pluginsFuncsListStore:on_row_deleted()
      updatePluginsFuncs()
   end

   -- As inserts are done without values this is used for new rows too
   function pluginsFuncsListStore:on_row_changed()
      updatePluginsFuncs()
   end

   local pluginsFuncsNameCellRenderer = Gtk.CellRendererText { }

   local pluginsFuncsNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Name',
      expand = false,
      {
         pluginsFuncsNameCellRenderer, { text = pluginsFuncsColumns.NAME }
      }
   }

   local pluginsFuncsEnabledCellRenderer = Gtk.CellRendererToggle {
      activatable = true
   }

   function pluginsFuncsEnabledCellRenderer:on_toggled(path, text)
      local iter = pluginsFuncsListStore:get_iter(Gtk.TreePath.new_from_string(path))
      pluginsFuncsListStore[iter][pluginsFuncsColumns.ENABLED] = not pluginsFuncsListStore[iter][pluginsFuncsColumns.ENABLED]
   end

   local pluginsFuncsEnabledTreeViewColumn = Gtk.TreeViewColumn {
      expand = false,
      {
         pluginsFuncsEnabledCellRenderer, { active = pluginsFuncsColumns.ENABLED }
      }
   }

   local pluginsFuncsTreeView = Gtk.TreeView {
      model = pluginsFuncsListStore,
      id = 'settings.pluginsFuncs',
      reorderable = true,
      activate_on_single_click = true,
      pluginsFuncsEnabledTreeViewColumn,
      pluginsFuncsNameTreeViewColumn
   }

   local settingsBox = Gtk.Box {
      margin = 0,
      spacing = 0,
      expand = true,
   }

   local settingsUi = nil

   local pluginsFuncsSelection = pluginsFuncsTreeView:get_selection()
   pluginsFuncsSelection.mode = 'SINGLE'

   function pluginsFuncsSelection:on_changed()
      if settingsUi then
         settingsUi:destroy()
      end

      local model, iter = pluginsFuncsSelection:get_selected()
      if iter then
         local pluginsType = pluginsFuncsListStore[iter][pluginsFuncsColumns.TYPE]
         local settingsId = pluginsFuncsListStore[iter][pluginsFuncsColumns.SETTINGSID]
         local settings = settingsRefs[settingsId]

         if pluginsType == 'plugin' then
            local pluginId = pluginsFuncsListStore[iter][pluginsFuncsColumns.PLUGIN]
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
      local model, iter = pluginsFuncsSelection:get_selected()
      if model and iter then
         local path = pluginsFuncsListStore:get_path(iter)

         if path:prev() then
            local prevIter = pluginsFuncsListStore:get_iter(path)
            if prevIter then
               pluginsFuncsListStore:swap(iter, prevIter)
            end
         end
      end
      updatePluginsFuncs()
   end

   local downButton = Gtk.Button {
      id = 'down',
      use_stock = true,
      label = Gtk.STOCK_GO_DOWN,
   }

   function downButton:on_clicked()
      local model, iter = pluginsFuncsSelection:get_selected()
      if model and iter then
         local path = pluginsFuncsListStore:get_path(iter)

         -- This works differently than prev(), for reasons.
         path:next()
         if path then
            local nextIter = pluginsFuncsListStore:get_iter(path)
            if nextIter then
               pluginsFuncsListStore:swap(iter, nextIter)
            end
         end
      end
      updatePluginsFuncs()
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
         title = 'Add Plugins Function',
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

               local model, selectedIter = pluginsFuncsSelection:get_selected()
               if model and selectedIter then
                  iter = pluginsFuncsListStore:insert_after(selectedIter)
               else
                  iter = pluginsFuncsListStore:append()
               end

               pluginsFuncsListStore[iter][pluginsFuncsColumns.NAME] = func
               pluginsFuncsListStore[iter][pluginsFuncsColumns.FUNC] = func
               pluginsFuncsListStore[iter][pluginsFuncsColumns.ENABLED] = true
               pluginsFuncsListStore[iter][pluginsFuncsColumns.SETTINGSID] = storeSettings({})

               log.message('Added function %s', func)
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
      local model, iter = pluginsFuncsSelection:get_selected()
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
            pluginsFuncsTreeView
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

return plugins
