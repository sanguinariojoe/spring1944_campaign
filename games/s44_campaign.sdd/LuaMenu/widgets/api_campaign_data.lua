--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

function widget:GetInfo()
	return {
		name      = "Campaign Data Handler",
		desc      = "",
		author    = "KingRaptor & GoogleFrog",
		date      = "2 March 2017",
		license   = "GNU GPL, v2 or later",
		layer     = -1000,
		enabled   = true,  --  loaded by default?
	}
end

--------------------------------------------------------------------------------
-- data
--------------------------------------------------------------------------------

-- this stores anything that goes into a save file
local gamedata = nil

local externalFunctions = {}

local SAVE_DIR = "Saves/campaign/"
local ICONS_DIR = LUA_DIRNAME .. "configs/gameConfig/s44/skinning/icons"
local WON_STRING = "Campaign_S44Won"
local LOST_STRING = "Campaign_S44Lost"
local AWARD_STRING = "Campaign_S44Award"
-- Just increase this value when something is changed in the campaign data
local VERSION = 1

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Listeners

local listeners = {}

local function CallListeners(event, ...)
	if listeners[event] == nil then
		return nil -- no event listeners
	end
	local eventListeners = Spring.Utilities.ShallowCopy(listeners[event])
	for i = 1, #eventListeners do
		local listener = eventListeners[i]
		args = {...}
		xpcall(function() listener(listener, unpack(args)) end,
			function(err) Spring.Echo("Campaign Listener Error", err) end )
	end
	return true
end

function externalFunctions.AddListener(event, listener)
	if listener == nil then
		Spring.Log(LOG_SECTION, LOG.ERROR, "Event: " .. tostring(event) .. ", listener cannot be nil")
		return
	end
	local eventListeners = listeners[event]
	if eventListeners == nil then
		eventListeners = {}
		listeners[event] = eventListeners
	end
	table.insert(eventListeners, listener)
end

function externalFunctions.RemoveListener(event, listener)
	if listeners[event] then
		for k, v in pairs(listeners[event]) do
			if v == listener then
				table.remove(listeners[event], k)
				if #listeners[event] == 0 then
					listeners[event] = nil
				end
				break
			end
		end
	end
end


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Save/Load
-- Returns the data stored in a save file
local function SaveGame()
	if gamedata == nil then
		LoadGame()
	end
	local fileName = WG.s44.Configuration.campaignSaveFile
	local success, err = pcall(function()
		Spring.CreateDir(SAVE_DIR)
		local path = SAVE_DIR .. fileName .. ".lua"
		local saveData = Spring.Utilities.CopyTable(gamedata, true)
		saveData.name = fileName
		saveData.date = os.date('*t')
		saveData.version = VERSION
		table.save(saveData, path)
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Saved game to " .. path)
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error saving game: " .. err)
	end
	return success
end

local function Load(filepath)
	local ret = nil
	local success, err = pcall(function()
		local saveData = VFS.Include(filepath)
		if saveData.version == VERSION then
			ret = saveData
		end
	end)
	if (not success) then
		Spring.Log(widget:GetInfo().name, LOG.ERROR, "Error loading file: " .. err)
	else
		return ret
	end
end

local function LoadGame()
	local fileName = WG.s44.Configuration.campaignSaveFile
	local path = SAVE_DIR .. fileName .. ".lua"
	if not VFS.FileExists(path) then
		gamedata = WG.s44.Configuration.campaignData
	else
		gamedata = Load(path)
		if not gamedata then
			gamedata = WG.s44.Configuration.campaignData
			Spring.Log(widget:GetInfo().name, LOG.WARNING, "Outdated campaign file")
		end
		Spring.Log(widget:GetInfo().name, LOG.INFO, "Loaded file " .. fileName)
	end
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Callins

function externalFunctions.GetNumberOfDays(campaign)
	if gamedata == nil then
		LoadGame()
	end
	local key = campaign or "allies"
	if not gamedata[key] then
		return 0
	end
	return #gamedata[key]
end

function externalFunctions.IsDayUnlocked(dayID, campaign)
	if gamedata == nil then
		LoadGame()
	end
	local key = campaign or "allies"
	if not gamedata[key] or dayID <= 0 or dayID > #gamedata[key] then
		return false
	end
	if dayID == 1 then
		-- The first day is always unlocked
		return true
	end
	local prev = gamedata[key]
	local unlocked = true
	for _,c in ipairs(prev.chapters) do
		if c.locks and not c.success then
			unlocked = false
			break
		end
	end
	return unlocked
end

function externalFunctions.GetLastDayUnlocked(campaign)
	if gamedata == nil then
		LoadGame()
	end
	local key = campaign or "allies"
	if not gamedata[key] then
		return nil
	end
	local dayID = 0
	for i=1,#gamedata[key] do
		if externalFunctions.IsDayUnlocked(i, key) then
			dayID = i
		end
	end
	if dayID == 0 then
		return nil
	end
	return dayID
end

function externalFunctions.GetDayData(dayID, campaign)
	if gamedata == nil then
		LoadGame()
	end
	local key = campaign or "allies"
	if not externalFunctions.IsDayUnlocked(dayID, key) then
		return nil
	end

	return gamedata[key][dayID]
end

function externalFunctions.IsCampaignFinished(campaign)
	if gamedata == nil then
		LoadGame()
	end
	local key = campaign or "allies"
	if not gamedata[key] then
		return false
	end
	if not externalFunctions.IsDayUnlocked(#gamedata[key], key) then
		return false
	end
	local finished = true
	for _,c in ipairs(gamedata[key].chapters) do
		if c.locks and not c.success then
			finished = false
			break
		end
	end
	return finished
end

function externalFunctions.SelectMission(chapterID, dayID, campaign)
	-- Call this function before starting the game!!!
	if gamedata == nil then
		LoadGame()
	end
	-- This function assumes that all, the chapter, day and campaign, are valid
	gamedata.selected = {campaign=campaign,
	                     day=dayID,
	                     chapter=chapterID}
end

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Initialiazation

function widget:Initialize()
	S44_DIR = "LuaMenu/widgets/s44/"
	VFS.Include("LuaMenu/widgets/s44/headers/exports.lua", nil, VFS.RAW_FIRST)
	
	WG.CampaignData = externalFunctions
	WG.CampaignData.Side = "allies"  -- Start with allies, for debugging purposes

	WG.Delay(LoadGame, 0.1)
end

function widget:RecvLuaMsg(msg)
	local sel = gamedata.selected
	if not sel then
		return
	end
	if string.find(msg, WON_STRING) then
		gamedata[sel.campaign][sel.day].chapters[sel.chapter].success = true
	elseif string.find(msg, LOST_STRING) then
		gamedata[sel.campaign][sel.day].chapters[sel.chapter].success = false
	elseif string.find(msg, AWARD_STRING) then
		local endOfID = string.find(msg, " ")
		local awardID = string.sub(msg, 18, endOfID)
		local awardImg = string.sub(msg, endOfID + 1)
		if not gamedata[sel.campaign][sel.day].chapters[sel.chapter].awards then
			gamedata[sel.campaign][sel.day].chapters[sel.chapter].awards = {}
		end
		local a = gamedata[sel.campaign][sel.day].chapters[sel.chapter].awards
		a[awardID] = {
			img = awardImg
		}
	end
	SaveGame()
end

function widget:Shutdown()
	WG.CampaignData = nil
end
