local misc = {}

-- http://snippets.luacode.org/snippets/Simple_Table_Dump_7
function misc.dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k, v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. crappy.misc.dump(v) .. ','
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
         crappy.misc.mergeTable(t1[k], t2[k])
      else
         t1[k] = v
      end
   end
   return t1
end

-- http://www.lua.org/pil/14.1.html
-- TODO: Can I make this not require globals?  I'm thinking not.
function misc.getFunction (f)
   local v 

   -- TODO: Fix RE...  Can't seem to use "^function *\(", it always
   -- complains about missing capture...
   if (string.match(f, '^function')) then
      v = (loadstring("return " .. f))()
   else
      v = _G    -- start with the table of globals
      for w in string.gfind(f, "[%w_]+") do
         v = v[w]
      end
   end

   if v == nil then
      print("Unable to find function: " .. f)
      assert(v ~= nil)
   end

   return v
end

return misc
