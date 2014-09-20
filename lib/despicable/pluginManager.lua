local lfs = require('lfs')

local pluginManager = {}

HOME=os.getenv('HOME')

pluginManager.pluginPaths = {
   '/usr/share/awesome/lib/despicable/plugins',
   '/usr/local/share/awesome/lib/despicable/plugins',
   '/etc/xdg/awesome/despicable/plugins',
   HOME .. '/.config/awesome/despicable/plugins',
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

   pluginManager.plugins[plugin.id] = plugin
   print('Added plugin ' .. plugin.id)
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

return pluginManager
