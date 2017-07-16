local includes = {
	-- order matters
	"headers/exports.lua",

	-- config
	"components/configuration.lua",

	-- basic components
	"components/component.lua",
	"components/console.lua",

	-- misc
	"components/background.lua",

	-- new stuff
	"components/interface_root.lua",
}

s44 = widget

for _, file in ipairs(includes) do
	VFS.Include(S44_DIR .. file, s44, VFS.RAW_FIRST)
end

function s44:_Initialize()
	self:WrapCall(function()
		WG.Delay(function()
			lobby:AddListener("OnJoinBattle",
				function(listener, battleID)
					local battle = lobby:GetBattle(battleID)
					if not WG.s44.Configuration.showMatchMakerBattles and battle and battle.isMatchMaker then
						WG.BattleStatusPanel.RemoveBattleTab()
						return
					end
					Spring.Log("chobby", LOG.NOTICE, "Showing battle with ID", battleID)
					WG.BattleRoomWindow.ShowMultiplayerBattleRoom(battleID)
				end
			)
		end, 0.001)
	end)
	self:WrapCall(function()
		WG.Delay(function()
			lobby:AddListener("OnSayServerMessage",
				function(listener, text, timeSent)
					Chotify:Post({
						title = "Server",
						body = text,
					})
				end
			)
		end, 0.001)
	end)
	self:WrapCall(function()
		WG.Delay(function()
			lobby:AddListener("OnSuggestedEngineVersion",
				function(listener, engineName)
					if engineName and not WG.s44.Configuration:IsValidEngineVersion(engineName) then
						WG.s44.InformationPopup("Wrong Spring engine version. The required version is '" .. engineName .. "', your version is '" .. Spring.Utilities.GetEngineVersion() .. "'.\n\nRestart the game to get the correct version.", 480, 248)
					end
				end
			)
		end, 0.001)
	end)
end

function s44:GetRegisteredComponents()
	return Component.registeredComponents
end

function s44:_DrawScreen()
	self:WrapCall(function()
	end)
end

function s44:_ViewResize(sw, sh)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:ViewResize(sw, sh)
		end
	end)
end

function s44:_DownloadStarted(id)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadStarted(id)
		end
	end)
end

function s44:_DownloadFinished(id)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadFinished(id)
		end
	end)
end

function s44:_DownloadFailed(id, errorId)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadFailed(id, errorId)
		end
	end)
end

function s44:_DownloadProgress(id, downloaded, total)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadProgress(id, downloaded, total)
		end
	end)
end

function s44:_DownloadQueued(id, archiveName, archiveType)
	self:WrapCall(function()
		for i, comp in pairs(self:GetRegisteredComponents()) do
			comp:DownloadQueued(id, archiveName, archiveType)
		end
	end)
end

function s44:WrapCall(func)
	xpcall(function() func() end,
		function(err) self:_PrintError(err) end )
end

function s44:_PrintError(err)
	Spring.Log("S44:Campaign", LOG.ERROR, err)
	Spring.Log("S44:Campaign", LOG.ERROR, debug.traceback(err))
end

function s44:_GetConfigData()
	return Configuration:GetConfigData()
end

function s44:_SetConfigData(data)
	Configuration:SetConfigData(data)
end

return s44
