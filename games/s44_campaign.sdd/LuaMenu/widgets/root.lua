--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function widget:GetInfo()
	return {
		name      = "Spring:1944 campaign lobby",
		desc      = "Lobby to play the Spring:1944 campaign",
		author    = "Jose Luis Cercos-Pita",
		date      = "15/7/2015",
		license   = "GPL-v3",
		layer     = 1001,
		enabled   = true,
	}
end

include("keysym.h.lua")

LIBS_DIR = "libs/"
LCS = loadstring(VFS.LoadFile(LIBS_DIR .. "lcs/LCS.lua"))
LCS = LCS()

S44_DIR = LUA_DIRNAME .. "widgets/s44/"

--------------------------------------------------------------------------------
-------------------------------------------------------------------------------- 
-- Callins

local interfaceRoot

local oldSizeX, oldSizeY
function widget:ViewResize(vsx, vsy)
	oldSizeX, oldSizeY = vsx, vsy
	screenWidth = vsx
	screenHeight = vsy
end

function widget:Update()
	local screenWidth, screenHeight = Spring.GetWindowGeometry()
	if screenWidth ~= oldSizeX or screenHeight ~= oldSizeY then
		widget:ViewResize(screenWidth, screenHeight)
	end
end

local ignoreFirstCall = true
function widget:ActivateMenu()
	if ignoreFirstCall then
		ignoreFirstCall = false
		return
	end
	interfaceRoot.SetIngame(false)
	lobby:SetIngameStatus(false)
end

function widget:ActivateGame()
	interfaceRoot.SetIngame(true)
end

function widget:Initialize()
	WG.LimitFps.ForceRedrawPeriod(5) -- High FPS for the first few seconds to shorten the initial white flash.
	if not WG.LibLobby then
		Spring.Log("chobby", LOG.ERROR, "Missing liblobby.")
		widgetHandler:RemoveWidget(widget)
		return
	end
	if not WG.Chili then
		Spring.Log("chobby", LOG.ERROR, "Missing chiliui.")
		widgetHandler:RemoveWidget(widget)
		return
	end

	s44 = VFS.Include(S44_DIR .. "core.lua", nil)

	WG.s44 = s44
	WG.s44:_Initialize()

	interfaceRoot = WG.s44.GetInterfaceRoot()
	local lobbyInterfaceHolder = interfaceRoot.GetLobbyInterfaceHolder()
	s44.lobbyInterfaceHolder = lobbyInterfaceHolder
	s44.interfaceRoot = interfaceRoot

	local function OnBattleAboutToStart()
		lobby:SetIngameStatus(true)
	end
	WG.LibLobby.localLobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)
	WG.LibLobby.lobby:AddListener("OnBattleAboutToStart", OnBattleAboutToStart)

	Spring.SetWMCaption("Spring:1944", "Spring:1944")
	local taskbarIcon = LUA_DIRNAME .. "configs/gameConfig/s44/taskbarLogo.png"
	if taskbarIcon then
		Spring.SetWMIcon(taskbarIcon)
	end
end

function widget:KeyPress(key, mods, isRepeat, label, unicode)
end

function widget:Shutdown()
	Spring.Log("S44", LOG.NOTICE, "Shutdown")
end

function widget:DownloadStarted(...)
end

function widget:DownloadFinished(...)
end

function widget:DownloadFailed(...)
end

function widget:DownloadProgress(...)
end

function widget:DownloadQueued(...)
end

function widget:GetConfigData()
end

function widget:SetConfigData(...)
end
