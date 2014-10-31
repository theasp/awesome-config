local lgi = require('lgi')
local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')
local shared = require('crappy.shared')

local plugin = {
   name = 'Bindings',
   description = 'Build standards keybindings',
   id = 'crappy.startup.bindings',
   requires = {"crappy.shared.mainmenu", "crappy.shared.layouts", "crappy.functions.client", "crappy.functions.global", "crappy.shared.settings.terminal"},
   provides = {"crappy.shared.clientkeys", "crappy.shared.clientbuttons"},
   defaults = {
      modKey = "Mod4",
      altKey = "Mod1",
      rootButtons = {
         ["3"] = "crappy.functions.menu.toggle",
         ["4"] = "awful.tag.viewnext",
         ["5"] = "awful.tag.viewprev"
      },
      clientButtons = {
         ["1"] = "crappy.functions.client.focus",
         ["2"] = "crappy.functions.client.focus",
         ["3"] = "crappy.functions.client.focus",
         ["M-1"] = "awful.mouse.client.move",
         ["M-3"] = "awful.mouse.client.resize"
      },
      globalKeys = {
         ["M-<Left>"] = "awful.tag.viewprev",
         ["M-<Right>"] = "awful.tag.viewnext",
         ["M-<Escape>"] = "awful.tag.history.restore",

         ["M-j"] = "crappy.functions.global.focusNext",
         ["M-k"] = "crappy.functions.global.focusPrev",
         ["M-w"] = "crappy.functions.global.showMenu",
         ["M-<Tab>"] = "crappy.functions.global.focusNext",
         ["M-`"] = "crappy.functions.global.focusPrevHist",

         ["M-S-j"] = "crappy.functions.global.swapNext",
         ["M-S-k"] = "crappy.functions.global.swapPrev",
         ["M-C-j"] = "crappy.functions.global.focusNextScreen",
         ["M-C-k"] = "crappy.functions.global.focusPrevScreen",
         ["M-u"] = "awful.client.urgent.jumpto",

         ["M-<Return>"] = "crappy.functions.global.spawnTerminal",
         ["M-x"] = "crappy.functions.global.spawnTerminal",
         ["M-S-x"] = "crappy.functions.global.spawnTerminal",
         ["M-C-r"] = "awesome.restart",
         ["M-S-q"] = "awesome.quit",

         ["M-l"] = "crappy.functions.global.wmfactInc",
         ["M-h"] = "crappy.functions.global.wmfactDec",
         ["M-S-h"] = "crappy.functions.global.nmasterInc",
         ["M-S-l"] = "crappy.functions.global.nmasterDec",
         ["M-C-h"] = "crappy.functions.global.ncolInc",
         ["M-C-l"] = "crappy.functions.global.ncolDec",
         ["M-<space>"] = "crappy.functions.global.layoutInc",
         ["M-S-<space>"] = "crappy.functions.global.layoutDec",

         ["M-r"] = "crappy.functions.global.showRunPrompt",
         ["M-C-x"] = "crappy.functions.global.showLuaPrompt",

         ["M-<F1>"] = "function() crappy.functions.tag.show(1) end",
         ["M-<F2>"] = "function() crappy.functions.tag.show(2) end",
         ["M-<F3>"] = "function() crappy.functions.tag.show(3) end",
         ["M-<F4>"] = "function() crappy.functions.tag.show(4) end",
         ["M-<F5>"] = "function() crappy.functions.tag.show(5) end",
         ["M-<F6>"] = "function() crappy.functions.tag.show(6) end",
         ["M-<F7>"] = "function() crappy.functions.tag.show(7) end",
         ["M-<F8>"] = "function() crappy.functions.tag.show(8) end",
         ["M-<F9>"] = "function() crappy.functions.tag.show(9) end",

         ["M-C-<F1>"] = "function() crappy.functions.tag.toggle(1) end",
         ["M-C-<F2>"] = "function() crappy.functions.tag.toggle(2) end",
         ["M-C-<F3>"] = "function() crappy.functions.tag.toggle(3) end",
         ["M-C-<F4>"] = "function() crappy.functions.tag.toggle(4) end",
         ["M-C-<F5>"] = "function() crappy.functions.tag.toggle(5) end",
         ["M-C-<F6>"] = "function() crappy.functions.tag.toggle(6) end",
         ["M-C-<F7>"] = "function() crappy.functions.tag.toggle(7) end",
         ["M-C-<F8>"] = "function() crappy.functions.tag.toggle(8) end",
         ["M-C-<F9>"] = "function() crappy.functions.tag.toggle(9) end",

         ["M-S-<F1>"] = "function() crappy.functions.tag.clientMoveTo(1) end",
         ["M-S-<F2>"] = "function() crappy.functions.tag.clientMoveTo(2) end",
         ["M-S-<F3>"] = "function() crappy.functions.tag.clientMoveTo(3) end",
         ["M-S-<F4>"] = "function() crappy.functions.tag.clientMoveTo(4) end",
         ["M-S-<F5>"] = "function() crappy.functions.tag.clientMoveTo(5) end",
         ["M-S-<F6>"] = "function() crappy.functions.tag.clientMoveTo(6) end",
         ["M-S-<F7>"] = "function() crappy.functions.tag.clientMoveTo(7) end",
         ["M-S-<F8>"] = "function() crappy.functions.tag.clientMoveTo(8) end",
         ["M-S-<F9>"] = "function() crappy.functions.tag.clientMoveTo(9) end",

         ["M-S-C-<F1>"] = "function() crappy.functions.tag.clientToggle(1) end",
         ["M-S-C-<F2>"] = "function() crappy.functions.tag.clientToggle(2) end",
         ["M-S-C-<F3>"] = "function() crappy.functions.tag.clientToggle(3) end",
         ["M-S-C-<F4>"] = "function() crappy.functions.tag.clientToggle(4) end",
         ["M-S-C-<F5>"] = "function() crappy.functions.tag.clientToggle(5) end",
         ["M-S-C-<F6>"] = "function() crappy.functions.tag.clientToggle(6) end",
         ["M-S-C-<F7>"] = "function() crappy.functions.tag.clientToggle(7) end",
         ["M-S-C-<F8>"] = "function() crappy.functions.tag.clientToggle(8) end",
         ["M-S-C-<F9>"] = "function() crappy.functions.tag.clientToggle(9) end"
      },
      clientKeys = {
         ["M-f"] = "crappy.functions.client.fullscreen",
         ["M-S-c"] = "crappy.functions.client.kill",
         ["M-C-<space>"] = "awful.client.floating.toggle",
         ["M-C-<Return>"] = "crappy.functions.client.swapMaster",
         ["M-o"] = "awful.client.movetoscreen",
         ["M-r"] = "crappy.functions.client.redraw",
         ["M-t"] = "crappy.functions.client.ontop",
         ["M-n"] = "crappy.functions.client.minimized",
         ["M-m"] = "crappy.functions.client.maximized"
      }
   }
}
local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   local ezconfig = require("crappy.ezconfig")
   local awful = misc.use('awful')

   assert(crappy.shared.settings.terminal ~= nil)
   assert(shared.mainmenu ~= nil)
   assert(shared.layouts ~= nil)

   ezconfig.modkey = settings.modKey
   ezconfig.altkey = settings.altKey

   local rootButtons = {}
   for k, v in pairs(settings.rootButtons) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --log.message("Adding root button " .. k .. " -> " .. v)
         table.insert(rootButtons, ezconfig.btn(k, f, awful.button))
      else
         log.warning("Not adding root button " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   root.buttons(awful.util.table.join(unpack(rootButtons)))

   local globalKeys = {}
   for k, v in pairs(settings.globalKeys) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --log.message("Adding global key " .. k .. " -> " .. v)
         table.insert(globalKeys, ezconfig.key(k, f, awful.key))
      else
         log.warning("Not adding global key " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   root.keys(awful.util.table.join(unpack(globalKeys)))

   local clientKeys = {}
   for k, v in pairs(settings.clientKeys) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --log.message("Adding client key " .. k .. " -> " .. v)
         table.insert(clientKeys, ezconfig.key(k, f, awful.key))
      else
         log.warning("Not adding client key " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   shared.clientkeys = awful.util.table.join(unpack(clientKeys))

   local clientButtons = {}
   for k, v in pairs(settings.clientButtons) do
      local f = functionManager.getFunction(v)
      if f ~= nil then
         --log.message("Adding client button " .. k .. " -> " .. v)
         table.insert(clientButtons, ezconfig.btn(k, f, awful.button))
      else
         log.warning("Not adding client button " .. k .. " -> " .. v .. ": Unable to find function")
      end
   end
   shared.clientbuttons = awful.util.table.join(unpack(clientButtons))
end

function plugin.buildUi(window, settings)
   local Gtk = lgi.require('Gtk')
   local GObject = lgi.require('GObject')
   local widgets = require('crappy.gui.widgets')

   local function makeBindingUi(settings, name, class)
      local valid = functionManager.getFunctionsForClass(class)
      table.sort(valid)

      local bindingColumn = {
         BIND = 1,
         FUNC = 2
      }

      local bindingListStore = Gtk.ListStore.new {
         [bindingColumn.BIND] = GObject.Type.STRING,
         [bindingColumn.FUNC] = GObject.Type.STRING
      }
      bindingListStore:set_sort_column_id(bindingColumn.BIND - 1, 0)

      for bind, func in pairs(settings[name]) do
         local iter = bindingListStore:append()
         bindingListStore[iter][bindingColumn.BIND] = bind
         bindingListStore[iter][bindingColumn.FUNC] = func
      end

      local bindingBindCellRenderer = Gtk.CellRendererText { }
      local bindingFuncCellRenderer = Gtk.CellRendererText { }

      local bindingBindTreeViewColumn = Gtk.TreeViewColumn {
         title = 'Binding',
         expand = false,
         sort_column_id = bindingColumn.BIND - 1,
         {
            bindingBindCellRenderer, { text = bindingColumn.BIND }
         }
      }

      local bindingFuncTreeViewColumn = Gtk.TreeViewColumn {
         title = 'Function',
         expand = true,
         sort_column_id = bindingColumn.FUNC - 1,
         {
            bindingFuncCellRenderer, { text = bindingColumn.FUNC }
         }
      }

      local bindingTreeView = Gtk.TreeView {
         model = bindingListStore,
         reorderable = reorderable,
         expand = true,
         bindingBindTreeViewColumn,
         bindingFuncTreeViewColumn
      }

      local bindingSelection = bindingTreeView:get_selection()
      bindingSelection.mode = 'SINGLE'

      local addButton = Gtk.Button {
         use_stock = true,
         label = Gtk.STOCK_ADD,
      }

      local removeButton = Gtk.Button {
         use_stock = true,
         label = Gtk.STOCK_REMOVE,
      }

      local editButton = Gtk.Button {
         use_stock = true,
         label = Gtk.STOCK_EDIT,
      }

      local function editBindingDialog(bindDef)
         if bindDef.bind == nil then
            bindDef.bind = ""
         end

         if bindDef.func == nil then
            bindDef.func = ""
         end

         local bindEntry = Gtk.Entry {
            hexpand = true,
            activates_default = true,
            text = bindDef.bind
         }

         local bindLabel = Gtk.Label {
            label = "_Binding:",
            halign = 'END',
            use_underline = true,
            mnemonic_widget = entry
         }

         local funcComboBox = widgets.functionComboBox(valid, bindDef.func)
         local funcEntry = funcComboBox:get_child()
         funcEntry:set_activates_default(true)

         local funcLabel = Gtk.Label {
            label = "Function:",
            halign = 'END',
            use_underline = true,
            mnemonic_widget = funcComboBox
         }

         local grid = Gtk.Grid {
            row_spacing = 6,
            column_spacing = 6,
            margin = 6,
            expand = true,
         }

         local row = -1;
         local function nextRow()
            row = row + 1
            return row
         end

         grid:attach(bindLabel, 0, nextRow(), 1, 1)
         grid:attach(bindEntry, 1, row, 1, 1)

         grid:attach(funcLabel, 0, nextRow(), 1, 1)
         grid:attach(funcComboBox, 1, row, 1, 1)

         local dialog = Gtk.Dialog {
            title = 'Edit Binding',
            transient_for = window,
            default_width = 600,
            buttons = {
               { Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL },
               { Gtk.STOCK_OK, Gtk.ResponseType.OK },
            },
         }

         dialog:get_content_area():add(grid)

         dialog:set_default_response(Gtk.ResponseType.OK)

         function dialog:on_response(response)
            if response == Gtk.ResponseType.OK then
               --local funcEntry = funcComboBox:get_child()

               bindDef.bind = bindEntry:get_text()
               bindDef.func = funcComboBox:get_active_text()
            end

            dialog:destroy()
         end

         dialog:show_all()
         dialog:run()

         return bindDef
      end

      local function updateBindingListStore()
         log.debug("Updating binding type " .. name)
         settings[name] = {}

         local iter = bindingListStore:get_iter_first()
         while iter do
            bind = bindingListStore[iter][bindingColumn.BIND]
            func = bindingListStore[iter][bindingColumn.FUNC]

            if bind ~= "" and func ~= "" then
               settings[name][bind] = func
            end
            iter = bindingListStore:next(iter)
         end
      end

      bindingListStore.on_row_deleted = updateBindingListStore
      bindingListStore.on_row_changed = updateBindingListStore

      function removeButton:on_clicked()
         local model, iter = bindingSelection:get_selected()
         if model and iter then
            model:remove(iter)
         end
      end

      local function editSelected()
         local model, iter = bindingSelection:get_selected()
         if model and iter then
            local bindDef = {
               bind = bindingListStore[iter][bindingColumn.BIND],
               func = bindingListStore[iter][bindingColumn.FUNC]
            }

            editBindingDialog(bindDef)

            if bindDef.bind ~= nil and bindDef.func ~= nil then
               bindingListStore:set(iter, {
                                       [bindingColumn.BIND] = bindDef.bind,
                                       [bindingColumn.FUNC] = bindDef.func
               })
            end
         end
      end

      editButton.on_clicked = editSelected
      bindingTreeView.on_row_activated = editSelected

      function addButton:on_clicked()
         local bindDef = editBindingDialog({})
         if bindDef.bind ~= nil and bindDef.func ~= nil then
            local iter = bindingListStore:append()
            bindingListStore:set(iter, {
                                    [bindingColumn.BIND] = bindDef.bind,
                                    [bindingColumn.FUNC] = bindDef.func
            })
         end
      end

      return Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         margin = 6,
         Gtk.ScrolledWindow {
            shadow_type = 'ETCHED_IN',
            bindingTreeView
         },
         Gtk.Box {
            orientation = 'HORIZONTAL',
            spacing = 4,
            homogeneous = true,
            addButton,
            removeButton,
            editButton
         }
      }
   end

   local grid = Gtk.Grid {
      row_spacing = 6,
      column_spacing = 6,
      hexpand = true,
   }


   local altKeyEntry = Gtk.Entry {
      hexpand = true
   }

   altKeyEntry:set_text(settings.altKey)

   function altKeyEntry:on_changed()
      settings.altKey = self:get_text()
   end

   local altKeyLabel = Gtk.Label {
      label = 'Alt Key:',
      halign = 'END',
      use_underline = true,
      mnemonic_widget = altKeyEntry
   }


   local modKeyEntry = Gtk.Entry {
      hexpand = true
   }

   modKeyEntry:set_text(settings.modKey)

   function modKeyEntry:on_changed()
      settings.modKey = self:get_text()
   end

   local modKeyLabel = Gtk.Label {
      label = 'Mod Key:',
      halign = 'END',
      use_underline = true,
      mnemonic_widget = modKeyEntry
   }

   local row = -1;
   local function nextRow()
      row = row + 1
      return row
   end

   grid:attach(modKeyLabel, 0, nextRow(), 1, 1)
   grid:attach(modKeyEntry, 1, row, 1, 1)

   grid:attach(altKeyLabel, 0, nextRow(), 1, 1)
   grid:attach(altKeyEntry, 1, row, 1, 1)

   local globalKeysBindingUi = makeBindingUi(settings, 'globalKeys', 'global')
   local rootButtonsBindingUi = makeBindingUi(settings, 'rootButtons', 'global')
   local clientKeysBindingUi = makeBindingUi(settings, 'clientKeys', 'client')
   local clientButtonsBindingUi = makeBindingUi(settings, 'clientButtons', 'client')

   return Gtk.Box {
      orientation = 'VERTICAL',
      spacing = 6,
      margin = 6,
      grid,
      Gtk.Frame {
         label = "Bindings",
         Gtk.Notebook {
            margin = 6,
            expand = true,
            { tab_label = "Global Keys", globalKeysBindingUi },
            { tab_label = "Root Mouse Buttons", rootButtonsBindingUi },
            { tab_label = "Client Keys", clientKeysBindingUi },
            { tab_label = "Client Mouse Buttons", clientButtonsBindingUi }
         }
      }
   }
end

return plugin
