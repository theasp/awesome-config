local misc = {}

-- http://snippets.luacode.org/snippets/Simple_Table_Dump_7
function misc.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k, v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. misc.dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- http://stackoverflow.com/a/7470789
function misc.mergeTable(t1, t2)
   for k, v in pairs(t2) do
      if (type(v) == "table") and (type(t1[k] or false) == "table") then
         misc.mergeTable(t1[k], t2[k])
      else
         if t1[k] == nil then
            t1[k] = v
         end
      end
   end
   return t1
end

-- http://www.lua.org/pil/14.1.html
function misc.getFunction (f)
   local v 

   -- TODO: Fix RE...  Can't seem to use "^function *\(", it always
   -- complains about missing capture...
   if (string.match(f, '^function')) then
      v = (loadstring("return " .. f))()
   else
      v = _G    -- start with the table of globals
      for w in string.gfind(f, "[%w_]+") do
         --print("w: " .. w)
         if v ~= nil then
            v = v[w]
         end
      end
   end

   return v
end

-- Yo-dah
function misc.use(name)
   result = require(name)

   if type(result) ~= "boolean" then
      return result
   else
      return nil
   end
end


return misc
