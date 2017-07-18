local shortname = "s44"

local desc = [[
Infantry basic course:
========================

	The top of the hill in front of you is a vital strategical point! command
	your squad to take the control.

	In this course you are learning the basics regarding infantry.
]]

local retData = {
	played = false,
	success = false,
	lock = true,
	map = "1944 - Campaign 0 - tutorial 1",
	level = 1,
	img = LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/000_000",
	x = "20%",
	y = "70%",
	width = nil,
	height = nil,
	description = desc,
}

return retData
