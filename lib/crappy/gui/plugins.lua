local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')

local pluginManager = require('crappy.pluginManager')
local fallback = require('crappy.gui.fallback')

local log = lgi.log.domain('awesome-config/plugins')
local misc = require('crappy.misc')

local plugins = {}

function plugins.buildPluginUi(window, pluginId, pluginConfig, log, updateUi, modifiedCallback)
   local plugin = pluginManager.plugins[pluginId]
   if plugin == nil then
      plugin = {id=pluginId}
   end

   unknownTypes = {"name", "description", "author"}
   for i, v in ipairs(unknownTypes) do
      if plugin[v] == nil then
         plugin[v] = 'Unknown';
      end
   end

   local row = -1;
   local function nextRow()
      row = row + 1
      return row
   end

   local grid = Gtk.Grid {
      row_spacing = 6,
      column_spacing = 6,
      margin = 6,
      expand = true,

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = 'Id:',
            halign = 'END',
         }
      },
      {
         left_attach = 1, top_attach = row,
         Gtk.Label {
            label = plugin.id,
            selectable = true,
            halign = 'START',
         }
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = 'Description:',
            halign = 'END',
         }
      },
      {
         left_attach = 1, top_attach = row,
         Gtk.Label {
            label = plugin.description,
            selectable = true,
            halign = 'START',
         }
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = 'Author:',
            halign = 'END',
         }
      },
      {
         left_attach = 1, top_attach = row,
         Gtk.Label {
            label = plugin.author,
            selectable = true,
            halign = 'START',
         }
      },

   }

   return Gtk.ScrolledWindow {
      shadow_type = 'ETCHED_IN',
      expand = true,
      grid
   }
end

function plugins.buildUi(window, config, updateUi, modifiedCallback)
   local pluginsColumns = {
      ENABLED = 1,
      NAME = 2,
      TYPE = 3,
      ID = 4,
   }

   local pluginsListStore = Gtk.ListStore.new {
      [pluginsColumns.ENABLED] = GObject.Type.BOOLEAN,
      [pluginsColumns.NAME] = GObject.Type.STRING,
      [pluginsColumns.TYPE] = GObject.Type.STRING,
      [pluginsColumns.ID] = GObject.Type.STRING,
   }

   for id, pluginDef in pairs(config.plugins) do
      iter = pluginsListStore:append()

      if not pluginDef.type or pluginDef.type == 'plugin' then
         local plugin = pluginManager.plugins[id]
         local name
         if plugin then
            name = plugin.name
         else
            name = id .. ' (Missing)'
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
   end

   -- Add in new plugins
   for id, plugin in pairs(pluginManager.plugins) do
      if not config.plugins[id] then
         local iter = pluginsListStore:append()

         pluginsListStore[iter][pluginsColumns.NAME] = plugin.name
         pluginsListStore[iter][pluginsColumns.ID] = id
         pluginsListStore[iter][pluginsColumns.TYPE] = 'plugin'
         pluginsListStore[iter][pluginsColumns.ENABLED] = true
      end
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

      if modifiedCallback then
         modifiedCallback()
      end
      updateUi()
   end

   local pluginsEnabledTreeViewColumn = Gtk.TreeViewColumn {
      expand = false,
      {
         pluginsEnabledCellRenderer, { active = pluginsColumns.ENABLED }
      }
   }

   local pluginsTreeView = Gtk.TreeView {
      model = pluginsListStore,
      reorderable = true,
      pluginsEnabledTreeViewColumn,
      pluginsNameTreeViewColumn
   }

   local settingsBox = Gtk.Box {
      margin = 0,
      spacing = 0,
      expand = true,
   }

   local pluginUi = nil

   local pluginsSelection = pluginsTreeView:get_selection()
   pluginsSelection.mode = 'SINGLE'

   local function replacePluginInfo()
      if pluginUi then
         pluginUi:destroy()
      end

      local model, iter = pluginsSelection:get_selected()
      if iter then
         local pluginId = pluginsListStore[iter][pluginsColumns.ID]
         pluginUi = plugins.buildPluginUi(window, pluginId, config.plugins[pluginId], log)
      end

      if pluginUi then
         settingsBox:add(pluginUi)
         pluginUi:show_all()
      end
   end

   pluginsSelection.on_changed = replacePluginInfo

   local function updatePlugins()
      local iter = pluginsListStore:get_iter_first()
      while iter do
         local id = pluginsListStore[iter][pluginsColumns.ID]
         local name = pluginsListStore[iter][pluginsColumns.NAME]
         local enabled = pluginsListStore[iter][pluginsColumns.ENABLED]
         if id then
            if not config.plugins[id] then
               config.plugins[id] = {
                  enabled = true,
                  settings = {}
               }
            end
            config.plugins[id].enabled = enabled
         end

         iter = pluginsListStore:next(iter)
      end

      replacePluginInfo()
   end

   -- As inserts are done without values this is used for new rows too
   pluginsListStore.on_row_changed = updatePlugins
   pluginsListStore.on_row_deleted = updatePlugins

   -- Do this on load so that new plugins get added to config TODO: Still needed?
   updatePlugins()

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

               if modifiedCallback then
                  modifiedCallback()
               end
            end
         end

         dialog:destroy()
      end

      dialog:show_all()
      dialog:run()
      updateUi()
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

         if modifiedCallback then
            modifiedCallback()
         end
      end
   end

   return Gtk.Box {
      spacing = 6,
      margin = 6,
      expand = true,
      orientation = 'HORIZONTAL',

      Gtk.Paned {
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
   }
end

return plugins
