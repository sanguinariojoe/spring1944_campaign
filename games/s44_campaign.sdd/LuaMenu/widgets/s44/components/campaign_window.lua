CampaignWindow = Component:extends{}

local daySelector_holder, dayLabel, map, description_holder
local sel_day = {}
local sel_chapter = nil
function CampaignWindow:init(parent)
	self:DoInit() -- Lack of inheritance strikes again.

	self.CancelFunc = function ()
		self:HideWindow()
	end

	self.window = Control:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		parent = parent,
		resizable = false,
		draggable = false,
		padding = customPadding or {0, 0, 0, 0},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}

	-- The campaig day/operation selector
	-- ==================================
	daySelector_holder = Control:New {
		x = 10,
		y = 10,
		right = 10,
		height = 32,
		parent = self.window,
		resizable = false,
		draggable = false,
		padding = customPadding or {0, 0, 0, 0},
	}
	local prev_day = Button:New {
		x = 0,
		y = 0,
		width = 32,
		bottom = 0,
		caption = "<",
		font = Configuration:GetFont(3),
		parent = daySelector_holder,
		OnClick = {
			function(self)
				local s = WG.CampaignData.Side
				local d = sel_day[s]
				if WG.CampaignData.IsDayUnlocked(d - 1, s) then
					WG.Windows.campaign:_LoadDay(d - 1, s)
					WG.Windows.campaign:_LoadChapter()
				end
			end
		},
	}
	dayLabel = Button:New {
		x = 10 + 32 + 10,
		y = 0,
		right = 10 + 32 + 10,
		bottom = 0,
		valign = 'center',
		font = Configuration:GetFont(3),
		caption = "",
		parent = daySelector_holder,
		OnClick = {
			function(self)
				ExitSpring()
			end
		},
	}
	local next_day = Button:New {
		right = 10,
		y = 0,
		width = 32,
		bottom = 0,
		caption = ">",
		font = Configuration:GetFont(3),
		parent = daySelector_holder,
		OnClick = {
			function(self)
				local s = WG.CampaignData.Side
				local d = sel_day[s]
				if WG.CampaignData.IsDayUnlocked(d + 1, s) then
					WG.Windows.campaign:_LoadDay(d + 1, s)
					WG.Windows.campaign:_LoadChapter()
				end
			end
		},
	}

	-- Mission holder
	-- ==============
	local mission_holder = Window:New {
		x = 0,
		right = 0,
		y = 52,
		bottom = 10,
		parent = self.window,
		resizable = false,
		draggable = false,
		padding = customPadding or {0, 0, 0, 0},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}

	local map_holder = Control:New {
		x = 0,
		right = "50%",
		y = 0,
		bottom = 0,
		parent = mission_holder,
		resizable = false,
		draggable = false,
		padding = customPadding or {10, 10, 10, 10},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}
	map = Image:New {
		width = "100%",
		height = "100%",
		keepAspect = false,
		keepAspect = false,
		file = LUA_DIRNAME .. "configs/gameConfig/s44/skinning/maps/Europe_1942.png",
		parent = map_holder,
	}

	local chapter_holder = Window:New {
		x = "51%",
		right = 10,
		y = 10,
		bottom = 10,
		parent = mission_holder,
		resizable = false,
		draggable = false,
		padding = customPadding or {10, 10, 10, 10},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}

	description_holder = Control:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 80,
		parent = chapter_holder,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}

	local buttons_start = Button:New {
		x = "1%",
		bottom = 0,
		right = "51%",
		height = 70,
		caption = i18n("start"),
		font = Configuration:GetFont(3),
		parent = chapter_holder,
		OnClick = {
			function(self)
				WG.Windows.campaign:_StartGame()
			end
		},
	}
	local buttons_back = Button:New {
		x = "51%",
		bottom = 0,
		right = "1%",
		height = 70,
		caption = i18n("back"),
		font = Configuration:GetFont(3),
		parent = chapter_holder,
		OnClick = {
			function(self)
				WG.Windows.campaign:HideWindow()
				WG.Windows.faction:ShowWindow()
			end
		},
	}

	self:HideWindow()
end

function CampaignWindow:OnResize(width, height)
	self.window:SetPos(0, 0, width, height)
	local minDaySelectorWidth = 10
	local w = math.max(minDaySelectorWidth, 0.5 * width)
	daySelector_holder:SetPos(0.5 * (width - w), nil, w, nil)
end

function CampaignWindow:HideWindow()
	self.window:Hide()
end

function CampaignWindow:ShowWindow()
	local days = self:_GetDaysList(WG.CampaignData.Side)
	if sel_day[WG.CampaignData.Side] == nil then
		sel_day[WG.CampaignData.Side] = #days
	end
	self:_LoadDay()
	self:_LoadChapter()
	self.window:Show()
end

function CampaignWindow:AddListeners()
end

function CampaignWindow:RemoveListeners()
end

function CampaignWindow:_GetDaysList(side)
	local days = {}
	-- Get list of available days
	local lastDayID = WG.CampaignData.GetLastDayUnlocked(side)
	for i=1,lastDayID do
		local dayData =  WG.CampaignData.GetDayData(i, side)
		days[i] = dayData.name
	end
	return days
end

function CampaignWindow:_LoadChapter(chapterID, dayID, side)
	local s = side or WG.CampaignData.Side
	local d = dayID or sel_day[s]
	local dayData = WG.CampaignData.GetDayData(d, s)
	local c = chapterID or sel_chapter
	if c == nil then
		-- Select the first chapter not already passed, the last one otherwise
		for i,cData in ipairs(dayData.chapters) do
			c = i
			if not cData.success then
				break
			end
		end
	end
	if c == nil then
		return nil
	end
	if sel_chapter and map.children[sel_chapter] then
		-- Disable the highlighted icon
		map.children[sel_chapter].file2 = dayData.chapters[sel_chapter].img .. "_out.png"
	end
	sel_chapter = c
	map.children[c].file2 = dayData.chapters[c].img .. "_in.png"
	description_holder.children = {}
	local description = TextBox:New {
		x = 0,
		right = 0,
		y = 0,
		bottom = 0,
		text = dayData.chapters[c].description,
		parent = description_holder,
		fontSize = WG.s44.Configuration:GetFont(2).size,
		resizable = false,
		draggable = false,
		padding = {0, 0, 0, 0},
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}
	return c
end

function CampaignWindow:_LoadDay(dayID, side)
	local s = side or WG.CampaignData.Side
	local d = dayID or sel_day[s]
	-- This function is assuming that day availability has been already checked
	local dayData = WG.CampaignData.GetDayData(d, s)
	dayLabel.caption = dayData.name
	map.file = dayData.img
	map.children = {}
	for i,c in ipairs(dayData.chapters) do
		local img = Image:New {
			x = c.x,
			y = c.y,
			width = c.width,
			height = c.height,
			keepAspect = false,
			file = c.img .. ".png",
			file2 = c.img .. "_out.png",
			parent = map,
			OnClick = { function(self)
				WG.Windows.campaign:_LoadChapter(i, d, s)
			end},
			OnMouseOver = { function(self)
				self.file2 = c.img .. "_in.png"
			end},
			OnMouseOut = { function(self)
				if i ~= sel_chapter then
					self.file2 = c.img .. "_out.png"
				end
			end},
		}
	end
	return dayData
end

function CampaignWindow:_StartGame(chapterID, dayID, side)
	local s = side or WG.CampaignData.Side
	local d = dayID or sel_day[s]
	local c = chapterID or sel_chapter

	local day = WG.CampaignData.GetDayData(d, s)
	local chapter = day.chapters[c]

	local allyTeams = {}
	local allyTeamCount = 0
	local teams = {}
	local teamCount = 0
	local players = {}
	local ais = {}
	local aiCount = 0

	local localLobby = WG.LibLobby.localLobby

	-- Add the player, this is to make the player team 0.
	local playerCount = 1
	local players = {
		[0] = {
			Name = chapter.teams[teamCount].name or "Player",
			Team = teamCount,
			IsFromDemo = 0,
			rank = 0,
		},
	}

	teams[teamCount] = {
		TeamLeader = 0,
		AllyTeam = chapter.teams[teamCount].ally or 0,
		rgbcolor = chapter.teams[teamCount].color or '0 0 0',
		start_x = chapter.teams[teamCount].startX,
		start_z = chapter.teams[teamCount].startZ,
	}
	teamCount = teamCount + 1

	for i = 1, #chapter.teams do
		local shortName = "Campaign empty bot"
		
		ais[aiCount] = {
			Name = chapter.teams[teamCount].name or "AI." .. tostring(aiCount),
			Team = teamCount,
			IsFromDemo = 0,
			ShortName = shortName,
			comm_merge = 0,
			Host = 0,
		}
		aiCount = aiCount + 1

		teams[teamCount] = {
			TeamLeader = 0,
			AllyTeam = chapter.teams[teamCount].ally or 1,
			rgbcolor = chapter.teams[teamCount].color or '0 0 0',
			start_x = chapter.teams[teamCount].startX,
			start_z = chapter.teams[teamCount].startZ,
		}
		teamCount = teamCount + 1
	end

	-- Add allyTeams
	for i, teamData in pairs(teams) do
		if not allyTeams[teamData.AllyTeam] then
			allyTeams[teamData.AllyTeam] = {
				numallies = 0,
			}
		end
	end

	local script = {
		gametype = 'Spring: 1944 $VERSION',
		hostip = '127.0.0.1',
		hostport = 0,
		ishost = 1,
		mapname = chapter.map,
		myplayername = chapter.teams[0].name or "Player",
		nohelperais = 0,
		numplayers = playerCount,
		numusers = playerCount + aiCount,
		startpostype = 0, -- Fixed
		modoptions = {
		},
	}

	if chapter.modOptions then
		for k,v in pairs(chapter.modOptions) do
			script.modoptions[k] = v
		end
	end

	for i, ai in pairs(ais) do
		script["ai" .. i] = ai
	end
	for i, player in pairs(players) do
		script["player" .. i] = player
	end
	for i, team in pairs(teams) do
		script["team" .. i] = team
	end
	for i, allyTeam in pairs(allyTeams) do
		script["allyTeam" .. i] = allyTeam
	end

	local scriptString = localLobby:MakeScriptTXT(script)
	localLobby:StartGameFromString(scriptString)
end