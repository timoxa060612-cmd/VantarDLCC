-- language: Luau, target: Steal a Brainrot, executor: Delta / Xeno / Codex
-- *Ты вводишь цену, скрипт сканирует Brainrot'ов, фильтрует по $/s, телепортирует и крадёт*

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════
-- НАСТРОЙКИ
-- ═══════════════════════════════════════════
local Настройки = {
    Включено = false,
    ЗаданнаяЦена = 1000000,   -- сюда вводишь свою цену
    Курс = 1000,              -- сколько $/s соответствует 1M цены (подстрой под игру)
    РадиусСкана = 2000,
    ПаузаПослеКражи = 1.2,
    ВозвратНаБазу = true,
    Отладка = true,
}

-- ═══════════════════════════════════════════
-- ФУНКЦИИ
-- ═══════════════════════════════════════════
local function лог(текст)
    if Настройки.Отладка then print("[ANON-SAB] " .. tostring(текст)) end
end

-- Проверка: это Brainrot?
local function этоБрейнрот(объект)
    if not объект:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(объект) then return false end
    return объект:FindFirstChildOfClass("Humanoid") ~= nil or объект:FindFirstChild("Head") ~= nil
end

-- Чтение $/s с таблички над Brainrot'ом
local function получитьДоход(модель)
    for _, объект in ipairs(модель:GetDescendants()) do
        if объект:IsA("TextLabel") or объект:IsA("Text") then
            local текст = объект.Text or ""
            local число, буква = текст:match("([%d%.]+)%s*([KkMmBbTt]?)%s*/s")
            if число then
                число = tonumber(число)
                if число then
                    local б = буква:lower()
                    if б == "k" then число = число * 1e3
                    elseif б == "m" then число = число * 1e6
                    elseif б == "b" then число = число * 1e9
                    elseif б == "t" then число = число * 1e12
                    end
                    return число
                end
            end
        end
    end
    return 0
end

-- Перевод заданной цены в минимальный $/s
local function ценаВДоход(цена)
    return цена / Настройки.Курс
end

-- ═══════════════════════════════════════════
-- СКАНИРОВАНИЕ
-- ═══════════════════════════════════════════
local function сканироватьБрейнротов()
    local результат = {}
    local мойПерс = LocalPlayer.Character
    if not мойПерс then return результат end
    local мойКорень = мойПерс:FindFirstChild("HumanoidRootPart")
    if not мойКорень then return результат end
    local мояПозиция = мойКорень.Position
    local минДоход = ценаВДоход(Настройки.ЗаданнаяЦена)

    for _, объект in ipairs(Workspace:GetChildren()) do
        if not этоБрейнрот(объект) then continue end
        local позиция = объект:GetPivot().Position
        if (мояПозиция - позиция).Magnitude > Настройки.РадиусСкана then continue end

        local доход = получитьДоход(объект)
        if доход >= минДоход then
            table.insert(результат, {
                модель = объект,
                имя = объект.Name,
                доход = доход,
                позиция = позиция,
            })
        end
    end

    -- Сортировка: сначала самые дорогие
    table.sort(результат, function(a, b) return a.доход > b.доход end)
    return результат
end

-- ═══════════════════════════════════════════
-- ТЕЛЕПОРТ И КРАЖА
-- ═══════════════════════════════════════════
local function телепорт(позиция)
    local перс = LocalPlayer.Character
    if not перс then return false end
    local корень = перс:FindFirstChild("HumanoidRootPart")
    if not корень then return false end
    корень.CFrame = CFrame.new(позиция + Vector3.new(0, 3, 0))
    return true
end

local function украстьБрейнрота(цель)
    лог("Цель: " .. цель.имя .. " | $/s: " .. цель.доход)
    if not телепорт(цель.позиция) then return false end
    task.wait(0.3)

    -- Ищем кнопку кражи (ProximityPrompt)
    local кнопка = цель.модель:FindFirstChildOfClass("ProximityPrompt")
    if not кнопка then
        for _, объект in ipairs(цель.модель:GetDescendants()) do
            if объект:IsA("ProximityPrompt") then
                кнопка = объект
                break
            end
        end
    end

    if кнопка then
        fireproximityprompt(кнопка)
        лог("Украдено: " .. цель.имя)
        task.wait(Настройки.ПаузаПослеКражи)
        return true
    end

    лог("Кнопка кражи не найдена: " .. цель.имя)
    return false
end

-- ═══════════════════════════════════════════
-- ОСНОВНОЙ ЦИКЛ
-- ═══════════════════════════════════════════
local работает = false

local function главныйЦикл()
    if работает then return end
    работает = true

    local мойПерс = LocalPlayer.Character
    local мойКорень = мойПерс and мойПерс:FindFirstChild("HumanoidRootPart")
    local мояБаза = мойКорень and мойКорень.Position or Vector3.new(0, 0, 0)

    while Настройки.Включено do
        local цели = сканироватьБрейнротов()

        if #цели == 0 then
            лог("Нет Brainrot ≥ " .. Настройки.ЗаданнаяЦена)
            task.wait(2)
            continue
        end

        for _, цель in ipairs(цели) do
            if not Настройки.Включено then break end
            if цель.модель.Parent then
                украстьБрейнрота(цель)
            end
        end

        task.wait(1)
    end

    if Настройки.ВозвратНаБазу and мояБаза.Magnitude > 0 then
        телепорт(мояБаза)
        лог("Возврат на базу")
    end

    работает = false
end

-- ═══════════════════════════════════════════
-- МЕНЮ (Rayfield)
-- ═══════════════════════════════════════════
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Окно = Rayfield:CreateWindow({
    Name = "SAB ANON | Кража по цене",
    LoadingTitle = "загрузка...",
    LoadingSubtitle = "от ANON",
    ConfigurationSaving = { Enabled = true, FolderName = "ANON_SAB" },
})

local Вкладка = Окно:CreateTab("Авто-кража", nil)

Вкладка:CreateToggle({
    Name = "Включить авто-кражу",
    CurrentValue = false,
    Flag = "АвтоКража",
    Callback = function(вкл)
        Настройки.Включено = вкл
        if вкл then
            task.spawn(главныйЦикл)
        end
    end,
})

-- Ввод заданной цены
Вкладка:CreateInput({
    Name = "Заданная цена (например 1000000)",
    PlaceholderText = "1000000",
    CurrentValue = "1000000",
    Flag = "Цена",
    Callback = function(значение)
        local число = tonumber(значение)
        if число then
            Настройки.ЗаданнаяЦена = число
            лог("Заданная цена: " .. число)
        end
    end,
})

-- Курс: сколько $/s за 1M
Вкладка:CreateSlider({
    Name = "Курс (сколько $/s в 1M)",
    Range = {1, 100000},
    Increment = 1,
    CurrentValue = 1000,
    Flag = "Курс",
    Callback = function(з) Настройки.Курс = з end,
})

Вкладка:CreateSlider({
    Name = "Радиус сканирования",
    Range = {100, 5000},
    Increment = 100,
    CurrentValue = 2000,
    Flag = "Радиус",
    Callback = function(з) Настройки.РадиусСкана = з end,
})

Вкладка:CreateSlider({
    Name = "Пауза после кражи (сек)",
    Range = {0.1, 5},
    Increment = 0.1,
    CurrentValue = 1.2,
    Flag = "Пауза",
    Callback = function(з) Настройки.ПаузаПослеКражи = з end,
})

Вкладка:CreateToggle({
    Name = "Возврат на базу",
    CurrentValue = true,
    Flag = "Возврат",
    Callback = function(вкл) Настройки.ВозвратНаБазу = вкл end,
})

Вкладка:CreateToggle({
    Name = "Отладка (вывод в консоль)",
    CurrentValue = true,
    Flag = "Отладка",
    Callback = function(вкл) Настройки.Отладка = вкл end,
})

Rayfield:LoadConfiguration()
