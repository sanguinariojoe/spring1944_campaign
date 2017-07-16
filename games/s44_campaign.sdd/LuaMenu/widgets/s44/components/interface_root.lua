function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)

	local externalFunctions = {}

	local globalKeyListener = false

	local titleWidthRel = 0.25

	-- Large title is 180x125
	-- Small title is 140x82

	local mainButtonsWidth = 180
	local mainButtonsWidthSmall = 140

	local imageFudge = 0

	local padding = 0

	-- Switch to single panel mode when below the minimum screen width
	local minScreenWidth = 1360

	local INVISIBLE_COLOR = {0, 0, 0, 0}
	local VISIBLE_COLOR = {1, 1, 1, 1}

	-------------------------------------------------------------------
	-- Window structure
	-------------------------------------------------------------------
	local ingameInterfaceHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "ingameInterfaceHolder",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
		preserveChildrenOrder = true
	}
	ingameInterfaceHolder:Hide()

	local lobbyInterfaceHolder = Control:New {
		x = 0,
		y = 0,
		right = 0,
		bottom = 0,
		name = "lobbyInterfaceHolder",
		parent = screen0,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
		preserveChildrenOrder = true
	}

	-- Direct children of lobbyInterfaceHolder are called holder_<name>
	-- and are each within their own subsection

	-----------------------------------
	-- Heading holder
	-----------------------------------
	local titleHeight = 125
	local titleWidth = 360
	local holder_heading = Control:New {
		x = 0,
		y = 0,
		width = titleWidth,
		height = titleHeight,
		name = "holder_heading",
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {}
	}
	local heading_image = Image:New {
		y = 0,
		x = 0,
		right = 0,
		bottom = 0,
		keepAspect = true,
		file = Configuration:GetHeadingImage(),
		OnClick = { function()
			Spring.Echo("OpenURL: uncomment me in interface_root.lua")
			-- Uncomment me to try it!
			--Spring.OpenURL("https://gitter.im/Spring-Chobby/Chobby")
			--Spring.OpenURL("/home/gajop")
		end},
		parent = holder_heading,
	}

	-- Exit button
	local function ExitSpring()
		Spring.Echo("Quitting...")
		Spring.Quit()
	end

	local buttons_exit = Button:New {
		x = 10,
		bottom = 0,
		right = 10,
		height = 70,
		caption = i18n("exit"),
		font = Configuration:GetFont(3),
		parent = lobbyInterfaceHolder,
		OnClick = {
			function(self)
				ExitSpring()
			end
		},
	}

	-----------------------------------
	-- Background holder is put here to be at the back
	-----------------------------------
	local backgroundHolder = Background(nil, nil, nil, "menuBackgroundBrightness")

	-------------------------------------------------------------------
	-- Resizing functions
	-------------------------------------------------------------------

	local function RescaleMainWindow(newFontSize, newButtonHeight, newButtonOffset, newButtonSpacing)
		buttons_exit:SetPos(nil, nil, nil, newButtonHeight)
	end

	-------------------------------------------------------------------
	-- External Functions
	-------------------------------------------------------------------

	function externalFunctions.ViewResize(screenWidth, screenHeight)
		titleWidth = math.floor(screenWidth * titleWidthRel)
		holder_heading:SetPos((screenWidth - titleWidth) / 2, 0.1 * screenHeight, titleWidth, nil)
	end

	function externalFunctions.KeyPressed(key, mods, isRepeat, label, unicode)
		if globalKeyListener then
			return globalKeyListener(key, mods, isRepeat, label, unicode)
		end
		return false
	end

	function externalFunctions.SetGlobalKeyListener(newListenerFunc)
		-- This is intentially set up such that there is only one global key
		-- listener at a time. This is indended for popups that monopolise input.
		globalKeyListener = newListenerFunc
	end

	function externalFunctions.GetIngameInterfaceHolder()
		return ingameInterfaceHolder
	end

	function externalFunctions.GetLobbyInterfaceHolder()
		return lobbyInterfaceHolder
	end

	function externalFunctions.GetBackgroundHolder()
		return backgroundHolder
	end

	-------------------------------------------------------------------
	-- Listening
	-------------------------------------------------------------------

	local function onConfigurationChange(listener, key, value)
	end
	Configuration:AddListener("OnConfigurationChange", onConfigurationChange)

	-------------------------------------------------------------------
	-- Initialization
	-------------------------------------------------------------------
	local screenWidth, screenHeight = Spring.GetWindowGeometry()

	RescaleMainWindow(3, 70, 50)

	externalFunctions.ViewResize(screenWidth, screenHeight)

	return externalFunctions
end

return GetInterfaceRoot
