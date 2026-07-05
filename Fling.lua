local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- НАСТРОЙКА: Ваша ссылка
local MY_TG_LINK = "https://t.me" 

-- Функция для полной очистки старых версий при перезапуске
local function CleanupExisting()
    if game:CoreGui:FindFirstChild("FlingGui_QueueSystem") then
        game:CoreGui.FlingGui_QueueSystem:Destroy()
    end
    -- Останавливаем старые глобальные циклы, если они были привязаны к имени
    getgenv().FlingScriptRunning = false
end
CleanupExisting()

getgenv().FlingScriptRunning = true

-- Создание GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingGui_QueueSystem"
ScreenGui.Parent = game:CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.Position = UDim2.new(0.35, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 260, 0, 500) -- Увеличили высоту под кнопку перезагрузки
MainFrame.Active = true
MainFrame.Draggable = true

-- Главный заголовок
local Title = Instance.new("TextLabel")
Title.Parent = MainFrame
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "FLING SYSTEM v4.5 OPTIMIZED"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 14

-- Красивый переливающийся текст с ТГК
local TgLabel = Instance.new("TextLabel")
TgLabel.Parent = MainFrame
TgLabel.BackgroundTransparency = 1
TgLabel.Position = UDim2.new(0, 0, 0, 35)
TgLabel.Size = UDim2.new(1, 0, 0, 25)
TgLabel.Font = Enum.Font.Code
TgLabel.Text = "TG: " .. MY_TG_LINK
TgLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
TgLabel.TextSize = 13

-- Анимация ТГК
task.spawn(function()
    local hue = 0
    while getgenv().FlingScriptRunning and task.wait(0.02) do
        hue = (hue + 1) % 360
        TgLabel.TextColor3 = Color3.fromHSV(hue/360, 0.8, 1)
    end
end)

-- Кнопка Анти-Флинг
local AntiFlingBtn = Instance.new("TextButton")
AntiFlingBtn.Parent = MainFrame
AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
AntiFlingBtn.Position = UDim2.new(0.05, 0, 0.13, 0)
AntiFlingBtn.Size = UDim2.new(0.9, 0, 0, 30)
AntiFlingBtn.Font = Enum.Font.SourceSansBold
AntiFlingBtn.Text = "🛡️ Анти-Флинг: ВЫКЛ"
AntiFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AntiFlingBtn.TextSize = 13

-- Кнопка запуска атаки
local StartFlingBtn = Instance.new("TextButton")
StartFlingBtn.Parent = MainFrame
StartFlingBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
StartFlingBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
StartFlingBtn.Size = UDim2.new(0.9, 0, 0, 35)
StartFlingBtn.Font = Enum.Font.SourceSansBold
StartFlingBtn.Text = "⚔️ ЗАПУСТИТЬ ФЛИНГ"
StartFlingBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartFlingBtn.TextSize = 14

-- Кнопка быстрой очистки целей
local ResetBtn = Instance.new("TextButton")
ResetBtn.Parent = MainFrame
ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ResetBtn.Position = UDim2.new(0.05, 0, 0.28, 0)
ResetBtn.Size = UDim2.new(0.9, 0, 0, 25)
ResetBtn.Font = Enum.Font.SourceSans
ResetBtn.Text = "🧹 Сбросить список целей"
ResetBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
ResetBtn.TextSize = 12

-- Прокручиваемый список игроков
local PlayersScroll = Instance.new("ScrollingFrame")
PlayersScroll.Parent = MainFrame
PlayersScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
PlayersScroll.Position = UDim2.new(0.05, 0, 0.34, 0)
PlayersScroll.Size = UDim2.new(0.9, 0, 0, 280)
PlayersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
PlayersScroll.ScrollBarThickness = 5

-- Кнопка ПЕРЕЗАГРУЗКИ СКРИПТА (внизу)
local ReloadBtn = Instance.new("TextButton")
ReloadBtn.Parent = MainFrame
ReloadBtn.BackgroundColor3 = Color3.fromRGB(210, 105, 30)
ReloadBtn.Position = UDim2.new(0.05, 0, 0.91, 0)
ReloadBtn.Size = UDim2.new(0.9, 0, 0, 35)
ReloadBtn.Font = Enum.Font.SourceSansBold
ReloadBtn.Text = "🔄 ПЕРЕЗАГРУЗИТЬ СКРИПТ"
ReloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ReloadBtn.TextSize = 14

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = PlayersScroll
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 5)

-- Переменные логики
local antiFlingActive = false
local flingLoopActive = false
local selectedPlayers = {}

-- Умный Анти-Флинг (Без просадки физики)
local antiFlingConnection
antiFlingConnection = RunService.Heartbeat:Connect(function()
    if not getgenv().FlingScriptRunning then 
        antiFlingConnection:Disconnect() 
        return 
    end
    
    if antiFlingActive then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                for _, part in pairs(p.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then 
                        part.CanCollide = false 
                    end
                end
            end
        end
    end
end)

AntiFlingBtn.MouseButton1Click:Connect(function()
    antiFlingActive = not antiFlingActive
    if antiFlingActive then
        AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 60)
        AntiFlingBtn.Text = "🛡️ Анти-Флинг: ВКЛ"
    else
        AntiFlingBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        AntiFlingBtn.Text = "🛡️ Анти-Флинг: ВЫКЛ"
    end
end)

-- Оптимизированная функция создания сил физики (без спама инстансами)
local function applyFlingVelocity(hrp)
    local att = hrp:FindFirstChild("FlingAttachment") or Instance.new("Attachment", hrp)
    att.Name = "FlingAttachment"
    
    local lv = hrp:FindFirstChild("FlingLV") or Instance.new("LinearVelocity", hrp)
    lv.Name = "FlingLV"
    lv.MaxForce = math.huge
    lv.VectorVelocity = Vector3.new(999999, 999999, 999999)
    lv.Attachment0 = att
    
    local av = hrp:FindFirstChild("FlingAV") or Instance.new("AngularVelocity", hrp)
    av.Name = "FlingAV"
    av.MaxTorque = math.huge
    av.AngularVelocity = Vector3.new(999999, 999999, 999999)
    av.Attachment0 = att
    
    return lv, av, att
end

local function removeFlingVelocity(hrp)
    if hrp then
        if hrp:FindFirstChild("FlingLV") then hrp.FlingLV:Destroy() end
        if hrp:FindFirstChild("FlingAV") then hrp.FlingAV:Destroy() end
        if hrp:FindFirstChild("FlingAttachment") then hrp.FlingAttachment:Destroy() end
        hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
        hrp.AssemblyAngularVelocity = Vector3.new(0,0,0)
    end
end

-- Цикл атаки целей
task.spawn(function()
    while getgenv().FlingScriptRunning do
        task.wait(0.1)
        if flingLoopActive then
            local targetCount = 0
            for _, isActive in pairs(selectedPlayers) do
                if isActive then targetCount = targetCount + 1 end
            end
            
            if targetCount > 0 then
                for targetPlayer, isActive in pairs(selectedPlayers) do
                    if not flingLoopActive or not getgenv().FlingScriptRunning then break end
                    
                    -- Проверяем, существует ли еще цель в игре
                    if isActive and targetPlayer and targetPlayer.Parent and targetPlayer.Character then
                        local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local myHumanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        
                        if myHRP and targetHRP and myHumanoid and myHumanoid.Health > 0 then
                            myHumanoid.Sit = true
                            
                            -- Создаем силы ОДИН раз за атаку на жертву
                            local lv, av, att = applyFlingVelocity(myHRP)
                            
                            local duration = 0
                            while duration < 0.4 and flingLoopActive and targetPlayer.Parent and targetPlayer.Character and myHumanoid.Health > 0 do
                                if not targetHRP or not myHRP then break end
                                
                                myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, 0, 0.05)
                                task.wait(0.02)
                                duration = duration + 0.02
                            end
                            
                            -- Убираем силы сразу после завершения флинга этой цели
                            removeFlingVelocity(myHRP)
                            if myHumanoid then myHumanoid.Sit = false end
                            
                            -- Пауза перед следующей жертвой
                            task.wait(3.0) 
                        end
                    end
                end
            else
                flingLoopActive = false
                StartFlingBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
                StartFlingBtn.Text = "⚔️ ЗАПУСТИТЬ ФЛИНГ"
            end
        end
    end
end)

-- Управление кнопкой Старт/Стоп
StartFlingBtn.MouseButton1Click:Connect(function()
    flingLoopActive = not flingLoopActive
    if flingLoopActive then
        StartFlingBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        StartFlingBtn.Text = "🛑 ОСТАНОВИТЬ ФЛИНГ"
    else
        StartFlingBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
        StartFlingBtn.Text = "⚔️ ЗАПУСТИТЬ ФЛИНГ"
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        removeFlingVelocity(myHRP)
    end
end)

-- Оптимизированное обновление списка (БЕЗ тотального Destroy)
local function updateList()
    if not getgenv().FlingScriptRunning then return end
    
    -- Собираем текущие кнопки, чтобы знать кого удалить
    local currentButtons = {}
for _, child in pairs(PlayersScroll:GetChildren()) do
    if child:IsA("TextButton") then
        currentButtons[child.Name] = child
    end
end

-- Список актуальных игроков для проверки удаления лишних кнопок
local activeNames = {}

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Parent then
        activeNames[p.Name] = true
        local PBtn = currentButtons[p.Name]
        
        -- Если кнопки для игрока еще нет — создаем её
        if not PBtn then
            PBtn = Instance.new("TextButton")
            PBtn.Name = p.Name
            PBtn.Size = UDim2.new(1, 0, 0, 30)
            PBtn.Font = Enum.Font.SourceSans
            PBtn.TextSize = 14
            PBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            PBtn.Parent = PlayersScroll
            
            PBtn.MouseButton1Click:Connect(function()
                if p and p.Parent then
                    selectedPlayers[p] = not selectedPlayers[p]
                    updateList()
                end
            end)
        end
        
        -- Обновляем только внешний вид (не пересоздавая саму кнопку)
        if selectedPlayers[p] then
            PBtn.BackgroundColor3 = Color3.fromRGB(45, 140, 45)
            PBtn.Text = "🎯 " .. p.DisplayName
        else
            PBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            PBtn.Text = p.DisplayName
        end
    end
end

-- Удаляем кнопки тех игроков, которые вышли
for btnName, btnObj in pairs(currentButtons) do
    if not activeNames[btnName] then
        btnObj:Destroy()
    end
end

PlayersScroll.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

-- Кнопка Сброса целей
ResetBtn.MouseButton1Click:Connect(function()
    selectedPlayers = {}
    updateList()
end)

-- Авто-обновление по событиям игры
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(function(p)
    selectedPlayers[p] = nil
    updateList()
end)

-- Постоянное фоновое авто-обновление (каждую 1 секунду на всякий случай)
task.spawn(function()
    while getgenv().FlingScriptRunning do
        updateList()
        task.wait(1.0)
    end
end)

-- Логика кнопки ПЕРЕЗАГРУЗКИ СКРИПТА
ReloadBtn.MouseButton1Click:Connect(function()
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    removeFlingVelocity(myHRP)
    CleanupExisting()
    
    -- Сообщение в консоль о перезагрузке
    print("Скрипт успешно перезагружен и очищен!")
end)

-- Первый запуск
updateList()
