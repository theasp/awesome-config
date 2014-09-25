local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

local log = lgi.log.domain('awesome-config-gui')

local configManager = require('crappy.configManager')
local pluginManager = require('crappy.pluginManager')
local misc = require('crappy.misc')

pluginManager.loadAllPlugins()

local gui = {}

gui.pluginTabs = {}

gui.plugins = require('crappy.gui.plugins')

local app = Gtk.Application {application_id = 'awesome-config.crappy.gui'}

gui.config = configManager.new()

function gui.quit()
   Gtk.main_quit()
end

function gui.activate_action(action)
   log.message('Action "%s" activated', action.name)
end

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


function app:on_activate()
   HOME=os.getenv('HOME')
   local file = HOME .. "/.config/awesome/crappy.json"

   local function addPluginTab(plugin)
      print("Adding tab " .. plugin.id)
      local label = Gtk.Label { label = plugin.name }
      local settings = gui.config.plugins[plugin.id].settings
      if not settings then
         settings = {}
         gui.config.plugins[plugin.id].settings = settings
      end

      local ui = plugin.buildUi(window, settings)
      if ui then
         ui:show_all()
         gui.mainNotebook:append_page(ui, label)
      end
   end

   local function updateUi()
      if (gui.pluginsUi) then
         gui.pluginsUi:destroy()
      end

      gui.pluginsUi = gui.plugins.buildUi(window, gui.config)
      gui.pluginsUiLabel = Gtk.Label { label = "Plugins"}
      gui.pluginsUi:show_all()
      gui.mainNotebook:append_page(gui.pluginsUi, gui.pluginsUiLabel)

      for i, pluginTab in pairs(gui.pluginTabs) do
         pluginTab:destroy()
      end

      local enabledPlugins = configManager.getEnabledPlugins(gui.config)
      table.sort(enabledPlugins,
                 function(a,b)
                    if a.name < b.name then
                       return true
                    end
                 end
      )

      for i, plugin in ipairs(enabledPlugins) do
         if plugin.buildUi then
            addPluginTab(plugin)
         end
      end
   end

   local function newFile()
      log.message('New file')

      gui.config = configManager.new()
      updateUi()
   end

   local function loadFile()
      log.message("Loading file " .. file)

      gui.config = configManager.load(file)
      updateUi()
   end

   local function saveFile()
      log.message('Save file')

      configManager.save(file, gui.config)
   end

   local actions = Gtk.ActionGroup {
      name = 'Actions',
      Gtk.Action { name = 'FileMenu', label = "_File" },
      Gtk.Action { name = 'HelpMenu', label = "_Help" },
      { Gtk.Action { name = 'New', stock_id  = Gtk.STOCK_NEW, label = "_New",
                     tooltip = "Create a new file",
                     on_activate = newFile },
        accelerator = '<control>N', },
      { Gtk.Action { name = 'Open', stock_id = Gtk.STOCK_OPEN, label = "_Open",
                     tooltip = "Open a file",
                     on_activate = gui.activate_action },
        accelerator = '<control>O', },
      { Gtk.Action { name = 'Save', stock_id = Gtk.STOCK_SAVE, label = "_Save",
                     tooltip = "Save current file",
                     on_activate = saveFile },
        accelerator = '<control>S', },
      Gtk.Action { name = 'SaveAs', stock_id = Gtk.STOCK_SAVE,
                   label = "Save _As...", tooltip = "Save to a file",
                   on_activate = activate_action },
      { Gtk.Action { name = 'Quit', stock_id = Gtk.STOCK_QUIT,
                     tooltip = "Quit",
                     on_activate = gui.quit },
        accelerator = '<control>Q', },
      { Gtk.Action { name = 'About', stock_id = Gtk.STOCK_ABOUT, label = "_About",
                     tooltip = "About",
                     on_activate = gui.activate_action }
      }
   }

   local ui = Gtk.UIManager()
   ui:insert_action_group(actions, 0)

   local ok, err = ui:add_ui_from_string(
      [[
<ui>
  <menubar name='MenuBar'>
    <menu action='FileMenu'>
      <menuitem action='New'/>
      <menuitem action='Open'/>
      <menuitem action='Save'/>
      <menuitem action='SaveAs'/>
      <separator/>
      <menuitem action='Quit'/>
    </menu>
    <menu action='HelpMenu'>
      <menuitem action='About'/>
    </menu>
  </menubar>
  <toolbar  name='ToolBar'>
    <toolitem action='Open'/>
    <toolitem action='Save'/>
    <toolitem action='Quit'/>
  </toolbar>
</ui>]], -1)

   if not ok then
      log.message('building menus failed: %s', err)
   end

   local window = Gtk.ApplicationWindow {
      type = Gtk.WindowType.TOPLEVEL,
      application = app,
      title = 'Awesome Config',
      on_destroy = gui.quit
   }

   gui.mainNotebook = Gtk.Notebook {}

   window:add(Gtk.Box {
                 orientation = 'VERTICAL',
                 ui:get_widget('/MenuBar'),
                 ui:get_widget('/ToolBar'),
                 gui.mainNotebook

   })

   window:add_accel_group(ui:get_accel_group())

   -- Show window and start the loop.
   window:show_all()

   loadFile()

   Gtk.main()
end

function gui.run()
   app:run {}
end

return gui
