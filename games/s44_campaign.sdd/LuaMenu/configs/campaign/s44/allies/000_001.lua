local shortname = "s44"

local desc = [[
Infantry advance course:
========================

	A small base at the top of hill is under your commands, your mission is
	organizing them to defend such stregical point!. That would not be however
	an easy task, since the enemy will push hard to recover the control.

	In this course you are learning to order squadds at the barracks, as well
	as managing other special units like machine guns and mortars.
]]

local retData = {
	played = false,
	success = false,
	lock = true,
	map = "1944 - Campaign 0 - tutorial 2",
	level = 1,
	img = LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/000_001",
	x = "57%",
	y = "5%",
	width = "23%",
	height = "81%",
	description = desc,
}

return retData
