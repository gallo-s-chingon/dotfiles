local wezterm = require("wezterm")

local config = {
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 650,
	cursor_blink_ease_in = "Linear",
	cursor_blink_ease_out = "Linear",
	font_size = 15.5,
	font = wezterm.font("Hack", { weight = "Regular" }),
	font_rules = {
		{
			italic = true,
			font = wezterm.font("Victor Mono"),
		},
		{
			intensity = "Bold",
			font = wezterm.font("Hack"),
		},
	},

	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	tab_bar_at_bottom = true,
	window_decorations = "RESIZE",
	show_new_tab_button_in_tab_bar = false,
	adjust_window_size_when_changing_font_size = false,
	send_composed_key_when_left_alt_is_pressed = true,
	colors = {
		foreground = "#AAAAFF",
		background = "#0F111A",

		cursor_bg = "#FFCC40",
		cursor_fg = "#000000",
		cursor_border = "#c8c093",

		selection_fg = "#2d4f67",
		selection_bg = "#cd4f67",

		scrollbar_thumb = "#16161d",
		split = "#16161d",

		ansi = { "#0F111A", "#ff5370", "#3ff765", "#ffcb6b", "#82aaff", "#c792ea", "#89ddff", "#c8c093" },
		brights = { "#212121", "#e83b3f", "#7aba3a", "#ffea2e", "#54a4f3", "#aa4dbc", "#26bbd1", "#d9d9d9" },
		indexed = { [16] = "#f6981e", [17] = "#ff5d62" },
	},
}
return config
