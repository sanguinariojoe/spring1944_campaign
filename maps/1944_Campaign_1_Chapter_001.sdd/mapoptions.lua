----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
-- File:        MapOptions.lua
-- Description: Custom MapOptions file that makes possible to set up variable options before game starts, like ModOptions.lua
-- Author:      SirArtturi, Lurker, Smoth, jK
----------------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------------
--	NOTES:
--	- using an enumerated table lets you specify the options order
--
--	These keywords must be lowercase for LuaParser to read them.
--
--	key:			the string used in the script.txt
--	name:		 the displayed name
--	desc:		 the description (could be used as a tooltip)
--	type:		 the option type
--	def:			the default value
--	min:			minimum value for number options
--	max:			maximum value for number options
--	step:		 quantization step, aligned to the def value
--	maxlen:	 the maximum string length for string options
--	items:		array of item strings for list options
--	scope:		'all', 'player', 'team', 'allyteam'			<<< not supported yet >>>
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local options = {
--// Sections
	{
		key  = 'Difficulty',
		name = 'Difficulty Settings',
		desc = 'Select the level of difficulty according to your skills',
		type = 'section',
	},

--// Options
	{
		key  = "level",
		name = "Level",
		desc = "Level",
		type = "list",
		def  = "normal",
		section = 'Difficulty',
		items = {
			{ key = "easy", name = "Easy", desc = "Begginers" },
			{ key = "normal", name = "Normal", desc = "Skilled players" },
			{ key = "hard", name = "Hard", desc = "Expert players" },
		},
	},
}

return options