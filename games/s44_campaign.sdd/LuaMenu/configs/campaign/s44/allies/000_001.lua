local shortname = "s44"

local desc = [[
Infantry advanced course:
========================

	A small base at the top of hill is under your control, your mission is organizing them to defend such stregical point!. That would not be however an easy task, since the enemy will push hard to recover the control.

	In this course you are learning to order new squads at the barracks, as well as managing other special units, like machine guns and mortars.
]]

local retData = {
	played = false,
	success = false,
	lock = false,
	img = LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/000_001",
	x = "57%",
	y = "5%",
	width = "23%",
	height = "81%",
	description = desc,
	map = "1944 - Campaign 0 - tutorial 2",
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
	}
}

return retData
