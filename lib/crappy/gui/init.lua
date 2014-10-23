local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

local log = lgi.log.domain('gui')

local configManager = require('crappy.configManager')
local pluginManager = require('crappy.pluginManager')
local misc = require('crappy.misc')

local fallback = require('crappy.gui.fallback')

local gui = {}

gui.version = "0.2"
gui.authors = {
   "Andrew Phillips",
}
gui.plugins = require('crappy.gui.plugins')
gui.pluginTabs = {}
gui.file = nil

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

function gui.on_startup(app)
   pluginManager.loadAllPlugins()
   gui.config = configManager.new()
end

function gui.on_shutdown(app)
end

function gui.on_activate(app)
   local function addPluginTab(plugin)
      log.message("Adding tab " .. plugin.id)
      local pluginLog = lgi.log.domain('gui/' .. plugin.id)
      local label = Gtk.Label { label = plugin.name }
      local settings = gui.config.plugins[plugin.id].settings
      if not settings then
         settings = {}
         gui.config.plugins[plugin.id].settings = settings
      end

      local ui
      if plugin.buildUi then
         ui = plugin.buildUi(window, settings, pluginLog)
      else
         ui = fallback.buildUi(window, settings, pluginLog)
      end

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
         addPluginTab(plugin)
      end
   end

   local function quit()
      log.message("Quitting...")
      app:quit()
   end

   local function activate_action(action)
      log.message('Action "%s" activated', action.name)
   end

   local function newFile()
      log.message('New file')

      gui.config = configManager.new()
      updateUi()
   end

   local function loadFile()
      log.message("Loading file " .. gui.file)

      gui.config = configManager.load(gui.file)
      updateUi()
   end

   local function saveFile()
      log.message('Save file')

      configManager.save(gui.file, gui.config)
   end

   local function about()
      local about = Gtk.AboutDialog {
         title = "About Awesome Config",
         program_name = "Awesome Config",
         version = gui.version,
         copyright = "© 2014 Andrew Phillips",
         license_type = 'GPL_2_0',
         website = 'http://github.com/theasp/awesome-config',
         authors = gui.authors
      }
      about:run()
      about:hide()
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
                     on_activate = activate_action },
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
                     on_activate = quit },
        accelerator = '<control>Q', },
      { Gtk.Action { name = 'About', stock_id = Gtk.STOCK_ABOUT, label = "_About",
                     tooltip = "About",
                     on_activate = about }
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
</ui>
]], -1)

   if not ok then
      log.message('building menus failed: %s', err)
   end

   local window = Gtk.ApplicationWindow {
      type = Gtk.WindowType.TOPLEVEL,
      application = app,
      title = 'Awesome Config',
      default_width = 600,
      default_height = 400,
      on_destroy = quit
   }

   gui.mainNotebook = Gtk.Notebook {
      scrollable = true,
   }

   window:add(Gtk.Box {
                 orientation = 'VERTICAL',
                 ui:get_widget('/MenuBar'),
                 ui:get_widget('/ToolBar'),
                 gui.mainNotebook
   })

   window:add_accel_group(ui:get_accel_group())

   -- Show window and start the loop.
   window:show_all()

   HOME=os.getenv('HOME')
   gui.file = HOME .. "/.config/awesome/crappy.json"
   loadFile()

   return window
end

return gui
