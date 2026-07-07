-- Right island (rightmost first): clock, wifi, bt, battery, volume, cpu, ram,
-- meeting, ai. Left click = quick action, right click = native CC module/popup.
SBAR.add("item", "clock", {
	position = "right",
	update_freq = 10,
	icon = { string = "", color = COLORS.dim },
	label = { padding_right = 12 },
	script = PLUGIN_DIR .. "/clock.sh",
	click_script = 'if [ "$BUTTON" = right ]; then '
		.. PLUGIN_DIR .. "/cc.sh Clock; else "
		.. PLUGIN_DIR .. "/popup_calendar.sh; fi",
})

SBAR.add("item", "control_center", {
	position = "right",
	icon = { string = "\u{F1DE}", color = COLORS.dim }, -- nf-fa-sliders
	label = { drawing = false },
	click_script = PLUGIN_DIR .. "/cc.sh Control",
})

SBAR.add("item", "wifi", {
	position = "right",
	update_freq = 30,
	script = PLUGIN_DIR .. "/wifi.sh",
	click_script = 'if [ "$BUTTON" = right ]; then '
		.. PLUGIN_DIR .. "/popup_wifi.sh; else "
		.. PLUGIN_DIR .. "/cc.sh Wi 'x-apple.systempreferences:com.apple.wifi-settings-extension'; fi",
})
SUBS[#SUBS + 1] = "--subscribe wifi wifi_change"

SBAR.add("item", "bluetooth", {
	position = "right",
	update_freq = 5,
	script = PLUGIN_DIR .. "/bluetooth.sh",
	click_script = PLUGIN_DIR .. "/cc.sh Bluetooth 'x-apple.systempreferences:com.apple.BluetoothSettings'",
})

SBAR.add("item", "battery", {
	position = "right",
	update_freq = 120,
	script = PLUGIN_DIR .. "/battery.sh",
	click_script = PLUGIN_DIR .. "/cc.sh Battery 'x-apple.systempreferences:com.apple.Battery-Settings.extension'",
})
SUBS[#SUBS + 1] = "--subscribe battery system_woke power_source_change"

SBAR.add("item", "volume", {
	position = "right",
	script = PLUGIN_DIR .. "/volume.sh",
	click_script = 'if [ "$BUTTON" = right ]; then '
		.. "osascript -e 'set volume output muted (not (output muted of (get volume settings)))'; else "
		.. PLUGIN_DIR .. "/cc.sh Sound; fi",
})
SUBS[#SUBS + 1] = "--subscribe volume volume_change mouse.scrolled"

SBAR.add("item", "cpu", {
	position = "right",
	update_freq = 10,
	icon = { string = "cpu", font = "Hack Nerd Font:Bold:10.0", color = COLORS.dim },
	script = PLUGIN_DIR .. "/cpu.sh",
	click_script = "open -a 'Activity Monitor'",
})

SBAR.add("item", "ram", {
	position = "right",
	update_freq = 10,
	icon = { string = "ram", font = "Hack Nerd Font:Bold:10.0", color = COLORS.dim },
	script = PLUGIN_DIR .. "/ram.sh",
	click_script = "open -a 'Activity Monitor'",
})

SBAR.add("item", "meeting", {
	position = "right",
	update_freq = 60,
	icon = { string = "󰃰", padding_left = 12 },
	script = PLUGIN_DIR .. "/calendar.sh",
	click_script = PLUGIN_DIR .. "/calendar.sh menu",
})
SUBS[#SUBS + 1] = "--subscribe meeting system_woke"

-- AI trio: ai (robot + running, green), ai_wait (yellow), ai_extra (dim).
-- ai.sh updates all three; Claude Code hooks fire ai_change for instant updates.
SBAR.add("event", "ai_change")

SBAR.add("item", "ai_extra", {
	position = "right",
	drawing = false,
	icon = { drawing = false },
	label = { color = COLORS.dim },
	click_script = "open -a 'cmux'",
})

SBAR.add("item", "ai_wait", {
	position = "right",
	drawing = false,
	icon = { drawing = false },
	label = { color = COLORS.yellow },
	click_script = "open -a 'cmux'",
})

SBAR.add("item", "ai", {
	position = "right",
	drawing = false,
	update_freq = 10,
	icon = { string = "󰚩" },
	label = { color = COLORS.green },
	script = PLUGIN_DIR .. "/ai.sh",
	click_script = "open -a 'cmux'",
})
SUBS[#SUBS + 1] = "--subscribe ai system_woke ai_change"

SBAR.add("bracket", "right_island",
	{ "clock", "control_center", "wifi", "bluetooth", "battery", "volume", "cpu", "ram", "meeting", "ai", "ai_wait", "ai_extra" }, {
	background = {
		drawing = true,
		color = COLORS.island,
		corner_radius = 10,
		height = 26,
	},
})
