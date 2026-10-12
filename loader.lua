-- MM2Hub config
local Config = {
    State = {
        espPlayers = false, espMurderer = false, espSheriff = false,
        aimbot = false, silentAim = false, fov = 120, gunShoot = false,
        killaura = false, killRange = 12,
        coinFarm = false, tpCoin = false,
        speed = false, speedVal = 40,
        fly = false, flySpeed = 60,
        noclip = false, infiniteJump = false
    },
    Pages = {},
    UI = nil,
    Utils = nil
}
return Config
-- MM2Hub utils
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local U = {}

function U.getHRP()
    local c = LocalPlayer.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

function U.getHum()
    local c = LocalPlayer.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

function U.getRole(player)
    if not player or not player.Character then return "?" end
    local c = player.Character
    for _, key in ipairs({"Role","role","Team","team"}) do
        local v = c:GetAttribute(key) or player:GetAttribute(key)
        if typeof(v) == "string" then return v end
    end
    if c:FindFirstChild("Knife") then return "Murderer" end
    if c:FindFirstChild("Gun") or c:FindFirstChild("Revolver") then return "Sheriff" end
    return "Innocent"
end

function U.getAllPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then table.insert(list, p) end
    end
    return list
end

return U
-- MM2Hub ui
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

if CoreGui:FindFirstChild("MM2Hub") then CoreGui.MM2Hub:Destroy() end

local UI = {}
UI.Pages = {}
UI.Tabs = {}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2Hub"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
UI.Root = ScreenGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 460, 0, 400)
Main.Position = UDim2.new(0.5, -230, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(15,15,20)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,0,0,34)
Title.BackgroundColor3 = Color3.fromRGB(30,30,40)
Title.BorderSizePixel = 0
Title.Text = "  MM2Hub  |  delta"
Title.TextColor3 = Color3.fromRGB(235,235,245)
Title.Font = Enum.Font.GothamSemibold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Main
Instance.new("UICorner", Title).CornerRadius = UDim.new(0,10)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0,28,0,28)
CloseBtn.Position = UDim2.new(1,-34,0,3)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200,60,60)
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = Title
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,6)
CloseBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = not ScreenGui.Enabled end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1,-20,0,30)
TabBar.Position = UDim2.new(0,10,0,40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0,4)
TabLayout.Parent = TabBar

local PageHolder = Instance.new("Frame")
PageHolder.Size = UDim2.new(1,-20,1,-80)
PageHolder.Position = UDim2.new(0,10,0,76)
PageHolder.BackgroundTransparency = 1
PageHolder.Parent = Main

function UI.makePage(name)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0,80,1,0)
    Btn.BackgroundColor3 = Color3.fromRGB(35,35,45)
    Btn.Text = name
    Btn.TextColor3 = Color3.fromRGB(200,200,215)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 12
    Btn.Parent = TabBar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,6)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1,0,1,0)
    Page.BackgroundTransparency = 1
    Page.CanvasSize = UDim2.new(0,0,0,0)
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.ScrollBarThickness = 4
    Page.Visible = false
    Page.Parent = PageHolder
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0,6)
    L.Parent = Page

    UI.Pages[name] = Page
    table.insert(UI.Tabs, {btn = Btn, page = Page})

    Btn.MouseButton1Click:Connect(function()
        for _, p in pairs(UI.Pages) do p.Visible = false end
        for _, t in ipairs(UI.Tabs) do t.btn.BackgroundColor3 = Color3.fromRGB(35,35,45) end
        Page.Visible = true
        Btn.BackgroundColor3 = Color3.fromRGB(70,90,200)
    end)
    return Page
end

function UI.makeToggle(parent, text, default, cb)
    local R = Instance.new("TextButton")
    R.Size = UDim2.new(1,0,0,30)
    R.BackgroundColor3 = Color3.fromRGB(24,24,32)
    R.Text = "  " .. text
    R.TextColor3 = Color3.fromRGB(215,215,225)
    R.Font = Enum.Font.Gotham
    R.TextSize = 13
    R.TextXAlignment = Enum.TextXAlignment.Left
    R.Parent = parent
    Instance.new("UICorner", R).CornerRadius = UDim.new(0,6)
    local s = default
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0,10,0,10)
    dot.Position = UDim2.new(1,-22,0.5,-5)
    dot.BackgroundColor3 = s and Color3.fromRGB(80,200,120) or Color3.fromRGB(70,70,80)
    dot.Parent = R
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    R.MouseButton1Click:Connect(function()
        s = not s
        dot.BackgroundColor3 = s and Color3.fromRGB(80,200,120) or Color3.fromRGB(70,70,80)
        cb(s)
    end)
end

function UI.makeSlider(parent, text, mn, mx, dflt, cb)
    local R = Instance.new("Frame")
    R.Size = UDim2.new(1,0,0,44)
    R.BackgroundColor3 = Color3.fromRGB(24,24,32)
    R.Parent = parent
    Instance.new("UICorner", R).CornerRadius = UDim.new(0,6)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1,-20,0,22)
    L.Position = UDim2.new(0,10,0,2)
    L.BackgroundTransparency = 1
    L.Text = text .. ": " .. dflt
    L.TextColor3 = Color3.fromRGB(215,215,225)
    L.Font = Enum.Font.Gotham
    L.TextSize = 13
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = R
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,-20,0,12)
    B.Position = UDim2.new(0,10,0,26)
    B.BackgroundColor3 = Color3.fromRGB(45,45,55)
    B.Text = ""
    B.Parent = R
    Instance.new("UICorner", B).CornerRadius = UDim.new(1,0)
    local F = Instance.new("Frame")
    F.Size = UDim2.new((dflt-mn)/(mx-mn),0,1,0)
    F.BackgroundColor3 = Color3.fromRGB(120,140,255)
    F.Parent = B
    Instance.new("UICorner", F).CornerRadius = UDim.new(1,0)
    local drag = false
    B.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - B.AbsolutePosition.X)/B.AbsoluteSize.X,0,1)
            F.Size = UDim2.new(rel,0,1,0)
            local v = math.floor((mn+(mx-mn)*rel)*10+0.5)/10
            L.Text = text .. ": " .. v
            cb(v)
        end
    end)
end

function UI.makeButton(parent, text, cb)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1,0,0,30)
    B.BackgroundColor3 = Color3.fromRGB(45,55,100)
    B.Text = text
    B.TextColor3 = Color3.fromRGB(220,220,235)
    B.Font = Enum.Font.GothamSemibold
    B.TextSize = 13
    B.Parent = parent
    Instance.new("UICorner", B).CornerRadius = UDim.new(0,6)
    B.MouseButton1Click:Connect(cb)
end

for _, n in ipairs({"ESP","Aim","Kill","Farm","Move"}) do UI.makePage(n) end
UI.Tabs[1].btn.BackgroundColor3 = Color3.fromRGB(70,90,200)
UI.Pages["ESP"].Visible = true

return UI
-- MM2Hub esp
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Config = _G.MM2Config
if not Config then warn("[esp] нет Config"); return end
local Utils, UI, State = Config.Utils, Config.UI, Config.State

local espFolder = Instance.new("Folder")
espFolder.Name = "MM2ESP"
espFolder.Parent = UI.Root

local COLORS = {
    Murderer = Color3.fromRGB(255,60,60),
    Sheriff  = Color3.fromRGB(80,160,255),
    Innocent = Color3.fromRGB(80,220,120),
    ["?"]    = Color3.fromRGB(200,200,200)
}

local cache = {}

local function clearAll()
    for _, e in pairs(cache) do
        if e.box then e.box:Destroy() end
        if e.label then e.label:Destroy() end
        if e.conn then e.conn:Disconnect() end
    end
    cache = {}
end

local refresh

local function addESP(player)
    if cache[player] then return end
    local e = {}
    local function build()
        local c = player.Character
        if not c then return end
        local part = c:FindFirstChild("HumanoidRootPart") or c:FindFirstChildWhichIsA("BasePart")
        if not part then return end
        local role = Utils.getRole(player)
        local col = COLORS[role] or COLORS["?"]
        local box = Instance.new("BoxHandleAdornment")
        box.Adornee = part
        box.Size = part.Size + Vector3.new(0.3,0.3,0.3)
        box.AlwaysOnTop = true
        box.Transparency = 0.4
        box.Color3 = col
        box.Parent = espFolder
        local lbl = Instance.new("BillboardGui")
        lbl.Size = UDim2.new(0,200,0,40)
        lbl.StudsOffset = Vector3.new(0,2.5,0)
        lbl.AlwaysOnTop = true
        lbl.Adornee = part
        lbl.Parent = espFolder
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1,0,0,20)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name .. " [" .. role .. "]"
        txt.TextColor3 = col
        txt.TextStrokeTransparency = 0
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 14
        txt.Parent = lbl
        local dist = Instance.new("TextLabel")
        dist.Size = UDim2.new(1,0,0,16)
        dist.Position = UDim2.new(0,0,0,20)
        dist.BackgroundTransparency = 1
        dist.TextColor3 = Color3.fromRGB(220,220,220)
        dist.TextStrokeTransparency = 0
        dist.Font = Enum.Font.Gotham
        dist.TextSize = 12
        dist.Parent = lbl
        e.box = box
        e.label = lbl
        e.dist = dist
        e.part = part
        if e.conn then e.conn:Disconnect() end
        e.conn = RunService.RenderStepped:Connect(function()
            local hrp = Utils.getHRP()
            if hrp and e.part and e.part.Parent then
                e.dist.Text = string.format("%d studs", (e.part.Position - hrp.Position).Magnitude)
            end
        end)
    end
    e.build = build
    cache[player] = e
    build()
    player.CharacterAdded:Connect(function() task.wait(0.3); clearAll(); refresh() end)
end

refresh = function()
    if not (State.espPlayers or State.espMurderer or State.espSheriff) then clearAll(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local role = Utils.getRole(p)
            local show = State.espPlayers
                or (State.espMurderer and role == "Murderer")
                or (State.espSheriff and role == "Sheriff")
            if show then addESP(p)
            elseif cache[p] then
                if cache[p].box then cache[p].box:Destroy() end
                if cache[p].label then cache[p].label:Destroy() end
                if cache[p].conn then cache[p].conn:Disconnect() end
                cache[p] = nil
            end
        end
    end
end

Players.PlayerRemoving:Connect(function(p)
    if cache[p] then
        if cache[p].box then cache[p].box:Destroy() end
        if cache[p].label then cache[p].label:Destroy() end
        if cache[p].conn then cache[p].conn:Disconnect() end
        cache[p] = nil
    end
end)

local p = UI.Pages["ESP"]
UI.makeToggle(p, "ESP — все игроки", false, function(v) State.espPlayers = v; refresh() end)
UI.makeToggle(p, "ESP — только убийца", false, function(v) State.espMurderer = v; refresh() end)
UI.makeToggle(p, "ESP — только шериф", false, function(v) State.espSheriff = v; refresh() end)

print("[esp] загружено")
-- MM2Hub aim
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local Config = _G.MM2Config
if not Config then warn("[aim] нет Config"); return end
local Utils, UI, State = Config.Utils, Config.UI, Config.State

local fovCircle = Instance.new("Frame")
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 2
fovCircle.BorderColor3 = Color3.fromRGB(255,255,255)
fovCircle.Visible = false
fovCircle.Parent = UI.Root
Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1,0)

RunService.RenderStepped:Connect(function()
    if State.aimbot or State.silentAim then
        fovCircle.Visible = true
        fovCircle.Size = UDim2.new(0, State.fov*2, 0, State.fov*2)
        fovCircle.Position = UDim2.new(0, Camera.ViewportSize.X/2 - State.fov, 0, Camera.ViewportSize.Y/2 - State.fov)
    else
        fovCircle.Visible = false
    end
end)

local function nearestInFOV()
    local best, bd = nil, math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Utils.getAllPlayers()) do
        local part = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if part then
            local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local d = (Vector2.new(sp.X, sp.Y) - center).Magnitude
                if d <= State.fov and d < bd then best, bd = p, d end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if not State.aimbot then return end
    local t = nearestInFOV()
    if t and t.Character then
        local part = t.Character:FindFirstChild("Head") or t.Character:FindFirstChild("HumanoidRootPart")
        if part then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, part.Position)
        end
    end
end)

local p = UI.Pages["Aim"]
UI.makeToggle(p, "Aimbot (доворот камеры)", false, function(v) State.aimbot = v end)
UI.makeToggle(p, "Silent Aim (заготовка)", false, function(v) State.silentAim = v end)
UI.makeSlider(p, "FOV", 30, 400, 120, function(v) State.fov = v end)
UI.makeToggle(p, "Gun Auto-Shoot", false, function(v) State.gunShoot = v end)

print("[aim] загружено")
-- MM2Hub kill
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local Config = _G.MM2Config
if not Config then warn("[kill] нет Config"); return end
local Utils, UI, State = Config.Utils, Config.UI, Config.State

local function nearestPlayer(range)
    local hrp = Utils.getHRP()
    if not hrp then return nil end
    local best, bd = nil, range
    for _, p in ipairs(Utils.getAllPlayers()) do
        local part = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if part then
            local d = (part.Position - hrp.Position).Magnitude
            if d < bd then best, bd = p, d end
        end
    end
    return best
end

RunService.Heartbeat:Connect(function()
    if not State.killaura then return end
    local knife = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Knife")
    if not knife then return end
    local t = nearestPlayer(State.killRange)
    if t and t.Character then
        local hrp = Utils.getHRP()
        local them = t.Character:FindFirstChild("HumanoidRootPart")
        if hrp and them then
            local old = hrp.CFrame
            hrp.CFrame = them.CFrame
            knife:Activate()
            task.wait()
            hrp.CFrame = old
        end
    end
end)

local p = UI.Pages["Kill"]
UI.makeToggle(p, "Killaura (нужен нож)", false, function(v) State.killaura = v end)
UI.makeSlider(p, "Радиус", 4, 30, 12, function(v) State.killRange = v end)

print("[kill] загружено")
-- MM2Hub farm
local Config = _G.MM2Config
if not Config then warn("[farm] нет Config"); return end
local Utils, UI, State = Config.Utils, Config.UI, Config.State

local function getCoins()
    local list = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o.Name:lower():find("coin") then table.insert(list, o) end
    end
    return list
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if State.coinFarm or State.tpCoin then
            local hrp = Utils.getHRP()
            if hrp then
                for _, c in ipairs(getCoins()) do
                    if c and c.Parent then
                        pcall(function() hrp.CFrame = c.CFrame + Vector3.new(0,2,0) end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)

local p = UI.Pages["Farm"]
UI.makeToggle(p, "Auto Coin Farm", false, function(v) State.coinFarm = v end)
UI.makeToggle(p, "TP к монетам", false, function(v) State.tpCoin = v end)
UI.makeButton(p, "Log Remotes → консоль", function()
    print("===== REMOTES =====")
    for _, o in ipairs(game:GetDescendants()) do
        if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
            print(o:GetFullName(), "|", o.ClassName)
        end
    end
    print("===================")
end)

print("[farm] загружено")
-- MM2Hub move
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = game:GetService("Players").LocalPlayer

local Config = _G.MM2Config
if not Config then warn("[move] нет Config"); return end
local Utils, UI, State = Config.Utils, Config.UI, Config.State

RunService.Heartbeat:Connect(function()
    local h = Utils.getHum()
    if not h then return end
    if State.speed then h.WalkSpeed = State.speedVal else h.WalkSpeed = 16 end
    if State.infiniteJump then h.UseJumpPower = true; h.JumpPower = 100 end
end)

UserInputService.JumpRequest:Connect(function()
    if State.infiniteJump then
        local h = Utils.getHum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flyBody
RunService.RenderStepped:Connect(function()
    if not State.fly then
        if flyBody then flyBody:Destroy(); flyBody = nil end
        return
    end
    local hrp = Utils.getHRP()
    if not hrp then return end
    if not flyBody then
        flyBody = Instance.new("BodyVelocity")
        flyBody.MaxForce = Vector3.new(1e5,1e5,1e5)
        flyBody.Velocity = Vector3.new(0,0,0)
        flyBody.Parent = hrp
    end
    local dir = Vector3.new(0,0,0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
    flyBody.Velocity = dir.Magnitude > 0 and dir.Unit * State.flySpeed or Vector3.new(0,0,0)
end)

local ncConn
local function startNoclip()
    ncConn = RunService.Stepped:Connect(function()
        local c = LocalPlayer.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end)
end

local p = UI.Pages["Move"]
UI.makeToggle(p, "Speed Hack", false, function(v) State.speed = v end)
UI.makeSlider(p, "Скорость", 16, 200, 40, function(v) State.speedVal = v end)
UI.makeToggle(p, "Fly (WASD + Space/Ctrl)", false, function(v) State.fly = v end)
UI.makeSlider(p, "Fly Speed", 20, 300, 60, function(v) State.flySpeed = v end)
UI.makeToggle(p, "Noclip", false, function(v)
    State.noclip = v
    if v then startNoclip() elseif ncConn then ncConn:Disconnect(); ncConn = nil end
end)
UI.makeToggle(p, "Infinite Jump", false, function(v) State.infiniteJump = v end)

print("[move] загружено")
-- MM2Hub loader — этот файл вставляешь в Delta
local BASE = "https://raw.githubusercontent.com/timoxa060612-cmd/mm2_hub/main/"

local function load(mod)
    local ok, res = pcall(function() return loadstring(game:HttpGet(BASE .. mod .. ".lua"))() end)
    if not ok then warn("[loader] не загрузился " .. mod .. ": " .. tostring(res)) end
    return res
end

local Config = load("config")
local UI     = load("ui")
local Utils  = load("utils")

Config.UI = UI
Config.Utils = Utils
_G.MM2Config = Config

load("esp")
load("aim")
load("kill")
load("farm")
load("move")

print("[MM2Hub] все модули загружены")
