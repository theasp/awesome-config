local misc = require('crappy.misc')
local functionManager = {}

local functions = {}
local functionsByClass = {}

functionManager.functions = functions
functionManager.functionsByClass = functionsByClass

function functionManager.registerFunction(funcDef)
   if not functionsByClass[funcDef.class] then
      functionsByClass[funcDef.class] = {}
   end

   functions[funcDef.id] = funcDef
   functionsByClass[funcDef.class][funcDef.id] = funcDef
end
   
function functionManager.registerPlugin(plugin)
   for funcId, funcDef in pairs(plugin.functions) do
      funcDef.id = funcId
      functionManager.registerFunction(funcDef)
   end
end

function functionManager.getFunction(funcId)
   local funcDef = functions[funcId]
   if funcDef and funcDef.func then
      return funcDef.func
   end

   local func = misc.getFunction(funcId)
   if func then
      functions[funcId] = {
         class = 'unknown',
         description = 'Unknown',
         func = func
      }
   end

   return func
end

function functionManager.getFunctionsForClass(class)
   local list = {}

   for i, v in pairs(functionsByClass[class]) do
      table.insert(list, i)
   end

   return list
end

return functionManager
