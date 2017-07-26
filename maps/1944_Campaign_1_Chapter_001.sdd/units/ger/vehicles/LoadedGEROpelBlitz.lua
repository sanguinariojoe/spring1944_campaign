local GER_LoadedOpelBlitzBase = Truck:New{
	name					= "Opel Blitz",
	trackOffset				= 10,
	trackWidth				= 13,
	customParams = {
		transportsquad = "ger_platoon_rifle",
	},
}

local GER_LoadedOpelBlitz = GER_LoadedOpelBlitzBase:New(TransportTruck)

return lowerkeys({
	["GERLoadedOpelBlitz"] = GER_LoadedOpelBlitz,
})
