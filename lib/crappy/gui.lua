local lgi = require 'lgi'
local Gtk = lgi.require('Gtk')

local log = lgi.log.domain('awesome-config-gui')

local despicable = require('despicable')
local settings 
local startup 

local gui = {}

gui.settings = require('awesome-config.gui.settings')
gui.startup = require('awesome-config.gui.startup')

local file = "/tmp/poop.json"

local function setConfig(config)
   gui.settings.setConfig(config)
   gui.startup.setConfig(config)
end

local function updateConfig(config)
   gui.settings.updateConfig(config)
   gui.startup.updateConfig(config)
end

local function activate_action(action)
   log.message('Action "%s" activated', action.name)
end

local function quit()
   Gtk.main_quit()
end

local function newFile()
   log.message('New file')

   local config = despicable.new()
   setConfig(config)
end

local function loadFile()
   log.message("Loading file " .. file)

   local config = despicable.load(file, config)
   setConfig(config)
end


local function saveFile()
   log.message('Save file')

   local config = despicable.new()
   updateConfig(config)

   despicable.save(file, config)
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
		  on_activate = activate_action }
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
   title = 'Awesome Config',
   on_destroy = quit
}

window:add(Gtk.Box {
              orientation = 'VERTICAL',
              ui:get_widget('/MenuBar'),
              ui:get_widget('/ToolBar'),
              Gtk.Notebook {
                 {
                    tab_label = "Settings",
                    gui.settings.buildUi(window)
                 },
                 {
                    tab_label = "Startup",
                    gui.startup.buildUi(window)
                 },
              }
})


window:add_accel_group(ui:get_accel_group())

loadFile()

-- Show window and start the loop.
window:show_all()
Gtk.main()

return gui
