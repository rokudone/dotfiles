local settings = require("settings")
local colors = require("colors")

local calendar_font_size = 13
local calendar_label_width = 150
local weekday_names = { "sun", "mon", "tue", "wed", "thu", "fri", "sat" }

-- Padding item required because of bracket
-- sbar.add("item", { position = "right", width = settings.group_paddings })
local cal_datetime = sbar.add("item", {
	icon = {
		drawing = "off",
	},
	label = {
		color = colors.tn_blue,
		padding_left = 0,
		padding_right = 0,
		align = "center",
		font = { family = settings.font.numbers, size = calendar_font_size },
		width = calendar_label_width,
	},
	position = "right",
	update_freq = 1,
	padding_left = 0,
	padding_right = 0,
})

-- Double border for calendar using a single item bracket
sbar.add("bracket", { cal_datetime.name }, {
	background = {
		color = colors.tn_black3,
		height = 30,
		border_color = colors.tn_blue,
	},
})

-- Padding item required because of bracket
sbar.add("item", { position = "right", width = settings.group_paddings })

cal_datetime:subscribe({ "forced", "routine", "system_woke" }, function(env)
	local wday = os.date("*t").wday
	local weekday = weekday_names[wday]
	cal_datetime:set({ label = os.date("%Y/%m/%d") .. " " .. weekday .. " " .. os.date("%H:%M") })
end)

-- add width
sbar.add("item", { position = "right", width = 6 })
