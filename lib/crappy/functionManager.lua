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

      print("Registered " .. funcName)
   end
end

function functionManager.addFunction(plugin, funcName)
   local funcDef = plugin.functions[funcName]
   
   if not functionsByClass[funcDef.class] then
      functionsByClass[funcDef.class] = {}
   end

   functionDefs[funcDef.class][funcName] = {
      owner = plugin.id,
      description = funcDef.description,
      func = funcDef.func,
   }

   functions[funcName] = func

   print("Registed " .. funcName .. " from " .. plugin.id)
end

function functionManager.getFunction(funcName)
   print("Looking for function: " .. funcName)
   if functions[funcName] then
      print("Found function: " .. funcName)
      
      return functions[funcName]
   end

   local func = misc.getFunction(funcName)
   if func then
      functions[funcName] = func
   end

   return func
end

return functionManager
