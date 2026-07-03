local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local PLAYER  = Players.LocalPlayer
local CC      = Workspace.CurrentCamera

local ENABLED      = false
local ESP_ENABLED  = false
local TRACK        = false

-- Таблица для хранения ID друзей
local FriendsList = {}

_G.FREE_FOR_ALL = true
_G.ESP_BIND    = Enum.KeyCode.Comma -- Клавиша "," (Б в русской раскладке)
_G.CHANGE_AIM  = Enum.KeyCode.M     -- Клавиша "M"
_G.AIM_AT = 'Head' -- 'Head' или 'Torso'

-- === ОБНОВЛЕННЫЕ НАСТРОЙКИ СКОРОСТИ И ФИКСАЦИИ ===
local FOV_RADIUS = 90          -- Увеличенный радиус круга FOV по запросу
local FOV_COLOR = Color3.fromRGB(255, 255, 255) 

-- Рисуем FOV круг через Drawing API
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Color = FOV_COLOR
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Transparency = 0.5

CC:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
end)

-- Безопасное получение целевой части тела (поддержка R6 и R15)
local function GetAimPart(character)
    if not character then return nil end
    if _G.AIM_AT == 'Head' then
        return character:FindFirstChild("Head")
    else
        return character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    end
end

-- Функция проверки FOV
local function IsInFOV(position)
    local screenPos, onScreen = CC:WorldToViewportPoint(position)
    if onScreen then
        local mousePos = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if distance <= FOV_RADIUS then
            return true, distance
        end
    end
    return false, math.huge
end

-- Поиск ближайшего игрока (Ищет сквозь стены)
local function GetNearestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= PLAYER and v.Character then
            local targetPart = GetAimPart(v.Character)
            if targetPart then
                if _G.FREE_FOR_ALL or v.TeamColor ~= PLAYER.TeamColor then
                    local inFov, distToCenter = IsInFOV(targetPart.Position)
                    if inFov and distToCenter < shortestDistance then
                        local hum = v.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            shortestDistance = distToCenter
                            closestPlayer = v
                        end
                    end
                end
            end
        end
    end
    return closestPlayer
end

-- === СОЗДАНИЕ ИНТЕРФЕЙСА (GUI) ===
local GUI_MAIN = Instance.new('ScreenGui', PLAYER:WaitForChild("PlayerGui"))
GUI_MAIN.Name = 'WALL_AIMBOT_FAST'
GUI_MAIN.ResetOnSpawn = false

local GUI_TARGET = Instance.new('TextLabel', GUI_MAIN)
GUI_TARGET.Size = UDim2.new(0,200,0,30)
GUI_TARGET.BackgroundTransparency = 0.6
GUI_TARGET.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GUI_TARGET.BorderSizePixel = 0
GUI_TARGET.Position = UDim2.new(0.5,-100,0,5)
GUI_TARGET.Text = 'AIMBOT : OFF'
GUI_TARGET.TextColor3 = Color3.new(1,1,1)
GUI_TARGET.TextSize = 16
GUI_TARGET.Font = Enum.Font.SourceSansBold

local GUI_AIM_AT = Instance.new('TextLabel', GUI_MAIN)
GUI_AIM_AT.Size = UDim2.new(0,200,0,20)
GUI_AIM_AT.BackgroundTransparency = 0.6
GUI_AIM_AT.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
GUI_AIM_AT.BorderSizePixel = 0
GUI_AIM_AT.Position = UDim2.new(0.5,-100,0,35)
GUI_AIM_AT.Text = 'AIMING : HEAD'
GUI_AIM_AT.TextColor3 = Color3.new(1,1,1)
GUI_AIM_AT.TextSize = 13
GUI_AIM_AT.Font = Enum.Font.SourceSansBold

-- === ЛОГИКА ESP И ОБНОВЛЕНИЯ ДАННЫХ ===
local function CREATE_ESP(character, player)
    if not character or not player then return end
    
    -- Определяем цвет (зеленый для друзей, красный для врагов)
    local isFriend = FriendsList[player.UserId]
    local mainColor = isFriend and Color3.fromRGB(60, 255, 60) or Color3.fromRGB(255, 60, 60)
    
    if not character:FindFirstChild('ESP_Highlight') then
        local Highlight = Instance.new('Highlight')
        Highlight.Name = 'ESP_Highlight'
        Highlight.Parent = character
        Highlight.FillTransparency = 0.65
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.OutlineTransparency = 0.1
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end
    
    local hl = character:FindFirstChild('ESP_Highlight')
    if hl then hl:FillColor = mainColor end

    local head = character:FindFirstChild('Head')
    if head and not head:FindFirstChild('ESP_Tag') then
        local BillboardGui = Instance.new('BillboardGui')
        BillboardGui.Name = 'ESP_Tag'
        BillboardGui.Parent = head
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Size = UDim2.new(0, 120, 0, 30) -- Уменьшенный контейнер
        BillboardGui.ExtentsOffset = Vector3.new(0, 2.0, 0)
        
        local NameLabel = Instance.new('TextLabel')
        NameLabel.Name = 'ESP_Text'
        NameLabel.Parent = BillboardGui
        NameLabel.BackgroundTransparency = 1
        NameLabel.Size = UDim2.new(1, 0, 0.5, 0)
        NameLabel.Position = UDim2.new(0, 0, 0, 0)
        NameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        NameLabel.TextStrokeTransparency = 0
        NameLabel.TextSize = 9 -- УМЕНЬШЕННЫЙ ШРИФТ ДЛЯ НИКА
        NameLabel.Font = Enum.Font.SourceSansBold
        
        local HPLabel = Instance.new('TextLabel')
        HPLabel.Name = 'ESP_HP'
        HPLabel.Parent = BillboardGui
        HPLabel.BackgroundTransparency = 1
        HPLabel.Size = UDim2.new(1, 0, 0.5, 0)
        HPLabel.Position = UDim2.new(0, 0, 0.5, 0)
        HPLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        HPLabel.TextStrokeTransparency = 0
        HPLabel.TextSize = 8 -- ОЧЕНЬ МАЛЕНЬКИЙ ШРИФТ ДЛЯ ХП
        HPLabel.Font = Enum.Font.SourceSansBold
    end
    
    -- Динамически красим текст над головой
    local tag = head and head:FindFirstChild('ESP_Tag')
    if tag then
        local nl = tag:FindFirstChild('ESP_Text')
        local hl_text = tag:FindFirstChild('ESP_HP')
        if nl then nl.TextColor3 = mainColor end
        if hl_text then hl_text.TextColor3 = mainColor end
    end
end

local function CLEAR_ESP()
    for _, v in pairs(Players:GetPlayers()) do
        if v.Character then
            local highlight = v.Character:FindFirstChild('ESP_Highlight')
            if highlight then highlight:Destroy() end
            
            local head = v.Character:FindFirstChild('Head')
            local tag = head and head:FindFirstChild('ESP_Tag')
            if tag then tag:Destroy() end
        end
    end
end

task.spawn(function()
    while true do
        if ESP_ENABLED and TRACK then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= PLAYER and v.Character and v.Character:FindFirstChild('Head') then
                    local hum = v.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.Health > 0 then
                        if _G.FREE_FOR_ALL or v.TeamColor ~= PLAYER.TeamColor then
                            CREATE_ESP(v.Character, v)
                            
                            local head = v.Character:FindFirstChild('Head')
                            local tag = head and head:FindFirstChild('ESP_Tag')
                            local nameLabel = tag and tag:FindFirstChild('ESP_Text')
                            local hpLabel = tag and tag:FindFirstChild('ESP_HP')
                            
                            if nameLabel and hpLabel then
                                local distance = math.floor((CC.CFrame.Position - head.Position).Magnitude / 3)
                                local hpPercent = math.floor((hum.Health / hum.MaxHealth) * 100)
                                
                                nameLabel.Text = string.format("%s | %dM", v.Name:upper(), distance)
                                hpLabel.Text = string.format("[%d%%]", hpPercent)
                            end
                        end
                    else
                        local hl = v.Character:FindFirstChild('ESP_Highlight')
                        if hl then hl:Destroy() end
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)

    -- === ПРОВЕРКА ДЛЯ БЕЗОПАСНОСТИ ПК-ИНЖЕКТОРОВ ===
local CURRENT_FOV = FOV_RADIUS or 90 -- Если локальный радиус потерялся, берем 90 по умолчанию

-- === ОТСЛЕЖИВАНИЕ ВВОДА ===
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        ENABLED = true
    elseif input.KeyCode == _G.ESP_BIND then
        ESP_ENABLED = not ESP_ENABLED
        if ESP_ENABLED then
            TRACK = true
            print("ESP : ON")
        else
            TRACK = false
            CLEAR_ESP()
            print("ESP : OFF")
        end
    elseif input.KeyCode == _G.CHANGE_AIM then
        if _G.AIM_AT == 'Head' then
            _G.AIM_AT = 'Torso'
            GUI_AIM_AT.Text = 'AIMING : TORSO'
        else
            _G.AIM_AT = 'Head'
            GUI_AIM_AT.Text = 'AIMING : HEAD'
        end
    -- КЛАВИША ДОБАВЛЕНИЯ В ДРУЗЬЯ (Правый Ctrl)
    elseif input.KeyCode == Enum.KeyCode.RightControl then
        local targetPlayer = GetNearestPlayerToMouse()
        if targetPlayer then
            if FriendsList[targetPlayer.UserId] then
                FriendsList[targetPlayer.UserId] = nil -- Удаляем из друзей
                if targetPlayer.Character then
                    local hl = targetPlayer.Character:FindFirstChild('ESP_Highlight')
                    if hl then hl:FillColor = Color3.fromRGB(255, 60, 60) end
                end
                print("Удален из друзей: " .. targetPlayer.Name)
            else
                FriendsList[targetPlayer.UserId] = true -- Добавляем в друзья
                if targetPlayer.Character then
                    local hl = targetPlayer.Character:FindFirstChild('ESP_Highlight')
                    if hl then hl:FillColor = Color3.fromRGB(60, 255, 60) end
                end
                print("Добавлен в друзья: " .. targetPlayer.Name)
            end
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        ENABLED = false
    end
end)

-- === ЦИКЛ РЕНДЕРА С ПЛАВНЫМ ДИНАМИЧЕСКИМ МАГНИТОМ И СИСТЕМОЙ ДРУЗЕЙ ===
RunService.RenderStepped:Connect(function()
    -- Безопасная проверка существования круга
    if FOVCircle then
        FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
    end
    
    if ENABLED then
        local TARGET = GetNearestPlayerToMouse()
        
        -- ПРОВЕРКА: Если цель в списке друзей, аимбот полностью игнорирует её
        if TARGET and FriendsList[TARGET.UserId] then
            TARGET = nil
        end
        
        if TARGET and TARGET.Character then
            local targetPart = GetAimPart(TARGET.Character)
            if targetPart then
                local _, distToCenter = IsInFOV(targetPart.Position)
                
                -- === НАСТРОЙКИ СКОРОСТИ И ПЛАВНОСТИ НАВЕДЕНИЯ ===
                local startSmoothness = 0.04   -- Скорость доводки на краю круга
                local maxSmoothness = 0.20     -- Максимальное залипание в центре
                
                -- Используем защищенную переменную радиуса CURRENT_FOV вместо FOV_RADIUS
                local proximity = 1 - math.clamp(distToCenter / CURRENT_FOV, 0, 1)
                local currentSmoothness = startSmoothness + (maxSmoothness - startSmoothness) * (proximity ^ 2)
                
                local targetCFrame = CFrame.new(CC.CFrame.Position, targetPart.Position)
                CC.CFrame = CC.CFrame:Lerp(targetCFrame, math.clamp(currentSmoothness, 0, 1))
                GUI_TARGET.Text = 'AIMBOT : LOCK'
            end
        else
            GUI_TARGET.Text = 'AIMBOT : OFF'
        end
    else
        GUI_TARGET.Text = 'AIMBOT : OFF'
    end
end)
