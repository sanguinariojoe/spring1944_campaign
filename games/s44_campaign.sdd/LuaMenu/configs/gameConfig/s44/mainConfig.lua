math.randomseed(os.time())
local shortname = "s44"

local backgroundConfig    = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/skinConfig.lua")

local headingLarge    = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/headingLarge.png"
local backgroundImage = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/backgrounds/background." .. string.format("%04d", math.random(41)) .. ".jpg"
local taskbarIcon     = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/taskbarLogo.png"

local background = {
	image           = backgroundImage,
	backgroundFocus = backgroundConfig.backgroundFocus,
}

local alliesImage = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/factions/allies"
local axisImage = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/factions/axis"

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

local externalFuncAndData = {
	dirName                 = "s44",
	name                    = "Spring:1944 Campaign",
	headingLarge            = headingLarge,
	taskbarIcon             = taskbarIcon,
	background              = background,
	alliesImage             = alliesImage,
	axisImage               = axisImage,
}

function externalFuncAndData.CheckAvailability()
	return true
end

return externalFuncAndData
