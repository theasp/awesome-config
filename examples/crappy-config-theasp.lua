{
  configver = 1,
  plugins = {
    ["crappy.functions.client"] = {
      enabled = true,
      settings = {}
    },
    ["crappy.functions.global"] = {
      enabled = true,
      settings = {}
    },
    ["crappy.functions.layouts"] = {
      enabled = true,
      settings = {}
    },
    ["crappy.functions.signals"] = {
      enabled = true,
      settings = {}
    },
    ["crappy.functions.tag"] = {
      enabled = true,
      settings = {}
    },
    ["crappy.functions.widgets"] = {
      enabled = true,
      settings = {}
    },
    ["crappy.startup.bindings"] = {
      enabled = true,
      settings = {
        altKey = "Mod1",
        altkey = "Mod1",
        clientButtons = {
          ["1"] = "crappy.functions.client.focus",
          ["2"] = "crappy.functions.client.focus",
          ["3"] = "crappy.functions.client.focus",
          ["M-1"] = "awful.mouse.client.move",
          ["M-3"] = "awful.mouse.client.resize"
        },
        clientKeys = {
          ["M-C-<Return>"] = "crappy.functions.client.swapMaster",
          ["M-C-<space>"] = "awful.client.floating.toggle",
          ["M-S-c"] = "crappy.functions.client.kill",
          ["M-f"] = "crappy.functions.client.fullscreen",
          ["M-m"] = "crappy.functions.client.maximized",
          ["M-n"] = "crappy.functions.client.minimized",
          ["M-o"] = "awful.client.movetoscreen",
          ["M-r"] = "crappy.functions.client.redraw",
          ["M-t"] = "crappy.functions.client.ontop"
        },
        globalKeys = {
          ["M-<Escape>"] = "awful.tag.history.restore",
          ["M-<F1>"] = "function() crappy.functions.tag.show(1) end",
          ["M-<F2>"] = "function() crappy.functions.tag.show(2) end",
          ["M-<F3>"] = "function() crappy.functions.tag.show(3) end",
          ["M-<F4>"] = "function() crappy.functions.tag.show(4) end",
          ["M-<F5>"] = "function() crappy.functions.tag.show(5) end",
          ["M-<F6>"] = "function() crappy.functions.tag.show(6) end",
          ["M-<F7>"] = "function() crappy.functions.tag.show(7) end",
          ["M-<F8>"] = "function() crappy.functions.tag.show(8) end",
          ["M-<F9>"] = "function() crappy.functions.tag.show(9) end",
          ["M-<Left>"] = "awful.tag.viewprev",
          ["M-<Return>"] = "crappy.functions.global.spawnTerminal",
          ["M-<Right>"] = "awful.tag.viewnext",
          ["M-<Tab>"] = "crappy.functions.global.focusNext",
          ["M-<space>"] = "crappy.functions.global.layoutInc",
          ["M-C-<F1>"] = "function() crappy.functions.tag.toggle(1) end",
          ["M-C-<F2>"] = "function() crappy.functions.tag.toggle(2) end",
          ["M-C-<F3>"] = "function() crappy.functions.tag.toggle(3) end",
          ["M-C-<F4>"] = "function() crappy.functions.tag.toggle(4) end",
          ["M-C-<F5>"] = "function() crappy.functions.tag.toggle(5) end",
          ["M-C-<F6>"] = "function() crappy.functions.tag.toggle(6) end",
          ["M-C-<F7>"] = "function() crappy.functions.tag.toggle(7) end",
          ["M-C-<F8>"] = "function() crappy.functions.tag.toggle(8) end",
          ["M-C-<F9>"] = "function() crappy.functions.tag.toggle(9) end",
          ["M-C-h"] = "crappy.functions.global.ncolInc",
          ["M-C-j"] = "crappy.functions.global.focusNextScreen",
          ["M-C-k"] = "crappy.functions.global.focusPrevScreen",
          ["M-C-l"] = "crappy.functions.global.ncolDec",
          ["M-C-r"] = "awesome.restart",
          ["M-C-x"] = "crappy.functions.global.showLuaPrompt",
          ["M-S-<F1>"] = "function() crappy.functions.tag.clientMoveTo(1) end",
          ["M-S-<F2>"] = "function() crappy.functions.tag.clientMoveTo(2) end",
          ["M-S-<F3>"] = "function() crappy.functions.tag.clientMoveTo(3) end",
          ["M-S-<F4>"] = "function() crappy.functions.tag.clientMoveTo(4) end",
          ["M-S-<F5>"] = "function() crappy.functions.tag.clientMoveTo(5) end",
          ["M-S-<F6>"] = "function() crappy.functions.tag.clientMoveTo(6) end",
          ["M-S-<F7>"] = "function() crappy.functions.tag.clientMoveTo(7) end",
          ["M-S-<F8>"] = "function() crappy.functions.tag.clientMoveTo(8) end",
          ["M-S-<F9>"] = "function() crappy.functions.tag.clientMoveTo(9) end",
          ["M-S-<space>"] = "crappy.functions.global.layoutDec",
          ["M-S-C-<F1>"] = "function() crappy.functions.tag.clientToggle(1) end",
          ["M-S-C-<F2>"] = "function() crappy.functions.tag.clientToggle(2) end",
          ["M-S-C-<F3>"] = "function() crappy.functions.tag.clientToggle(3) end",
          ["M-S-C-<F4>"] = "function() crappy.functions.tag.clientToggle(4) end",
          ["M-S-C-<F5>"] = "function() crappy.functions.tag.clientToggle(5) end",
          ["M-S-C-<F6>"] = "function() crappy.functions.tag.clientToggle(6) end",
          ["M-S-C-<F7>"] = "function() crappy.functions.tag.clientToggle(7) end",
          ["M-S-C-<F8>"] = "function() crappy.functions.tag.clientToggle(8) end",
          ["M-S-C-<F9>"] = "function() crappy.functions.tag.clientToggle(9) end",
          ["M-S-h"] = "crappy.functions.global.nmasterInc",
          ["M-S-j"] = "crappy.functions.global.swapNext",
          ["M-S-k"] = "crappy.functions.global.swapPrev",
          ["M-S-l"] = "crappy.functions.global.nmasterDec",
          ["M-S-q"] = "awesome.quit",
          ["M-S-x"] = "function() awful.util.spawn('run-asp ' .. crappy.shared.settings.terminal) end",
          ["M-`"] = "crappy.functions.global.focusPrevHist",
          ["M-h"] = "crappy.functions.global.wmfactDec",
          ["M-j"] = "crappy.functions.global.focusNext",
          ["M-k"] = "crappy.functions.global.focusPrev",
          ["M-l"] = "crappy.functions.global.wmfactInc",
          ["M-p"] = "crappy.shared.menubar.show",
          ["M-r"] = "crappy.functions.global.showRunPrompt",
          ["M-u"] = "awful.client.urgent.jumpto",
          ["M-w"] = "crappy.functions.global.showMenu",
          ["M-x"] = "crappy.functions.global.spawnTerminal"
        },
        modKey = "Mod4",
        modkey = "Mod4",
        rootButtons = {
          ["3"] = "crappy.functions.menu.toggle",
          ["4"] = "awful.tag.viewnext",
          ["5"] = "awful.tag.viewprev"
        }
      }
    },
    ["crappy.startup.layouts"] = {
      enabled = true,
      settings = {
        layouts = {
          "awful.layout.suit.tile",
          "awful.layout.suit.max",
          "awful.layout.suit.tile.left",
          "awful.layout.suit.tile.bottom",
          "awful.layout.suit.tile.top",
          "awful.layout.suit.fair",
          "awful.layout.suit.floating"
        }
      }
    },
    ["crappy.startup.menu"] = {
      enabled = true,
      settings = {
        menu = {
          {
            iconresult = "function() return beautiful.awesome_icon end",
            name = "awesome",
            table = {
              {
                func = "awesome.restart",
                name = "restart"
              },
              {
                func = "awesome.quit",
                name = "quit"
              }
            }
          },
          {
            name = "Debian",
            result = "function() return debian.menu.Debian_menu.Debian end"
          },
          {
            name = "open terminal",
            result = "function() return crappy.shared.settings.terminal end"
          },
          {
            name = "firefox",
            string = "firefox"
          }
        }
      }
    },
    ["crappy.startup.menubar"] = {
      enabled = true,
      settings = {
        categories = {
          andrew = {
            app_type = "Andrew",
            icon_name = "applications-accessories.png",
            name = "Andrew",
            use = true
          }
        },
        dirs = {
          "/usr/share/applications/",
          "/usr/local/share/applications/",
          ".local/share/applications/",
          ".local/share/applications/andrew/"
        }
      }
    },
    ["crappy.startup.rules"] = {
      enabled = true,
      settings = {
        rules = {
          {
            properties = {
              floating = true
            },
            rule = {
              class = "MPlayer"
            }
          },
          {
            properties = {
              floating = true
            },
            rule = {
              class = "pinentry"
            }
          },
          {
            properties = {
              screen = 1,
              switchtotag = true,
              tag = 4
            },
            rule = {
              class = "Steam"
            }
          },
          {
            properties = {
              screen = 1,
              switchtotag = true,
              tag = 3
            },
            rule = {
              instance = "launcher.exe"
            }
          },
          {
            properties = {
              screen = 1,
              switchtotag = true,
              tag = 3
            },
            rule = {
              instance = "ExeFile.exe"
            }
          },
          {
            properties = {
              screen = 1,
              switchtotag = true,
              tag = 3
            },
            rule = {
              instance = "explorer.exe"
            }
          },
          {
            properties = {
              fullscreen = true,
              screen = 2,
              tag = 1
            },
            rule = {
              class = "Mythfrontend.real"
            }
          },
          {
            properties = {
              screen = 1,
              tag = 2
            },
            rule = {
              class = "Xchat"
            }
          },
          {
            properties = {
              floating = true,
              size_hints_honor = true
            },
            rule = {
              instance = "sun-awt-X11-XDialogPeer"
            }
          }
        }
      }
    },
    ["crappy.startup.settings"] = {
      enabled = true,
      settings = {
        editor = "gedit",
        sloppyfocus = false,
        terminal = "gnome-terminal",
        titlebar = true
      }
    },
    ["crappy.startup.signals"] = {
      enabled = true,
      settings = {
        focus = "crappy.functions.signals.focus",
        manage = "crappy.functions.signals.manage",
        unfocus = "crappy.functions.signals.unfocus"
      }
    },
    ["crappy.startup.tags"] = {
      enabled = true,
      settings = {
        ["1"] = {
          layout = "awful.layout.suit.max",
          tagLayout = {
            ["1"] = "awful.layout.suit.fair"
          }
        },
        default = {
          layout = "awful.layout.suit.max",
          tags = {
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9"
          }
        }
      }
    },
    ["crappy.startup.theme"] = {
      enabled = true,
      settings = {
        file = "/usr/share/awesome/themes/default/theme.lua",
        font = "Sans 10"
      }
    },
    ["crappy.startup.wibox"] = {
      enabled = true,
      settings = {
        left = {
          "crappy.functions.widgets.launcher",
          "crappy.functions.widgets.taglist",
          "crappy.functions.widgets.prompt"
        },
        middle = {
          "crappy.functions.widgets.tasklist"
        },
        position = "bottom",
        right = {
          "crappy.functions.widgets.layout"
        }
      }
    }
  }
}
