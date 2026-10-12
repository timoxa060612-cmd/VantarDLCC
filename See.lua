-- language: Lua, file: v4.lua, target: Delta (Roblox), Murder Mystery 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera

if CoreGui:FindFirstChild("VantarDLC") then CoreGui.VantarDLC:Destroy() end

local CFG = {
    accent = Color3.fromRGB(120, 90, 255),
    bg = Color3.fromRGB(14, 14, 20),
    row = Color3.fromRGB(30, 30, 40),
    text = Color3.fromRGB(230, 230, 240),
    dim = Color3.fromRGB(150, 150, 165),
    fovColor = Color3.fromRGB(255, 90, 90),
    espMurderer = Color3.fromRGB(255, 60, 60),
    espSheriff = Color3.fromRGB(80, 160, 255),
    espInnocent = Color3.fromRGB(80, 220, 120),
    espBox = true, espName = true, espDist = true,
}

local S = {
    espAll = false, espMurder = false, espSheriff = false,
    aim = false, aimOnlyM = true, aimSmooth = 3, fov = 120,
    silent = false, silentOnlyM = true,
    kill = false, killRange = 12,
    coins = false,
    noclip = false, infJump = false,
    hitbox = false, hitboxSize = 12,
    spin = false, spinSpeed = 15,
    antiAim = false, banish = false, dodge = false
}

local Gui = Instance.new("ScreenGui")
Gui.Name = "VantarDLC"
Gui.ResetOnSpawn = false
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 420, 0, 380)
Main.Position = UDim2.new(0.5, -210, 0.5, -190)
Main.BackgroundColor3 = CFG.bg
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Head = Instance.new("Frame")
Head.Size = UDim2.new(1, 0, 0, 34)
Head.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Head.BorderSizePixel = 0
Head.Parent = Main
Instance.new("UICorner", Head).CornerRadius = UDim.new(0, 10)

local HeadFix = Instance.new("Frame")
HeadFix.Size = UDim2.new(1, 0, 0, 12)
HeadFix.Position = UDim2.new(0, 0, 1, -12)
HeadFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
HeadFix.BorderSizePixel = 0
HeadFix.Parent = Head

local Ttl = Instance.new("TextLabel")
Ttl.Size = UDim2.new(1, -80, 1, 0)
Ttl.Position = UDim2.new(0, 12, 0, 0)
Ttl.BackgroundTransparency = 1
Ttl.Text = "VantarDLC"
Ttl.TextColor3 = CFG.text
Ttl.Font = Enum.Font.GothamBold
Ttl.TextSize = 14
Ttl.TextXAlignment = Enum.TextXAlignment.Left
Ttl.Parent = Head

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 24, 0, 24)
Close.Position = UDim2.new(1, -30, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(190, 55, 55)
Close.Text = "×"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.Parent = Head
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)
Close.MouseButton1Click:Connect(function() Gui.Enabled = not Gui.Enabled end)

local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -16, 0, 28)
TabBar.Position = UDim2.new(0, 8, 0, 40)
TabBar.BackgroundTransparency = 1
TabBar.Parent = Main
local TL = Instance.new("UIListLayout")
TL.FillDirection = Enum.FillDirection.Horizontal
TL.Padding = UDim.new(0, 4)
TL.Parent = TabBar

local Holder = Instance.new("Frame")
Holder.Size = UDim2.new(1, -16, 1, -78)
Holder.Position = UDim2.new(0, 8, 0, 72)
Holder.BackgroundTransparency = 1
Holder.Parent = Main

local Pages, Tabs = {}, {}

local function page(name)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(0, 60, 1, 0)
    B.BackgroundColor3 = CFG.row
    B.Text = name
    B.TextColor3 = CFG.dim
    B.Font = Enum.Font.GothamSemibold
    B.TextSize = 10
    B.AutoButtonColor = false
    B.Parent = TabBar
    Instance.new("UICorner", B).CornerRadius = UDim.new(0, 6)

    local P = Instance.new("ScrollingFrame")
    P.Size = UDim2.new(1, 0, 1, 0)
    P.BackgroundTransparency = 1
    P.CanvasSize = UDim2.new(0, 0, 0, 0)
    P.AutomaticCanvasSize = Enum.AutomaticSize.Y
    P.ScrollBarThickness = 3
    P.ScrollBarImageColor3 = CFG.accent
    P.Visible = false
    P.Parent = Holder
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 5)
    L.Parent = P

    Pages[name] = P
    table.insert(Tabs, {b = B, p = P})

    B.MouseButton1Click:Connect(function()
        for _, x in pairs(Pages) do x.Visible = false end
        for _, t in ipairs(Tabs) do
            t.b.BackgroundColor3 = CFG.row
            t.b.TextColor3 = CFG.dim
        end
        P.Visible = true
        B.BackgroundColor3 = CFG.accent
        B.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    return P
end

local function toggle(parent, text, def, cb)
    local R = Instance.new("TextButton")
    R.Size = UDim2.new(1, 0, 0, 28)
    R.BackgroundColor3 = CFG.row
    R.Text = "  " .. text
    R.TextColor3 = CFG.text
    R.Font = Enum.Font.Gotham
    R.TextSize = 12
    R.TextXAlignment = Enum.TextXAlignment.Left
    R.AutoButtonColor = false
    R.Parent = parent
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 6)

    local st = def
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 10, 0, 10)
    dot.Position = UDim2.new(1, -18, 0.5, -5)
    dot.BackgroundColor3 = st and CFG.accent or Color3.fromRGB(60, 60, 75)
    dot.Parent = R
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    R.MouseButton1Click:Connect(function()
        st = not st
        dot.BackgroundColor3 = st and CFG.accent or Color3.fromRGB(60, 60, 75)
        cb(st)
    end)
end

local function slider(parent, text, mn, mx, def, cb)
    local R = Instance.new("Frame")
    R.Size = UDim2.new(1, 0, 0, 40)
    R.BackgroundColor3 = CFG.row
    R.Parent = parent
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 6)

    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -16, 0, 18)
    L.Position = UDim2.new(0, 8, 0, 2)
    L.BackgroundTransparency = 1
    L.Text = text .. ": " .. def
    L.TextColor3 = CFG.text
    L.Font = Enum.Font.Gotham
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left
    L.Parent = R

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -16, 0, 8)
    B.Position = UDim2.new(0, 8, 0, 26)
    B.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    B.Text = ""
    B.AutoButtonColor = false
    B.Parent = R
    Instance.new("UICorner", B).CornerRadius = UDim.new(1, 0)

    local F = Instance.new("Frame")
    F.Size = UDim2.new((def - mn) / (mx - mn), 0, 1, 0)
    F.BackgroundColor3 = CFG.accent
    F.Parent = B
    Instance.new("UICorner", F).CornerRadius = UDim.new(1, 0)

    local drag = false
    B.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - B.AbsolutePosition.X) / B.AbsoluteSize.X, 0, 1)
            F.Size = UDim2.new(rel, 0, 1, 0)
            local v = math.floor((mn + (mx - mn) * rel) * 10 + 0.5) / 10
            L.Text = text .. ": " .. v
            cb(v)
        end
    end)
end

local Palette = {
    Color3.fromRGB(255, 60, 60), Color3.fromRGB(255, 140, 60),
    Color3.fromRGB(255, 220, 60), Color3.fromRGB(80, 220, 120),
    Color3.fromRGB(80, 200, 255), Color3.fromRGB(120, 90, 255),
    Color3.fromRGB(255, 90, 200), Color3.fromRGB(255, 255, 255)
}

local function colorRow(parent, text, init, cb)
    local R = Instance.new("TextButton")
    R.Size = UDim2.new(1, 0, 0, 28)
    R.BackgroundColor3 = CFG.row
    R.Text = "  " .. text
    R.TextColor3 = CFG.text
    R.Font = Enum.Font.Gotham
    R.TextSize = 12
    R.TextXAlignment = Enum.TextXAlignment.Left
    R.AutoButtonColor = false
    R.Parent = parent
    Instance.new("UICorner", R).CornerRadius = UDim.new(0, 6)

    local Sw = Instance.new("Frame")
    Sw.Size = UDim2.new(0, 30, 0, 14)
    Sw.Position = UDim2.new(1, -38, 0.5, -7)
    Sw.BackgroundColor3 = init
    Sw.Parent = R
    Instance.new("UICorner", Sw).CornerRadius = UDim.new(0, 4)

    local idx = 1
    R.MouseButton1Click:Connect(function()
        idx = idx % #Palette + 1
        Sw.BackgroundColor3 = Palette[idx]
        cb(Palette[idx])
    end)
end

for _, n in ipairs({"ESP", "Aim", "Kill", "Farm", "Visual", "Misc"}) do page(n) end
Tabs[1].b.BackgroundColor3 = CFG.accent
Tabs[1].b.TextColor3 = Color3.fromRGB(255, 255, 255)
Pages["ESP"].Visible = true

local function hrp()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function hum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function role(p)
    if not p or not p.Character then return "?" end
    local c = p.Character
    for _, k in ipairs({"Role", "Team", "role", "team"}) do
        local v = c:GetAttribute(k) or p:GetAttribute(k)
        if typeof(v) == "string" then return v end
    end
    if c:FindFirstChild("Knife") then return "Murderer" end
    if c:FindFirstChild("Gun") or c:FindFirstChild("Revolver") then return "Sheriff" end
    return "Innocent"
end
local function isM(p) return role(p) == "Murderer" end
local function allPlayers()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then table.insert(t, p) end
    end
    return t
end
local function roleCol(r)
    if r == "Murderer" then return CFG.espMurderer end
    if r == "Sheriff" then return CFG.espSheriff end
    return CFG.espInnocent
end
local espFolder = Instance.new("Folder", Gui)
local espCache = {}

local function clearESP()
    for _, e in pairs(espCache) do
        if e.box then e.box:Destroy() end
        if e.lbl then e.lbl:Destroy() end
        if e.conn then e.conn:Disconnect() end
    end
    espCache = {}
end

local refreshESP

local function addESP(p)
    if espCache[p] then return end
    local c = p.Character
    if not c then return end
    local part = c:FindFirstChild("HumanoidRootPart")
    if not part then return end
    local r = role(p)
    local col = roleCol(r)
    local e = {}
    if CFG.espBox then
        local b = Instance.new("BoxHandleAdornment")
        b.Adornee = part
        b.Size = part.Size + Vector3.new(0.3, 0.3, 0.3)
        b.AlwaysOnTop = true
        b.Transparency = 0.35
        b.Color3 = col
        b.Parent = espFolder
        e.box = b
    end
    local lbl = Instance.new("BillboardGui")
    lbl.Size = UDim2.new(0, 220, 0, 40)
    lbl.StudsOffset = Vector3.new(0, 2.5, 0)
    lbl.AlwaysOnTop = true
    lbl.Adornee = part
    lbl.Parent = espFolder
    local nt = Instance.new("TextLabel")
    nt.Size = UDim2.new(1, 0, 0, 20)
    nt.BackgroundTransparency = 1
    nt.Text = p.Name .. " [" .. r .. "]"
    nt.TextColor3 = col
    nt.TextStrokeTransparency = 0
    nt.Font = Enum.Font.GothamBold
    nt.TextSize = 13
    nt.Parent = lbl
    local dt = Instance.new("TextLabel")
    dt.Size = UDim2.new(1, 0, 0, 16)
    dt.Position = UDim2.new(0, 0, 0, 20)
    dt.BackgroundTransparency = 1
    dt.TextColor3 = Color3.fromRGB(230, 230, 230)
    dt.TextStrokeTransparency = 0
    dt.Font = Enum.Font.Gotham
    dt.TextSize = 11
    dt.Parent = lbl
    e.lbl = lbl
    e.nt = nt
    e.dt = dt
    e.part = part
    e.conn = RunService.RenderStepped:Connect(function()
        if e.part and e.part.Parent then
            e.nt.Visible = CFG.espName
            local h = hrp()
            if h and CFG.espDist then
                e.dt.Text = string.format("%d studs", (e.part.Position - h.Position).Magnitude)
            else
                e.dt.Text = ""
            end
            if e.box then e.box.Visible = CFG.espBox end
        end
    end)
    espCache[p] = e
end

refreshESP = function()
    if not (S.espAll or S.espMurder or S.espSheriff) then clearESP(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local r = role(p)
            local show = S.espAll or (S.espMurder and r == "Murderer") or (S.espSheriff and r == "Sheriff")
            if show and not espCache[p] then
                addESP(p)
            elseif not show and espCache[p] then
                if espCache[p].box then espCache[p].box:Destroy() end
                if espCache[p].lbl then espCache[p].lbl:Destroy() end
                if espCache[p].conn then espCache[p].conn:Disconnect() end
                espCache[p] = nil
            end
        end
    end
end

local fovC = Instance.new("Frame")
fovC.BackgroundTransparency = 1
fovC.BorderSizePixel = 2
fovC.BorderColor3 = CFG.fovColor
fovC.Visible = false
fovC.Parent = Gui
Instance.new("UICorner", fovC).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    if S.aim or S.silent then
        fovC.Visible = true
        fovC.Size = UDim2.new(0, S.fov * 2, 0, S.fov * 2)
        fovC.Position = UDim2.new(0, Cam.ViewportSize.X / 2 - S.fov, 0, Cam.ViewportSize.Y / 2 - S.fov)
        fovC.BorderColor3 = CFG.fovColor
    else
        fovC.Visible = false
    end
end)

local function aimPart(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
end

local function nearestFOV(onlyM)
    local best, bd = nil, math.huge
    local cx, cy = Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2
    for _, p in ipairs(allPlayers()) do
        if onlyM and not isM(p) then goto skip end
        local part = aimPart(p)
        if part then
            local sp, on = Cam:WorldToViewportPoint(part.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Magnitude
                if d <= S.fov and d < bd then best, bd = p, d end
            end
        end
        ::skip::
    end
    return best
end

RunService.RenderStepped:Connect(function(dt)
    if not S.aim then return end
    local t = nearestFOV(S.aimOnlyM)
    if not t then return end
    local part = aimPart(t)
    if not part then return end
    local want = CFrame.new(Cam.CFrame.Position, part.Position)
    local a = math.clamp(dt * S.aimSmooth, 0, 1)
    Cam.CFrame = Cam.CFrame:Lerp(want, a)
end)

local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local old = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if S.silent and m == "FireServer" then
            local t = nearestFOV(S.silentOnlyM)
            if t then
                local tp = aimPart(t)
                if tp then
                    local args = {...}
                    local na = {}
                    local ch = false
                    for i, v in ipairs(args) do
                        if typeof(v) == "Vector3" then na[i] = tp.Position; ch = true
                        elseif typeof(v) == "CFrame" then na[i] = CFrame.new(tp.Position); ch = true
                        elseif typeof(v) == "Instance" and v:IsA("BasePart") and v.Parent and Players:GetPlayerFromCharacter(v.Parent) then na[i] = tp; ch = true
                        else na[i] = v end
                    end
                    if ch then return old(self, table.unpack(na)) end
                end
            end
        end
        return old(self, ...)
    end)
    setreadonly(mt, true)
end

RunService.RenderStepped:Connect(function(dt)
    if not S.antiAim then return end
    local c = LP.Character
    if not c then return end
    local t = c:FindFirstChild("Torso") or c:FindFirstChild("UpperTorso")
    local h = c:FindFirstChild("Head")
    if t then t.CFrame = t.CFrame * CFrame.Angles(0, math.rad(180) * dt * 30, 0) end
    if h then h.CFrame = h.CFrame * CFrame.Angles(math.rad(90), 0, 0) end
end)

local function nearestR(range)
    local h = hrp()
    if not h then return nil end
    local best, bd = nil, range
    for _, p in ipairs(allPlayers()) do
        local part = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if part then
            local d = (part.Position - h.Position).Magnitude
            if d < bd then best, bd = p, d end
        end
    end
    return best
end

RunService.Heartbeat:Connect(function()
    if not S.kill then return end
    local knife = LP.Character and LP.Character:FindFirstChild("Knife")
    if not knife then return end
    local t = nearestR(S.killRange)
    if t and t.Character then
        local h = hrp()
        local th = t.Character:FindFirstChild("HumanoidRootPart")
        if h and th then
            local old = h.CFrame
            h.CFrame = th.CFrame
            knife:Activate()
            task.wait()
            h.CFrame = old
        end
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not S.spin then return end
    local h = hrp()
    if h then h.CFrame = h.CFrame * CFrame.Angles(0, math.rad(S.spinSpeed) * dt * 60, 0) end
end)

local function coins()
    local t = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("BasePart") and o.Name:lower():find("coin") then table.insert(t, o) end
    end
    return t
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if S.coins then
            local h = hrp()
            if h then
                for _, c in ipairs(coins()) do
                    if c and c.Parent then
                        pcall(function() h.CFrame = c.CFrame + Vector3.new(0, 2, 0) end)
                        task.wait(0.05)
                    end
                end
            end
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if S.infJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local ncConn
local function startNC()
    if ncConn then ncConn:Disconnect() end
    ncConn = RunService.Stepped:Connect(function()
        local c = LP.Character
        if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end)
end

local saved = {}
local function bright(on)
    if on then
        saved.Amb = Lighting.Ambient
        saved.OA = Lighting.OutdoorAmbient
        saved.Br = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(200, 200, 200)
        Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        Lighting.Brightness = 3
    else
        for k, v in pairs(saved) do Lighting[k] = v end
        saved = {}
    end
end

local function noFog(on)
    if on then
        saved.FE = Lighting.FogEnd
        saved.FS = Lighting.FogStart
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
    else
        if saved.FE then Lighting.FogEnd = saved.FE end
        if saved.FS then Lighting.FogStart = saved.FS end
    end
end

RunService.Heartbeat:Connect(function()
    if not S.hitbox then return end
    for _, p in ipairs(allPlayers()) do
        local part = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if part then
            part.Size = Vector3.new(S.hitboxSize, S.hitboxSize, S.hitboxSize)
            part.Transparency = 0.7
            part.CanCollide = false
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.3)
        if S.banish then
            local h = hrp()
            if h then
                local m = nil
                for _, p in ipairs(allPlayers()) do
                    if isM(p) then m = p break end
                end
                if m and m.Character then
                    local mp = m.Character:FindFirstChild("HumanoidRootPart")
                    if mp and (mp.Position - h.Position).Magnitude < 25 then
                        local aw = (h.Position - mp.Position).Unit
                        h.CFrame = h.CFrame + aw * 40
                        task.wait(3)
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not S.dodge then return end
    local h = hrp()
    if not h then return end
    for _, p in ipairs(allPlayers()) do
        if role(p) == "Sheriff" then
            local g = p.Character and (p.Character:FindFirstChild("Gun") or p.Character:FindFirstChild("Revolver"))
            if g then
                local b = g:FindFirstChild("Handle") or g:FindFirstChildWhichIsA("BasePart")
                if b then
                    local d = (h.Position - b.Position).Unit
                    h.CFrame = h.CFrame + d * 8
                end
            end
        end
    end
end)

local p = Pages["ESP"]
toggle(p, "ESP все", false, function(v) S.espAll = v; refreshESP() end)
toggle(p, "ESP убийца", false, function(v) S.espMurder = v; refreshESP() end)
toggle(p, "ESP шериф", false, function(v) S.espSheriff = v; refreshESP() end)
toggle(p, "Бокс", true, function(v) CFG.espBox = v end)
toggle(p, "Имя", true, function(v) CFG.espName = v end)
toggle(p, "Дистанция", true, function(v) CFG.espDist = v end)
colorRow(p, "Цвет убийцы", CFG.espMurderer, function(c) CFG.espMurderer = c end)
colorRow(p, "Цвет шерифа", CFG.espSheriff, function(c) CFG.espSheriff = c end)
colorRow(p, "Цвет невинных", CFG.espInnocent, function(c) CFG.espInnocent = c end)

p = Pages["Aim"]
toggle(p, "Aimbot", false, function(v) S.aim = v end)
toggle(p, "Aim только убийца", true, function(v) S.aimOnlyM = v end)
slider(p, "Smooth (больше — резче)", 1, 20, 3, function(v) S.aimSmooth = v end)
toggle(p, "Silent Aim", false, function(v) S.silent = v end)
toggle(p, "Silent только убийца", true, function(v) S.silentOnlyM = v end)
slider(p, "FOV", 30, 400, 120, function(v) S.fov = v end)
colorRow(p, "Цвет FOV", CFG.fovColor, function(c) CFG.fovColor = c; fovC.BorderColor3 = c end)

p = Pages["Kill"]
toggle(p, "Killaura (нож)", false, function(v) S.kill = v end)
slider(p, "Радиус", 4, 30, 12, function(v) S.killRange = v end)
toggle(p, "Spinbot", false, function(v) S.spin = v end)
slider(p, "Spin Speed", 5, 60, 15, function(v) S.spinSpeed = v end)

p = Pages["Farm"]
toggle(p, "Auto Coin Farm", false, function(v) S.coins = v end)

p = Pages["Visual"]
toggle(p, "Fullbright", false, function(v) bright(v) end)
toggle(p, "No Fog", false, function(v) noFog(v) end)
toggle(p, "Hitbox Expand", false, function(v) S.hitbox = v end)
slider(p, "Hitbox Size", 4, 30, 12, function(v) S.hitboxSize = v end)
toggle(p, "Noclip", false, function(v)
    if v then startNC() elseif ncConn then ncConn:Disconnect(); ncConn = nil end
end)
toggle(p, "Infinite Jump", false, function(v) S.infJump = v end)

p = Pages["Misc"]
toggle(p, "Anti-Aim", false, function(v) S.antiAim = v end)
toggle(p, "Banish Hop", false, function(v) S.banish = v end)
toggle(p, "Auto Dodge (от шерифа)", false, function(v) S.dodge = v end)

print("[VantarDLC] загружено")
