local plugin = {}

local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')

plugin.name = 'Menu'
plugin.description = 'Build the menu'
plugin.id = 'crappy.startup.menu'
plugin.provides = {"crappy.shared.mainmenu", "crappy.shared.launcher"}


function plugin.settingsDefault(settings)
   if #settings == 0 then
      local newSettings = {
         {
            ["name"] = "awesome",
            ["iconresult"] = "function() return beautiful.awesome_icon end",
            ["table"] = {
               {
                  ["name"] = "manual",
                  ["result"] = "function() return crappy.shared.settings.terminal .. \" -e man awesome\" end"
               },
               {
                  ["name"] ="edit config",
                  ["result"] = "function() return crappy.shared.settings.editor .. ' ' .. awful.util.getdir('config') .. '/rc.lua' end"
               },
               {
                  ["name"] = "restart",
                  ["func"] = "awesome.restart"
               },
               {
                  ["name"] = "quit",
                  ["func"] = "awesome.quit"
               }
            }
         },
         {
            ["name"] = "open terminal",
            ["result"] = "function() return crappy.shared.settings.terminal end"
         },
         {
            ["name"] = "firefox",
            ["string"] = "firefox"
         }
      }

      misc.mergeTable(settings, newSettings)
   end

   return settings
end

-- Build a menu table for awful to work with
local function buildMenuTable(menu)
   local m = {}

   for i, entry in ipairs(menu) do
      local e = {}

      table.insert(e, entry.name)

      if entry.table ~= nil then
         table.insert(e, buildMenuTable(entry.table))
      elseif entry.result ~= nil then
         table.insert(e, functionManager.getFunction(entry.result)())
      elseif entry.func ~= nil then
         table.insert(e, functionManager.getFunction(entry.func))
      elseif entry.string ~= nil then
         table.insert(e, entry.string)
      else
         print("Unknown menu type!")
         table.insert(e, nil)
      end

      if entry.iconresult ~= nil then
         table.insert(e, functionManager.getFunction(entry.iconresult)())
      elseif entry.iconfile ~= nil then
         table.insert(e, entry.iconfile)
      else
         table.insert(e, nil)
      end

      table.insert(m, e)
   end

   return m
end

function plugin.startup(awesomever, settings)
   local shared = require('crappy.shared')

   plugin.settingsDefault(settings)

   local menu = buildMenuTable(settings)
   shared.mainmenu = awful.menu({ items = menu })

   shared.launcher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                             menu = shared.mainmenu })
end

return plugin
