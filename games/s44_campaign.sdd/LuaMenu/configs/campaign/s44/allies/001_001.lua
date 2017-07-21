local shortname = "s44"

local desc = [[
101st Airbourne jump:
========================

We have been delaying the jump too much! The D day has arrived, and is time for the 101st airborne to land in Normandy!

We are jumping at night, while the gliders will be sent along the day to provide support.

Our first mission is regrouping right after landing, subsequently securing the designated area. Don't attracting the attention of the enemy forces is absolutely crucial.

Good luck!
]]

local retData = {
	played = false,
	success = false,
	lock = true,
	img = LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/001_001",
	x = "16.5%",
	y = "55.5%",
	width = "5.5%",
	height = "7.5%",
	description = desc,
	map = "1944 - Campaign 1 (US) - Chapter 1",
	level = 1,
	teams = {  -- Add always a player, and as many AIs as map slots
		[0] = {  -- Always the Player
			name = "US",        -- Optional
			ally = 0,           -- Optional
			color = '0 0.5 0',  -- Optional
			startX = 300,
			startZ = 100,
		},
		[1] = {  -- AI controlled players
			name = "GER",           -- Optional
			ally = 1,               -- Optional
			color = '0.3 0.5 0.3',  -- Optional
			startX = 3800,
			startZ = 3800,
		},
	},
	modOptions = {
		communism_mode = 1,
	}
}

return retData
