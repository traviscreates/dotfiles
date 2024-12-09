-------------------------------------------------------------------------------
-- {{{ Imports
-------------------------------------------------------------------------------

-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")
-- Standard awesome library
local awful = require("awful")
local gears = require("gears")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
-- Other stuff
local utils = require("utils")
local battery = require("widgets.battery")
local volume = require("widgets.volume")
local playback = require("widgets.playback")
local net_widget = require("widgets.net")

-- }}}

-- Load Debian menu entries
local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
-- beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
beautiful.init(gears.filesystem.get_dir("config") .. "/themes/gruvbox/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	-- awful.layout.suit.tile.left,
	-- awful.layout.suit.tile.bottom,
	-- awful.layout.suit.tile.top,
	-- awful.layout.suit.fair,
	-- awful.layout.suit.fair.horizontal,
	-- awful.layout.suit.spiral,
	-- awful.layout.suit.spiral.dwindle,
	-- awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	-- awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.nw,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

if has_fdo then
	mymainmenu = freedesktop.menu.build({
		before = { menu_awesome },
		after = { menu_terminal },
	})
else
	mymainmenu = awful.menu({
		items = {
			menu_awesome,
			{ "Debian", debian.menu.Debian_menu.Debian },
			menu_terminal,
		},
	})
end

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-------------------------------------------------------------------------------
-- {{{ Wibar
-------------------------------------------------------------------------------

-- Clock
-------------------------------------------------------------------------------
-- Create a textclock widget and attach a calendar to it
local mytextclock = wibox.widget.textclock(beautiful.widget_markup:format(beautiful.bg_normal, "%H:%M"), 60)
local month_calendar = awful.widget.calendar_popup.month({
	long_weekdays = true,
	margin = beautiful.gap,
})

mytextclock:connect_signal("mouse::enter", function()
	month_calendar:call_calendar(0, "tr", awful.screen.focused())
	month_calendar.visible = true
end)
mytextclock:connect_signal("mouse::leave", function()
	month_calendar.visible = false
end)
mytextclock:buttons(gears.table.join(
	awful.button({}, 1, function()
		month_calendar:call_calendar(-1)
	end),
	awful.button({}, 3, function()
		month_calendar:call_calendar(1)
	end)
))

-- Wallpaper
-------------------------------------------------------------------------------
local function set_wallpaper(s)
	if beautiful.wallpaper then
		utils.wallpaper.repeated(beautiful.wallpaper, s)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- Widget Initialization
-------------------------------------------------------------------------------
volume.init()
battery.init()
net_widget.init()
playback.init()

-- create new playback widgets for each screen so that mouse feedback isn't shown in every wibar
function playback.create_widget()
	local title = playback.text
	local widget = wibox.widget({
		{
			{
				title,
				max_size = beautiful.playback_width,
				speed = 70,
				step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
				layout = wibox.container.scroll.horizontal,
			},
			top = beautiful.small_gap,
			bottom = beautiful.small_gap,
			left = beautiful.med_gap,
			right = beautiful.med_gap,
			widget = wibox.container.margin,
		},
		shape = gears.shape.rectangle,
		bg = beautiful.bg_focus,
		widget = wibox.container.background,
		opacity = 0,
		buttons = awful.button({}, 1, function(self)
			self.widget.bg = beautiful.playback_bg_press
			if #title.text > 0 then
				-- save titles of interesting songs for later, useful for radio streams
				local songlist = io.open(os.getenv("HOME") .. "/Documents/songlist", "a+")
				if songlist then
					if not string.find(songlist:read("*a"), title.text, 1, true) then
						songlist:write(title.text .. "\n")
					end
					songlist:close()
				end
			end
		end, function(self)
			self.widget.bg = beautiful.playback_bg_hover
		end),
	})

	widget:connect_signal("mouse::enter", function()
		widget.bg = beautiful.playback_bg_hover
	end)
	widget:connect_signal("mouse::leave", function()
		widget.bg = beautiful.playback_bg_normal
	end)
	title:connect_signal("widget::redraw_needed", function()
		widget.opacity = #title.text > 0 and 1 or 0
	end)

	return widget
end

-- Taglist
-------------------------------------------------------------------------------
-- Each screen has its own tag table.
local tags = { "❶", "❷", "❸", "❹", "❺", "❻", "❼", "❽", "❾" }

-- Assign the buttons for the taglist
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local widget_template = {
	{
		{
			id = "text_role",
			widget = wibox.widget.textbox,
		},
		id = "text_margin_role",
		left = beautiful.big_gap,
		right = beautiful.big_gap,
		widget = wibox.container.margin,
	},
	id = "background_role",
	widget = wibox.container.background,
	create_callback = function(self, tag, index, taglist)
		-- Add support for hover colors
		local bg_empty = table.concat({ gears.color(beautiful.taglist_bg_empty):get_rgba() })
		local bg_occupied = table.concat({ gears.color(beautiful.taglist_bg_occupied):get_rgba() })
		local bg_hover = table.concat({ gears.color(beautiful.taglist_bg_hover):get_rgba() })
		self:connect_signal("mouse::enter", function()
			local bg = table.concat({ self.bg:get_rgba() })
			if bg == bg_empty or bg == bg_occupied then
				self.bg = beautiful.taglist_bg_hover
			end
		end)
		self:connect_signal("mouse::leave", function()
			if table.concat({ self.bg:get_rgba() }) == bg_hover then
				self.bg = #tag:clients() == 0 and beautiful.taglist_bg_empty or beautiful.taglist_bg_occupied
			end
		end)

		-- modify the shape of the last tag
		if index == #taglist then
			self:get_children_by_id("text_margin_role")[1]:set_right(beautiful.med_gap)
			self:connect_signal("widget::redraw_needed", function()
				self:set_shape(utils.shape.rightangled.right_mirrored)
			end)
		end
	end,
}

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Taglist
	local ultrawide, highres = s.geometry.width / s.geometry.height > 2, s.geometry.height >= 1440
	for index, tag in ipairs(tags) do
		awful.tag.add(tag, {
			layout = awful.layout.layouts[ultrawide and 1 or 2],
			gap = highres and beautiful.useless_gap or 0,
			screen = s,
			selected = index == 1,
		})
	end

	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		style = {
			shape = utils.shape.parallelogram.left,
		},
		layout = {
			spacing = beautiful.negative_gap,
			homogeneous = false,
			layout = wibox.layout.grid.horizontal,
		},
		widget_template = widget_template,
		buttons = taglist_buttons,
	})

	-- Wibar
	-------------------------------------------------------------------------------
	-- Create the wibar
	s.mywibox = awful.wibar({ position = "top", screen = s, height = beautiful.wibar_height })
	--global titlebar title container
	s.title_container = wibox.container.margin()
	-- global titlebar buttons contianer
	s.buttonsbox_container = wibox.container.margin()

	-- add widgets to the wibar
	s.mywibox:setup({
		{ -- Left widgets
			wibox.container.margin(
				wibox.widget({
					text = "  ",
					widget = wibox.widget.textbox,
					fg = "#D79921",
				}),
				beautiful.gap,
				beautiful.big_gap
			),
			-- mylauncher,
			s.mytaglist,
			wibox.container.margin(playback.create_widget(), beautiful.pgram_slope),
			spacing = beautiful.negative_gap,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle widgets
			s.title_container,
			layout = wibox.layout.align.horizontal,
		},
		{ -- Right widgets
			-- wibox.container.margin(modalawesome.sequence, beautiful.gap, beautiful.big_gap),

			-- Internet Widget
			utils.widget.compose({
				{
					net_widget.text,
					color = beautiful.fg_normal,
					shape = utils.shape.rightangled.left_mirrored,
				},
				{
					net_widget.image,
					color = beautiful.bg_focus,
					shape = utils.shape.parallelogram.right,
					margin = beautiful.gap,
				},
			}),

			-- Audio Volume
			utils.widget.compose({
				{
					volume.text,
					color = beautiful.fg_normal,
					shape = utils.shape.parallelogram.right,
				},
				{
					volume.image,
					color = beautiful.bg_focus,
					shape = utils.shape.parallelogram.right,
					margin = beautiful.gap,
				},
			}),

			-- Battery Indicator
			utils.widget.compose({
				{
					battery.text,
					color = beautiful.fg_normal,
					shape = utils.shape.parallelogram.right,
				},
				{
					battery.image,
					color = beautiful.bg_focus,
					shape = utils.shape.parallelogram.right,
					margin = beautiful.gap,
				},
			}),

			-- Clock / Layout / Global Titlebar Buttons
			utils.widget.compose({
				{
					mytextclock,
					color = beautiful.fg_normal,
					shape = utils.shape.parallelogram.right,
				},
				{
					{
						s.mylayoutbox,
						s.buttonsbox_container,
						spacing = beautiful.small_gap,
						layout = wibox.layout.fixed.horizontal,
					},
					color = beautiful.bg_focus,
					shape = utils.shape.rightangled.right,
					margin = beautiful.gap,
				},
			}),

			spacing = beautiful.negative_gap,
			fill_space = true,
			layout = wibox.layout.fixed.horizontal,
		},
		expand = "none",
		layout = wibox.layout.align.horizontal,
	})
end)

-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ modkey }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ modkey }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ modkey }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ modkey, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ modkey }, "r", function()
		awful.util.spawn("rofi -show drun")
	end, { description = "run rofi", group = "launcher" }),
	awful.key({ modkey, "Shift" }, "r", function()
		awful.util.spawn("/home/travis/.config/rofi/run_shell_command.sh")
	end, { description = "run shell command with rofi", group = "launcher" }),

	awful.key({ modkey }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),
	-- Menubar
	awful.key({ modkey }, "p", function()
		menubar.show()
	end, { description = "show the menubar", group = "launcher" }),

	-- Media Keys
	awful.key({}, "XF86MonBrightnessDown", function()
		awful.spawn("brightnessctl set 5%-")
	end, { description = "lower brightness 5%", group = "media" }),
	awful.key({}, "XF86MonBrightnessUp", function()
		awful.spawn("brightnessctl set 5+%")
	end, { description = "raise brightness 5%", group = "media" }),
	awful.key({}, "XF86AudioLowerVolume", function()
		awful.util.spawn("amixer -D pulse sset Master 5%-")
	end),
	awful.key({}, "XF86AudioRaiseVolume", function()
		awful.util.spawn("amixer -D pulse sset Master 5%+")
	end)
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ modkey, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ modkey }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ modkey }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ modkey, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Add titlebars to normal clients and dialogs
	-- { rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = true } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	-- { rule = { class = "Firefox" },
	--   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}

-- Custom Configuration
-- gears.wallpaper.maximized("/path/to/gruvbox-gecko.png")
-- beautiful.useless_gap = 0

-- Spawn Compositor
-- awful.spawn("/path/to/set_key_repeat_rate.sh")
awful.spawn.with_shell("picom &")
