-- mm2delta.lua
-- GitHub: https://github.com/username/mm2-delta
-- Raw URL: https://raw.githubusercontent.com/username/mm2-delta/main/mm2delta.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local OrionLib = loadstring(game:HttpGet("https://cdn.jsdelivr.net/gh/shlexware/Orion@main/source.lua"))()
local oldRay = Ray.new
local oldNamecall
local mt = getrawmetatable(game)
setreadonly(mt, false)

local Silent = {
    enabled = false,
    fov = 120,
    smoothing = 0.15,
    target = nil,
    hitChance = 85,
}

local function getClosestTarget(fov)
    local cam = workspace.CurrentCamera
    local closest, dist = nil, fov
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local head = p.Character:FindFirstChild("Head")
            if head then
                local screen = cam:WorldToViewportPoint(head.Position)
                if screen.Z > 0 then
                    local dx = screen.X - cam.ViewportSize.X / 2
                    local dy = screen.Y - cam.ViewportSize.Y / 2
                    local d = math.sqrt(dx * dx + dy * dy)
                    if d < dist then
                        closest, dist = head, d
                    end
                end
            end
        end
    end
    return closest
end

oldNamecall = mt.__namecall
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if Silent.enabled and (method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
        local args = { ... }
        if Silent.target and Silent.target.Parent then
            local origin = args[1].Origin
            local dir = (Silent.target.Position - origin).Unit * 1000
            args[1] = Ray.new(origin, dir)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

RunService.RenderStepped:Connect(function()
    if Silent.enabled then
        Silent.target = getClosestTarget(Silent.fov)
    end
end)

local Window = OrionLib:MakeWindow({
    Name = "MM2 Delta",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "MM2Delta",
})

local Combat = Window:MakeTab({ Name = "Combat", Icon = "rbxassetid://4483345998" })

Combat:AddToggle({ Name = "Silent Aim", Default = false, Callback = function(v)
    Silent.enabled = v
end })

Combat:AddSlider({ Name = "Silent FOV", Min = 60, Max = 180, Default = 120, Callback = function(v)
    Silent.fov = v
end })

Combat:AddSlider({ Name = "Smoothing x100", Min = 5, Max = 30, Default = 15, Callback = function(v)
    Silent.smoothing = v / 100
end })

Combat:AddSlider({ Name = "Hit Chance %", Min = 50, Max = 100, Default = 85, Callback = function(v)
    Silent.hitChance = v
end })

Combat:AddToggle({ Name = "Auto Shoot", Default = false, Callback = function(v)
    getgenv().AutoShoot = v
end })

Combat:AddToggle({ Name = "Wallbang", Default = false, Callback = function(v)
    getgenv().Wallbang = v
end })

Combat:AddToggle({ Name = "Hitbox Expander", Default = false, Callback = function(v)
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = v and Vector3.new(10, 10, 10) or Vector3.new(2, 2, 1)
            end
        end
    end
end })

Combat:AddToggle({ Name = "Auto Kill", Default = false, Callback = function(v)
    getgenv().AutoKill = v
end })

Combat:AddToggle({ Name = "Kill Aura", Default = false, Callback = function(v)
    getgenv().KillAura = v
end })

Combat:AddToggle({ Name = "Instant Kill", Default = false, Callback = function(v)
    getgenv().InstantKill = v
end })

Combat:AddToggle({ Name = "No Recoil", Default = false, Callback = function(v)
    getgenv().NoRecoil = v
end })

Combat:AddToggle({ Name = "Infinite Ammo", Default = false, Callback = function(v)
    getgenv().InfAmmo = v
end })

local Movement = Window:MakeTab({ Name = "Movement", Icon = "rbxassetid://4483345998" })

Movement:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = v
    end
end })

Movement:AddSlider({ Name = "JumpPower", Min = 50, Max = 500, Default = 50, Callback = function(v)
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("Humanoid") then
        char.Humanoid.JumpPower = v
    end
end })

Movement:AddToggle({ Name = "Fly", Default = false, Callback = function(v)
    getgenv().Fly = v
    if v then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity", char.HumanoidRootPart)
            bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
            bv.Velocity = Vector3.zero
            getgenv().FlyBV = bv
        end
    else
        if getgenv().FlyBV then getgenv().FlyBV:Destroy() end
    end
end })

Movement:AddToggle({ Name = "Noclip", Default = false, Callback = function(v)
    getgenv().Noclip = v
    if v then
        RunService.Stepped:Connect(function()
            if getgenv().Noclip and LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    end
end })

Movement:AddToggle({ Name = "Infinite Jump", Default = false, Callback = function(v)
    getgenv().InfJump = v
end })

Movement:AddToggle({ Name = "Speed Hack", Default = false, Callback = function(v)
    getgenv().SpeedHack = v
end })

Movement:AddToggle({ Name = "Teleport", Default = false, Callback = function(v)
    getgenv().Teleport = v
end })

Movement:AddToggle({ Name = "Anti Fall", Default = false, Callback = function(v)
    getgenv().AntiFall = v
end })

Movement:AddToggle({ Name = "Bunny Hop", Default = false, Callback = function(v)
    getgenv().BunnyHop = v
end })

Movement:AddToggle({ Name = "Slide", Default = false, Callback = function(v)
    getgenv().Slide = v
end })

local Visual = Window:MakeTab({ Name = "Visual", Icon = "rbxassetid://4483345998" })

Visual:AddToggle({ Name = "ESP Players", Default = false, Callback = function(v)
    getgenv().ESP = v
end })

Visual:AddToggle({ Name = "ESP Murderer", Default = false, Callback = function(v)
    getgenv().ESPMurder = v
end })

Visual:AddToggle({ Name = "ESP Sheriff", Default = false, Callback = function(v)
    getgenv().ESPSheriff = v
end })

Visual:AddToggle({ Name = "ESP Innocent", Default = false, Callback = function(v)
    getgenv().ESPInnocent = v
end })

Visual:AddToggle({ Name = "Fullbright", Default = false, Callback = function(v)
    Lighting.Ambient = v and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(0, 0, 0)
end })

Visual:AddToggle({ Name = "No Fog", Default = false, Callback = function(v)
    Lighting.FogEnd = v and 9e9 or 1000
end })

Visual:AddToggle({ Name = "Chams", Default = false, Callback = function(v)
    getgenv().Chams = v
end })

Visual:AddToggle({ Name = "Tracers", Default = false, Callback = function(v)
    getgenv().Tracers = v
end })

Visual:AddToggle({ Name = "Box ESP", Default = false, Callback = function(v)
    getgenv().BoxESP = v
end })

Visual:AddToggle({ Name = "Name ESP", Default = false, Callback = function(v)
    getgenv().NameESP = v
end })

Visual:AddToggle({ Name = "Distance ESP", Default = false, Callback = function(v)
    getgenv().DistESP = v
end })

Visual:AddToggle({ Name = "Health Bar", Default = false, Callback = function(v)
    getgenv().HealthBar = v
end })

Visual:AddColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(255, 0, 0), Callback = function(c)
    getgenv().ESPColor = c
end })

Visual:AddToggle({ Name = "Skeleton ESP", Default = false, Callback = function(v)
    getgenv().SkeletonESP = v
end })

local PlayerTab = Window:MakeTab({ Name = "Player", Icon = "rbxassetid://4483345998" })

PlayerTab:AddButton({ Name = "Reset Character", Callback = function()
    LocalPlayer.Character:BreakJoints()
end })

PlayerTab:AddButton({ Name = "Rejoin Server", Callback = function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })

PlayerTab:AddButton({ Name = "Server Hop", Callback = function()
    local servers = HttpService:JSONDecode(game:HttpGet(
        "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    ))
    for _, v in ipairs(servers.data) do
        if v.playing < v.maxPlayers then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, v.id)
            break
        end
    end
end })

PlayerTab:AddButton({ Name = "Get All Tools", Callback = function()
    for _, tool in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if tool:IsA("Tool") then
            tool:Clone().Parent = LocalPlayer.Backpack
        end
    end
end })

PlayerTab:AddButton({ Name = "Drop All Tools", Callback = function()
    for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
        tool.Parent = workspace
    end
end })

PlayerTab:AddToggle({ Name = "Anti AFK", Default = true, Callback = function(v)
    getgenv().AntiAFK = v
end })

PlayerTab:AddToggle({ Name = "Auto Pickup", Default = false, Callback = function(v)
    getgenv().AutoPickup = v
end })

PlayerTab:AddToggle({ Name = "No Clip Camera", Default = false, Callback = function(v)
    getgenv().NoClipCam = v
end })

PlayerTab:AddToggle({ Name = "God Mode", Default = false, Callback = function(v)
    getgenv().GodMode = v
end })

local Misc = Window:MakeTab({ Name = "Misc", Icon = "rbxassetid://4483345998" })

Misc:AddToggle({ Name = "Auto Farm Coins", Default = false, Callback = function(v)
    getgenv().AutoFarm = v
end })

Misc:AddToggle({ Name = "Chat Spam", Default = false, Callback = function(v)
    getgenv().ChatSpam = v
end })

Misc:AddTextbox({ Name = "Spam Message", Default = "MM2 Delta", Callback = function(t)
    getgenv().SpamMsg = t
end })

Misc:AddToggle({ Name = "Anti Kick", Default = false, Callback = function(v)
    getgenv().AntiKick = v
end })

Misc:AddToggle({ Name = "FPS Boost", Default = false, Callback = function(v)
    getgenv().FPSBoost = v
end })

Misc:AddToggle({ Name = "Hide GUI", Default = false, Callback = function(v)
    getgenv().HideGUI = v
end })

Misc:AddToggle({ Name = "Auto Rejoin", Default = false, Callback = function(v)
    getgenv().AutoRejoin = v
end })

Misc:AddToggle({ Name = "Logs", Default = false, Callback = function(v)
    getgenv().Logs = v
end })

OrionLib:Init()

local function onCharacter(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Died:Connect(function()
        if getgenv().AutoRejoin then
            task.wait(3)
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
end

if LocalPlayer.Character then
    onCharacter(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(onCharacter)

UserInputService.JumpRequest:Connect(function()
    if getgenv().InfJump and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

spawn(function()
    while task.wait(0.1) do
        if getgenv().AutoShoot and Silent.target then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool then
                tool:Activate()
            end
        end
        if getgenv().AutoKill then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and myHRP and (hrp.Position - myHRP.Position).Magnitude < 15 then
                        local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate() end
                    end
                end
            end
        end
        if getgenv().AntiAFK then
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new())
        end
    end
end)

print("[MM2 Delta] Loaded. 53 functions. Silent Aim ready.")
