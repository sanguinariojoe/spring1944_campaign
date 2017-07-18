Configuration = LCS.class{}

VFS.Include("libs/liblobby/lobby/json.lua")

LIB_LOBBY_DIRNAME = "libs/liblobby/lobby/"


-- all configuration attribute changes should use the :Set*Attribute*() and :Get*Attribute*() methods in order to assure proper functionality
function Configuration:init()
	self.listeners = {}

	self.errorColor = "\255\255\0\0"
	self.warningColor = "\255\255\255\0"
	self.normalColor = "\255\255\255\255"
	self.successColor = "\255\0\255\0"
	self.partialColor = "\255\190\210\50"
	self.selectedColor = "\255\99\184\255"
	self.highlightedColor = "\255\125\255\0"
	self.meColor = "\255\0\190\190"

	self.buttonFocusColor = {0.54,0.72,1,0.3}
	self.buttonSelectedColor = {0.54,0.72,1,0.6}--{1.0, 1.0, 1.0, 1.0}

	self.atiIntelCompat = self:GetIsNotRunningNvidia()
	Spring.Echo("ATI/intel/other non-nvidia compatibility state:", self.atiIntelCompat)

	self.gameConfigName = "s44"
	self.gameConfig = VFS.Include(LUA_DIRNAME .. "configs/gameConfig/" .. self.gameConfigName .. "/mainConfig.lua")

	self.font = {
		[0] = {size = 10, shadow = false},
		[1] = {size = 14, shadow = false},
		[2] = {size = 18, shadow = false},
		[3] = {size = 22, shadow = false},
		[4] = {size = 32, shadow = false},
		[5] = {size = 48, shadow = false},
	}

	self.configParamTypes = {}
	for _, param in pairs(Spring.GetConfigParams()) do
		self.configParamTypes[param.name] = param.type
	end
	
	self.AtiIntelSettingsOverride = nil
	self.fixedSettingsOverride = AtiIntelSettingsOverride

	self.game_settings = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettings.lua")

	self.animate_lobby = gl.CreateShader ~= nil

	self.campaignData = VFS.Include(LUA_DIRNAME .. "configs/campaign/" .. self.gameConfigName .. "/mainConfig.lua")
	self.campaignSaveFile = "Campaign"

	self:UpdateFixedSettings()
end

---------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------

function Configuration:SetSpringsettingsValue(key, value, compatOverride)
	if self.doNotSetAnySpringSettings then
		return
	end
	
	if not compatOverride then
		local compatProfile = self.forcedCompatibilityProfile
		if compatProfile and compatProfile[key] then
			return
		end
	end
	
	value = (self.fixedSettingsOverride and self.fixedSettingsOverride[key]) or value
	
	local configType = self.configParamTypes[key]
	if configType == "int" then
		Spring.Echo("SetSettings Int", key, value)
		Spring.SetConfigInt(key, value)
	elseif configType == "bool" or configType == "float" then
		Spring.Echo("SetSettings Value", key, value)
		Spring.SetConfigString(key, value)
	elseif configType == nil then
		Spring.Log("Settings", LOG.WARNING, "No such key: " .. tostring(key) .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	else
		Spring.Log("Settings", LOG.WARNING, "Unexpected key type: " .. configType .. ", but setting it as string anyway.")
		Spring.SetConfigString(key, value)
	end
end

function Configuration:UpdateFixedSettings(newOverride)
	local gameSettings = self.game_settings
	
	-- Reset old
	local oldOverride = self.fixedSettingsOverride
	self.fixedSettingsOverride = nil
	if oldOverride then
		for key, value in pairs(oldOverride) do
			if gameSettings[key] then
				self:SetSpringsettingsValue(key, gameSettings[key])
			end
		end
	end
	
	-- Apply new
	self.fixedSettingsOverride = newOverride
	if newOverride then
		for key, value in pairs(newOverride) do
			self:SetSpringsettingsValue(key, value)
		end
	end
end

function Configuration:SetSettingsConfigOption(name, newValue)
	local setting = self.gameConfig.settingsNames[name]
	if not setting then
		return false
	end

	if setting.isNumberSetting then
		local applyFunction = setting.applyFunction
		if applyFunction then
			local applyData = applyFunction(newValue)
			if applyData then
				for applyName, value in pairs(applyData) do
					self.game_settings[applyName] = value
					self:SetSpringsettingsValue(applyName, value)
				end
			end
		else
			local springValue = setting.springConversion(newValue)
			self.game_settings[setting.applyName] = springValue
			self:SetSpringsettingsValue(setting.applyName, springValue)
		end
	else
		-- Selection from multiple options
		local selectedOption = setting.optionNames[newValue]
		if setting.fileTarget then
			local sourceFile = VFS.LoadFile(selectedOption.file)
			local settingsFile = io.open(setting.fileTarget, "w")
			settingsFile:write(sourceFile)
			settingsFile:close()
		else
			local applyData = selectedOption.apply or (selectedOption.applyFunction and selectedOption.applyFunction())
			if not applyData then
				return
			end
			for applyName, value in pairs(applyData) do
				self.game_settings[applyName] = value
				self:SetSpringsettingsValue(applyName, value)
			end
		end
	end
end

function Configuration:ApplySettingsConfigPreset(preset)
	for name, value in pairs(preset) do
		self:SetSettingsConfigOption(name, value)
	end
end

---------------------------------------------------------------------------------
-- Widget interface callins
---------------------------------------------------------------------------------

function Configuration:SetConfigData(data)
	if data ~= nil then
		for k, v in pairs(data) do
			self:SetConfigValue(k, v)
		end
	end

	-- Fix old channel memory.
	for key, value in pairs(self.channels) do
		if string.find(key, "debriefing") then
			self.channels[key] = nil
		end
	end
	
	self.game_settings.XResolutionWindowed = nil
	self.game_settings.YResolutionWindowed = nil
	self.game_settings.WindowPosX = nil
	self.game_settings.WindowPosY = nil
	self.game_settings.WindowBorderless = nil
	self.game_settings.Fullscreen = nil
	
	local newSpringsettings = VFS.Include(LUA_DIRNAME .. "configs/springsettings/springsettingsChanges.lua")
	for key, value in pairs(newSpringsettings) do
		self.game_settings[key] = value
	end
	
	self.forcedCompatibilityProfile = VFS.Include(LUA_DIRNAME .. "configs/springsettings/forcedCompatibilityProfile.lua")
	
	self.defaultSettingsPreset = data.defaultSettingsPreset
	if (not self.defaultSettingsPreset) and self.gameConfig.SettingsPresetFunc then
		self.defaultSettingsPreset = self.gameConfig.SettingsPresetFunc()
		if self.defaultSettingsPreset then
			self:ApplySettingsConfigPreset(self.defaultSettingsPreset)
		end
	end
end

function Configuration:GetConfigData()
	return {
		game_fullscreen = self.game_fullscreen,
		animate_lobby = self.animate_lobby,
		game_settings = self.game_settings,
		atiIntelCompat = self.atiIntelCompat,
		window_WindowPosX = self.window_WindowPosX,
		window_WindowPosY = self.window_WindowPosY,
		window_XResolutionWindowed = self.window_XResolutionWindowed,
		window_YResolutionWindowed = self.window_YResolutionWindowed,
		campaignSaveFile = self.campaignSaveFile,
	}
end

---------------------------------------------------------------------------------
-- Setters
---------------------------------------------------------------------------------

function Configuration:SetConfigValue(key, value)
	if self[key] == value then
		return
	end
	self[key] = value
	if key == "atiIntelCompat" then
		if value then
			self:UpdateFixedSettings(self.AtiIntelSettingsOverride)
		else
			self:UpdateFixedSettings()
		end
	end
	self:_CallListeners("OnConfigurationChange", key, value)
end

---------------------------------------------------------------------------------
-- Getters
---------------------------------------------------------------------------------

function Configuration:GetErrorColor()
	return self.errorColor
end

function Configuration:GetWarningColor()
	return self.warningColor
end

function Configuration:GetNormalColor()
	return self.normalColor
end

function Configuration:GetSuccessColor()
	return self.successColor
end

function Configuration:GetPartialColor()
	return self.partialColor
end

function Configuration:GetSelectedColor()
	return self.selectedColor
end

function Configuration:GetHighlightedColor()
	return self.highlightedColor
end

function Configuration:GetButtonFocusColor()
	return self.buttonFocusColor
end

-- NOTE: this one is in opengl range [0,1]
function Configuration:GetButtonSelectedColor()
	return self.buttonSelectedColor
end

function Configuration:GetCross()
	return self:GetErrorColor() .. "X"
end

function Configuration:GetTick()
	return self:GetSuccessColor() .. "O"
end

function Configuration:GetFont(sizeScale)
	return {
		size = self.font[sizeScale].size,
		shadow = self.font[sizeScale].shadow,
	}
end

function Configuration:GetHeadingImage()
	return self.gameConfig.headingLarge
end

function Configuration:GetAlliesFactionImage(suffix)
	local s = suffix or ""
	return self.gameConfig.alliesImage .. s .. ".png"
end

function Configuration:GetAxisFactionImage(suffix)
	local s = suffix or ""
	return self.gameConfig.axisImage .. s .. ".png"
end

function Configuration:GetEngineVersion()
	if tonumber(Spring.Utilities.GetEngineVersion()) then
		-- Master releases lack the '.0' at the end. Who knows what other cases are wrong.
		-- Add as required.
		return (Spring.Utilities.GetEngineVersion() .. ".0")
	else
		return string.gsub(Spring.Utilities.GetEngineVersion(), " develop", "")
	end
end

function Configuration:IsValidEngineVersion(engineVersion)
	return engineVersion == self:GetEngineVersion()
end

function Configuration:GetIsRunning64Bit()
	if self.isRunning64Bit ~= nil then
		return self.isRunning64Bit
	end
	if Platform then
		-- osWordSize is not the same as spring bit version.
		--return Platform.osWordSize == 64
	end
	local infologFile, err = io.open("infolog.txt", "r")
	if not infologFile then
		Spring.Echo("Error opening infolog.txt", err)
		return false
	end
	local line = infologFile:read()
	while line do
		if string.find(line, "Physical CPU Cores") then
			break
		end
		if string.find(line, "Word Size") then
			if string.find(line, "64%-bit") then
				self.isRunning64Bit = true
				infologFile:close()
				return true
			else
				self.isRunning64Bit = false
				infologFile:close()
				return false
			end
		end
		line = infologFile:read()
	end
	infologFile:close()
	return false
end

function Configuration:GetIsNotRunningNvidia()
	if self.isNotRunningNvidia ~= nil then
		return self.isNotRunningNvidia
	end
	if Platform then
		return Platform.gpuVendor ~= "Nvidia"
	end
	local infologFile, err = io.open("infolog.txt", "r")
	if not infologFile then
		Spring.Echo("Error opening infolog.txt", err)
		return false
	end
	local line = infologFile:read()
	while line do
		if string.find(line, "PostInit") then
			-- We are past the part of the infolog where NVIDIA would appear
			infologFile:close()
			self.isNotRunningNvidia = true
			return true
		end
		if string.find(line, "NVIDIA") then
			infologFile:close()
			self.isNotRunningNvidia = false
			return false
		end
		line = infologFile:read()
	end
	infologFile:close()
	self.isNotRunningNvidia = true
	return true
end

---------------------------------------------------------------------------------
-- Listener handler
---------------------------------------------------------------------------------
local function ShallowCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in pairs(orig) do
			copy[orig_key] = orig_value
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function Configuration:AddListener(event, listener)
	if listener == nil then
		Log.Error("Event: " .. tostring(event) .. ", listener cannot be nil")
		return
	end
	local eventListeners = self.listeners[event]
	if eventListeners == nil then
		eventListeners = {}
		self.listeners[event] = eventListeners
	end
	table.insert(eventListeners, listener)
end

function Configuration:RemoveListener(event, listener)
	if self.listeners[event] then
		for k, v in pairs(self.listeners[event]) do
			if v == listener then
				table.remove(self.listeners[event], k)
				if #self.listeners[event] == 0 then
					self.listeners[event] = nil
				end
				break
			end
		end
	end
end

function Configuration:_CallListeners(event, ...)
	if self.listeners[event] == nil then
		return nil -- no event listeners
	end
	local eventListeners = ShallowCopy(self.listeners[event])
	local args = {...}
	local n = select("#", ...)
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		xpcall(function() listener(listener, unpack(args, 1, n)) end,
			function(err) self:_PrintError(err) end )
	end
	return true
end

function Configuration:_PrintError(err)
	-- FIXME: cleanup more
	Log.Error(err)
	Log.Error(debug.traceback(err))
end

---------------------------------------------------------------------------------
-- 'Initialization'
---------------------------------------------------------------------------------
-- shadow the Configuration class with a singleton
Configuration = Configuration()
