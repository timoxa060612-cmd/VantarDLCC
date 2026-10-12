-- language: Luau, target: Roblox MM2, executor required
-- *Скрипт объединяет silent aim через hooknamecall, ESP через Drawing API и скинченжер через подмену модели оружия*

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- КОНФИГ
-- ═══════════════════════════════════════════
local Config = {
    SilentAim = {
        Enabled = false,
        HitPart = "Head",
        WallCheck = false,
        FOV = 120,
        ShowFOV = true,
        TeamCheck = true,
    },
    ESP = {
        Enabled = false,
        Boxes = true,
        Names = true,
        Distance = true,
        RoleColor = true,
        BoxColor = Color3.fromRGB(255, 255, 255),
        MurdererColor = Color3.fromRGB(255, 50, 50),
        SheriffColor = Color3.fromRGB(50, 100, 255),
        InnocentColor = Color3.fromRGB(200, 200, 200),
    },
    Bhop = {
        Enabled = false,
        Speed = 250,
        JumpPower = 50,
        AutoStrafe = true,
    },
    AntiAim = {
        Enabled = false,
        Mode = "spin",
        SpinSpeed = 15,
    },
    SkinChanger = {
        Enabled = false,
        KnifeName = "",
        GunName = "",
    },
}

-- ═══════════════════════════════════════════
-- УТИЛИТЫ
-- ═══════════════════════════════════════════
local function getPlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local head = p.Character:FindFirstChild("Head")
            if hum and hum.Health > 0 and hrp and head then
                table.insert(list, {
                    player = p,
                    character = p.Character,
                    humanoid = hum,
                    root = hrp,
                    head = head,
                })
            end
        end
    end
    return list
end

local function getRole(player)
    if player == LocalPlayer then return "Ты" end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character
    if (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return "Маньяк"
    end
    if (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return "Шериф"
    end
    return "Мирный"
end

local function getRoleColor(role)
    if role == "Маньяк" then return Config.ESP.MurdererColor end
    if role == "Шериф" then return Config.ESP.SheriffColor end
    return Config.ESP.InnocentColor
end

-- ═══════════════════════════════════════════
-- SILENT AIM (настоящий через hooknamecall)
-- ═══════════════════════════════════════════
local silentTarget = nil

local function getClosestToMouse()
    local mousePos = UserInputService:GetMouseLocation()
    local closest = nil
    local closestDist = Config.SilentAim.FOV

    for _, entry in ipairs(getPlayers()) do
        if Config.SilentAim.TeamCheck and entry.player.Team == LocalPlayer.Team then continue end

        local targetPart = entry.character:FindFirstChild(Config.SilentAim.HitPart)
        if not targetPart then continue end

        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(mousePos.X, mousePos.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        if dist < closestDist then
            closestDist = dist
            closest = entry
        end
    end
    return closest
end

-- Hook namecall для перехвата FireServer на оружие
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = { ... }

    if Config.SilentAim.Enabled and method == "FireServer" then
        local selfName = tostring(self)
        -- Ремоуты MM2: WeaponHit, KnifeHit, GunHit
        if selfName:find("WeaponHit") or selfName:find("KnifeHit") or selfName:find("GunHit") then
            local target = getClosestToMouse()
            if target then
                local targetPart = target.character:FindFirstChild(Config.SilentAim.HitPart)
                if targetPart then
                    -- Подменяем аргументы на реальную часть цели
                    if args[1] and type(args[1]) == "table" then
                        args[1].part = targetPart
                        args[1].position = targetPart.Position
                    elseif args[2] and type(args[2]) == "table" then
                        args[2].part = targetPart
                        args[2].position = targetPart.Position
                    end
                end
            end
        end
    end
    return oldNamecall(self, unpack(args))
end)

setreadonly(mt, true)

-- ═══════════════════════════════════════════
-- КРУГ FOV
-- ═══════════════════════════════════════════
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 1.5
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Filled = false
fovCircle.NumSides = 64
fovCircle.Transparency = 0.8

RunService.RenderStepped:Connect(function()
    if Config.SilentAim.ShowFOV and Config.SilentAim.Enabled then
        local mouse = UserInputService:GetMouseLocation()
        fovCircle.Position = Vector2.new(mouse.X, mouse.Y)
        fovCircle.Radius = Config.SilentAim.FOV
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end
end)

-- ═══════════════════════════════════════════
-- ESP С БОКСАМИ (настоящий, через Drawing API)
-- ═══════════════════════════════════════════
local espCache = {}

local function createBoxESP(entry)
    local player = entry.player
    local drawings = {}

    -- Основной бокс
    drawings.box = Drawing.new("Square")
    drawings.box.Thickness = 1.5
    drawings.box.Filled = false
    drawings.box.Color = Config.ESP.BoxColor
    drawings.box.Transparency = 1
    drawings.box.Visible = false

    -- Обводка бокса (толще, чёрная, для читаемости)
    drawings.boxOutline = Drawing.new("Square")
    drawings.boxOutline.Thickness = 3
    drawings.boxOutline.Filled = false
    drawings.boxOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.boxOutline.Transparency = 1
    drawings.boxOutline.Visible = false

    -- Имя
    drawings.name = Drawing.new("Text")
    drawings.name.Size = 14
    drawings.name.Center = true
    drawings.name.Outline = true
    drawings.name.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.name.Transparency = 1
    drawings.name.Visible = false

    -- Дистанция
    drawings.dist = Drawing.new("Text")
    drawings.dist.Size = 12
    drawings.dist.Center = true
    drawings.dist.Outline = true
    drawings.dist.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.dist.Transparency = 1
    drawings.dist.Visible = false

    espCache[player] = drawings
end

local function removeBoxESP(player)
    if espCache[player] then
        for _, d in pairs(espCache[player]) do
            d:Remove()
        end
        espCache[player] = nil
    end
end

local function updateESP()
    if not Config.ESP.Enabled then
        for player, drawings in pairs(espCache) do
            for _, d in pairs(drawings) do
                d.Visible = false
            end
        end
        return
    end

    local myPos = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myPos then return end
    myPos = myPos.Position

    for _, entry in ipairs(getPlayers()) do
        local player = entry.player
        if not espCache[player] then
            createBoxESP(entry)
        end

        local drawings = espCache[player]
        if not drawings then continue end

        -- Проверка дистанции для бокса
        local rootPos = entry.root.Position
        local distance = (myPos - rootPos).Magnitude
        if distance > 500 then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        -- Позиция на экране
        local screenPos, onScreen = Camera:WorldToScreenPoint(rootPos)
        if not onScreen then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        -- Размер бокса через WorldToScreenPoint
        local headPos = entry.head.Position
        local headScreen, headOnScreen = Camera:WorldToScreenPoint(headPos)

        if not headOnScreen then
            for _, d in pairs(drawings) do d.Visible = false end
            continue
        end

        -- Вычисляем высоту бокса (от корня до головы + запас)
        local height = math.abs(headScreen.Y - screenPos.Y) * 1.4
        local width = height * 0.55

        -- Позиция бокса (центр сверху)
        local boxX = screenPos.X - width / 2
        local boxY = headScreen.Y - height * 0.15

        -- Цвет по роли
        local role = getRole(player)
        local color = Config.ESP.RoleColor and getRoleColor(role) or Config.ESP.BoxColor

        -- Бокс
        drawings.box.Position = Vector2.new(boxX, boxY)
        drawings.box.Size = Vector2.new(width, height)
        drawings.box.Color = color
        drawings.box.Visible = Config.ESP.Boxes

        -- Обводка
        drawings.boxOutline.Position = Vector2.new(boxX, boxY)
        drawings.boxOutline.Size = Vector2.new(width, height)
        drawings.boxOutline.Visible = Config.ESP.Boxes

        -- Имя
        drawings.name.Position = Vector2.new(screenPos.X, boxY - 18)
        drawings.name.Text = player.Name .. " [" .. role .. "]"
        drawings.name.Color = color
        drawings.name.Visible = Config.ESP.Names

        -- Дистанция
        drawings.dist.Position = Vector2.new(screenPos.X, boxY + height + 4)
        drawings.dist.Text = string.format("%.0f м", distance)
        drawings.dist.Color = color
        drawings.dist.Visible = Config.ESP.Distance
    end
end

RunService.RenderStepped:Connect(updateESP)

-- Очистка при выходе игрока
Players.PlayerRemoving:Connect(removeBoxESP)

-- ═══════════════════════════════════════════
-- СКИНЧЕНЖЕР (настоящий)
-- ═══════════════════════════════════════════
local function applySkin()
    if not Config.SkinChanger.Enabled then return end

    local char = LocalPlayer.Character
    if not char then return end

    local backpack = LocalPlayer:FindFirstChild("Backpack")

    -- Ищем оружие в руках
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                if mesh then
                    if tool.Name == "Knife" and Config.SkinChanger.KnifeName ~= "" then
                        -- Подмена меша ножа на меш скина
                        -- В MM2 скины ножей имеют свои MeshId
                        -- Замени MeshId на ID нужного скина
                        mesh.MeshId = Config.SkinChanger.KnifeName
                        mesh.TextureId = "" -- скины MM2 часто без текстуры или с ней
                    elseif tool.Name == "Gun" and Config.SkinChanger.GunName ~= "" then
                        mesh.MeshId = Config.SkinChanger.GunName
                        mesh.TextureId = ""
                    end
                end
            end
        end
    end

    -- Ищем оружие в бэкпаке (запасное)
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local mesh = handle:FindFirstChildOfClass("SpecialMesh")
                    if mesh then
                        if tool.Name == "Knife" and Config.SkinChanger.KnifeName ~= "" then
                            mesh.MeshId = Config.SkinChanger.KnifeName
                        elseif tool.Name == "Gun" and Config.SkinChanger.GunName ~= "" then
                            mesh.MeshId = Config.SkinChanger.GunName
                        end
                    end
                end
            end
        end
    end
end

-- Применять скин при подборе оружия
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    applySkin()

    -- Следим за новыми тулзами
    char.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.2)
            applySkin()
        end
    end)
end)

-- Периодическая проверка (для надёжности)
spawn(function()
    while task.wait(3) do
        if Config.SkinChanger.Enabled then
            applySkin()
        end
    end
end)

-- ═══════════════════════════════════════════
-- БАННИХОП
-- ═══════════════════════════════════════════
local lastJump = 0

UserInputService.JumpRequest:Connect(function()
    if Config.Bhop.Enabled and tick() - lastJump > 0.1 then
        lastJump = tick()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.JumpPower = Config.Bhop.JumpPower
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not Config.Bhop.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end

    hum.WalkSpeed = Config.Bhop.Speed

    if Config.Bhop.AutoStrafe then
        local moveDir = hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local vel = hrp.AssemblyLinearVelocity
            hrp.AssemblyLinearVelocity = Vector3.new(
                vel.X + moveDir.X * 2,
                vel.Y,
                vel.Z + moveDir.Z * 2
            )
        end
    end
end)

-- ═══════════════════════════════════════════
-- АНТИ-АИМ
-- ═══════════════════════════════════════════
local antiAimAngle = 0

RunService.RenderStepped:Connect(function(dt)
    if not Config.AntiAim.Enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local mode = Config.AntiAim.Mode
    if mode == "spin" then
        antiAimAngle = antiAimAngle + Config.AntiAim.SpinSpeed * dt
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(antiAimAngle), 0)
    elseif mode == "jitter" then
        local jitter = (tick() * 10) % 2 < 1 and 180 or -180
        hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, math.rad(jitter), 0)
    end
end)

-- ═══════════════════════════════════════════
-- UI (Rayfield, на русском)
-- ═══════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "MM2 ANON | Чит-меню",
    LoadingTitle = "загрузка...",
    LoadingSubtitle = "от ANON",
    ConfigurationSaving = { Enabled = true, FolderName = "ANON_MM2" },
})

-- Silent Aim
local AimTab = Window:CreateTab("Silent Aim", nil)
AimTab:CreateToggle({
    Name = "Включить Silent Aim",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(v) Config.SilentAim.Enabled = v end,
})
AimTab:CreateDropdown({
    Name = "Часть тела",
    Options = {"Head", "HumanoidRootPart", "UpperTorso"},
    CurrentOption = {"Head"},
    Flag = "HitPart",
    Callback = function(o) Config.SilentAim.HitPart = o[1] end,
})
AimTab:CreateSlider({
    Name = "Радиус FOV",
    Range = {10, 500},
    Increment = 5,
    Suffix = "px",
    CurrentValue = 120,
    Flag = "FOV",
    Callback = function(v) Config.SilentAim.FOV = v end,
})
AimTab:CreateToggle({
    Name = "Показывать круг FOV",
    CurrentValue = true,
    Flag = "ShowFOV",
    Callback = function(v) Config.SilentAim.ShowFOV = v end,
})
AimTab:CreateToggle({
    Name = "Проверка команды",
    CurrentValue = true,
    Flag = "TeamCheck",
    Callback = function(v) Config.SilentAim.TeamCheck = v end,
})

-- ESP
local EspTab = Window:CreateTab("ESP / ВХ", nil)
EspTab:CreateToggle({
    Name = "Включить ESP",
    CurrentValue = false,
    Flag = "ESPToggle",
    Callback = function(v) Config.ESP.Enabled = v end,
})
EspTab:CreateToggle({
    Name = "Боксы",
    CurrentValue = true,
    Flag = "Boxes",
    Callback = function(v) Config.ESP.Boxes = v end,
})
EspTab:CreateToggle({
    Name = "Имена",
    CurrentValue = true,
    Flag = "Names",
    Callback = function(v) Config.ESP.Names = v end,
})
EspTab:CreateToggle({
    Name = "Дистанция",
    CurrentValue = true,
    Flag = "Distance",
    Callback = function(v) Config.ESP.Distance = v end,
})
EspTab:CreateToggle({
    Name = "Цвет по роли",
    CurrentValue = true,
    Flag = "RoleColor",
    Callback = function(v) Config.ESP.RoleColor = v end,
})

-- Движение
local MoveTab = Window:CreateTab("Движение", nil)
MoveTab:CreateToggle({
    Name = "Баннихоп",
    CurrentValue = false,
    Flag = "Bhop",
    Callback = function(v) Config.Bhop.Enabled = v end,
})
MoveTab:CreateSlider({
    Name = "Скорость",
    Range = {16, 500},
    Increment = 5,
    CurrentValue = 250,
    Flag = "BhopSpeed",
    Callback = function(v) Config.Bhop.Speed = v end,
})
MoveTab:CreateSlider({
    Name = "Сила прыжка",
    Range = {50, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "JumpPower",
    Callback = function(v) Config.Bhop.JumpPower = v end,
})
MoveTab:CreateToggle({
    Name = "Авто-стрейф",
    CurrentValue = true,
    Flag = "AutoStrafe",
    Callback = function(v) Config.Bhop.AutoStrafe = v end,
})

-- Анти-аим
local AATab = Window:CreateTab("Анти-аим", nil)
AATab:CreateToggle({
    Name = "Включить анти-аим",
    CurrentValue = false,
    Flag = "AAToggle",
    Callback = function(v) Config.AntiAim.Enabled = v end,
})
AATab:CreateDropdown({
    Name = "Режим",
    Options = {"spin", "jitter"},
    CurrentOption = {"spin"},
    Flag = "AAMode",
    Callback = function(o) Config.AntiAim.Mode = o[1] end,
})
AATab:CreateSlider({
    Name = "Скорость вращения",
    Range = {5, 50},
    Increment = 1,
    CurrentValue = 15,
    Flag = "SpinSpeed",
    Callback = function(v) Config.AntiAim.SpinSpeed = v end,
})

-- Скинченжер
local SkinTab = Window:CreateTab("Скинченжер", nil)
SkinTab:CreateToggle({
    Name = "Включить скинченжер",
    CurrentValue = false,
    Flag = "SkinToggle",
    Callback = function(v)
        Config.SkinChanger.Enabled = v
        if v then applySkin() end
    end,
})
SkinTab:CreateInput({
    Name = "MeshId ножа",
    PlaceholderText = "rbxassetid://...",
    CurrentValue = "",
    Flag = "KnifeMesh",
    Callback = function(v)
        Config.SkinChanger.KnifeName = v
        applySkin()
    end,
})
SkinTab:CreateInput({
    Name = "MeshId пистолета",
    PlaceholderText = "rbxassetid://...",
    CurrentValue = "",
    Flag = "GunMesh",
    Callback = function(v)
        Config.SkinChanger.GunName = v
        applySkin()
    end,
})

Rayfield:LoadConfiguration()
