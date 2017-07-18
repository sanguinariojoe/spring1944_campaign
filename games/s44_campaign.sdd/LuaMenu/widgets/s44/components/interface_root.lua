function GetInterfaceRoot(optionsParent, mainWindowParent, fontFunction)

	local externalFunctions = {}

	local globalKeyListener = false

	local titleWidthRel = 0.1

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
	local texInfo = gl.TextureInfo(Configuration:GetHeadingImage())
	local titleWidth = texInfo.xsize
	local titleHeight = texInfo.ysize
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
	-- Controls holder
	-----------------------------------
	local holder_controls = Control:New {
		x = 10,
		y = titleHeight,
		right = 10,
		bottom = 80,
		name = "holder_controls",
		parent = lobbyInterfaceHolder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		children = {},
	}
	local factionWindow = FactionWindow(holder_controls)
	local campaignWindow = CampaignWindow(holder_controls)
	WG.Windows = {
		faction = factionWindow,
		campaign = campaignWindow,
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
		local tw = math.floor(screenWidth * titleWidthRel)
		local th = tw * titleHeight / titleWidth
		holder_heading:SetPos((screenWidth - tw) / 2, 0.05 * screenHeight, tw, nil)
		heading_image:SetPos(0, 0, tw, th)
		-- Controls
		local x = 10
		local y = 0.05 * screenHeight + th + 10
		local w = screenWidth - 2 * x
		local h = screenHeight - y - 80
		holder_controls:SetPos(x, y, w, h)
		factionWindow:OnResize(w, h)
		campaignWindow:OnResize(w, h)
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

	function externalFunctions.SetIngame(status)
		if lobbyInterfaceHolder.visible ~= status then
			return
		end
		backgroundHolder:SetEnabled(not status)
		if status then
			lobbyInterfaceHolder:Hide()
			ingameInterfaceHolder:Show()
		else
			lobbyInterfaceHolder:Show()
			ingameInterfaceHolder:Hide()
		end
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
