local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local PLAYER  = Players.LocalPlayer
local CC      = Workspace.CurrentCamera

local ENABLED      = false
local ESP_ENABLED  = false
local TRACK        = false

_G.FREE_FOR_ALL = true
_G.ESP_BIND    = Enum.KeyCode.Comma -- Клавиша "," (Б в русской раскладке)
_G.CHANGE_AIM  = Enum.KeyCode.M     -- Клавиша "M"
_G.AIM_AT = 'Head' -- 'Head' или 'Torso'

-- === ОПТИМАЛЬНЫЕ НАСТРОЙКИ СКОРОСТИ И ФИКСАЦИИ ===
local FOV_RADIUS = 85           -- Комфортный радиус круга FOV
local FOV_COLOR = Color3.fromRGB(255, 255, 255) 
local BASE_SMOOTHNESS = 0.13    -- Увеличена начальная скорость (быстрая доводка)
local TIGHT_LOCK_MULT = 1.5     -- Множитель сильного магнита у центра (крепкий лок)

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
local GUI_MAIN = Instance.new('ScreenGui', game.CoreGui)
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

-- === ЛОГИКА ESP ===
local function CREATE_ESP(character, player)
    if not character or not player then return end
    
    if not character:FindFirstChild('ESP_Highlight') then
        local Highlight = Instance.new('Highlight')
        Highlight.Name = 'ESP_Highlight'
        Highlight.Parent = character
        Highlight.FillColor = Color3.fromRGB(255, 60, 60)
        Highlight.FillTransparency = 0.65
        Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        Highlight.OutlineTransparency = 0.1
        Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    end

    local head = character:FindFirstChild('Head')
    if head and not head:FindFirstChild('ESP_Tag') then
        local BillboardGui = Instance.new('BillboardGui')
        BillboardGui.Name = 'ESP_Tag'
        BillboardGui.Parent = head
        BillboardGui.AlwaysOnTop = true
        BillboardGui.Size = UDim2.new(0, 100, 0, 20)
        BillboardGui.ExtentsOffset = Vector3.new(0, 2.5, 0)
        
        local TextLabel = Instance.new('TextLabel')
        TextLabel.Parent = BillboardGui
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.Text = player.Name:upper()
        TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextSize = 10
        TextLabel.Font = Enum.Font.SourceSansBold
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
                        end
                    else
                        local hl = v.Character:FindFirstChild('ESP_Highlight')
                        if hl then hl:Destroy() end
                    end
                end
            end
        end
        task.wait(0.4)
    end
end)

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
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        ENABLED = false
    end
end)

-- === ЦИКЛ РЕНДЕРА ===
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
    
    if ENABLED then
        local TARGET = GetNearestPlayerToMouse()
        if TARGET and TARGET.Character then
            local targetPart = GetAimPart(TARGET.Character)
            if targetPart then
                local _, distToCenter = IsInFOV(targetPart.Position)
                
                -- Адаптивный лок
                local currentSmoothness = BASE_SMOOTHNESS
                if distToCenter < (FOV_RADIUS * 0.4) then
                    currentSmoothness = BASE_SMOOTHNESS * TIGHT_LOCK_MULT
                end
                
                local targetCFrame = CFrame.new(CC.CFrame.Position, targetPart.Position)
                CC.CFrame = CC.CFrame:Lerp(targetCFrame, currentSmoothness)
                GUI_TARGET.Text = 'AIMBOT : LOCK'
            end
        else
            GUI_TARGET.Text = 'AIMBOT : OFF'
        end
    else
        GUI_TARGET.Text = 'AIMBOT : OFF'
    end
end)
