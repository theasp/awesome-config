local plugin = {}

local misc = require('crappy.misc')

plugin.name = 'Standard Rules'
plugin.description = 'Standard rules'
plugin.id = 'crappy.startup.rules'
plugin.requires = {"clientkeys", "clientbuttons"}

function plugin.settingsDefault(settings)
   if #settings == 0 then
      settings =  {
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
   end
   
   return settings
end

function plugin.startup(awesomever, settings)
   print("Initializing crappy rules...")

   local shared = require('crappy.shared')
   local awful = misc.use('awful')
   awful.rules = misc.use('awful.rules')
   
   plugin.settingsDefault(settings)

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

   for i,rule in ipairs(settings) do
      if rule.properties ~= nil then
         -- As we need to find a reference to the tag, use tag and screen
         -- to find it.  If tag is supplied without screen, set it to nil.
         if rule.properties.tag ~= nil then
            if rule.properties.screen ~= nil and shared.tags[rule.properties.screen] ~= nil then
               rule.properties.tag = shared.tags[rule.properties.screen][rule.properties.tag]
            else
               rule.properties.tag = nil
            end
         end
      end

      if rule.callback ~= nil then
         rule.callback = misc.getFunction(rule.callback)
      end

      table.insert(rules, rule)
   end

   awful.rules.rules = rules
end

return plugin
