local shortname = "s44"

local retData = {
	[1] = {
		name = "Infantry tutorials",
		img = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/maps/Cooper_Hill.png",
		chapters = {
			[1] = VFS.Include(LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/000_000.lua"),
			[2] = VFS.Include(LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/000_001.lua"),
		},
	},
	[2] = {
		name = "The D day",
		img = LUA_DIRNAME .. "configs/gameConfig/" .. shortname .. "/skinning/maps/Europe_1942.png",
		chapters = {
			[1] = VFS.Include(LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies/001_001.lua"),
		},
	},
}

return retData
