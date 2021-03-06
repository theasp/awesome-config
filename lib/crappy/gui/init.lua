local lgi = require('lgi')
local Gtk = lgi.require('Gtk')
local Gio = lgi.require('Gio')

local log = lgi.log.domain('crappy.gui')

local configManager = require('crappy.configManager')
local pluginManager = require('crappy.pluginManager')
local misc = require('crappy.misc')

local fallback = require('crappy.gui.fallback')

local gui = {}

gui.title = "Awesome Config"
gui.version = "0.3"
gui.authors = {
   "Andrew Phillips",
}
gui.plugins = require('crappy.gui.plugins')

function gui.newWindow(app, file)
   log.message("Opening new window")
   local pluginTabs = {}
   local pluginsUi = nil
   local config = configManager.new()
   local configModified = true

   local window = Gtk.ApplicationWindow {
      type = Gtk.WindowType.TOPLEVEL,
      id = 'Awesome-Config',
      application = app,
      title = gui.title,
      default_width = 600,
      default_height = 400,
   }

   local mainNotebook = Gtk.Notebook {
      scrollable = true,
   }

   local function setWindowTitle()
      local fileName = file and file:get_parse_name()
      if fileName == nil then
         fileName = "<Unknown>"
      end

      local modifiedFlag = ""
      if configModified then
         modifiedFlag = "*"
      end

      window:set_title(gui.title .. ' - ' .. modifiedFlag .. fileName)
   end

   local function setConfigModified(modified)
      configModified = modified
      if file == nil then
         configModified = true
      end

      if configModified then
         log.message("Modified state changed to true")
      else
         log.message("Modified state changed to false")
      end

      setWindowTitle()
   end

   local function modifiedCallback()
      setConfigModified(true)
   end

   -- Function to add a plugin tab
   local function addPluginTab(pluginId)
      local plugin = pluginManager.plugins[pluginId]
      local label = Gtk.Label { label = plugin.name }
      local settings = config.plugins[pluginId].settings

      -- Use the plugin's buildUi function to populate the tab,
      -- otherwise use the fallback.
      local ui
      if plugin.buildUi then
         ui = plugin.buildUi(window, settings, modifiedCallback)
      else
         ui = fallback.buildUi(plugin, window, settings, modifiedCallback)
      end

      -- Don't add a tab if the plugin's buildUi function returned nil
      if ui then
         ui:show_all()
         mainNotebook:append_page(ui, label)
      end

      return ui
   end

   -- Function to reset the GUI based on the current config
   local function updateUi()
      configManager.makeFullConfig(config)

      if not pluginsUi then
         pluginsUi = gui.plugins.buildUi(window, config, updateUi, modifiedCallback)
         local pluginsUiLabel = Gtk.Label { label = "Plugins"}

         pluginsUi:show_all()
         mainNotebook:append_page(pluginsUi, pluginsUiLabel)
      end

      local enabledPlugins = configManager.getEnabledPlugins(config)

      local sortedPlugins = {}
      for pluginId, pluginInfo in pairs(config.plugins) do
         table.insert(sortedPlugins, pluginId)
      end

      table.sort(sortedPlugins)

      -- Add all new enabled pluginTabs
      for i, pluginId in ipairs(sortedPlugins) do
         if not pluginTabs[pluginId] and enabledPlugins[pluginId] then
            pluginTabs[pluginId] = addPluginTab(pluginId)
         end
      end

      -- Remove existing tabs that aren't enabled
      for pluginId, pluginTab in pairs(pluginTabs) do
         if not enabledPlugins[pluginId] then
            pluginTab:destroy()
            pluginTabs[pluginId] = nil
         end
      end
   end

   local function resetUi()
      for pluginId, pluginTab in pairs(pluginTabs) do
         pluginTab:destroy()
      end
      pluginTabs = {}

      if pluginsUi then
         pluginsUi:destroy()
         pluginsUi = nil
      end

      updateUi()
      setWindowTitle()
   end

   local function newFile()
      log.message('New file')

      gui.newWindow(app, nil)
   end

   local function loadFile(f)
      print("Loading file")
      file = f
      local configText = f:load_contents()

      config = configManager.parse(tostring(configText))
      setConfigModified(false)
      resetUi()
   end

   local function loadFileDialog()
      local dialog = Gtk.FileChooserDialog {
         title = "Open File",
         transient_for = window,
         action = 'OPEN',
         buttons = {
            {Gtk.STOCK_CLOSE, Gtk.ResponseType.CLOSE},
            {Gtk.STOCK_OPEN, Gtk.ResponseType.ACCEPT}
         }
      }

      local res = dialog:run()

      if res == Gtk.ResponseType.ACCEPT then
         local fileName = dialog:get_uri()
         file = Gio.File.new_for_uri(fileName)
         gui.newWindow(app, file)
      end
      dialog:destroy()
   end

   local function saveFile()
      log.message('Save file')

      if configManager.save(file:get_path(), config) then
         setConfigModified(false)
         return true
      else
         return false
      end
   end

   local function saveFileDialog()
      log.message("saveFileDialog")

      local dialog = Gtk.FileChooserDialog {
         title = "Save File",
         transient_for = window,
         action = 'SAVE',
         buttons = {
            {Gtk.STOCK_CLOSE, Gtk.ResponseType.CLOSE},
            {Gtk.STOCK_SAVE, Gtk.ResponseType.ACCEPT}
         }
      }

      local res = dialog:run()
      dialog:destroy()

      if res == Gtk.ResponseType.ACCEPT then
         file = dialog:get_filename()
         return saveFile()
      else
         return false
      end
   end

   local function close()
      if configModified then
         local fileName = file and file:get_parse_name()
         local saveStockButton = {Gtk.STOCK_SAVE, Gtk.ResponseType.ACCEPT}

         if fileName == nil then
            fileName = "<Unknown>"
            local saveStockButton = {Gtk.STOCK_SAVE_AS, Gtk.ResponseType.ACCEPT}
         end

         local dialog = Gtk.Dialog {
            title = fileName,
            transient_for = window,
            buttons = {
               {Gtk.STOCK_CLOSE, Gtk.ResponseType.CLOSE},
               {Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL},
               saveStockButton
            }
         }

         local hbox = Gtk.Box {
            orientation = 'HORIZONTAL',
            spacing = 8,
            border_width = 8,
            Gtk.Image {
               stock = Gtk.STOCK_DIALOG_QUESTION,
               icon_size = Gtk.IconSize.DIALOG,
            },
            Gtk.Label {
               label = "Save changes to document \"" .. fileName .. "\" before closing?"
            }
         }
         dialog:get_content_area():add(hbox)
         hbox:show_all()

         local res = dialog:run()
         dialog:destroy()

         if res == Gtk.ResponseType.CANCEL then
            return true
         end

         if res == Gtk.ResponseType.ACCEPT then
            if file == nil then
               if saveFileDialog() == false then
                  return true
               end
            else
               if saveFile() == false then
                  return true
               end
            end
         end
      end

      log.message("Closing window...")

      window:destroy()

      -- for i, oldWindow in ipairs(gui.windows) do
      --    if oldWindow == window then
      --       gui.windows[i] = nil
      --    end
      -- end
   end

   local function quit()
      log.message("Quitting...")

      for i, oldWindow in ipairs(app:get_windows()) do
         if oldWindow then
            log.message("Window " .. i .. " is still open")
            oldWindow:close()
         end
      end
   end

   local function about()
      local about = Gtk.AboutDialog {
         title = "About Awesome Config",
         program_name = "Awesome Config",
         version = gui.version,
         copyright = "© 2015 Andrew Phillips",
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
                     on_activate = loadFileDialog },
        accelerator = '<control>O', },
      { Gtk.Action { name = 'Save', stock_id = Gtk.STOCK_SAVE, label = "_Save",
                     tooltip = "Save current file",
                     on_activate = saveFile },
        accelerator = '<control>S', },
      Gtk.Action { name = 'SaveAs', stock_id = Gtk.STOCK_SAVE,
                   label = "Save _As...", tooltip = "Save to a file",
                   on_activate = saveFileDialog },
      { Gtk.Action { name = 'Close', stock_id = Gtk.STOCK_CLOSE,
                     tooltip = "Close",
                     on_activate = close },
        accelerator = '<control>C', },
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
               <menuitem action='Close'/>
               <menuitem action='Quit'/>
            </menu>
               <menu action='HelpMenu'>
               <menuitem action='About'/>
            </menu>
               </menubar>
               <toolbar  name='ToolBar'>
               <toolitem action='Open'/>
               <toolitem action='Save'/>
               <toolitem action='Close'/>
            </toolbar>
               </ui>
      ]], -1)

   if not ok then
      log.message('building menus failed: %s', err)
   end

   window:add(Gtk.Box {
                 orientation = 'VERTICAL',
                 ui:get_widget('/MenuBar'),
                 ui:get_widget('/ToolBar'),
                 mainNotebook
   })

   window:add_accel_group(ui:get_accel_group())

   -- Show window and start the loop.
   window:show_all()

   if file then
      loadFile(file)
   else
      config = configManager.new()
      resetUi()
   end

   window.on_delete_event = close

   return window
end

return gui
