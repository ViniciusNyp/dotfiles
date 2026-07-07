-- Left island: apple, workspace pills, front app. Then the media island.
-- Plugins stay shell scripts; SUBS collects native --subscribe calls so
-- sketchybar keeps delivering events straight to them (no lua callbacks yet).
SBAR.add("item", "apple", {
	position = "left",
	icon = { string = "\u{F0035}", padding_left = 12 }, -- nf-md-apple (native Hack NF metrics)
	label = { drawing = false },
	click_script = PLUGIN_DIR .. "/menus.sh 1",
})

SBAR.add("event", "aerospace_workspace_change")

local aerospace = io.popen("aerospace list-workspaces --all")
for sid in aerospace:lines() do
	SBAR.add("item", "space." .. sid, {
		position = "left",
		drawing = false,
		background = { drawing = false, corner_radius = 6, height = 18 },
		icon = {
			string = sid,
			font = "Hack Nerd Font:Bold:12.0",
			padding_left = 7,
			padding_right = 2,
		},
		label = {
			drawing = false,
			font = "sketchybar-app-font:Regular:14.0",
			padding_left = 2,
			padding_right = 7,
		},
		click_script = "aerospace workspace " .. sid .. "; sketchybar --set $NAME popup.drawing=off",
		script = PLUGIN_DIR .. "/space_hover.sh " .. sid,
	})
	SUBS[#SUBS + 1] = "--subscribe space." .. sid .. " mouse.entered mouse.exited mouse.exited.global"
end
aerospace:close()

SBAR.add("item", "aerospace_listener", {
	position = "left",
	drawing = false,
	width = 0,
	script = PLUGIN_DIR .. "/aerospace_listener.sh",
})
SUBS[#SUBS + 1] = "--subscribe aerospace_listener aerospace_workspace_change"

SBAR.add("item", "front_app", {
	position = "left",
	icon = { font = "sketchybar-app-font:Regular:16.0" },
	label = { padding_right = 12 },
	script = PLUGIN_DIR .. "/front_app.sh",
	click_script = PLUGIN_DIR .. "/menus.sh 2",
})
SUBS[#SUBS + 1] = "--subscribe front_app front_app_switched"

-- Media island: flows after the left island; media.sh truncates before the notch
SBAR.add("item", "media", {
	position = "left",
	drawing = false,
	update_freq = 10,
	icon = { string = "󰝚", color = COLORS.dim, padding_left = 12 },
	label = { padding_right = 12 },
	background = {
		drawing = true,
		color = COLORS.island,
		corner_radius = 10,
		height = 26,
	},
	script = PLUGIN_DIR .. "/media.sh",
	click_script = "nowplaying-cli togglePlayPause",
})
SUBS[#SUBS + 1] = "--subscribe media front_app_switched aerospace_workspace_change"

SBAR.add("bracket", "left_island", { "apple", "/space\\..*/", "front_app" }, {
	background = {
		drawing = true,
		color = COLORS.island,
		corner_radius = 10,
		height = 26,
	},
})
