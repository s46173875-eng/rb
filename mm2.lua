PLAYER = game.Players.LocalPlayer
MOUSE = PLAYER:GetMouse()
CC = game.Workspace.CurrentCamera

_G.SHOW_MURDERER = true
_G.SHOW_SHERIFF = true
_G.SHOW_INNOCENTS = true
_G.AIM_ENABLED = true

AIM_LOCK = false
local TARGET = nil
_G.AIM_BIND = 'r'

local PREDICTION_COEF = 0.185
local AIM_SMOOTHNESS = 0.25

if game.CoreGui:FindFirstChild("MM2_Menu") then
    game.CoreGui.MM2_Menu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MM2_Menu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 310)
MainFrame.Position = UDim2.new(0, 30, 0.4, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local MainCorner = Instance.new("UICorner", MainFrame)
MainCorner.CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.FontSize = Enum.FontSize.Size18

local MiniFrame = Instance.new("TextButton", ScreenGui)
MiniFrame.Size = UDim2.new(0, 45, 0, 45)
MiniFrame.Position = UDim2.new(0, 30, 0.4, -22)
MiniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MiniFrame.BorderSizePixel = 0
MiniFrame.Text = "GUI"
MiniFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniFrame.Font = Enum.Font.SourceSansBold
MiniFrame.FontSize = Enum.FontSize.Size14
MiniFrame.Visible = false
MiniFrame.Active = true
MiniFrame.Draggable = true

local MiniCorner = Instance.new("UICorner", MiniFrame)
MiniCorner.CornerRadius = UDim.new(0, 6)

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    MiniFrame.Position = UDim2.new(0, MainFrame.AbsolutePosition.X, 0, MainFrame.AbsolutePosition.Y)
    MiniFrame.Visible = true
end)

MiniFrame.MouseButton1Click:Connect(function()
    MiniFrame.Visible = false
    MainFrame.Position = UDim2.new(0, MiniFrame.AbsolutePosition.X, 0, MiniFrame.AbsolutePosition.Y)
    MainFrame.Visible = true
end)

local EspTitle = Instance.new("TextLabel", MainFrame)
EspTitle.Size = UDim2.new(1, 0, 0, 30)
EspTitle.Position = UDim2.new(0, 15, 0, 10)
EspTitle.BackgroundTransparency = 1
EspTitle.Text = "ESP"
EspTitle.TextColor3 = Color3.fromRGB(255, 180, 0)
EspTitle.Font = Enum.Font.SourceSansBold
EspTitle.FontSize = Enum.FontSize.Size18
EspTitle.TextXAlignment = Enum.TextXAlignment.Left

local function CreateToggle(text, pos, state_var, color)
    local LabelBtn = Instance.new("TextButton", MainFrame)
    LabelBtn.Size = UDim2.new(1, -30, 0, 25)
    LabelBtn.Position = pos
    LabelBtn.BackgroundTransparency = 1
    LabelBtn.Font = Enum.Font.SourceSansBold
    LabelBtn.FontSize = Enum.FontSize.Size18
    LabelBtn.TextXAlignment = Enum.TextXAlignment.Left
    
    local function refresh()
        if _G[state_var] then
            LabelBtn.Text = text .. " - ✅"
            LabelBtn.TextColor3 = color
        else
            LabelBtn.Text = text .. " - ❌"
            LabelBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
        end
    end
    
    refresh()
    LabelBtn.MouseButton1Click:Connect(function()
        _G[state_var] = not _G[state_var]
        refresh()
    end)
end

CreateToggle("Убийца", UDim2.new(0, 15, 0, 45), "SHOW_MURDERER", Color3.fromRGB(255, 50, 50))
CreateToggle("Шериф", UDim2.new(0, 15, 0, 75), "SHOW_SHERIFF", Color3.fromRGB(50, 150, 255))
CreateToggle("Невинный", UDim2.new(0, 15, 0, 105), "SHOW_INNOCENTS", Color3.fromRGB(50, 255, 50))

local Line = Instance.new("TextLabel", MainFrame)
Line.Size = UDim2.new(1, -30, 0, 15)
Line.Position = UDim2.new(0, 15, 0, 140)
Line.BackgroundTransparency = 1
Line.Text = "------------------------"
Line.TextColor3 = Color3.fromRGB(255, 50, 50)
Line.Font = Enum.Font.SourceSansBold
Line.FontSize = Enum.FontSize.Size14

local AimTitle = Instance.new("TextLabel", MainFrame)
AimTitle.Size = UDim2.new(1, 0, 0, 30)
AimTitle.Position = UDim2.new(0, 15, 0, 165)
AimTitle.BackgroundTransparency = 1
AimTitle.Text = "AIM-BOT"
AimTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
AimTitle.Font = Enum.Font.SourceSansBold
AimTitle.FontSize = Enum.FontSize.Size18
AimTitle.TextXAlignment = Enum.TextXAlignment.Left

CreateToggle("AIM [".._G.AIM_BIND:upper().."]", UDim2.new(0, 15, 0, 200), "AIM_ENABLED", Color3.fromRGB(255, 80, 80))

local RefreshBtn = Instance.new("TextButton", MainFrame)
RefreshBtn.Size = UDim2.new(1, -30, 0, 35)
RefreshBtn.Position = UDim2.new(0, 15, 1, -45)
RefreshBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
RefreshBtn.Text = "ОБНОВИТЬ СКРИПТ 🔄"
RefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
RefreshBtn.Font = Enum.Font.SourceSansBold
RefreshBtn.FontSize = Enum.FontSize.Size14
RefreshBtn.BorderSizePixel = 0

local RefCorner = Instance.new("UICorner", RefreshBtn)
RefCorner.CornerRadius = UDim.new(0, 4)

RefreshBtn.MouseButton1Click:Connect(function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v.Character then
            if v.Character:FindFirstChild('ESP_Highlight') then v.Character.ESP_Highlight:Destroy() end
            if v.Character:FindFirstChild('Head') and v.Character.Head:FindFirstChild('ESP_Tag') then v.Character.Head.ESP_Tag:Destroy() end
        end
    end
    ScreenGui:Destroy()
    local H = string.char(104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47)
    loadstring(game:HttpGet(H .. "s46173875-eng/rb/main/mm2.lua"))()
end)
local function GetRole(player)
    if not player or not player:FindFirstChild("Backpack") or not player.Character then return "Innocent" end
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then return "Murderer" end
    if player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

function GetClosestPlayer()
 if not _G.AIM_ENABLED then return nil end
 local closest = nil
 local shortestDist = math.huge
 for _, v in pairs(game.Players:GetPlayers()) do
  if v ~= PLAYER and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
   local pos, onScreen = CC:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
   if onScreen then
    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(MOUSE.X, MOUSE.Y)).Magnitude
    if dist < shortestDist then
     shortestDist = dist
     closest = v
    end
   end
  end
 end
 return closest
end

function UPDATE_ESP(CHARACTER, PLAYER_OBJ)
 if not CHARACTER or not PLAYER_OBJ then return end
 local role = GetRole(PLAYER_OBJ)
 
 local shouldShow = false
 if role == "Murderer" and _G.SHOW_MURDERER then shouldShow = true
 elseif role == "Sheriff" and _G.SHOW_SHERIFF then shouldShow = true
 elseif role == "Innocent" and _G.SHOW_INNOCENTS then shouldShow = true end

 if not shouldShow then
  if CHARACTER:FindFirstChild('ESP_Highlight') then CHARACTER.ESP_Highlight:Destroy() end
  if CHARACTER:FindFirstChild('Head') and CHARACTER.Head:FindFirstChild('ESP_Tag') then CHARACTER.Head.ESP_Tag:Destroy() end
  return
 end

 if not CHARACTER:FindFirstChild('ESP_Highlight') then
  local Highlight = Instance.new('Highlight', CHARACTER)
  Highlight.Name = 'ESP_Highlight'
  Highlight.FillTransparency = 0.6
  Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
  Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
 end

 local Head = CHARACTER:FindFirstChild('Head')
 if Head and not Head:FindFirstChild('ESP_Tag') then
  local BillboardGui = Instance.new('BillboardGui', Head)
  BillboardGui.Name = 'ESP_Tag'
  BillboardGui.AlwaysOnTop = true
  BillboardGui.Size = UDim2.new(0, 200, 0, 20)
  BillboardGui.ExtentsOffset = Vector3.new(0, 2.5, 0)
  
  local TextLabel = Instance.new('TextLabel', BillboardGui)
  TextLabel.BackgroundTransparency = 1
  TextLabel.Size = UDim2.new(1, 0, 1, 0)
  TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
  TextLabel.TextStrokeTransparency = 0
  TextLabel.FontSize = Enum.FontSize.Size10
  TextLabel.Font = Enum.Font.SourceSansBold
 end

 local highlight = CHARACTER:FindFirstChild('ESP_Highlight')
 local tag = Head and Head:FindFirstChild('ESP_Tag')
 local textLabel = tag and tag:FindFirstChildOfClass("TextLabel")
 
 if highlight and textLabel then
     if role == "Murderer" then
         highlight.FillColor = Color3.fromRGB(255, 0, 0)
         textLabel.Text = PLAYER_OBJ.Name:upper() .. " [УБИЙЦА 🔪]"
         textLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
     elseif role == "Sheriff" then
         highlight.FillColor = Color3.fromRGB(0, 0, 255)
         textLabel.Text = PLAYER_OBJ.Name:upper() .. " [ШЕРИФ ︻╦╤─]"
         textLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
     else
         highlight.FillColor = Color3.fromRGB(0, 255, 0)
         textLabel.Text = PLAYER_OBJ.Name:upper() .. " [МИРНЫЙ 👤]"
         textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
     end
 end
end

local AIM_READY = false 

game:GetService('UserInputService').InputBegan:Connect(function(i, g)
    if g then return end
    
    -- Кнопка R: Включает или выключает готовность аима
    if i.KeyCode == Enum.KeyCode.R then
        AIM_READY = not AIM_READY
        if not AIM_READY then
            AIM_LOCK = false
            TARGET = nil
        end
    end
    
    -- Правая кнопка мыши: Захватывает ближайшего игрока, если активирован режим R
    if i.UserInputType == Enum.UserInputType.MouseButton2 and AIM_READY then
        AIM_LOCK = true
        TARGET = GetClosestPlayer()
    end
end)

game:GetService('UserInputService').InputEnded:Connect(function(i, g)
    if g then return end
    
    -- Отпускание правой кнопки мыши: Сбрасывает прицеливание
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        AIM_LOCK = false
        TARGET = nil
    end
end)

game:GetService('RunService').RenderStepped:Connect(function()
  for _, v in pairs(game.Players:GetPlayers()) do
   if v ~= PLAYER and v.Character and v.Character:FindFirstChild('Head') then
     UPDATE_ESP(v.Character, v)
    end
  end
 
 if AIM_LOCK and TARGET and TARGET.Character and TARGET.Character:FindFirstChild("HumanoidRootPart") then
  local root = TARGET.Character.HumanoidRootPart
  local predictedPosition = root.Position + (root.Velocity * PREDICTION_COEF)
  local targetCFrame = CFrame.new(CC.CoordinateFrame.p, predictedPosition)
  CC.CoordinateFrame = CC.CoordinateFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)
 end
end)
