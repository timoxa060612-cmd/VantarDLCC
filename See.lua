-- language: Lua, file: see.lua, target: Delta (Roblox), Murder Mystery 2
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
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
    espColor = Color3.fromRGB(255, 60, 60),
}

local S = {
    esp = false, espName = true, espDist = true,
    silent = false, fov = 200,
    banish = false, banishRange = 25, banishDist = 40
}

local Gui = Instance.new("ScreenGui")
Gui.Name = "VantarDLC"
Gui.ResetOnSpawn = false
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LP:WaitForChild("PlayerGui") end

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 300)
Main.Position = UDim2.new(0.5, -160, 0.5, -150)
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
Ttl.Size = UDim2.new(1, -60, 1, 0)
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

local Body = Instance.new("Frame")
Body.Size = UDim2.new(1, -16, 1, -50)
Body.Position = UDim2.new(0, 8, 0, 42)
Body.BackgroundTransparency = 1
Body.Parent = Main
local BL = Instance.new("UIListLayout")
BL.Padding = UDim.new(0, 5)
BL.Parent = Body

local function toggle(parent, text, def, cb)
    local R = Instance.new("TextButton")
    R.Size = UDim2.new(1, 0, 0, 30)
    R.BackgroundColor3 = CFG.row
    R.Text = "  " .. text
    R.TextColor3 = CFG.text
    R.Font = Enum.Font.Gotham
    R.TextSize = 13
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
    R.Size = UDim2.new(1, 0, 0, 42)
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
    B.Position = UDim2.new(0, 8, 0, 28)
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

local function hrp()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function allPlayers()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(t, p)
        end
    end
    return t
end

local function targetPart(p)
    if not p or not p.Character then return nil end
    return p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
end

-- ===== FOV circle =====
local fovC = Instance.new("Frame")
fovC.BackgroundTransparency = 1
fovC.BorderSizePixel = 2
fovC.BorderColor3 = CFG.fovColor
fovC.Visible = false
fovC.Parent = Gui
Instance.new("UICorner", fovC).CornerRadius = UDim.new(1, 0)

RunService.RenderStepped:Connect(function()
    if S.silent then
        fovC.Visible = true
        fovC.Size = UDim2.new(0, S.fov * 2, 0, S.fov * 2)
        fovC.Position = UDim2.new(0, Cam.ViewportSize.X / 2 - S.fov, 0, Cam.ViewportSize.Y / 2 - S.fov)
    else
        fovC.Visible = false
    end
end)

-- ===== target finder =====
local function nearestInFOV()
    local best, bd = nil, S.fov
    local cx, cy = Cam.ViewportSize.X / 2, Cam.ViewportSize.Y / 2
    for _, p in ipairs(allPlayers()) do
        local part = targetPart(p)
        if part then
            local sp, on = Cam:WorldToViewportPoint(part.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - Vector2.new(cx, cy)).Magnitude
                if d <= bd then best, bd = p, d end
            end
        end
    end
    return best
end

-- ===== SILENT AIM =====
-- перехват Namecall: при FireServer / InvokeServer из аргументов вырезаем цель
-- и подставляем в поля, где игра ожидает игрока или позицию.
local mt = getrawmetatable and getrawmetatable(game)
if mt then
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if S.silent and (method == "FireServer" or method == "InvokeServer") then
            local t = nearestInFOV()
            if t then
                local tp = targetPart(t)
                if tp then
                    local args = {...}
                    local newArgs = {}
                    local changed = false
                    for i, v in ipairs(args) do
                        local ty = typeof(v)
                        if ty == "Instance" then
                            if v:IsA("Player") then
                                newArgs[i] = t; changed = true
                            elseif v:IsA("Model") and Players:GetPlayerFromCharacter(v) then
                                newArgs[i] = t.Character; changed = true
                            elseif v:IsA("BasePart") then
                                newArgs[i] = tp; changed = true
                            else
                                newArgs[i] = v
                            end
                        elseif ty == "Vector3" then
                            newArgs[i] = tp.Position; changed = true
                        elseif ty == "CFrame" then
                            newArgs[i] = CFrame.new(tp.Position); changed = true
                        else
                            newArgs[i] = v
                        end
                    end
                    if changed then
                        if method == "FireServer" then
                            return oldNamecall(self, table.unpack(newArgs))
                        else
                            return oldNamecall(self, table.unpack(newArgs))
                        end
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end

-- ===== ESP =====
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

local function addESP(p)
    if espCache[p] then return end
    local part = targetPart(p)
    if not part then return end
    local e = {}

    local root = p.Character:FindFirstChild("HumanoidRootPart")
    if root then
        local b = Instance.new("BoxHandleAdornment")
        b.Adornee = root
        b.Size = root.Size + Vector3.new(0.3, 0.3, 0.3)
        b.AlwaysOnTop = true
        b.Transparency = 0.35
        b.Color3 = CFG.espColor
        b.Parent = espFolder
        e.box = b
    end

    local lbl = Instance.new("BillboardGui")
    lbl.Size = UDim2.new(0, 200, 0, 38)
    lbl.StudsOffset = Vector3.new(0, 2.5, 0)
    lbl.AlwaysOnTop = true
    lbl.Adornee = part
    lbl.Parent = espFolder

    local nt = Instance.new("TextLabel")
    nt.Size = UDim2.new(1, 0, 0, 18)
    nt.BackgroundTransparency = 1
    nt.Text = p.Name
    nt.TextColor3 = CFG.espColor
    nt.TextStrokeTransparency = 0
    nt.Font = Enum.Font.GothamBold
    nt.TextSize = 13
    nt.Parent = lbl

    local dt = Instance.new("TextLabel")
    dt.Size = UDim2.new(1, 0, 0, 14)
    dt.Position = UDim2.new(0, 0, 0, 18)
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
    e.root = root
    e.conn = RunService.RenderStepped:Connect(function()
        if e.part and e.part.Parent then
            local h = hrp()
            if h and S.espDist then
                e.dt.Text = string.format("%d studs", (e.part.Position - h.Position).Magnitude)
            else
                e.dt.Text = ""
            end
            e.nt.Visible = S.espName
            if e.box and e.root then
                e.box.Size = e.root.Size + Vector3.new(0.3, 0.3, 0.3)
            end
        end
    end)
    espCache[p] = e
end

local function refreshESP()
    if not S.esp then clearESP(); return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            if not espCache[p] then addESP(p) end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.5)
        if S.esp then refreshESP() end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    if espCache[p] then
        if espCache[p].box then espCache[p].box:Destroy() end
        if espCache[p].lbl then espCache[p].lbl:Destroy() end
        if espCache[p].conn then espCache[p].conn:Disconnect() end
        espCache[p] = nil
    end
end)

-- ===== BANISH HOP =====
local function hasKnife(p)
    if not p or not p.Character then return false end
    return p.Character:FindFirstChild("Knife") ~= nil
end

task.spawn(function()
    while true do
        task.wait(0.2)
        if S.banish then
            local h = hrp()
            if h then
                for _, p in ipairs(allPlayers()) do
                    if hasKnife(p) then
                        local mp = p.Character:FindFirstChild("HumanoidRootPart")
                        if mp and (mp.Position - h.Position).Magnitude < S.banishRange then
                            local away = h.Position - mp.Position
                            if away.Magnitude < 0.1 then away = Vector3.new(1, 0, 0) end
                            h.CFrame = h.CFrame + away.Unit * S.banishDist
                            task.wait(1.5)
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- ===== UI =====
toggle(Body, "ESP все игроки", false, function(v) S.esp = v; refreshESP() end)
toggle(Body, "ESP — показывать имя", true, function(v) S.espName = v end)
toggle(Body, "ESP — дистанция", true, function(v) S.espDist = v end)
toggle(Body, "Silent Aim", false, function(v) S.silent = v end)
slider(Body, "Silent FOV", 30, 600, 200, function(v) S.fov = v end)
toggle(Body, "Banish Hop", false, function(v) S.banish = v end)
slider(Body, "Banish радиус", 10, 60, 25, function(v) S.banishRange = v end)
slider(Body, "Banish отскок", 10, 100, 40, function(v) S.banishDist = v end)

print("[VantarDLC] загружено")
