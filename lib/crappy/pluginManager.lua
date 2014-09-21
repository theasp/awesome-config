local lfs = require('lfs')

local pluginManager = {}

HOME=os.getenv('HOME')

pluginManager.pluginPaths = {
   '/usr/share/awesome/lib/crappy-plugins',
   '/usr/local/share/awesome/lib/crappy-plugins',
   '/etc/xdg/awesome/crappy-plugins',
   HOME .. '/.config/awesome/crappy-plugins',
}

pluginManager.functions = {}
pluginManager.startupFunctions = {}
pluginManager.plugins = {}

function pluginManager.addFunction(funcType, funcName, owner, description)
   functions[funcType][funcName] = {
      owner = ownerName,
      description = description
   }
end

function pluginManager.addStartupFunction(funcName, defaultFuncName, lgiFuncName, owner, description)
   functions[funcName] = {
      defaultFuncName = defaultFuncName,
      lgiFuncName = lgiFuncName,
      owner = ownerName,
      description = description
   }
end

function pluginManager.loadPlugin(file)
   local plugin = dofile(file)

   if plugin then
      pluginManager.plugins[plugin.id] = plugin
      print('Added plugin ' .. plugin.id)
   end
end

function pluginManager.loadPlugins(path)
   local res, files, iter = pcall(lfs.dir, path)

   if res then
      local file = iter:next()
      while file do
         if string.match(file, '.lua$') then
            pluginManager.loadPlugin(path .. '/' .. file)
         end
         file = iter:next()
      end
      iter:close()
   end
end

function pluginManager.loadAllPlugins()
   print('Loading all plugins')
   for i, path in ipairs(pluginManager.pluginPaths) do
      pluginManager.loadPlugins(path)
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

      if n.requires then
         for x, req in ipairs(n.requires) do
            for y, plugin in pairs(plugins) do
               if plugin.provides then
                  for z, provide in ipairs(plugin.provides) do
                     if req == provide then
                        --print(n.id .. " requires " .. plugin.id)
                        table.insert(result, plugin)
                     end
                  end
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
      --print("Looking at " .. n.id)
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
