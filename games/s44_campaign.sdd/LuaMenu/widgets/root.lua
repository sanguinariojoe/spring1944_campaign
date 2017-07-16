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

local glTexCoord = gl.TexCoord
local glVertex = gl.Vertex
local glColor = gl.Color
local glRect = gl.Rect
local glTexture = gl.Texture
local glTexRect = gl.TexRect
local glDepthTest = gl.DepthTest
local glBeginEnd = gl.BeginEnd
local GL_QUADS = GL.QUADS
local GL_TRIANGLE_FAN = GL.TRIANGLE_FAN
local glPushMatrix = gl.PushMatrix
local glPopMatrix = gl.PopMatrix
local glTranslate = gl.Translate
local glBeginText = gl.BeginText
local glEndText = gl.EndText
local glText = gl.Text
local glCallList = gl.CallList
local glCreateList = gl.CreateList
local glDeleteList = gl.DeleteList


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
end

function widget:ActivateGame()
end

function widget:Initialize()
	WG.LimitFps.ForceRedrawPeriod(5) -- High FPS for the first few seconds to shorten the initial white flash.

	if not WG.Chili then
		Spring.Log("chobby", LOG.ERROR, "Missing chiliui.")
		widgetHandler:RemoveWidget(widget)
		return
	end

	s44 = VFS.Include(S44_DIR .. "core.lua", nil)

	WG.s44 = s44
	WG.s44:_Initialize()

	interfaceRoot = WG.s44.GetInterfaceRoot()
	s44.interfaceRoot = interfaceRoot

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

function BackgroundList()
	glColor(1, 1, 1, 1)
	glTexture(LUA_DIRNAME .. "configs/gameConfig/s44/skinning/background.png")
	glTexRect(0, 0, screenWidth, screenHeight, true, true)
	glTexture(false)
end

local backgroundList
function widget:DrawScreen()
	glPushMatrix()
	glTranslate(0, 0, 0)
	--call list
	if backgroundList then
		glCallList(backgroundList)
	else 
		backgroundList = glCreateList(BackgroundList)
	end
	glPopMatrix()
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
