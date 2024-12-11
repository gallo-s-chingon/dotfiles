local wezterm = require("wezterm")

local config = {
	default_cursor_style = "BlinkingBar",
	cursor_blink_rate = 650,
	cursor_blink_ease_in = "Linear",
	cursor_blink_ease_out = "Linear",
	color_scheme = "MaterialOcean",
	font_size = 19,
	font = wezterm.font("Hack", { weight = "Regular", style = "Normal" }),

	use_fancy_tab_bar = false,
	hide_tab_bar_if_only_one_tab = true,
	tab_bar_at_bottom = true,
	window_decorations = "RESIZE",
	show_new_tab_button_in_tab_bar = false,
	adjust_window_size_when_changing_font_size = false,
	send_composed_key_when_left_alt_is_pressed = true,
}

return config
