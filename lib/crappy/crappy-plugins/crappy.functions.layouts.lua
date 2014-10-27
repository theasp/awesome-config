local lgi = require('lgi')
local misc = require('crappy.misc')

local plugin = {
   name = 'Layout Functions',
   description = 'Functions that are used to layout the windows',
   id = 'crappy.functions.layouts',
   requires = {},
   provides = {},
   functions = {
      ["awful.layout.suit.floating"] = {
         class = "layout",
         description = "Floating windows",
      },
      ["awful.layout.suit.tile"] = {
         class = "layout",
         description = "Tiled windows, aligned right",
      },
      ["awful.layout.suit.tile.left"] = {
         class = "layout",
         description = "Tiled windows, aligned left",
      },
      ["awful.layout.suit.tile.bottom"] = {
         class = "layout",
         description = "Tiled windows, aligned bottom",
      },
      ["awful.layout.suit.tile.top"] = {
         class = "layout",
         description = "Tiled windows, aligned top",
      },
      ["awful.layout.suit.fair"] = {
         class = "layout",
         description = "Tiled windows, aligned fairly vertically",
      },
      ["awful.layout.suit.fair.horizontal"] = {
         class = "layout",
         description = "Tiled windows, aligned fairly horizontally",
      },
      ["awful.layout.suit.spiral"] = {
         class = "layout",
         description = "Tiled windows, spiralled",
      },
      ["awful.layout.suit.spiral.dwindle"] = {
         class = "layout",
         description = "Tiled windows, spiralled, dwindle",
      },
      ["awful.layout.suit.max"] = {
         class = "layout",
         description = "Maximized windows",
      },
      ["awful.layout.suit.max.fullscreen"] = {
         class = "layout",
         description = "Fullscreen windows",
      },
      ["awful.layout.suit.magnifier"] = {
         class = "layout",
         description = "Tiled windows in the background, current window above in the foreground",
      }
   }
}

local log = lgi.log.domain(plugin.id)

function plugin.startup(awesomever, settings)
   local awful = misc.use('awful')

   plugin.functions["awful.layout.suit.floating"].func = awful.layout.suit.floating
   plugin.functions["awful.layout.suit.tile"].func = awful.layout.suit.tile
   plugin.functions["awful.layout.suit.tile.left"].func = awful.layout.suit.tile.left
   plugin.functions["awful.layout.suit.tile.bottom"].func = awful.layout.suit.tile.bottom
   plugin.functions["awful.layout.suit.tile.top"].func = awful.layout.suit.tile.top
   plugin.functions["awful.layout.suit.fair"].func = awful.layout.suit.fair
   plugin.functions["awful.layout.suit.fair.horizontal"].func = awful.layout.suit.fair.horizontal
   plugin.functions["awful.layout.suit.spiral"].func = awful.layout.suit.spiral
   plugin.functions["awful.layout.suit.spiral.dwindle"].func = awful.layout.suit.spiral.dwindle
   plugin.functions["awful.layout.suit.max"].func = awful.layout.suit.max
   plugin.functions["awful.layout.suit.max.fullscreen"].func = awful.layout.suit.max.fullscreen
   plugin.functions["awful.layout.suit.magnifier"].func = awful.layout.suit.magnifier
end

function plugin.buildUi(window, settings)
   return nil
end

return plugin
