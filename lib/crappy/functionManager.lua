local misc = require('crappy.misc')
local functionManager = {}

local functions = {}
local functionsByClass = {}

function functionManager.registerPlugin(plugin)
   for funcName, funcDef in pairs(plugin.functions) do
      if not functionsByClass[funcDef.class] then
         functionsByClass[funcDef.class] = {}
      end
      
      functions[funcName] = funcDef.func
   end
end

function functionManager.getFunction(funcName)
   if functions[funcName] then
      return functions[funcName]
   end

   local func = misc.getFunction(funcName)
   if func then
      functions[funcName] = func
   end

   return func
end

return functionManager
