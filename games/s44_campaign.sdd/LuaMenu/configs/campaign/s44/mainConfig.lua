local shortname = "s44"

local alliesDefs = VFS.Include(LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/allies.lua")
-- local axisDefs     = VFS.Include(LUA_DIRNAME .. "configs/campaign/" .. shortname .. "/axis.lua")


local externalFuncAndData = {
	allies = alliesDefs,
	-- axis = axisDefs,
}


return externalFuncAndData 
