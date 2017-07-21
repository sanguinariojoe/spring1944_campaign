--------------------------------------------------------------------------------------------------------
-- Rain settings
--------------------------------------------------------------------------------------------------------

-- if (Spring.GetMapOptions().weather ~= "rain") then
-- 	return
-- end

local cfg = {
	atmosphere = {
		skyColor     = {0.0, 0.0, 0.1},
		cloudColor   = {0.5, 0.5, 0.6},
		clouddensity = 0.8,
	},

	grass = {
		bladeColor  = {0.6, 1, 0.8},
	},

	custom = {
		precipitation = {
			density   = 120000,
			size      = 1.5,
			speed     = 100,
			windscale = 1.3,
			texture   = 'LuaGaia/effects/drop.png',
		},
	},
}

return cfg
