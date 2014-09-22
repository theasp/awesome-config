local misc = require('crappy.misc')
local functionManager = {}

local functions = {}
local functionsByClass = {}

function functionManager.registerPlugin(plugin)
   for funcName, funcDef in pairs(plugin.functions) do
      if not functionsByClass[funcDef.class] then
         functionsByClass[funcDef.class] = {}
      end
      
      functions[funcName] = funcDef
      functionsByClass[funcDef.class][funcName] = funcDef
   end
end

function functionManager.getFunction(funcName)
   local funcDef = functions[funcName]
   if funcDef and funcDef.func then
      return funcDef.func
   end

   local func = misc.getFunction(funcName)
   if func then
      functions[funcName] = {
         class = 'unknown',
         description = 'Unknown',
         func = func
      }
   end

   return func
end

return functionManager
