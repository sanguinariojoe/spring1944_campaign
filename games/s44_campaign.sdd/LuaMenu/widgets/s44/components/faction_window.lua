FactionWindow = Component:extends{}

local allies_w, allies_h, allies_btn, axis_w, axis_h, axis_btn
function FactionWindow:init(parent, root)
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

	local texInfo = gl.TextureInfo(Configuration:GetAlliesFactionImage())
	allies_w = texInfo.xsize
	allies_h = texInfo.ysize
	allies_btn = Image:New {
		y = 0,
		x = 0,
		right = 0,
		bottom = 0,
		keepAspect = true,
		file = Configuration:GetAlliesFactionImage(),
		file2 = Configuration:GetAlliesFactionImage("_out"),
		OnClick = { function(self)
			WG.CampaignData.Side = "allies"
			WG.Windows.faction:HideWindow()
			WG.Windows.campaign:ShowWindow()
		end},
		OnMouseOver = { function(self)
			self.file2 = Configuration:GetAlliesFactionImage("_in")
		end},
		OnMouseOut = { function(self)
			self.file2 = Configuration:GetAlliesFactionImage("_out")
		end},
		parent = self.window,
	}
	local texInfo = gl.TextureInfo(Configuration:GetAxisFactionImage())
	axis_h = texInfo.ysize
	axis_w = texInfo.xsize
	axis_btn = Image:New {
		y = 0,
		x = 0,
		right = 0,
		bottom = 0,
		keepAspect = true,
		file = Configuration:GetAxisFactionImage(),
		file2 = Configuration:GetAxisFactionImage("_out"),
		OnClick = { function(self)
			WG.CampaignData.Side = "axis"
			WG.Windows.faction:HideWindow()
			WG.Windows.campaign:ShowWindow()
		end},
		OnMouseOver = { function(self)
			self.file2 = Configuration:GetAxisFactionImage("_in")
		end},
		OnMouseOut = { function(self)
			self.file2 = Configuration:GetAxisFactionImage("_out")
		end},
		parent = self.window,
	}

	if not allies_btn.visible then
		allies_btn:Show()
	end
	if not axis_btn.visible then
		axis_btn:Show()
	end
end

function FactionWindow:OnResize(width, height)
	local x, y, w, h
	self.window:SetPos(0, 0, width, height)
	x, y, w, h = self:CenterImage(allies_w, allies_h, 0.5 * width, height)
	allies_btn:SetPos(x, y, w, h)
	x, y, w, h = self:CenterImage(axis_w, axis_h, 0.5 * width, height)
	axis_btn:SetPos(x + 0.5 * width, y, w, h)
end

function FactionWindow:HideWindow()
	self.window:Hide()
end

function FactionWindow:ShowWindow()
	self.window:Show()
end

function FactionWindow:AddListeners()
end

function FactionWindow:RemoveListeners()
end

function FactionWindow:CenterImage(w, h, W, H)
	local f = math.min(W / w, H / h)
	local width, height = f * w, f * h
	local x, y = 0.5 * (W - width), 0.5 * (H - height)
	Spring.Echo(f, x, y, width, height)
	return x, y, width, height
end
