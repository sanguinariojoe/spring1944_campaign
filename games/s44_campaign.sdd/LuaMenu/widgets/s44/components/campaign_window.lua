CampaignWindow = Component:extends{}

local daySelector_holder, dayLabel
local sel_day = {}
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
		classname = windowClassname,
		OnDispose = {
			function()
				self:RemoveListeners()
			end
		},
	}

	-- Get the list of available days
	daySelector_holder = Control:New {
		x = 10,
		y = 10,
		right = 10,
		height = 32,
		parent = self.window,
		resizable = false,
		draggable = false,
		padding = customPadding or {0, 0, 0, 0},
		classname = windowClassname,
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
				ExitSpring()
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
				ExitSpring()
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
	local days = self:GetDaysList(WG.CampaignData.Side)
	if sel_day[WG.CampaignData.Side] == nil then
		sel_day[WG.CampaignData.Side] = #days
	end
	dayLabel.caption = days[sel_day[WG.CampaignData.Side]]
	self.window:Show()
end

function CampaignWindow:AddListeners()
end

function CampaignWindow:RemoveListeners()
end

function CampaignWindow:GetDaysList(side)
	local days = {}
	-- Get list of available days
	local lastDayID = WG.CampaignData.GetLastDayUnlocked(side)
	for i=1,lastDayID do
		local dayData =  WG.CampaignData.GetDayData(i, side)
		days[i] = dayData.name
	end
	return days
end
