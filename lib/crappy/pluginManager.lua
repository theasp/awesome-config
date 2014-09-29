local lgi = require 'lgi'
local Gio = lgi.require('Gio')

local functionManager = require("crappy.functionManager")

local pluginManager = {}

pluginManager.plugins = {}

HOME=os.getenv('HOME')

pluginManager.pluginPaths = {
   '/usr/share/awesome/lib',
   '/usr/local/share/awesome/lib',
   '/etc/xdg/awesome',
   HOME .. '/.config/awesome',
}

function pluginManager.registerPlugin(plugin)
   if not plugin.provides then
      provides = {}
   end

   if not plugin.provides then
      requires = {}
   end

   if not plugin.type then
      plugin.type = "plugin"
   end

   table.insert(plugin.provides, plugin.id)

   pluginManager.plugins[plugin.id] = plugin

   if plugin.functions then
      functionManager.registerPlugin(plugin)
   end
end

function pluginManager.makePluginFromFunc(pluginId, pluginDef)
   local plugin = {
      id = pluginId,
      startup = pluginManager.getFunction(pluginId),
      requires = pluginDef.requires,
      provides = pluginDef.provides,
      type = "func"
   }

   pluginManager.registerPlugin(plugin)

   return plugin
end

function pluginManager.loadPlugin(file)
   local plugin = dofile(file)

   if plugin then
      pluginManager.registerPlugin(plugin)
   else
      print('Warning: Unable to load plugin ' .. file)
   end
end

function pluginManager.loadPlugins(path)
   local dir = Gio.File.new_for_path(path)
   local dirEnumerator = dir:enumerate_children('*', 'NONE', nil)

   if dirEnumerator then
      local file = dirEnumerator:next_file()
      while file do
         if string.match(file:get_name(), '.lua$') then
            pluginManager.loadPlugin(dir:get_path() .. '/' .. file:get_name())
         end
         file = dirEnumerator:next_file()
      end
   end
end

function pluginManager.loadSubdirPlugins(path)
   local dir = Gio.File.new_for_path(path)
   local dirEnumerator = dir:enumerate_children('*', 'NONE', nil)

   if dirEnumerator then
      local file = dirEnumerator:next_file()
      while file do
         if file:get_file_type() == 'DIRECTORY' then
            if file:get_name() == 'crappy-plugins' then
               pluginManager.loadPlugins(dir:get_path() .. '/' .. file:get_name())
            else
               pluginManager.loadSubdirPlugins(dir:get_path() .. '/' .. file:get_name())
            end
         end
         file = dirEnumerator:next_file()
      end
   end
end

function pluginManager.loadAllPlugins()
   for i, path in ipairs(pluginManager.pluginPaths) do
      pluginManager.loadSubdirPlugins(path)
   end
end

-- http://en.wikipedia.org/wiki/Topological_sorting
function pluginManager.sortByDependency(plugins)
   local markedPlugins = {}
   -- I don't need a graph of all the connections, just enough to
   -- satisfy dependencies, therefore treat tmpMarkedPlugins as marked too
   --local tmpMarkedPlugins = {}
   local tmpMarkedPlugins = markedPlugins
   local result = {}

   local function count(t)
      local c = 0
      for k, v in pairs(t) do
         c = c + 1
      end
      return c
   end

   local function edges(n, plugins)
      local result = {}

      -- Process the plugins to see what plugins this plugin requires
      if n.requires then
         for x, req in ipairs(n.requires) do
            for y, plugin in pairs(plugins) do
               if plugin.provides then
                  for z, provide in ipairs(plugin.provides) do
                     if req == provide then
                        table.insert(result, plugin)
                     end
                  end
               end
            end
         end
      end

      -- Process the plugins to see if anything needs to be before the
      -- current plugin
      for y, plugin in pairs(plugins) do
         if plugin.before then
            for z, before in ipairs(plugin.before) do
               if n.id == before then
                  table.insert(result, plugin)
               end
            end
         end
      end

      return result
   end

   local function selectN(plugins)
      for k, v in pairs(plugins) do
         if not markedPlugins[v] then
            return v
         end
      end
      return nil
   end

   local function visit(n)
      if tmpMarkedPlugins[n] then
         return
      else
         tmpMarkedPlugins[n] = 1
         for i, m in pairs(edges(n, plugins)) do
            visit(m)
         end
         tmpMarkedPlugins[n] = nil
         markedPlugins[n] = 1
         table.insert(result, n)
      end
   end

   while count(plugins) ~= count(markedPlugins) do
      local n = selectN(plugins)
      visit(n)
   end

   return result
end

function pluginManager.simulateLoad(plugins)
   local state = {}
   for k, v in pairs(plugins) do
      if v.requires then
         for j, req in ipairs(v.requires) do
            if not state[req] then
               print('Warning: ' .. v.name .. " needs " .. req .. " but nothing is providing it")
            end
         end
      end

      if v.provides then
         for j, req in ipairs(v.provides) do
            state[req] = 1
         end
      end
   end
end

return pluginManager
