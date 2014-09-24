local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')

local pluginManager = require('crappy.pluginManager')
local fallback = require('crappy.gui.fallback')

local log = lgi.log.domain('awesome-config/plugins')

local plugins = {}

local objStore = {}

function objStore.new()
   local self = {}

   function self:store(obj)
      self.count = self.count + 1
      self.objs[self.count] = obj
      return self.count
   end

   function self:get(count)
      return self.objs[count]
   end

   function self:remove(count)
      table.remove(self.objs, count)
   end

   function self:clear()
      self.count = 0
      self.objs = {}
   end

   self:clear()

   return self
end

function plugins.buildUi(window, config)
   local settingsObjs = objStore.new()

   local pluginsColumns = {
      ENABLED = 1,
      NAME = 2,
      SETTINGSID = 3,
      TYPE = 4,
      ID = 5,
      UI = 6,
   }

   local pluginsListStore = Gtk.ListStore.new {
      [pluginsColumns.ENABLED] = GObject.Type.BOOLEAN,
      [pluginsColumns.NAME] = GObject.Type.STRING,
      [pluginsColumns.SETTINGSID] = GObject.Type.UINT,
      [pluginsColumns.TYPE] = GObject.Type.STRING,
      [pluginsColumns.ID] = GObject.Type.STRING,
      [pluginsColumns.UI] = GObject.Type.UINT
   }

   function namePlugin(plugin)
      local name = plugin.name
      if plugin.buildUi == nil then
         name = name .. ' (No UI)'
      end

      return name
   end

   if not config.plugins then
      config.plugins = {}
   end

   for id, pluginDef in pairs(config.plugins) do
      iter = pluginsListStore:append()

      if pluginDef.settings == nil then
         pluginDef.settings = {}
      end

      if not pluginDef.type or pluginDef.type == 'plugin' then
         local plugin = pluginManager.plugins[id]
         local name
         if plugin then
            name = namePlugin(plugin)

            if plugin.settingsDefault then
               plugin.settingsDefault(pluginDef.settings)
            end

         else
            name = pluginDef.plugin .. ' (Missing)'
         end

         pluginsListStore[iter][pluginsColumns.NAME] = name
         pluginsListStore[iter][pluginsColumns.ID] = id
         pluginsListStore[iter][pluginsColumns.TYPE] = 'plugin'
      elseif pluginDef.type == 'func' then
         pluginsListStore[iter][pluginsColumns.NAME] = id .. ' (Function)'
         pluginsListStore[iter][pluginsColumns.ID] = id
         pluginsListStore[iter][pluginsColumns.TYPE] = 'func'
      else
         log.message("Unknown plugin type " .. pluginDef.type)
      end

      pluginsListStore[iter][pluginsColumns.ENABLED] = pluginDef.enabled
      pluginsListStore[iter][pluginsColumns.SETTINGSID] = settingsObjs:store(pluginDef.settings)
   end

   -- Add in new plugins
   for id, plugin in pairs(pluginManager.plugins) do
      if not config.plugins[id] then
         local iter = pluginsListStore:append()

         local settings = {}
         if plugin.settingsDefault then
            plugin.settingsDefault(settings)
         end

         pluginsListStore[iter][pluginsColumns.NAME] = namePlugin(plugin)
         pluginsListStore[iter][pluginsColumns.ID] = id
         pluginsListStore[iter][pluginsColumns.TYPE] = 'plugin'
         pluginsListStore[iter][pluginsColumns.ENABLED] = true
         pluginsListStore[iter][pluginsColumns.SETTINGSID] = settingsObjs:store(settings)
      end
   end

   local function updatePlugins()
      config.plugins = {}

      local iter = pluginsListStore:get_iter_first()
      while iter do
         local id = pluginsListStore[iter][pluginsColumns.ID]
         local name = pluginsListStore[iter][pluginsColumns.NAME]
         local enabled = pluginsListStore[iter][pluginsColumns.ENABLED]
         local settingsId = pluginsListStore[iter][pluginsColumns.SETTINGSID]
         local pluginsType = pluginsListStore[iter][pluginsColumns.TYPE]
         local val

         config.plugins[id] = {
            enabled = enabled,
            type = pluginType,
            settings = settingsObjs:get(settingsId)
         }

         iter = pluginsListStore:next(iter)
      end
   end

   -- Do this on load so that new plugins get added to config
   updatePlugins()

   function pluginsListStore:on_row_deleted()
      updatePlugins()
   end

   -- As inserts are done without values this is used for new rows too
   function pluginsListStore:on_row_changed()
      updatePlugins()
   end

   pluginsListStore:set_sort_func(pluginsColumns.NAME,
                                  function(model, a, b)
                                     a = model[a][pluginsColumns.NAME]
                                     b = model[b][pluginsColumns.NAME]
                                     if a == b then return 0
                                     elseif a < b then return -1
                                     else return 1 end
                                  end
   )

   pluginsListStore:set_sort_column_id(pluginsColumns.NAME, Gtk.SortType.ASCENDING)

   local pluginsNameCellRenderer = Gtk.CellRendererText { }

   local pluginsNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Name',
      expand = false,
      {
         pluginsNameCellRenderer, { text = pluginsColumns.NAME }
      }
   }

   local pluginsEnabledCellRenderer = Gtk.CellRendererToggle {
      activatable = true
   }

   function pluginsEnabledCellRenderer:on_toggled(path, text)
      local iter = pluginsListStore:get_iter(Gtk.TreePath.new_from_string(path))
      pluginsListStore[iter][pluginsColumns.ENABLED] = not pluginsListStore[iter][pluginsColumns.ENABLED]
   end

   local pluginsEnabledTreeViewColumn = Gtk.TreeViewColumn {
      expand = false,
      {
         pluginsEnabledCellRenderer, { active = pluginsColumns.ENABLED }
      }
   }

   local pluginsTreeView = Gtk.TreeView {
      model = pluginsListStore,
      id = 'settings.plugins',
      reorderable = true,
      activate_on_single_click = true,
      pluginsEnabledTreeViewColumn,
      pluginsNameTreeViewColumn
   }

   local settingsBox = Gtk.Box {
      margin = 0,
      spacing = 0,
      expand = true,
   }

   local settingsUi = nil

   local pluginsSelection = pluginsTreeView:get_selection()
   pluginsSelection.mode = 'SINGLE'

   function pluginsSelection:on_changed()
      if settingsUi then
         settingsUi:destroy()
      end

      local model, iter = pluginsSelection:get_selected()
      if iter then
         local pluginsType = pluginsListStore[iter][pluginsColumns.TYPE]
         local settingsId = pluginsListStore[iter][pluginsColumns.SETTINGSID]
         local settings = settingsObjs:get(settingsId)

         if pluginsType == 'plugin' then
            local pluginId = pluginsListStore[iter][pluginsColumns.ID]
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

               local model, selectedIter = pluginsSelection:get_selected()
               if model and selectedIter then
                  iter = pluginsListStore:insert_after(selectedIter)
               else
                  iter = pluginsListStore:append()
               end

               pluginsListStore[iter][pluginsColumns.NAME] = func
               pluginsListStore[iter][pluginsColumns.ID] = func
               pluginsListStore[iter][pluginsColumns.TYPE] = 'func'
               pluginsListStore[iter][pluginsColumns.ENABLED] = true
               pluginsListStore[iter][pluginsColumns.SETTINGSID] = settingsObjs:store({})
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
      local model, iter = pluginsSelection:get_selected()
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
            pluginsTreeView
         },

         Gtk.Box {
            orientation = 'HORIZONTAL',
            spacing = 4,
            homogeneous = true,
            addButton,
            removeButton
         }
      },
      settingsBox
   }
end

return plugins
