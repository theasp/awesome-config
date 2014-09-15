#!/usr/bin/lua

-- Load some of crappy
crappy = {}
crappy.json = require("crappy.JSON") 
crappy.misc = require("crappy.misc")
crappy.default = require("crappy.default")

crappy.awesomeconf = {}
crappy.awesomeconf.command = {}

function crappy.awesomeconf.command.quit(ctx, tokens)
   os.exit()
end

function crappy.awesomeconf.command.help(ctx, tokens)
   print("Commands:")

   for name, func in pairs(ctx.commands) do
      print("  " .. name)
   end
end

function crappy.awesomeconf.command.show(ctx, tokens)
   if tokens[2] == nil then
      print(crappy.json:encode_pretty(ctx.config))
   else
      if ctx.config[tokens[2]] ~= nil then
         print(crappy.json:encode_pretty(ctx.config[tokens[2]]))
      end
   end
end

function crappy.awesomeconf.command.list(ctx, tokens)
   if tokens[2] == nil then
      if ctx.path == "/startup/" then
         for name,value in pairs(ctx.config) do
            print(name, ctx.config[name].func)
         end
      else
         for name,value in pairs(ctx.config) do
            print(name)
         end
      end
   else
      if ctx.config[tokens[2]] ~= nil and type(ctx.config[tokens[2]]) == "table" then
         for name,value in pairs(ctx.config[tokens[2]]) do
            print(name)
         end
      else
         print("Unable to list " .. tokens[2])
      end
   end
end

function crappy.awesomeconf.command.top(ctx, tokens)
   ctx.path = "/"
   ctx.config = ctx.top
end

function crappy.awesomeconf.command.settings(ctx, tokens)
   ctx.path = "/settings/"
   ctx.config = ctx.top.settings
end

function crappy.awesomeconf.command.startup(ctx, tokens)
   ctx.path = "/startup/"
   ctx.config = ctx.top.startup
end

crappy.awesomeconf.commands = {
   ["exit"] = crappy.awesomeconf.command.quit,
   ["help"] = crappy.awesomeconf.command.help,
   ["show"] = crappy.awesomeconf.command.show,
   ["list"] = crappy.awesomeconf.command.list,
   ["settings"] = crappy.awesomeconf.command.settings,
   ["startup"] = crappy.awesomeconf.command.startup,
   ["top"] = crappy.awesomeconf.command.top
}

function loadConfig(file)
   print("Loading crappy file " .. file .. "...")

   -- TODO: Error handling
   local f = assert(io.open(file, "r"))
   local configJson = f:read("*all")
   f:close()

   return crappy.json:decode(configJson)
end

function main()
   local awesomedir = os.getenv("HOME") .. "/.config/awesome/"

   local config = loadConfig(awesomedir .. "crappy.json")
   --local config = loadConfig("~/.config/awesome/crappy.json")
   
   assert(config ~= nil)

   prompt(config)
end

-- http://snippets.luacode.org/snippets/String_Tokenizer_113
local function _tokenizer(str)
   local yield = coroutine.yield
   local i = 1
   local i1,i2
   local function find(pat)
      i1,i2 = str:find(pat,i)
      return i1 ~= nil
   end
   local function token()
      return str:sub(i,i2)
   end
   while true do
      if find '^%s+' then
         -- ignore
      elseif find '^[%+%-]*%d+' then
         local ilast = i
         i = i2+1 -- just after the sequence of digits
         -- fractional part?
         local _,idx = str:find('^%.%d+',i)
         if idx then
            i2 = idx
            i = i2+1
         end
         -- exponent part?
         _,idx = str:find('^[eE][%+%-]*%d+',i)
         if idx then
            i2 = idx
         end
         i = ilast
         yield('number',tonumber(token()))
      elseif find '^[_%a][_%w]*' then
         yield('iden',token())
      elseif find '^"[^"]*"' or find "^'[^']*'" then
         -- strip the quotes
         yield('string',token():sub(2,-2))
      else -- any other character
         local ch = str:sub(i,i)
         if ch == '' then return 'eof','eof' end
         i2 = i
         yield(ch,ch)
      end
      i = i2+1
   end
end

function tokenizer(str)
   return coroutine.wrap(function() _tokenizer(str) end)
end

function processCommand(ctx, tokens)
   local command = tokens[1]
   if command ~= nil then
      if ctx.commands[command] ~= nil then
         ctx.commands[command](ctx, tokens) 
      else
         print("Unknown command: " .. tokens[1])
      end
   end
end

function prompt(config)
   local doExit = false

   local ctx = {
      path = "/",
      config = config,
      top = config,
      commands = crappy.awesomeconf.commands
   }
   print(crappy.misc.dump(crappy.awesomeconf.commands))

   repeat
      io.write("awesome" .. ctx.path .. "> ")
      local line = io.read()

      if line ~= nil then
         local T = tokenizer(line)
         local tokens = {}
         for type,value in T do
            table.insert(tokens, value)
         end

         processCommand(ctx, tokens)
      else
         os.exit()
      end
   until false
end

function crappy.json:onDecodeError(message, text, location, etc)
   if text then
      if location then
         message = string.format("Error reading JSON at char %d: %s", location, message)
      else
         message = string.format("Error reading JSON: %s", message)
      end
   end

   if etc ~= nil then
      message = message .. " (" .. OBJDEF:encode(etc) .. ")"
   end

   if self.assert then
      self.assert(false, message)
   else
      assert(false, message)
   end
end

main()
