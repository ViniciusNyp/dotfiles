-- Right island (rightmost first): clock, battery, cpu, ram, agents.
-- Read-only: hover for details; controls live in the native menu bar.
SBAR.add("item", "clock", {
	position = "right",
	update_freq = 10,
	icon = { string = "", color = COLORS.dim },
	label = { padding_right = 12 },
	script = PLUGIN_DIR .. "/clock.sh",
})
SUBS[#SUBS + 1] = "--subscribe clock mouse.entered mouse.exited mouse.exited.global"

SBAR.add("item", "battery", {
	position = "right",
	update_freq = 120,
	script = PLUGIN_DIR .. "/battery.sh",
})
SUBS[#SUBS + 1] = "--subscribe battery system_woke power_source_change"

SBAR.add("item", "cpu", {
	position = "right",
	update_freq = 10,
	icon = { string = "cpu", font = "Hack Nerd Font:Bold:10.0", color = COLORS.dim },
	script = PLUGIN_DIR .. "/cpu.sh",
})

SBAR.add("item", "ram", {
	position = "right",
	update_freq = 10,
	icon = { string = "ram", font = "Hack Nerd Font:Bold:10.0", color = COLORS.dim },
	script = PLUGIN_DIR .. "/ram.sh",
})

-- T3 Code agents: ai (robot + running, green), ai_wait (waiting on you, yellow).
-- ai.sh polls T3's local DB and updates both; hover lists active threads.
SBAR.add("item", "ai_wait", {
	position = "right",
	drawing = false,
	icon = { drawing = false },
	label = { color = COLORS.yellow },
})

SBAR.add("item", "ai", {
	position = "right",
	drawing = false,
	update_freq = 5,
	icon = { string = "󰚩" },
	label = { color = COLORS.green },
	script = PLUGIN_DIR .. "/ai.sh",
})
SUBS[#SUBS + 1] = "--subscribe ai system_woke mouse.entered mouse.exited mouse.exited.global"

SBAR.add("bracket", "right_island", { "clock", "battery", "cpu", "ram", "ai", "ai_wait" }, {
	background = {
		drawing = true,
		color = COLORS.island,
		corner_radius = 10,
		height = 26,
	},
})

-- Meeting island: separate capsule at the notch-facing edge of the right
-- group — the only elastic width on this side, so calendar.sh's notch guard
-- only ever has to trim this one item.
SBAR.add("item", "meeting", {
	position = "right",
	update_freq = 60,
	icon = { string = "󰃰", padding_left = 12 },
	label = { padding_right = 12 },
	background = {
		drawing = true,
		color = COLORS.island,
		corner_radius = 10,
		height = 26,
	},
	script = PLUGIN_DIR .. "/calendar.sh",
})
SUBS[#SUBS + 1] = "--subscribe meeting system_woke"
