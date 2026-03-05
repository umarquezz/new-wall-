-- ╔══════════════════════════════════════════════════╗
-- ║              W O R L D   Script                  ║
-- ║           Blox Fruits | by umarquezz             ║
-- ║                  v2.0.0                          ║
-- ╚══════════════════════════════════════════════════╝

-- ══════════════════════════════════════════
--   SERVIÇOS
-- ══════════════════════════════════════════
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer      = Players.LocalPlayer
local Camera           = Workspace.CurrentCamera

-- ══════════════════════════════════════════
--   PALETA DE CORES
-- ══════════════════════════════════════════
local C = {
    bg0         = Color3.fromRGB(8,   8,  18),
    bg1         = Color3.fromRGB(14,  14, 28),
    bg2         = Color3.fromRGB(20,  20, 40),
    bg3         = Color3.fromRGB(28,  28, 54),
    accent      = Color3.fromRGB(80,  160, 255),
    accent2     = Color3.fromRGB(140,  80, 255),
    accentHover = Color3.fromRGB(110, 185, 255),
    green       = Color3.fromRGB(60,  210, 130),
    red         = Color3.fromRGB(220,  70,  70),
    orange      = Color3.fromRGB(220, 160,  40),
    text        = Color3.fromRGB(230, 230, 240),
    textDim     = Color3.fromRGB(140, 140, 160),
    white       = Color3.fromRGB(255, 255, 255),
    transparent = Color3.fromRGB(0,   0,   0),
}

-- ══════════════════════════════════════════
--   CONFIGURAÇÕES
-- ══════════════════════════════════════════
local Cfg = {
    ToggleKey       = Enum.KeyCode.RightShift,
    -- aura
    AuraEnabled     = false,
    AuraColor       = Color3.fromRGB(80, 160, 255),
    AuraPulse       = true,
    -- tracers
    TracersEnabled  = false,
    TracerColor     = Color3.fromRGB(80, 160, 255),
    TracerThickness = 2,
    -- farm
    AutoFarmMobs    = false,
    AutoFarmBoss    = false,
    AutoFarmFruit   = false,
    -- esp
    ESPEnabled      = false,
    -- misc
    InfiniteJump    = false,
    SpeedBoost      = false,
    SpeedValue      = 32,
    NoFallDamage    = false,
}

-- ══════════════════════════════════════════
--   HELPERS
-- ══════════════════════════════════════════
local function GetChar()  return LocalPlayer.Character end
local function GetHum()   local c=GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function GetHRP()   local c=GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end

local function Notify(title, body, dur)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification",{
            Title=title, Text=body, Duration=dur or 3
        })
    end)
end

local function Tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play(); return t
end

local function Spring(obj, t, style, props)
    return Tween(obj, TweenInfo.new(t, style or Enum.EasingStyle.Quint,
        Enum.EasingDirection.Out), props)
end

-- ══════════════════════════════════════════
--   AURA SYSTEM
-- ══════════════════════════════════════════
local _auraObjs = {}

local function AuraDestroy()
    for _,v in pairs(_auraObjs) do pcall(function() v:Destroy() end) end
    _auraObjs = {}
end

local function AuraCreate()
    AuraDestroy()
    local hrp = GetHRP(); if not hrp then return end
    local char = GetChar()

    -- holder
    local mdl  = Instance.new("Model"); mdl.Name="WORLD_Aura"; mdl.Parent=Workspace

    -- selection box
    local sb = Instance.new("SelectionBox")
    sb.Adornee             = char
    sb.Color3              = Cfg.AuraColor
    sb.SurfaceColor3       = Cfg.AuraColor
    sb.SurfaceTransparency = 0.75
    sb.LineThickness       = 0.06
    sb.Parent              = mdl

    -- neon sphere
    local sphere = Instance.new("Part")
    sphere.Name          = "AuraSphere"
    sphere.Shape         = Enum.PartType.Ball
    sphere.Size          = Vector3.new(8,8,8)
    sphere.Color         = Cfg.AuraColor
    sphere.Material      = Enum.Material.Neon
    sphere.Transparency  = 0.5
    sphere.CanCollide    = false
    sphere.CastShadow    = false
    sphere.Anchored      = false
    sphere.Parent        = mdl

    local w = Instance.new("Weld")
    w.Part0=hrp; w.Part1=sphere; w.C0=CFrame.new(0,0,0); w.Parent=sphere

    -- trail
    local a0 = Instance.new("Attachment"); a0.Position=Vector3.new(0, 1,0); a0.Parent=hrp
    local a1 = Instance.new("Attachment"); a1.Position=Vector3.new(0,-1,0); a1.Parent=hrp
    local trail = Instance.new("Trail")
    trail.Attachment0    = a0
    trail.Attachment1    = a1
    trail.Color          = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Cfg.AuraColor),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255)),
    })
    trail.Transparency   = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(1, 1),
    })
    trail.Lifetime=0.6; trail.MinLength=0; trail.FaceCamera=true
    trail.Parent=hrp

    -- particles
    local pe = Instance.new("ParticleEmitter")
    pe.Color         = ColorSequence.new(Cfg.AuraColor)
    pe.LightEmission = 1; pe.LightInfluence=0
    pe.Size          = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.25), NumberSequenceKeypoint.new(1,0)
    })
    pe.Transparency  = NumberSequence.new({
        NumberSequenceKeypoint.new(0,0.2), NumberSequenceKeypoint.new(1,1)
    })
    pe.Speed=NumberRange.new(2,6); pe.Rate=35
    pe.Lifetime=NumberRange.new(0.6,1.2)
    pe.SpreadAngle=Vector2.new(180,180)
    pe.Parent=hrp

    -- pulse tween
    if Cfg.AuraPulse then
        Tween(sphere, TweenInfo.new(1.2, Enum.EasingStyle.Sine,
            Enum.EasingDirection.InOut, -1, true),
            {Transparency=0.25, Size=Vector3.new(10,10,10)})
    end

    for _,v in pairs({mdl,a0,a1,trail,pe}) do table.insert(_auraObjs,v) end
end

-- ══════════════════════════════════════════
--   TRACERS SYSTEM  (Drawing API)
-- ══════════════════════════════════════════
local _tracerLines = {}      -- { [player] = drawLine }
local _tracerConn           -- RenderStepped connection

local function TracerGetScreenCenter()
    return Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
end

local function TracerDestroy()
    if _tracerConn then _tracerConn:Disconnect(); _tracerConn=nil end
    for _,line in pairs(_tracerLines) do
        pcall(function() line:Remove() end)
    end
    _tracerLines = {}
end

local function TracerCreate()
    TracerDestroy()
    if not Drawing then
        Notify("⚠️ Tracers", "Drawing API não disponível neste executor.", 4)
        return
    end

    _tracerConn = RunService.RenderStepped:Connect(function()
        local hrp  = GetHRP()
        local myPos = hrp and Camera:WorldToViewportPoint(hrp.Position)

        for _, plt in pairs(Players:GetPlayers()) do
            if plt == LocalPlayer then continue end

            local chr = plt.Character
            local tgt = chr and chr:FindFirstChild("HumanoidRootPart")

            if not _tracerLines[plt] then
                local ln = Drawing.new("Line")
                ln.Thickness  = Cfg.TracerThickness
                ln.Color      = Cfg.TracerColor
                ln.Transparency = 1
                ln.Visible    = false
                _tracerLines[plt] = ln
            end

            local ln = _tracerLines[plt]

            if tgt and hrp then
                local wpos, onScreen = Camera:WorldToViewportPoint(tgt.Position)
                if onScreen then
                    ln.From      = TracerGetScreenCenter()
                    ln.To        = Vector2.new(wpos.X, wpos.Y)
                    ln.Color     = Cfg.TracerColor
                    ln.Visible   = true
                else
                    ln.Visible = false
                end
            else
                ln.Visible = false
            end
        end

        -- limpa players que saíram
        for plt, ln in pairs(_tracerLines) do
            if not plt.Parent then
                pcall(function() ln:Remove() end)
                _tracerLines[plt] = nil
            end
        end
    end)
end

-- ══════════════════════════════════════════
--   ESP SYSTEM
-- ══════════════════════════════════════════
local _espObjs = {}

local function ESPDestroy()
    for _,v in pairs(_espObjs) do pcall(function() v:Destroy() end) end
    _espObjs = {}
end

local function ESPForPlayer(plt)
    if plt == LocalPlayer then return end
    local function attach()
        local chr = plt.Character; if not chr then return end
        local hrp = chr:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        if hrp:FindFirstChild("W_ESP_"..plt.Name) then return end

        local bb = Instance.new("BillboardGui")
        bb.Name          = "W_ESP_"..plt.Name
        bb.Size          = UDim2.new(0,120,0,48)
        bb.StudsOffset   = Vector3.new(0,3.5,0)
        bb.AlwaysOnTop   = true
        bb.Parent        = hrp

        local bg = Instance.new("Frame")
        bg.Size             = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(8,8,18)
        bg.BackgroundTransparency = 0.25
        bg.BorderSizePixel  = 0
        Instance.new("UICorner",bg).CornerRadius = UDim.new(0,6)
        bg.Parent = bb

        local stroke = Instance.new("UIStroke")
        stroke.Color     = Cfg.TracerColor
        stroke.Thickness = 1.5
        stroke.Parent    = bg

        local nLbl = Instance.new("TextLabel")
        nLbl.Size   = UDim2.new(1,0,0.55,0)
        nLbl.BackgroundTransparency=1
        nLbl.Text   = "⬡ "..plt.Name
        nLbl.TextColor3 = C.accent
        nLbl.Font   = Enum.Font.GothamBold
        nLbl.TextScaled=true
        nLbl.Parent = bg

        local hLbl = Instance.new("TextLabel")
        hLbl.Position  = UDim2.new(0,0,0.55,0)
        hLbl.Size      = UDim2.new(1,0,0.45,0)
        hLbl.BackgroundTransparency=1
        hLbl.TextColor3 = C.green
        hLbl.Font       = Enum.Font.Gotham
        hLbl.TextScaled = true
        hLbl.Parent     = bg

        local hum = chr:FindFirstChildOfClass("Humanoid")
        RunService.RenderStepped:Connect(function()
            if not bb.Parent then return end
            if hum then
                hLbl.Text = ("❤ %d/%d"):format(math.floor(hum.Health), math.floor(hum.MaxHealth))
            end
        end)

        table.insert(_espObjs, bb)
    end

    plt.CharacterAdded:Connect(function() task.wait(0.8); attach() end)
    if plt.Character then attach() end
end

local function ESPCreate()
    for _,p in pairs(Players:GetPlayers()) do ESPForPlayer(p) end
    Players.PlayerAdded:Connect(ESPForPlayer)
end

-- ══════════════════════════════════════════
--   MISC
-- ══════════════════════════════════════════
local _ijConn
local function SetInfiniteJump(on)
    if _ijConn then _ijConn:Disconnect(); _ijConn=nil end
    if on then
        _ijConn = UserInputService.JumpRequest:Connect(function()
            local h=GetHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
    Notify("♾ Infinite Jump", on and "Ativado!" or "Desativado!", 2)
end

local _nfdConn
local function SetNoFallDamage(on)
    if _nfdConn then _nfdConn:Disconnect(); _nfdConn=nil end
    if on then
        _nfdConn = RunService.Heartbeat:Connect(function()
            local h=GetHum()
            if h and h:GetState()==Enum.HumanoidStateType.Freefall then
                h:ChangeState(Enum.HumanoidStateType.Landed)
            end
        end)
    end
    Notify("🛡 No Fall Damage", on and "Ativado!" or "Desativado!", 2)
end

local function SetSpeed(mult)
    local h=GetHum(); if h then h.WalkSpeed = mult end
end

-- RESPAWN: restaura features
LocalPlayer.CharacterAdded:Connect(function(chr)
    task.wait(1.5)
    if Cfg.AuraEnabled  then AuraCreate() end
    if Cfg.InfiniteJump then SetInfiniteJump(true) end
    if Cfg.NoFallDamage then SetNoFallDamage(true) end
    if Cfg.SpeedBoost   then
        local h=chr:FindFirstChildOfClass("Humanoid")
        if h then h.WalkSpeed=Cfg.SpeedValue end
    end
end)

-- ══════════════════════════════════════════
--   GUI — WORLD
-- ══════════════════════════════════════════
if game.CoreGui:FindFirstChild("WORLD_GUI") then
    game.CoreGui.WORLD_GUI:Destroy()
end

local Screen = Instance.new("ScreenGui")
Screen.Name           = "WORLD_GUI"
Screen.ResetOnSpawn   = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Screen.IgnoreGuiInset = true
Screen.Parent         = (gethui and gethui()) or game.CoreGui

-- ────────────────────────────────
--   JANELA PRINCIPAL
-- ────────────────────────────────
local Win = Instance.new("Frame")
Win.Name             = "Win"
Win.Size             = UDim2.new(0,500,0,430)
Win.Position         = UDim2.new(0.5,-250,0.5,-215)
Win.BackgroundColor3 = C.bg0
Win.BorderSizePixel  = 0
Win.ClipsDescendants = false
Win.Parent           = Screen

Instance.new("UICorner",Win).CornerRadius = UDim.new(0,14)

-- sombra
local Shadow = Instance.new("ImageLabel")
Shadow.Name              = "Shadow"
Shadow.AnchorPoint       = Vector2.new(0.5,0.5)
Shadow.BackgroundTransparency = 1
Shadow.Position          = UDim2.new(0.5,0,0.5,8)
Shadow.Size              = UDim2.new(1,40,1,40)
Shadow.ZIndex            = 0
Shadow.Image             = "rbxassetid://6014261993"
Shadow.ImageColor3       = Color3.fromRGB(0,0,0)
Shadow.ImageTransparency = 0.45
Shadow.ScaleType         = Enum.ScaleType.Slice
Shadow.SliceCenter       = Rect.new(49,49,450,450)
Shadow.Parent            = Win

-- stroke gradiente  
local WinStroke = Instance.new("UIStroke")
WinStroke.Thickness  = 1.5
WinStroke.Color      = C.accent
WinStroke.Transparency = 0.2
WinStroke.Parent     = Win

-- inner background gradient
local WinGrad = Instance.new("UIGradient")
WinGrad.Color    = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   C.bg0),
    ColorSequenceKeypoint.new(0.6, C.bg1),
    ColorSequenceKeypoint.new(1,   C.bg2),
})
WinGrad.Rotation = 135
WinGrad.Parent   = Win

-- ────────────────────────────────
--   TOPBAR
-- ────────────────────────────────
local TopBar = Instance.new("Frame")
TopBar.Name             = "TopBar"
TopBar.Size             = UDim2.new(1,0,0,50)
TopBar.BackgroundColor3 = C.bg1
TopBar.BorderSizePixel  = 0
TopBar.ZIndex           = 2
TopBar.Parent           = Win

Instance.new("UICorner",TopBar).CornerRadius=UDim.new(0,14)

local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(20,60,160)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60,20,160)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(20,100,200)),
})
TopGrad.Rotation = 90
TopGrad.Parent   = TopBar

-- Gloss top line
local GlossLine = Instance.new("Frame")
GlossLine.Size             = UDim2.new(0.6,0,0,1)
GlossLine.Position         = UDim2.new(0.2,0,0,0)
GlossLine.BackgroundColor3 = C.white
GlossLine.BackgroundTransparency = 0.6
GlossLine.BorderSizePixel  = 0
GlossLine.ZIndex           = 3
GlossLine.Parent           = TopBar
Instance.new("UICorner",GlossLine).CornerRadius=UDim.new(1,0)

-- Logo / Título
local LogoFrame = Instance.new("Frame")
LogoFrame.Size             = UDim2.new(0,38,0,38)
LogoFrame.Position         = UDim2.new(0,8,0.5,-19)
LogoFrame.BackgroundColor3 = C.accent
LogoFrame.BorderSizePixel  = 0
LogoFrame.ZIndex           = 3
LogoFrame.Parent           = TopBar
Instance.new("UICorner",LogoFrame).CornerRadius=UDim.new(0,8)

local LogoGrad = Instance.new("UIGradient")
LogoGrad.Color   = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(1, C.accent2),
})
LogoGrad.Rotation=135; LogoGrad.Parent=LogoFrame

local LogoLabel = Instance.new("TextLabel")
LogoLabel.Size        = UDim2.new(1,0,1,0)
LogoLabel.BackgroundTransparency=1
LogoLabel.Text        = "W"
LogoLabel.TextColor3  = C.white
LogoLabel.Font        = Enum.Font.GothamBold
LogoLabel.TextScaled  = true
LogoLabel.ZIndex      = 4
LogoLabel.Parent      = LogoFrame

local TitleLbl = Instance.new("TextLabel")
TitleLbl.Size         = UDim2.new(0,120,1,0)
TitleLbl.Position     = UDim2.new(0,54,0,0)
TitleLbl.BackgroundTransparency=1
TitleLbl.Text         = "WORLD"
TitleLbl.TextColor3   = C.white
TitleLbl.Font         = Enum.Font.GothamBlack
TitleLbl.TextScaled   = true
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex       = 3
TitleLbl.Parent       = TopBar

local SubLbl = Instance.new("TextLabel")
SubLbl.Size           = UDim2.new(0,200,0,16)
SubLbl.Position       = UDim2.new(0,56,1,-20)
SubLbl.BackgroundTransparency=1
SubLbl.Text           = "Blox Fruits  •  v2.0.0"
SubLbl.TextColor3     = Color3.fromRGB(180,200,255)
SubLbl.Font           = Enum.Font.Gotham
SubLbl.TextSize       = 11
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex         = 3
SubLbl.Parent         = TopBar

-- Botão fechar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size            = UDim2.new(0,30,0,30)
CloseBtn.Position        = UDim2.new(1,-38,0.5,-15)
CloseBtn.BackgroundColor3 = C.red
CloseBtn.Text            = "✕"
CloseBtn.TextColor3      = C.white
CloseBtn.TextScaled      = true
CloseBtn.Font            = Enum.Font.GothamBold
CloseBtn.BorderSizePixel = 0
CloseBtn.ZIndex          = 4
CloseBtn.Parent          = TopBar
Instance.new("UICorner",CloseBtn).CornerRadius=UDim.new(0,8)

CloseBtn.MouseEnter:Connect(function()
    Spring(CloseBtn, 0.15, nil, {BackgroundColor3=Color3.fromRGB(255,80,80)})
end)
CloseBtn.MouseLeave:Connect(function()
    Spring(CloseBtn, 0.15, nil, {BackgroundColor3=C.red})
end)
CloseBtn.MouseButton1Click:Connect(function()
    Win.Visible = false
end)

-- Botão minimizar
local MinBtn = Instance.new("TextButton")
MinBtn.Size            = UDim2.new(0,30,0,30)
MinBtn.Position        = UDim2.new(1,-72,0.5,-15)
MinBtn.BackgroundColor3 = C.orange
MinBtn.Text            = "–"
MinBtn.TextColor3      = C.white
MinBtn.TextScaled      = true
MinBtn.Font            = Enum.Font.GothamBold
MinBtn.BorderSizePixel = 0
MinBtn.ZIndex          = 4
MinBtn.Parent          = TopBar
Instance.new("UICorner",MinBtn).CornerRadius=UDim.new(0,8)

local _minimized = false
MinBtn.MouseButton1Click:Connect(function()
    _minimized = not _minimized
    Spring(Win,0.35, Enum.EasingStyle.Back, {
        Size = _minimized and UDim2.new(0,500,0,50) or UDim2.new(0,500,0,430)
    })
end)

-- Drag
local _drag, _dStart, _dPos
TopBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        _drag=true; _dStart=i.Position; _dPos=Win.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if _drag and i.UserInputType==Enum.UserInputType.MouseMovement then
        local d=i.Position-_dStart
        Win.Position=UDim2.new(_dPos.X.Scale,_dPos.X.Offset+d.X,
                                _dPos.Y.Scale,_dPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 then _drag=false end
end)

-- ────────────────────────────────
--   LINHA DIVISÓRIA
-- ────────────────────────────────
local Divider = Instance.new("Frame")
Divider.Size             = UDim2.new(1,-24,0,1)
Divider.Position         = UDim2.new(0,12,0,50)
Divider.BackgroundColor3 = C.accent
Divider.BackgroundTransparency = 0.6
Divider.BorderSizePixel  = 0
Divider.Parent           = Win

-- ────────────────────────────────
--   BARRA DE ABAS
-- ────────────────────────────────
local TABS = {
    {icon="⚡", name="Aura"},
    {icon="🔗", name="Tracers"},
    {icon="🌾", name="Farm"},
    {icon="👁",  name="ESP"},
    {icon="🔧", name="Misc"},
}

local TabBar = Instance.new("Frame")
TabBar.Size             = UDim2.new(1,-24,0,34)
TabBar.Position         = UDim2.new(0,12,0,56)
TabBar.BackgroundColor3 = C.bg2
TabBar.BorderSizePixel  = 0
TabBar.Parent           = Win
Instance.new("UICorner",TabBar).CornerRadius=UDim.new(0,10)

local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.SortOrder     = Enum.SortOrder.LayoutOrder
TabLayout.Padding       = UDim.new(0,3)
TabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabLayout.VerticalAlignment   = Enum.VerticalAlignment.Center
TabLayout.Parent        = TabBar

-- Indicator (pill que desliza)
local TabIndicator = Instance.new("Frame")
TabIndicator.Size             = UDim2.new(0,84,0,26)
TabIndicator.BackgroundColor3 = C.accent
TabIndicator.BorderSizePixel  = 0
TabIndicator.ZIndex           = 2
TabIndicator.Parent           = TabBar
Instance.new("UICorner",TabIndicator).CornerRadius=UDim.new(0,8)

local IndicatorGrad = Instance.new("UIGradient")
IndicatorGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accent),
    ColorSequenceKeypoint.new(1, C.accent2),
})
IndicatorGrad.Rotation=90; IndicatorGrad.Parent=TabIndicator

-- Content area
local ContentWrap = Instance.new("Frame")
ContentWrap.Size             = UDim2.new(1,-24,1,-108)
ContentWrap.Position         = UDim2.new(0,12,0,100)
ContentWrap.BackgroundTransparency = 1
ContentWrap.ClipsDescendants = true
ContentWrap.Parent           = Win

local _tabBtns     = {}
local _tabContents = {}
local _activeTab   = 0

local function SelectTab(idx)
    -- mover indicator
    local btn = _tabBtns[idx]
    if btn then
        Spring(TabIndicator, 0.25, Enum.EasingStyle.Quint, {
            Position = UDim2.new(0, btn.AbsolutePosition.X - TabBar.AbsolutePosition.X + 2, 0, 4)
        })
    end

    for i,b in pairs(_tabBtns) do
        -- deselected
        b.TextColor3 = (i==idx) and C.white or C.textDim
    end
    for i,c in pairs(_tabContents) do
        if i==idx then
            c.Visible = true
            c.Position = UDim2.new(0.05,0,0,0)
            c:TweenPosition(UDim2.new(0,0,0,0), Enum.EasingDirection.Out,
                Enum.EasingStyle.Quint, 0.25, true)
        else
            c.Visible = false
        end
    end
    _activeTab = idx
end

-- Build tabs
for i, tab in ipairs(TABS) do
    local w = 84

    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(0,w,0,30)
    btn.BackgroundTransparency = 1
    btn.Text             = tab.icon.." "..tab.name
    btn.TextColor3       = C.textDim
    btn.TextScaled       = true
    btn.Font             = Enum.Font.GothamBold
    btn.BorderSizePixel  = 0
    btn.ZIndex           = 3
    btn.LayoutOrder      = i
    btn.Parent           = TabBar
    _tabBtns[i]          = btn

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size              = UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel   = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.accent
    scroll.CanvasSize        = UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Visible           = false
    scroll.Parent            = ContentWrap
    _tabContents[i]          = scroll

    local layout = Instance.new("UIListLayout")
    layout.SortOrder  = Enum.SortOrder.LayoutOrder
    layout.Padding    = UDim.new(0,7)
    layout.Parent     = scroll

    Instance.new("UIPadding",scroll).PaddingTop = UDim.new(0,4)

    btn.MouseButton1Click:Connect(function()
        SelectTab(i)
    end)
end

-- ────────────────────────────────
--   HELPERS DE COMPONENTES
-- ────────────────────────────────

local function MakeSection(parent, label)
    local f = Instance.new("Frame")
    f.Size             = UDim2.new(1,0,0,22)
    f.BackgroundTransparency = 1
    f.Parent           = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size           = UDim2.new(1,-4,1,0)
    lbl.Position       = UDim2.new(0,4,0,0)
    lbl.BackgroundTransparency=1
    lbl.Text           = label
    lbl.TextColor3     = C.accent
    lbl.Font           = Enum.Font.GothamBold
    lbl.TextSize       = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent         = f

    local line = Instance.new("Frame")
    line.Size            = UDim2.new(1,0,0,1)
    line.Position        = UDim2.new(0,0,1,-1)
    line.BackgroundColor3 = C.accent
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent          = f

    return f
end

local function MakeToggle(parent, icon, label, default, cb)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,40)
    row.BackgroundColor3 = C.bg2
    row.BorderSizePixel  = 0
    row.Parent           = parent
    Instance.new("UICorner",row).CornerRadius=UDim.new(0,10)

    local hover = Instance.new("UIStroke")
    hover.Thickness=1; hover.Color=C.accent; hover.Transparency=0.85
    hover.Parent=row

    local icoLbl = Instance.new("TextLabel")
    icoLbl.Size      = UDim2.new(0,32,1,0)
    icoLbl.Position  = UDim2.new(0,6,0,0)
    icoLbl.BackgroundTransparency=1
    icoLbl.Text      = icon
    icoLbl.TextScaled= true
    icoLbl.Font      = Enum.Font.GothamBold
    icoLbl.TextColor3= C.text
    icoLbl.Parent    = row

    local txtLbl = Instance.new("TextLabel")
    txtLbl.Size      = UDim2.new(1,-100,1,0)
    txtLbl.Position  = UDim2.new(0,42,0,0)
    txtLbl.BackgroundTransparency=1
    txtLbl.Text      = label
    txtLbl.TextColor3= C.text
    txtLbl.Font      = Enum.Font.Gotham
    txtLbl.TextSize  = 14
    txtLbl.TextXAlignment = Enum.TextXAlignment.Left
    txtLbl.Parent    = row

    -- pill toggle
    local pill = Instance.new("Frame")
    pill.Size            = UDim2.new(0,48,0,26)
    pill.Position        = UDim2.new(1,-56,0.5,-13)
    pill.BackgroundColor3 = default and C.green or Color3.fromRGB(55,55,75)
    pill.BorderSizePixel = 0
    pill.Parent          = row
    Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)

    local knob = Instance.new("Frame")
    knob.Size            = UDim2.new(0,20,0,20)
    knob.Position        = default and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
    knob.BackgroundColor3 = C.white
    knob.BorderSizePixel = 0
    knob.Parent          = pill
    Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)

    local state = default or false
    local btn = Instance.new("TextButton")
    btn.Size             = UDim2.new(1,0,1,0)
    btn.BackgroundTransparency=1
    btn.Text             = ""
    btn.Parent           = row

    local function SetState(v)
        state = v
        Spring(pill,0.3,nil,{BackgroundColor3 = state and C.green or Color3.fromRGB(55,55,75)})
        Spring(knob,0.3,Enum.EasingStyle.Back,{
            Position = state and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
        })
        if cb then cb(state) end
    end

    btn.MouseButton1Click:Connect(function() SetState(not state) end)
    btn.MouseEnter:Connect(function()
        Spring(row,0.2,nil,{BackgroundColor3=C.bg3})
        hover.Transparency=0.5
    end)
    btn.MouseLeave:Connect(function()
        Spring(row,0.2,nil,{BackgroundColor3=C.bg2})
        hover.Transparency=0.85
    end)

    return row, function() return state end
end

local function MakeColorPicker(parent, colorList, onPick)
    local row = Instance.new("Frame")
    row.Size             = UDim2.new(1,0,0,40)
    row.BackgroundTransparency = 1
    row.Parent           = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding       = UDim.new(0,6)
    layout.SortOrder     = Enum.SortOrder.LayoutOrder
    layout.Parent        = row

    for _,pair in ipairs(colorList) do
        local name, clr = pair[1], pair[2]
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(0,36,0,36)
        btn.BackgroundColor3 = clr
        btn.BorderSizePixel  = 0
        btn.Text             = ""
        btn.Parent           = row
        Instance.new("UICorner",btn).CornerRadius=UDim.new(1,0)

        local stroke = Instance.new("UIStroke")
        stroke.Thickness=2; stroke.Color=C.white; stroke.Transparency=0.6
        stroke.Parent=btn

        btn.MouseEnter:Connect(function()
            Spring(btn,0.15,nil,{Size=UDim2.new(0,40,0,40)})
            stroke.Transparency=0
        end)
        btn.MouseLeave:Connect(function()
            Spring(btn,0.15,nil,{Size=UDim2.new(0,36,0,36)})
            stroke.Transparency=0.6
        end)
        btn.MouseButton1Click:Connect(function()
            if onPick then onPick(name, clr) end
        end)
    end

    return row
end

-- ────────────────────────────────
-- ABA 1 — AURA
-- ────────────────────────────────
do
    local sc = _tabContents[1]
    MakeSection(sc, "  ⚡  EFEITO DE AURA")

    MakeToggle(sc, "🌟", "Ativar Aura", false, function(on)
        Cfg.AuraEnabled = on
        if on then AuraCreate() else AuraDestroy()
            Notify("WORLD","Aura desativada.",2)
        end
    end)

    MakeToggle(sc, "🔄", "Pulso Animado", true, function(on)
        Cfg.AuraPulse = on
        if Cfg.AuraEnabled then AuraDestroy(); AuraCreate() end
    end)

    MakeSection(sc, "  🎨  COR DA AURA")

    local COLORS = {
        {"Azul",   Color3.fromRGB(80,160,255)},
        {"Roxo",   Color3.fromRGB(160,80,255)},
        {"Cyan",   Color3.fromRGB(0,220,220)},
        {"Verde",  Color3.fromRGB(60,210,130)},
        {"Vermelho",Color3.fromRGB(220,70,70)},
        {"Dourado",Color3.fromRGB(255,190,0)},
        {"Rosa",   Color3.fromRGB(255,80,160)},
        {"Branco", Color3.fromRGB(240,240,255)},
    }

    MakeColorPicker(sc, COLORS, function(name, clr)
        Cfg.AuraColor = clr
        Notify("🎨 Aura","Cor: "..name, 2)
        if Cfg.AuraEnabled then AuraDestroy(); AuraCreate() end
    end)
end

-- ────────────────────────────────
-- ABA 2 — TRACERS
-- ────────────────────────────────
do
    local sc = _tabContents[2]
    MakeSection(sc, "  🔗  LINHAS / TRACERS")

    MakeToggle(sc, "🔗", "Linhas para Jogadores", false, function(on)
        Cfg.TracersEnabled = on
        if on then
            TracerCreate()
            Notify("🔗 Tracers","Tracers ativados!",2)
        else
            TracerDestroy()
            Notify("🔗 Tracers","Tracers desativados.",2)
        end
    end)

    MakeSection(sc, "  🎨  COR DAS LINHAS")

    local TCOLORS = {
        {"Azul",   Color3.fromRGB(80,160,255)},
        {"Roxo",   Color3.fromRGB(160,80,255)},
        {"Cyan",   Color3.fromRGB(0,220,220)},
        {"Verde",  Color3.fromRGB(60,210,130)},
        {"Vermelho",Color3.fromRGB(220,70,70)},
        {"Dourado",Color3.fromRGB(255,190,0)},
        {"Rosa",   Color3.fromRGB(255,80,160)},
        {"Branco", Color3.fromRGB(240,240,255)},
    }

    MakeColorPicker(sc, TCOLORS, function(name, clr)
        Cfg.TracerColor = clr
        Notify("🎨 Tracers","Cor: "..name,2)
    end)

    MakeSection(sc, "  ℹ  INFORMAÇÃO")

    local info = Instance.new("TextLabel")
    info.Size             = UDim2.new(1,0,0,54)
    info.BackgroundColor3 = C.bg2
    info.TextColor3       = C.textDim
    info.Text             = "Tracers usam a Drawing API do executor.\nLinhas partem do centro da tela até\no HumanoidRootPart de cada player."
    info.Font             = Enum.Font.Gotham
    info.TextSize         = 12
    info.TextWrapped      = true
    info.BorderSizePixel  = 0
    info.Parent           = sc
    Instance.new("UICorner",info).CornerRadius=UDim.new(0,10)
    Instance.new("UIPadding",info).PaddingLeft=UDim.new(0,8)
end

-- ────────────────────────────────
-- ABA 3 — FARM
-- ────────────────────────────────
do
    local sc = _tabContents[3]
    MakeSection(sc, "  🌾  AUTO FARM")

    MakeToggle(sc, "⚔️", "Auto Farm Mobs", false, function(on)
        Cfg.AutoFarmMobs = on
        Notify("🌾 Farm", on and "Auto Farm ativado!" or "Desativado.", 2)
    end)

    MakeToggle(sc, "💀", "Auto Farm Boss", false, function(on)
        Cfg.AutoFarmBoss = on
        Notify("💀 Boss", on and "Boss farm ativado!" or "Desativado.", 2)
    end)

    MakeToggle(sc, "🍎", "Auto Coletar Frutas", false, function(on)
        Cfg.AutoFarmFruit = on
        Notify("🍎 Frutas", on and "Auto coleta ativado!" or "Desativado.", 2)
    end)

    MakeSection(sc, "  📊  AUTO STATS")

    local statTypes = {
        {icon="👊","Melee"},
        {icon="🛡","Defense"},
        {icon="⚔","Sword"},
        {icon="🔫","Gun"},
        {icon="🍈","Fruit"},
    }
    for _,st in ipairs(statTypes) do
        local icn, nm = st.icon or "•", st[1]
        local btn = Instance.new("TextButton")
        btn.Size             = UDim2.new(1,0,0,36)
        btn.BackgroundColor3 = C.bg3
        btn.BorderSizePixel  = 0
        btn.Text             = icn.."  "..nm
        btn.TextColor3       = C.text
        btn.Font             = Enum.Font.Gotham
        btn.TextSize         = 14
        btn.Parent           = sc
        Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)

        btn.MouseButton1Click:Connect(function()
            Cfg.StatType = nm
            Notify("📊 Stats", "Tipo: "..nm, 2)
        end)
        btn.MouseEnter:Connect(function()
            Spring(btn,0.15,nil,{BackgroundColor3=C.bg2})
        end)
        btn.MouseLeave:Connect(function()
            Spring(btn,0.15,nil,{BackgroundColor3=C.bg3})
        end)
    end
end

-- ────────────────────────────────
-- ABA 4 — ESP
-- ────────────────────────────────
do
    local sc = _tabContents[4]
    MakeSection(sc, "  👁  ESP")

    MakeToggle(sc, "👥", "ESP Jogadores (Nome+HP)", false, function(on)
        Cfg.ESPEnabled = on
        if on then ESPCreate()
            Notify("👁 ESP","ESP de jogadores ativado!",2)
        else
            ESPDestroy()
            Notify("👁 ESP","ESP desativado.",2)
        end
    end)

    MakeToggle(sc, "🗺", "ESP Mobs", false, function(on)
        Notify("👁 ESP Mobs", on and "Ativado!" or "Desativado.",2)
    end)

    MakeToggle(sc, "🍑", "ESP Frutas no Mapa", false, function(on)
        Notify("🍑 ESP Frutas", on and "Ativado!" or "Desativado.",2)
    end)
end

-- ────────────────────────────────
-- ABA 5 — MISC
-- ────────────────────────────────
do
    local sc = _tabContents[5]
    MakeSection(sc, "  🔧  MISCELÂNEA")

    MakeToggle(sc, "♾️", "Infinite Jump", false, function(on)
        Cfg.InfiniteJump = on; SetInfiniteJump(on)
    end)

    MakeToggle(sc, "💨", "Speed 2× (WalkSpeed "..Cfg.SpeedValue..")", false, function(on)
        Cfg.SpeedBoost = on
        SetSpeed(on and Cfg.SpeedValue or 16)
        Notify("💨 Speed", on and ("WalkSpeed "..Cfg.SpeedValue) or "Normal", 2)
    end)

    MakeToggle(sc, "🛡️", "Sem Dano de Queda", false, function(on)
        Cfg.NoFallDamage = on; SetNoFallDamage(on)
    end)

    MakeToggle(sc, "✨", "God Mode (Exp.)", false, function(on)
        Cfg.GodMode = on
        if on then
            Notify("⚠ God Mode","Experimental — pode não funcionar em todos os servidores.",4)
        end
    end)

    MakeSection(sc, "  ℹ  SOBRE")

    local aboutBox = Instance.new("Frame")
    aboutBox.Size             = UDim2.new(1,0,0,68)
    aboutBox.BackgroundColor3 = C.bg2
    aboutBox.BorderSizePixel  = 0
    aboutBox.Parent           = sc
    Instance.new("UICorner",aboutBox).CornerRadius=UDim.new(0,10)

    local aboutLbl = Instance.new("TextLabel")
    aboutLbl.Size             = UDim2.new(1,-16,1,0)
    aboutLbl.Position         = UDim2.new(0,8,0,0)
    aboutLbl.BackgroundTransparency=1
    aboutLbl.Text             = "WORLD Script  v2.0.0\numarquezz/wrld  •  github.com\nRightShift → Abrir/Fechar GUI"
    aboutLbl.TextColor3       = C.textDim
    aboutLbl.Font             = Enum.Font.Gotham
    aboutLbl.TextSize         = 12
    aboutLbl.TextWrapped      = true
    aboutLbl.TextXAlignment   = Enum.TextXAlignment.Left
    aboutLbl.Parent           = aboutBox
end

-- God Mode loop
RunService.Heartbeat:Connect(function()
    if Cfg.GodMode then
        local h=GetHum()
        if h and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
    end
end)

-- ────────────────────────────────
--   TOGGLE TECLA
-- ────────────────────────────────
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Cfg.ToggleKey then
        Win.Visible = not Win.Visible
    end
end)

-- ────────────────────────────────
--   ANIMAÇÃO DE ENTRADA
-- ────────────────────────────────
Win.Size     = UDim2.new(0,500,0,0)
Win.Visible  = true
Spring(Win, 0.5, Enum.EasingStyle.Back, {Size = UDim2.new(0,500,0,430)})

SelectTab(1)

-- ────────────────────────────────
--   NOTIFICAÇÃO INICIAL
-- ────────────────────────────────
task.wait(0.6)
Notify("🌐 WORLD Script","Carregado! RightShift para abrir/fechar.",4)
print("╔════════════════════════════════╗")
print("║     WORLD Script  v2.0.0      ║")
print("║   umarquezz  •  Blox Fruits   ║")
print("╚════════════════════════════════╝")
