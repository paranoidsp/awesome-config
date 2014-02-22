-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
vicious = require("vicious")
--FreeDesktop
require('freedesktop.utils')
require('freedesktop.menu')
--local wi = loadfile('.config/awesome/awesome-laptop/wi')
freedesktop.utils.icon_theme = 'gnome'

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, there was an error!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
--beautiful.init(awful.util.getdir("config") .. "themes/zenburn/theme.lua")
--beautiful.init("~/.config/awesome/themes/default/theme.lua")
--beautiful.init("/usr/share/awesome/themes/default/theme.lua")
beautiful.init("/home/paranoidsp/.config/awesome/themes/copland/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "gnome-terminal"
browser = "google-chrome"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
browser_cmd = terminal .. " -e " .. browser

-- Setting Cairo compmgr for transparency
awful.util.spawn_with_shell("pkill cairo-compmgr ; cairo-compmgr &")
awful.util.spawn_with_shell("pkill conky ; conky &")
awful.util.spawn_with_shell("yakuake &")

-- {{{ Naughty presets
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "terminus 6"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 256
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 2
naughty.config.defaults.hover_timeout = nil
-- -- }}}
-- Making the notifications transparent.
naughty.config.presets.normal.opacity = 0.6
naughty.config.presets.low.opacity = 0.6
naughty.config.presets.critical.opacity = 0.6

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
tags = {
 names  = { 
         '♬:Clementine',
         '☭:IRC',
         '⚡:Luakit', 
         '♨:Chrome', 
         '☠:Vim',  
         '☃:Vbox', 
         '⌥:Multimedia', 
         '⌘:Conky',
         '✇:IDE',
         '✣:Facepalm',
           },
 layout = {
      layouts[5],   -- 1:irc
      layouts[10],  -- 2:luakit
      layouts[10],  -- 3:chrome
      layouts[12],  -- 4:vim
      layouts[2],   -- 5:vbox
      layouts[10],  -- 6:multimedia
      layouts[10],  -- 7:conky
      layouts[2],   -- 8:ide
      layouts[10],  -- 9:facepalm
          }
       }
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s,tags.layout) 
end
-- }}}
--
-- Wallpaper Changer Based On 
-- menu icon menu pdq 07-02-2012
 --local wallmenu = {}
 --local function wall_load(wall)
 --local f = io.popen('ln -sfn ' .. home_path .. '~/Pictures/Wallpapers/' .. wall .. ' ' .. home_path .. '.config/awesome/themes/default/bg.png')
 --awesome.restart()
 --end
 --local function wall_menu()
 --local f = io.popen('ls -1 ' .. home_path .. '.config/awesome/wallpaper/')
 --for l in f:lines() do
--local item = { l, function () wall_load(l) end }
 --table.insert(wallmenu, item)
 --end
 --f:close()
 --end
 --wall_menu()
 
-- Widgets
spacer       = wibox.widget.textbox()
spacer:set_text(' | ')
--
--Weather Widget
--
weather = wibox.widget.textbox()
vicious.register(weather, vicious.widgets.weather, "Weather: ${city}. Sky: ${sky}. Temp: ${tempc}c Humid: ${humid}%. Wind: ${windkmh} KM/h", 1200, "YMML")

--Battery Widget
batt = wibox.widget.textbox()
vicious.register(batt, vicious.widgets.bat, "Batt: $2% Rem: $3", 61, "BAT0")
-- Spacers
volspace = wibox.widget.textbox()
volspace:set_text(" ")

-- {{{ BATTERY
-- Battery attributes
local bat_state  = ""
local bat_charge = 0
local bat_time   = 0
local blink      = true

-- Icon
baticon = wibox.widget.imagebox()
baticon:set_image(beautiful.widget_batfull)

-- Charge %
batpct = wibox.widget.textbox()
vicious.register(batpct, vicious.widgets.bat, function(widget, args)
  bat_state  = args[1]
  bat_charge = args[2]
  bat_time   = args[3]

  if args[1] == "-" then
    if bat_charge > 70 then
      baticon:set_image(beautiful.widget_batfull)
    elseif bat_charge > 30 then
      baticon:set_image(beautiful.widget_batmed)
    elseif bat_charge > 10 then
      baticon:set_image(beautiful.widget_batlow)
    else
      baticon:set_image(beautiful.widget_batempty)
    end
  else
    baticon:set_image(beautiful.widget_ac)
    if args[1] == "+" then
      blink = not blink
      if blink then
        baticon:set_image(beautiful.widget_acblink)
      end
    end
  end

  return args[2] .. "%"
end, nil, "BAT0")

-- Buttons
function popup_bat()
  local state = ""
  if bat_state == "↯" then
    state = "Full"
  elseif bat_state == "↯" then
    state = "Charged"
  elseif bat_state == "+" then
    state = "Charging"
  elseif bat_state == "-" then
    state = "Discharging"
  elseif bat_state == "⌁" then
    state = "Not charging"
  else
    state = "Unknown"
  end

  naughty.notify { text = "Charge : " .. bat_charge .. "%\nState  : " .. state ..
    " (" .. bat_time .. ")", timeout = 5, hover_timeout = 0.5 }
end
batpct:buttons(awful.util.table.join(awful.button({ }, 1, popup_bat)))
baticon:buttons(batpct:buttons())
-- End Battery}}}
--
-- {{{ PACMAN
-- Icon
pacicon = wibox.widget.imagebox()
pacicon:set_image(beautiful.widget_pac)
--
-- Upgrades
pacwidget = wibox.widget.textbox()
vicious.register(pacwidget, vicious.widgets.pkg, function(widget, args)
   if args[1] > 0 then
   pacicon:set_image(beautiful.widget_pacnew)
   else
   pacicon:set_image(beautiful.widget_pac)
   end

  return args[1]
  end, 1801, "Arch S") -- Arch S for ignorepkg
--
-- Buttons
  function popup_pac()
  local pac_updates = ""
  local f = io.popen("pacman -Sup --dbpath /tmp/pacsync")
  if f then
  pac_updates = f:read("*a"):match(".*/(.*)-.*\n$")
  end
  f:close()
  if not pac_updates then
  pac_updates = "System is up to date"
  end
  naughty.notify { text = pac_updates }
  end
  pacwidget:buttons(awful.util.table.join(awful.button({ }, 1, popup_pac)))
  pacicon:buttons(pacwidget:buttons())
-- End Pacman }}}
--
-- {{{ VOLUME
-- Cache
vicious.cache(vicious.widgets.volume)
--
-- Icon
volicon = wibox.widget.imagebox()
volicon:set_image(beautiful.widget_vol)
--
-- Volume %
volpct = wibox.widget.textbox()
vicious.register(volpct, vicious.widgets.volume, "$1%", nil, "Master")
--
-- Buttons
volicon:buttons(awful.util.table.join(
     awful.button({ }, 1,
     function() awful.util.spawn_with_shell("amixer -q set Master toggle") end),
     awful.button({ }, 4,
     function() awful.util.spawn_with_shell("amixer -q set Master 3+% unmute") end),
     awful.button({ }, 5,
     function() awful.util.spawn_with_shell("amixer -q set Master 3-% unmute") end)
            ))
     volpct:buttons(volicon:buttons())
     volspace:buttons(volicon:buttons())
 -- End Volume }}}
 --
-- {{{ Start CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
--
cpu = wibox.widget.textbox()
vicious.register(cpu, vicious.widgets.cpu, "All: $1% 1: $2% 2: $3% 3: $4% 4: $5%", 2)
-- End CPU }}}
--
-- {{{ Start Mem
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_ram)
--
mem = wibox.widget.textbox()
vicious.register(mem, vicious.widgets.mem, "Mem: $1% Use: $2MB Total: $3MB Free: $4MB Swap: $5%", 2)
-- End Mem }}}
--
-- {{{ Start Gmail 
mailicon = wibox.widget.imagebox(beautiful.widget_mail)
mailwidget = wibox.widget.textbox()
gmail_t = awful.tooltip({ objects = { mailwidget },})
vicious.register(mailwidget, vicious.widgets.gmail,
        function (widget, args)
        gmail_t:set_text(args["{subject}"])
        gmail_t:add_to_object(mailicon)
            return args["{count}"]
                 end, 120) 

     mailicon:buttons(awful.util.table.join(
         awful.button({ }, 1, function () awful.util.spawn("gnome-terminal -e mutt", false) end)
     ))
-- End Gmail }}}
--
-- {{{ Start Wifi
wifiicon = wibox.widget.imagebox()
wifiicon:set_image(beautiful.widget_wifi)
--
wifi = wibox.widget.textbox()
vicious.register(wifi, vicious.widgets.wifi, "${ssid} Rate: ${rate}MB/s Link: ${link}%", 3, "wlp3s0")
-- End Wifi }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome",freedesktop.utils.lookup_icon({ icon = 'help' }) },
   { "edit config", editor_cmd .. " " .. awesome.conffile, freedesktop.utils.lookup_icon({ icon = 'package_settings' }) },
   { "restart", awesome.restart, freedesktop.utils.lookup_icon({ icon = 'system-shutdown' }) },
   { "quit", awesome.quit, freedesktop.utils.lookup_icon({ icon = 'system-shutdown' }) }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })



-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}
--
--
--

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
myinfowibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen 
mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    --{{{  My Widgets.  Mostly from the vicious website.  More config later.
     --Initialize widget
    --datewidget = wibox.widget.textbox()
     --Register widget
    --vicious.register(datewidget, vicious.widgets.date, "%b %d, %R", 60)

    -- Initialize widget
    --memwidget = wibox.widget.textbox()
    ---- Register widget
    --vicious.register(memwidget, vicious.widgets.mem, "$1% ($2MB/$3MB)", 13)

    -- Initialize widget
    --memwidget = awful.widget.progressbar()
    ---- Progressbar properties
    --memwidget:set_width(30)
    --memwidget:set_height(10)
    --memwidget:set_vertical(true)
    --memwidget:set_background_color("#494B4F")
    --memwidget:set_border_color(nil)
    --memwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#AECF96"}, {0.5, "#88A175"}, 
                        --{1, "#FF5656"}}})
    ---- Register widget
    --vicious.register(memwidget, vicious.widgets.mem, "$1", 1)
    --
    --
    -- Initialize widget
    cpuwidget = awful.widget.graph()
    -- Graph properties
    cpuwidget:set_width(50)
    cpuwidget:set_height(15)
    cpuwidget:set_background_color("#494B4F")
    cpuwidget:set_color({ type = "linear", from = { 0, 0 }, to = { 10,0 }, stops = { {0, "#FF5656"}, {0.5, "#88A175"}, 
                        {1, "#AECF96" }}})
    -- Register widget
    vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

    -- Battery
    -- {{{ Battery state
    -- Initialize widget
    batwidget = awful.widget.progressbar()
    batwidget:set_width(30)
    batwidget:set_height(14)
    batwidget:set_vertical(true)
    batwidget:set_background_color("#000000")
    batwidget:set_border_color(nil)
    batwidget:set_color("#00bfff")

    --  Register widget
    vicious.register(batwidget, vicious.widgets.bat, "$2", 120, "BAT0")

    --}}}

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(spacer)
    right_layout:add(mailicon)
    right_layout:add(mailwidget)
    right_layout:add(spacer)
    right_layout:add(baticon)
    right_layout:add(batpct)
    right_layout:add(spacer)
    right_layout:add(pacicon)
    right_layout:add(pacwidget)
    right_layout:add(spacer)
    right_layout:add(volicon)
    right_layout:add(volpct)
    right_layout:add(volspace)
    right_layout:add(spacer)
    right_layout:add(mytextclock)
    right_layout:add(batwidget)
    right_layout:add(mylayoutbox[s])
    --right_layout:add(mytextclock)
    ----right_layout:add(memwidget)
    ----right_layout:add(cpuwidget)
    --right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
    --
   -- Create the bottom wibox
     myinfowibox[s] = awful.wibox({ position = "bottom", screen = s })
   -- Widgets that are aligned to the bottom
    local bottom_layout = wibox.layout.fixed.horizontal()
    bottom_layout:add(cpuicon)
    bottom_layout:add(cpu)
    bottom_layout:add(spacer)
    bottom_layout:add(memicon)
    bottom_layout:add(mem)
    bottom_layout:add(spacer)
    bottom_layout:add(wifiicon)
    bottom_layout:add(wifi)
    bottom_layout:add(spacer)
    bottom_layout:add(weather)
    bottom_layout:add(spacer)

    myinfowibox[s]:set_widget(bottom_layout)

end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ }, "Print", function () awful.util.spawn("scrot -e 'mv $f ~/Pictures/Screenshots/ 2>/dev/null'") naughty.notify({ preset = naughty.config.presets.normal,
                    title = "Screenshot taken!",
                    text =  "Saved in ~/Pictures/Screenshots." })
  end),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "c", function () awful.util.spawn(browser) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1,keynumber  do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "Chrome" },
      properties = { tag = tags[1][3] } },
    { rule = { class = "Vlc" },
      properties = { tag = tags[1][6] } },
    { rule = { class = "VirtualBox" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Gns3" },
      properties = { tag = tags[1][5] } },
    { rule = { class = "Bitcoin-qt" },
      properties = { tag = tags[1][9] } },
    { rule = { class = "luakit" },
      properties = { tag = tags[1][2] } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = true
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

   
    
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
