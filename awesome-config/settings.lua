local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')
local GObject = lgi.require('GObject')

local despicable = require('despicable/init')

local log = lgi.log.domain('awesome-config/settings')

local settings = {}
local layouts = {}
local row = -1;

local titlebarCheckButton = Gtk.CheckButton {
   label = 'Show _Titlebar',
   id = 'settings.titlebar',
   use_underline = true
}

local sloppyfocusCheckButton = Gtk.CheckButton {
   label = '_Sloppy Focus',
   id = 'settings.sloppyfocus',
   use_underline = true
}

local terminalEntry = Gtk.Entry {
   hexpand = true,
   id = 'settings.terminal'
}

local editorEntry = Gtk.Entry {
   hexpand = true,
   id = 'settings.editor'
}

local layoutsListStore = Gtk.ListStore.new {
   [1] = GObject.Type.STRING
}

local layoutsNameCellRenderer = Gtk.CellRendererText {
   editable = true,
   placeholder_text = "Enter layout function name..."
}

function layoutsNameCellRenderer:on_edited(path, text)
   local iter = layoutsListStore:get_iter(Gtk.TreePath.new_from_string(path))

   if text ~= "" then
      layoutsListStore[iter][1] = text
   else
      layoutsListStore:remove(iter)
   end
end

local layoutsNameTreeViewColumn = Gtk.TreeViewColumn {
   title = 'Layout',
   expand = true,
   {
      layoutsNameCellRenderer, { text = 1}
   }
}

local layoutsTreeView = Gtk.TreeView {
   model = layoutsListStore,
   id = 'settings.layouts',
   reorderable = true,
   layoutsNameTreeViewColumn
}

local layoutsTreeModel = layoutsTreeView:get_model()

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
      local path = layoutsTreeModel:get_path(iter)

      if path:prev() then
         local prevIter = layoutsListStore:get_iter(path)
         if prevIter then
            layoutsListStore:swap(iter, prevIter)
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
   local model, iter = layoutsSelection:get_selected()
   if model and iter then
      local path = layoutsTreeModel:get_path(iter)

      -- This works differently than prev()
      path:next()
      if path then
         local nextIter = layoutsListStore:get_iter(path)
         if nextIter then
            layoutsListStore:swap(iter, nextIter)
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

   local model, selectedIter = layoutsSelection:get_selected()
   if model and selectedIter then
      iter = layoutsListStore:insert_before(selectedIter)
      layoutsListStore[iter][1] = ''
   else
      iter = layoutsListStore:append({[1] = ''})
   end

   layoutsTreeView:set_cursor(layoutsTreeModel:get_path(iter), layoutsNameTreeViewColumn, true)
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
end

function settings.setConfig(config)
   config.settings = despicable.default.settings(config.settings)
   titlebarCheckButton:set_active(config.settings.titlebar)
   sloppyfocusCheckButton:set_active(config.settings.sloppyfocus)
   terminalEntry:set_text(config.settings.terminal)
   editorEntry:set_text(config.settings.editor)

   layoutsListStore:clear()
   for i, layoutName in ipairs(config.settings.layouts) do
      layoutsListStore:append({[1] = layoutName})
   end
end

function settings.updateConfig(config)
   config.settings = despicable.default.settings(config.settings)
   config.settings.titlebar = titlebarCheckButton:get_active()
   config.settings.sloppyfocus = sloppyfocusCheckButton:get_active()
   config.settings.terminal = terminalEntry:get_text()
   config.settings.editor = editorEntry:get_text()

   config.settings.layouts = {}
   local ok
   local iter = layoutsTreeModel:get_iter_first()
   while iter do
      val = layoutsListStore[iter][1]

      if val ~= "" then
         table.insert(config.settings.layouts, val)
      end
      iter = layoutsTreeModel:next(iter)
   end

   return config
end

local function nextRow()
   row = row + 1
   return row
end

settings.ui = Gtk.ScrolledWindow {
   shadow_type = 'ETCHED_IN',
   margin = 6,
   expand = true,

   Gtk.Grid {
      row_spacing = 6,
      column_spacing = 6,
      margin = 6,
      expand = true,

      {
         left_attach = 0, top_attach = nextRow(),
         titlebarCheckButton
      },

      {
         left_attach = 0, top_attach = nextRow(),
         sloppyfocusCheckButton
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = 'Te_rminal Emulator:',
            use_underline = true,
            mnemonic_widget = terminalEntry
         },
      },
      {
         left_attach = 1, top_attach = row,
         terminalEntry
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = '_Editor:',
            use_underline = true,
            mnemonic_widget = editorEntry
         },
      },
      {
         left_attach = 1, top_attach = row,
         editorEntry
      },

      {
         left_attach = 0, top_attach = nextRow(),
         Gtk.Label {
            label = '_Layouts:',
            use_underline = true,
            mnemonic_widget = layoutsTreeView,
            valign = 'START',
         },
      },
      {
         left_attach = 1, top_attach = row,
         Gtk.Box {
            orientation = 'VERTICAL',
            spacing = 6,
            expand = true,

            Gtk.ScrolledWindow {
               shadow_type = 'ETCHED_IN',
               expand = true,
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
   }
}

return settings
