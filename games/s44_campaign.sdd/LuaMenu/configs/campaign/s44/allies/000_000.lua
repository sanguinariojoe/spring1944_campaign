local shortname = "s44"

local desc = [[
Infantry basic course:
========================

	The top of the hill in front of you is a critical point! command your squad to take the control.

	In this course you are learning the basics regarding infantry.
]]

local retData = {
	played = false,
	success = false,
	lock = true,
	img = LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/000_000",
	x = "3%",
	y = "40%",
	width = "53%",
	height = "23%",
	description = desc,
	map = "1944 - Campaign 0 - tutorial 1",
	level = 1,
	teams = {  -- Add always a player, and as many AIs as map slots
		[0] = {  -- Always the Player
			name = "US",        -- Optional
			ally = 0,           -- Optional
			color = '0 0.5 0',  -- Optional
			startX = 900,
			startZ = 1500,
		},
		[1] = {  -- AI controlled players
			name = "GER",           -- Optional
			ally = 1,               -- Optional
			color = '0.3 0.5 0.3',  -- Optional
			startX = 3200,
			startZ = 1500,
		},
	},
	modOptions = {
		communism_mode = 1,
	},
}

return retData
