local lgi = require('lgi')
local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')

local plugin = {
   id = 'crappy.startup.rules',
   name = 'Rules',
   description = 'Rules',
   author = 'Andrew Phillips <theasp@gmail.com>',
   requires = {"crappy.shared.clientkeys", "crappy.shared.clientbuttons", "crappy.shared.tags", "crappy.startup.signals"},
   provides = {},
   defaults = {
      rules = {
         {
            rule = {
               class = "MPlayer"
            },
            properties = {
               floating = true
            }
         },
         {
            rule = {
               class = "pinentry"
            },
            properties = {
               floating = true
            }
         }
      }
   }
}

local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   local shared = require('crappy.shared')
   local awful = misc.use('awful')
   awful.rules = misc.use('awful.rules')

   assert(shared.clientkeys ~= nil)
   assert(shared.clientbuttons ~= nil)

   local rules = {
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       maximized_vertical   = false,
                       maximized_horizontal = false,
                       size_hints_honor = false,
                       keys = shared.clientkeys,
                       buttons = shared.clientbuttons } }}

   for i,rule in ipairs(settings.rules) do
      if rule.properties ~= nil then
         -- As we need to find a reference to the tag, use tag and screen
         -- to find it.  If tag is supplied without screen, set it to nil.
         if rule.properties.tag then
            if rule.properties.screen and shared.tags[rule.properties.screen] then
               rule.properties.tag = shared.tags[tonumber(rule.properties.screen)][tostring(rule.properties.tag)]
            else
               rule.properties.tag = nil
            end
         end
      end

      if rule.callback then
         rule.callback = functionManager.getFunction(rule.callback)
      end

      table.insert(rules, rule)
   end

   awful.rules.rules = rules
end

function plugin.buildUi(window, settings, modifiedCallback)
   local Gtk = lgi.require('Gtk')
   local GObject = lgi.require('GObject')
   local widgets = require('crappy.gui.widgets')

   local ruleDefRefs = {}
   local ruleDefCount = 0

   local function storeRuleDef(ruleDef)
      if ruleDef == nil then
         ruleDef = {}
      end

      ruleDefCount = ruleDefCount + 1
      ruleDefRefs[ruleDefCount] = ruleDef

      return ruleDefCount
   end

   local function removeRuleDef(ruleDefId)
      table.remove(ruleDefRefs, ruleDefId)
   end

   local ruleColumn = {
      NAME = 1,
      ID = 2
   }

   local ruleListStore = Gtk.ListStore.new {
      [ruleColumn.NAME] = GObject.Type.STRING,
      [ruleColumn.ID] = GObject.Type.UINT
   }

   for i, ruleDef in pairs(settings.rules) do
      local name = ruleDef.name
      local id = storeRuleDef(ruleDef)

      if not ruleDef.rule then
         ruleDef.rule = {}
      end

      if name == nil or name == '' then
         if ruleDef.rule.class then
            name = 'Class: ' .. ruleDef.rule.class
         elseif ruleDef.rule.instance then
            name = 'Instance: ' .. ruleDef.rule.instance
         else
            name = 'Unknown'
         end
      end

      ruleDef.name = name

      ruleListStore:append({
            [ruleColumn.NAME] = name,
            [ruleColumn.ID] = id
      })
   end

   local ruleNameCellRenderer = Gtk.CellRendererText { }

   local ruleNameTreeViewColumn = Gtk.TreeViewColumn {
      title = 'Name',
      expand = true,
      {
         ruleNameCellRenderer, { text = ruleColumn.NAME }
      }
   }

   local ruleTreeView = Gtk.TreeView {
      model = ruleListStore,
      ruleNameTreeViewColumn,
   }

   local ruleSelection = ruleTreeView:get_selection()

   local ruleBox = Gtk.Box {
      margin = 6,
      spacing = 0,
      expand = true,
   }

   local function buildRuleUi(ruleDef, ruleIter)
      assert(ruleDef ~= nil)
      assert(ruleIter ~= nil)

      local nameEntry = Gtk.Entry {
         hexpand = true
      }
      nameEntry:set_text(ruleDef.name)

      function nameEntry:on_changed()
         ruleDef.name = nameEntry:get_text()
         ruleListStore:set(ruleIter, {[ruleColumn.NAME] = ruleDef.name})

         if modifiedCallback then
            modifiedCallback()
         end
      end

      local ruleJsonEditor = widgets.jsonEditor(window, ruleDef.rule, modifiedCallback)
      local propertiesJsonEditor = widgets.jsonEditor(window, ruleDef.properties, modifiedCallback)

      return Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         expand = true,
         nameEntry,
         Gtk.Frame {
            expand = true,
            label = "Rule",
            ruleJsonEditor
         },
         Gtk.Frame {
            expand = true,
            label = "Properties",
            propertiesJsonEditor
         }
      }
   end

   local ruleUi

   local function replaceRuleInfo()
      if ruleUi then
         ruleUi:destroy()
      end

      local model, iter = ruleSelection:get_selected()
      if iter then
         local ruleId = ruleListStore[iter][ruleColumn.ID]
         ruleUi = buildRuleUi(ruleDefRefs[ruleId], iter)
      end

      if ruleUi then
         ruleBox:add(ruleUi)
         ruleUi:show_all()
      end
   end

   ruleSelection.on_changed = replaceRuleInfo

   local addButton = Gtk.Button {
      id = 'add',
      use_stock = true,
      label = Gtk.STOCK_ADD,
   }

   function addButton:on_clicked()
      local ruleDef = {}
      ruleDef.rule = {}
      ruleDef.properties = {}
      ruleDef.name = "Unknown"

      local id = storeRuleDef(ruleDef)

      ruleListStore:append({
            [ruleColumn.NAME] = ruleDef.name,
            [ruleColumn.ID] = id
      })

      if modifiedCallback then
         modifiedCallback()
      end
   end

   local removeButton = Gtk.Button {
      id = 'remove',
      use_stock = true,
      label = Gtk.STOCK_REMOVE,
   }

   return Gtk.Paned {
      margin = 6,
      Gtk.Box {
         orientation = 'VERTICAL',
         spacing = 6,
         hexpand = false,
         vexpand = true,

         Gtk.ScrolledWindow {
            shadow_type = 'ETCHED_IN',
            hexpand = false,
            vexpand = true,
            ruleTreeView
         },

         Gtk.Box {
            orientation = 'HORIZONTAL',
            spacing = 4,
            homogeneous = true,
            addButton,
            removeButton
         }
      },
      ruleBox
   }
end

return plugin
