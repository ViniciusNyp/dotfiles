-- Bar: invisible window, islands paint themselves.
-- topmost=window keeps the bar above the hidden-menu-bar hot zone (clickability)
SBAR.bar({
	position = "top",
	height = 28,
	notch_display_height = 38,
	notch_width = 200,
	topmost = "window",
	blur_radius = 0,
	color = COLORS.bar,
})

-- Defaults: flat monochrome items; popups bordered + blurred
SBAR.default({
	padding_left = 4,
	padding_right = 4,
	icon = {
		font = "Hack Nerd Font:Bold:15.0",
		color = COLORS.fg,
		padding_left = 6,
		padding_right = 3,
	},
	label = {
		font = "Hack Nerd Font:Bold:13.0",
		color = COLORS.fg,
		padding_left = 3,
		padding_right = 6,
	},
	background = {
		color = COLORS.bg1,
		corner_radius = 7,
		height = 20,
	},
	popup = {
		background = {
			color = COLORS.popup,
			corner_radius = 9,
			border_width = 2,
			border_color = COLORS.selection,
			shadow = { drawing = true },
		},
		blur_radius = 50,
	},
})
