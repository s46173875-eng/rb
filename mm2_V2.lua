-- Создание ScreenGui
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local ToggleButton = Instance.new("TextButton")
local UICorner_Main = Instance.new("UICorner")
local UICorner_Toggle = Instance.new("UICorner")
local TGLabel = Instance.new("TextLabel")

ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "MM2_Premium_V2"

-- Настройки главного окна (MainFrame)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true -- Позволяет двигать GUI

UICorner_Main.Parent = MainFrame
UICorner_Main.CornerRadius = UDim.new(0, 8)

-- Текст с вашим ТГК
TGLabel.Parent = MainFrame
TGLabel.Size = UDim2.new(1, 0, 0, 20)
TGLabel.Position = UDim2.new(0, 0, 1, -25)
TGLabel.BackgroundTransparency = 1
TGLabel.Text = "TG: @VNMA_OFFICIAL"
TGLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TGLabel.TextSize = 14
TGLabel.Font = Enum.Font.SourceSansItalic

-- Маленький черный квадратик для скрытия (GUI Button)
ToggleButton.Name = "ToggleButton"
ToggleButton.Parent = ScreenGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleButton.Position = UDim2.new(0.05, 0, 0.3, 0)
ToggleButton.Size = UDim2.new(0, 40, 0, 40)
ToggleButton.Text = "GUI"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.Visible = false

UICorner_Toggle.Parent = ToggleButton
UICorner_Toggle.CornerRadius = UDim.new(0, 6)

-- Логика скрытия/показа интерфейса
local guiHidden = false
local function toggleGuiVisual()
    guiHidden = not guiHidden
    if guiHidden then
        MainFrame.Visible = false
        ToggleButton.Position = MainFrame.Position
        ToggleButton.Visible = true
    else
        MainFrame.Visible = true
        ToggleButton.Visible = false
    end
end

-- Переключение по нажатию на маленький квадрат
ToggleButton.MouseButton1Click:Connect(toggleGuiVisual)

-- Переключение по нажатию кнопки (добавьте кнопку закрытия в интерфейс по желанию)
-- Для удобства вы можете вызывать toggleGuiVisual() из вашей системы меню
-- Переменные состояний читов
local Cheats = {
    ESP_Murder = false,
    ESP_Sheriff = false,
    ESP_Innocent = false,
    AimBot_Enabled = false
}

-- Шаблон для создания строк меню
local function createMenuButton(name, text, positionY, color, callback)
    local TextLabel = Instance.new("TextLabel")
    local ActionButton = Instance.new("TextButton")
    
    TextLabel.Parent = MainFrame
    TextLabel.BackgroundTransparency = 1
    TextLabel.Position = UDim2.new(0, 15, 0, positionY)
    TextLabel.Size = UDim2.new(0, 120, 0, 30)
    TextLabel.Text = text
    TextLabel.TextColor3 = color
    TextLabel.TextSize = 18
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.Font = Enum.Font.SourceSansBold

    ActionButton.Parent = MainFrame
    ActionButton.BackgroundTransparency = 1
    ActionButton.Position = UDim2.new(0, 140, 0, positionY)
    ActionButton.Size = UDim2.new(0, 30, 0, 30)
    ActionButton.Text = "❌"
    ActionButton.TextColor3 = Color3.fromRGB(255, 0, 0)
    ActionButton.TextSize = 20

    ActionButton.MouseButton1Click:Connect(function()
        local newState = not Cheats[name]
        Cheats[name] = newState
        if newState then
            ActionButton.Text = "✅"
        else
            ActionButton.Text = "❌"
        end
        callback(newState)
    end)
end

-- Заголовки разделов
local function createSectionTitle(text, positionY, color)
    local Title = Instance.new("TextLabel")
    Title.Parent = MainFrame
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, positionY)
    Title.Size = UDim2.new(0, 150, 0, 25)
    Title.Text = text
    Title.TextColor3 = color
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.SourceSansBold
end

-- Отрисовка элементов GUI (как на вашем скриншоте)
createSectionTitle("ESP", 15, Color3.fromRGB(255, 185, 0))
createMenuButton("ESP_Murder", "Убийца-", 45, Color3.fromRGB(255, 50, 50), function(val) print("Murder ESP:", val) end)
createMenuButton("ESP_Sheriff", "Шериф-", 75, Color3.fromRGB(50, 150, 255), function(val) print("Sheriff ESP:", val) end)
createMenuButton("ESP_Innocent", "Невинный-", 105, Color3.fromRGB(150, 255, 150), function(val) print("Innocent ESP:", val) end)

-- Разделительная линия
local Line = Instance.new("Frame")
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Line.Position = UDim2.new(0, 15, 0, 145)
Line.Size = UDim2.new(0, 190, 0, 2)
Line.BorderSizePixel = 0

createSectionTitle("AIM-BOT", 160, Color3.fromRGB(255, 255, 255))
createMenuButton("AimBot_Enabled", "AIM-", 190, Color3.fromRGB(255, 100, 100), function(val) print("Aim Mode:", val) end)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local aimbotActive = false -- Состояние переключателя на кнопку R
local lockedTarget = nil   -- Зафиксированная цель на ПКМ

-- Функция поиска ближайшего игрока к курсору мыши
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end
    return closestPlayer
end

-- Отслеживание нажатий клавиатуры и мыши
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Кнопка R работает как главный переключатель режима AIM
    if input.KeyCode == Enum.KeyCode.R and Cheats.AimBot_Enabled then
        aimbotActive = not aimbotActive
        if not aimbotActive then
            lockedTarget = nil -- Сбрасываем цель при выключении режима
        end
    end
    
    -- Нажатие ПКМ фиксирует или сбрасывает цель, если режим активен
    if input.UserInputType == Enum.UserInputType.MouseButton2 and aimbotActive then
        if lockedTarget then
            lockedTarget = nil -- Если цель уже была, снимаем фиксацию
        else
            lockedTarget = getClosestPlayerToCursor() -- Фиксируем нового игрока
        end
    end
end)
-- Постоянное обновление камеры (Слежение и упреждение быстрого пистолета)
RunService.RenderStepped:Connect(function()
    if not aimbotActive or not Cheats.AimBot_Enabled or not lockedTarget then return end
    
    local char = lockedTarget.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
        local targetHRP = char.HumanoidRootPart
        
        -- Дистанция до цели для динамического расчета времени полета пули
        local distance = (targetHRP.Position - Camera.CFrame.Position).Magnitude
        
        -- Скорость пули пистолета в MM2 примерно равна 200-250 studs/sec.
        -- Рассчитываем точное время полета пули (время = дистанция / скорость)
        local bulletSpeed = 230
        local timeToTarget = distance / bulletSpeed
        
        -- Упреждение: позиция цели + (её скорость движения * время полета пули)
        local bulletPredictionOffset = targetHRP.Velocity * timeToTarget
        
        -- Целимся в торс (HumanoidRootPart) с учетом движения игрока
        local aimPosition = targetHRP.Position + bulletPredictionOffset
        
        -- Наведение камеры на точку, куда прилетит пуля
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
    else
        lockedTarget = nil -- Сброс, если игрок погиб или вышел из игры
    end
end)
