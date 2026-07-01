-- MM2 SCRIPT V2
-- TGK: @VNMA_OFFICIAL

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- Твои оригинальные переменные
_G.ESP_Murder = false
_G.ESP_Sheriff = false
_G.ESP_Innocent = false
_G.AimBot_Enabled = false

local r_ToggleActive = false
local pkm_Pressed = false
local lockedTarget = nil

-- === ОРИГИНАЛЬНОЕ СОЗДАНИЕ ИНТЕРФЕЙСА ===
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ESP_Title = Instance.new("TextLabel")
local Murder_Btn = Instance.new("TextButton")
local Sheriff_Btn = Instance.new("TextButton")
local Innocent_Btn = Instance.new("TextButton")
local Line = Instance.new("Frame")
local Aim_Title = Instance.new("TextLabel")
local Aim_Btn = Instance.new("TextButton")
local Hide_Btn = Instance.new("TextButton")
local UICorner_Hide = Instance.new("UICorner")
local TGLabel = Instance.new("TextLabel")

ScreenGui.Parent = (gethui and gethui()) or game.CoreGui
ScreenGui.Name = "MM2_V2"

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.Size = UDim2.new(0, 220, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 8)

-- Твой ТГК на GUI
TGLabel.Parent = MainFrame
TGLabel.Size = UDim2.new(1, 0, 0, 20)
TGLabel.Position = UDim2.new(0, 0, 1, -25)
TGLabel.BackgroundTransparency = 1
TGLabel.Text = "TG: @VNMA_OFFICIAL"
TGLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
TGLabel.TextSize = 14
TGLabel.Font = Enum.Font.SourceSansItalic

ESP_Title.Name = "ESP_Title"
ESP_Title.Parent = MainFrame
ESP_Title.BackgroundTransparency = 1
ESP_Title.Position = UDim2.new(0, 15, 0, 15)
ESP_Title.Size = UDim2.new(0, 150, 0, 25)
ESP_Title.Font = Enum.Font.SourceSansBold
ESP_Title.Text = "ESP"
ESP_Title.TextColor3 = Color3.fromRGB(255, 185, 0)
ESP_Title.TextSize = 22
ESP_Title.TextXAlignment = Enum.TextXAlignment.Left

Murder_Btn.Name = "Murder_Btn"
Murder_Btn.Parent = MainFrame
Murder_Btn.BackgroundTransparency = 1
Murder_Btn.Position = UDim2.new(0, 15, 0, 45)
Murder_Btn.Size = UDim2.new(0, 190, 0, 30)
Murder_Btn.Font = Enum.Font.SourceSansBold
Murder_Btn.Text = "Убийца- ❌"
Murder_Btn.TextColor3 = Color3.fromRGB(255, 50, 50)
Murder_Btn.TextSize = 18
Murder_Btn.TextXAlignment = Enum.TextXAlignment.Left

Sheriff_Btn.Name = "Sheriff_Btn"
Sheriff_Btn.Parent = MainFrame
Sheriff_Btn.BackgroundTransparency = 1
Sheriff_Btn.Position = UDim2.new(0, 15, 0, 75)
Sheriff_Btn.Size = UDim2.new(0, 190, 0, 30)
Sheriff_Btn.Font = Enum.Font.SourceSansBold
Sheriff_Btn.Text = "Шериф- ❌"
Sheriff_Btn.TextColor3 = Color3.fromRGB(50, 150, 255)
Sheriff_Btn.TextSize = 18
Sheriff_Btn.TextXAlignment = Enum.TextXAlignment.Left

Innocent_Btn.Name = "Innocent_Btn"
Innocent_Btn.Parent = MainFrame
Innocent_Btn.BackgroundTransparency = 1
Innocent_Btn.Position = UDim2.new(0, 15, 0, 105)
Innocent_Btn.Size = UDim2.new(0, 190, 0, 30)
Innocent_Btn.Font = Enum.Font.SourceSansBold
Innocent_Btn.Text = "Невинный- ❌"
Innocent_Btn.TextColor3 = Color3.fromRGB(150, 255, 150)
Innocent_Btn.TextSize = 18
Innocent_Btn.TextXAlignment = Enum.TextXAlignment.Left

Line.Name = "Line"
Line.Parent = MainFrame
Line.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
Line.Position = UDim2.new(0, 15, 0, 145)
Line.Size = UDim2.new(0, 190, 0, 2)
Line.BorderSizePixel = 0

Aim_Title.Name = "Aim_Title"
Aim_Title.Parent = MainFrame
Aim_Title.BackgroundTransparency = 1
Aim_Title.Position = UDim2.new(0, 15, 0, 160)
Aim_Title.Size = UDim2.new(0, 150, 0, 25)
Aim_Title.Font = Enum.Font.SourceSansBold
Aim_Title.Text = "AIM-BOT"
Aim_Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Aim_Title.TextSize = 22
Aim_Title.TextXAlignment = Enum.TextXAlignment.Left

Aim_Btn.Name = "Aim_Btn"
Aim_Btn.Parent = MainFrame
Aim_Btn.BackgroundTransparency = 1
Aim_Btn.Position = UDim2.new(0, 15, 0, 190)
Aim_Btn.Size = UDim2.new(0, 190, 0, 30)
Aim_Btn.Font = Enum.Font.SourceSansBold
Aim_Btn.Text = "AIM- ❌"
Aim_Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
Aim_Btn.TextSize = 18
Aim_Btn.TextXAlignment = Enum.TextXAlignment.Left

-- Кнопка скрытия "gyi"
Hide_Btn.Name = "Hide_Btn"
Hide_Btn.Parent = ScreenGui
Hide_Btn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Hide_Btn.Position = UDim2.new(0.05, 0, 0.3, 0)
Hide_Btn.Size = UDim2.new(0, 40, 0, 40)
Hide_Btn.Font = Enum.Font.SourceSansBold
Hide_Btn.Text = "gyi"
Hide_Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Hide_Btn.TextSize = 14
Hide_Btn.Visible = false

UICorner_Hide.Parent = Hide_Btn
UICorner_Hide.CornerRadius = UDim.new(0, 6)

local guiHidden = false
local function toggleGuiVisual()
    guiHidden = not guiHidden
    if guiHidden then
        MainFrame.Visible = false
        Hide_Btn.Position = MainFrame.Position
        Hide_Btn.Visible = true
    else
        MainFrame.Visible = true
        Hide_Btn.Visible = false
    end
end
Hide_Btn.MouseButton1Click:Connect(toggleGuiVisual)

-- Переключение состояний кнопок
Murder_Btn.MouseButton1Click:Connect(function()
    _G.ESP_Murder = not _G.ESP_Murder
    Murder_Btn.Text = _G.ESP_Murder and "Убийца- ✅" or "Убийца- ❌"
end)

Sheriff_Btn.MouseButton1Click:Connect(function()
    _G.ESP_Sheriff = not _G.ESP_Sheriff
    Sheriff_Btn.Text = _G.ESP_Sheriff and "Шериф- ✅" or "Шериф- ❌"
end)

Innocent_Btn.MouseButton1Click:Connect(function()
    _G.ESP_Innocent = not _G.ESP_Innocent
    Innocent_Btn.Text = _G.ESP_Innocent and "Невинный- ✅" or "Невинный- ❌"
end)

Aim_Btn.MouseButton1Click:Connect(function()
    _G.AimBot_Enabled = not _G.AimBot_Enabled
    Aim_Btn.Text = _G.AimBot_Enabled and "AIM- ✅" or "AIM- ❌"
    if not _G.AimBot_Enabled then
        r_ToggleActive = false
        lockedTarget = nil
    end
end)


-- === ЛОГИКА ESP ИЗ ТВОЕЙ ССЫЛКИ ===
local function createESP(player, color, roleName)
    if player.Character and not player.Character:FindFirstChild("MM2_ESP") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "MM2_ESP"
        highlight.Parent = player.Character
        highlight.FillColor = color
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "MM2_Name"
        billboard.Parent = player.Character
        billboard.Adornee = player.Character:FindFirstChild("Head")
        billboard.Size = UDim2.new(0, 100, 0, 150)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = player.Name .. " [" .. roleName .. "]"
        textLabel.TextColor3 = color
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.SourceSansBold
    end
end

local function removeESP(player)
    if player.Character then
        local hl = player.Character:FindFirstChild("MM2_ESP")
        local bb = player.Character:FindFirstChild("MM2_Name")
        if hl then hl:Destroy() end
        if bb then bb:Destroy() end
    end
end

task.spawn(function()
    while true do
        task.wait(0.5)
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local backpack = p:FindFirstChild("Backpack")
                local character = p.Character
                
                local isMurder = (backpack and backpack:FindFirstChild("Knife")) or character:FindFirstChild("Knife")
                local isSheriff = (backpack and backpack:FindFirstChild("Gun")) or character:FindFirstChild("Gun")
                
                if isMurder and _G.ESP_Murder then
                    createESP(p, Color3.fromRGB(255, 50, 50), "Murder")
                elseif isSheriff and _G.ESP_Sheriff then
                    createESP(p, Color3.fromRGB(50, 150, 255), "Sheriff")
                elseif not isMurder and not isSheriff and _G.ESP_Innocent then
                    createESP(p, Color3.fromRGB(150, 255, 150), "Innocent")
                else
                    removeESP(p)
                end
            end
        end
    end
end)


-- === СВЕРХБЫСТРЫЙ АИМ-БОТ ИЗ ВАРИАНТА 1 ===
local function getClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge
    for _, player in pairs(Players:GetPlayers()) do
        -- Моментальный поиск БЕЗ задержек на проверку ролей
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

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.R and _G.AimBot_Enabled then
        r_ToggleActive = not r_ToggleActive
        if not r_ToggleActive then
            lockedTarget = nil
        end
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 and r_ToggleActive and _G.AimBot_Enabled then
        pkm_Pressed = true
                    lockedTarget = getClosestPlayerToCursor()
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        pkm_Pressed = false
        lockedTarget = nil
    end
end)

RunService.RenderStepped:Connect(function()
    if not _G.AimBot_Enabled or not r_ToggleActive or not pkm_Pressed or not lockedTarget then return end
    
    local char = lockedTarget.Character
    if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
        local targetHRP = char.HumanoidRootPart
        
        -- Быстрый расчёт упреждения пистолета
        local distance = (targetHRP.Position - Camera.CFrame.Position).Magnitude
        local bulletSpeed = 230
        local timeToTarget = distance / bulletSpeed
        
        local bulletPredictionOffset = targetHRP.Velocity * timeToTarget
        local aimPosition = targetHRP.Position + bulletPredictionOffset
        
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, aimPosition)
    else
        lockedTarget = getClosestPlayerToCursor()
    end
end)
