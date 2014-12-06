local lgi = require('lgi')
local misc = require('crappy.misc')
local functionManager = require('crappy.functionManager')

local plugin = {
   id = 'crappy.startup.rules',
   name = 'Rules',
   description = 'Rules',
   author = 'Andrew Phillips <theasp@gmail.com>',
   requires = {"crappy.shared.clientkeys", "crappy.shared.clientbuttons", "crappy.shared.tags", "crappy.startup.signals"},
   provides = {},
   defaults = {
      rules = {
         {
            rule = {
               class = "MPlayer"
            },
            properties = {
               floating = true
            }
         },
         {
            rule = {
               class = "pinentry"
            },
            properties = {
               floating = true
            }
         }
      }
   }
}

local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   local shared = require('crappy.shared')
   local awful = misc.use('awful')
   awful.rules = misc.use('awful.rules')

   assert(shared.clientkeys ~= nil)
   assert(shared.clientbuttons ~= nil)

   local rules = {
      { rule = { },
        properties = { border_width = beautiful.border_width,
                       border_color = beautiful.border_normal,
                       focus = awful.client.focus.filter,
                       maximized_vertical   = false,
                       maximized_horizontal = false,
                       size_hints_honor = false,
                       keys = shared.clientkeys,
                       buttons = shared.clientbuttons } }}

   for i,rule in ipairs(settings.rules) do
      if rule.properties ~= nil then
         -- As we need to find a reference to the tag, use tag and screen
         -- to find it.  If tag is supplied without screen, set it to nil.
         if rule.properties.tag then
            if rule.properties.screen and shared.tags[rule.properties.screen] then
               rule.properties.tag = shared.tags[tonumber(rule.properties.screen)][tostring(rule.properties.tag)]
            else
               rule.properties.tag = nil
            end
         end
      end

      if rule.callback then
         rule.callback = functionManager.getFunction(rule.callback)
      end

      table.insert(rules, rule)
   end

   awful.rules.rules = rules
end

return plugin

