local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')

local despicable = require('despicable/init')

local log = lgi.log.domain('awesome-config/settings')

local startup = {}


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
   FUNCTION = 1,
   ENABLED = 2,
   SETTINGSID = 3,
}

local startupFuncsListStore = Gtk.ListStore.new {
   [startupFuncsColumns.FUNCTION] = GObject.Type.STRING,
   [startupFuncsColumns.ENABLED] = GObject.Type.BOOLEAN,
   [startupFuncsColumns.SETTINGSID] = GObject.Type.UINT,
}

local startupFuncsNameCellRenderer = Gtk.CellRendererText {
   editable = true,
   placeholder_text = "Enter startup function name..."
}

function startupFuncsNameCellRenderer:on_edited(path, text)
   local iter = startupFuncsListStore:get_iter(Gtk.TreePath.new_from_string(path))

   if text ~= "" then
      startupFuncsListStore[iter][startupFuncsColumns.FUNCTION] = text
   else
      startupFuncsListStore:remove(iter)
   end
end

local startupFuncsNameTreeViewColumn = Gtk.TreeViewColumn {
   title = 'Function',
   expand = false,
   {
      startupFuncsNameCellRenderer, { text = 1}
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
   startupFuncsEnabledTreeViewColumn,
   startupFuncsNameTreeViewColumn
}

local startupFuncsTreeModel = startupFuncsTreeView:get_model()

local startupFuncsSelection = startupFuncsTreeView:get_selection()
startupFuncsSelection.mode = 'SINGLE'

local upButton = Gtk.Button {
   id = 'up',
   use_stock = true,
   label = Gtk.STOCK_GO_UP,
}

function upButton:on_clicked()
   local model, iter = startupFuncsSelection:get_selected()
   if model and iter then
      local path = startupFuncsTreeModel:get_path(iter)

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
      local path = startupFuncsTreeModel:get_path(iter)

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
   local iter

   local model, selectedIter = startupFuncsSelection:get_selected()
   if model and selectedIter then
      iter = startupFuncsListStore:insert_before(selectedIter)
      startupFuncsListStore[iter][startupFuncsColumns.FUNCTION] = ''
   else
      iter = startupFuncsListStore:append({[startupFuncsColumns.FUNCTION] = ''})
   end

   startupFuncsTreeView:set_cursor(startupFuncsTreeModel:get_path(iter), startupFuncsNameTreeViewColumn, true)
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


function startup.setConfig(config)
   startupFuncsListStore:clear()
   for i, startupDef in ipairs(config.startup) do
      log.message("Adding %s", startupDef.func)
      startupFuncsListStore:append({
            [startupFuncsColumns.FUNCTION] = startupDef.func,
            [startupFuncsColumns.ENABLED] = startupDef.enabled,
            [startupFuncsColumns.SETTINGSID] = storeSettings(startupDef.settings),
      })
      
   end
end

function startup.updateConfig(config)
   config.startup = {}
   local iter = startupFuncsTreeModel:get_iter_first()
   while iter do
      local func = startupFuncsListStore[iter][startupFuncsColumns.FUNCTION]
      local enabled = startupFuncsListStore[iter][startupFuncsColumns.ENABLED]
      local settingsId = startupFuncsListStore[iter][startupFuncsColumns.SETTINGSID]
      local val = {
         func = func,
         enabled = enabled,
         settings = settingsRefs[settingsId],
      }

      log.message("Updating %s", func)
      if func ~= "" then
         table.insert(config.startup, val)
      end

      iter = startupFuncsTreeModel:next(iter)
   end

   return config
end


startup.ui = Gtk.Box {
   spacing = 6,
   margin = 6,
   expand = true,

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
   }
}

return startup