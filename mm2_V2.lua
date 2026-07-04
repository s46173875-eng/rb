local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local VirtualInputManager = game:GetService("VirtualInputManager")

local PLAYER = Players.LocalPlayer
local MOUSE = PLAYER:GetMouse()
local CC = game.Workspace.CurrentCamera

_G.SHOW_MURDERER = false
_G.SHOW_SHERIFF = false
_G.SHOW_INNOCENTS = false
_G.AIM_ENABLED = false
_G.MOBILE_SHOOT_GUI = false

local AIM_LOCK = false
local TARGET = nil
_G.AIM_BIND = 'r'
local PREDICTION_COEF = 0.215
local AIM_SMOOTHNESS = 0.25

if CoreGui:FindFirstChild("MM2_Menu") then
    CoreGui.MM2_Menu:Destroy()
end

local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MM2_Menu"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 360, 0, 255)
MainFrame.Position = UDim2.new(0.5, -180, 0.4, -127)
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
CloseBtn.TextSize = 18

local MiniFrame = Instance.new("TextButton", ScreenGui)
MiniFrame.Size = UDim2.new(0, 45, 0, 45)
MiniFrame.Position = UDim2.new(0.5, -22, 0.4, -22)
MiniFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MiniFrame.BorderSizePixel = 0
MiniFrame.Text = "GUI"
MiniFrame.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniFrame.Font = Enum.Font.SourceSansBold
MiniFrame.TextSize = 14
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

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(0, 100, 1, -35)
TabContainer.Position = UDim2.new(0, 5, 0, 5)
TabContainer.BackgroundTransparency = 1

local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -115, 1, -35)
PagesContainer.Position = UDim2.new(0, 110, 0, 5)
PagesContainer.BackgroundTransparency = 1

local EspPage = Instance.new("Frame", PagesContainer)
EspPage.Size = UDim2.new(1, 0, 1, 0)
EspPage.BackgroundTransparency = 1
EspPage.Visible = true

local AimPage = Instance.new("Frame", PagesContainer)
AimPage.Size = UDim2.new(1, 0, 1, 0)
AimPage.BackgroundTransparency = 1
AimPage.Visible = false

local MiscPage = Instance.new("Frame", PagesContainer)
MiscPage.Size = UDim2.new(1, 0, 1, 0)
MiscPage.BackgroundTransparency = 1
MiscPage.Visible = false

local TgcLabel = Instance.new("TextLabel", MainFrame)
TgcLabel.Size = UDim2.new(1, -10, 0, 20)
TgcLabel.Position = UDim2.new(0, 5, 1, -22)
TgcLabel.BackgroundTransparency = 1
TgcLabel.Text = "TGK: VNMA_OFFICIAL"
TgcLabel.TextColor3 = Color3.fromRGB(0, 200, 255)
TgcLabel.Font = Enum.Font.SourceSansBold
TgcLabel.TextSize = 13
TgcLabel.TextXAlignment = Enum.TextXAlignment.Center
local function SwitchTab(pageToShow)
    EspPage.Visible = false
    AimPage.Visible = false
    MiscPage.Visible = false
    pageToShow.Visible = true
end

local function CreateTabBtn(text, pos, page)
    local TabBtn = Instance.new("TextButton", TabContainer)
    TabBtn.Size = UDim2.new(1, 0, 0, 35)
    TabBtn.Position = pos
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TabBtn.Text = text
    TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabBtn.Font = Enum.Font.SourceSansBold
    TabBtn.TextSize = 13
    local corner = Instance.new("UICorner", TabBtn)
    corner.CornerRadius = UDim.new(0, 4)
    TabBtn.MouseButton1Click:Connect(function()
        SwitchTab(page)
    end)
    return TabBtn
end

local EspTab = CreateTabBtn("ESP", UDim2.new(0, 0, 0, 10), EspPage)
local AimTab = CreateTabBtn("AIM BOT", UDim2.new(0, 0, 0, 50), AimPage)
local MiscTab = CreateTabBtn("РАЗНОЕ", UDim2.new(0, 0, 0, 90), MiscPage)

local function CreatePageTitle(text, parent)
    local Title = Instance.new("TextLabel", parent)
    Title.Size = UDim2.new(1, 0, 0, 25)
    Title.Position = UDim2.new(0, 0, 0, 5)
    Title.BackgroundTransparency = 1
    Title.Text = text
    Title.TextColor3 = Color3.fromRGB(255, 180, 0)
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 15
    Title.TextXAlignment = Enum.TextXAlignment.Left
end

CreatePageTitle("ВИЗУАЛЬНЫЕ НАСТРОЙКИ", EspPage)
CreatePageTitle("НАСТРОЙКИ АИМБОТА", AimPage)
CreatePageTitle("ДОПОЛНИТЕЛЬНО", MiscPage)

local ToggleLabels = {}
local function CreateToggle(text, pos, state_var, color, parentPage)
    local LabelBtn = Instance.new("TextButton", parentPage)
    LabelBtn.Size = UDim2.new(1, 0, 0, 25)
    LabelBtn.Position = pos
    LabelBtn.BackgroundTransparency = 1
    LabelBtn.Font = Enum.Font.SourceSansBold
    LabelBtn.TextSize = 15
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
    ToggleLabels[state_var] = refresh
    LabelBtn.MouseButton1Click:Connect(function()
        _G[state_var] = not _G[state_var]
        refresh()
    end)
end

CreateToggle("Убийца", UDim2.new(0, 0, 0, 35), "SHOW_MURDERER", Color3.fromRGB(255, 50, 50), EspPage)
CreateToggle("Шериф", UDim2.new(0, 0, 0, 65), "SHOW_SHERIFF", Color3.fromRGB(50, 150, 255), EspPage)
CreateToggle("Невинный", UDim2.new(0, 0, 0, 95), "SHOW_INNOCENTS", Color3.fromRGB(50, 255, 50), EspPage)

CreateToggle("Активировать AIM [".._G.AIM_BIND:upper().."]", UDim2.new(0, 0, 0, 35), "AIM_ENABLED", Color3.fromRGB(255, 80, 80), AimPage)
CreateToggle("Кнопка стрельбы (Мобилки)", UDim2.new(0, 0, 0, 75), "MOBILE_SHOOT_GUI", Color3.fromRGB(0, 200, 255), AimPage)

local MobileShootBtn = Instance.new("TextButton", ScreenGui)
MobileShootBtn.Name = "MobileShootButton"
MobileShootBtn.Size = UDim2.new(0, 65, 0, 65)
MobileShootBtn.Position = UDim2.new(0.75, 0, 0.5, 0)
MobileShootBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
MobileShootBtn.BackgroundTransparency = 0.3
MobileShootBtn.Text = "🔥"
MobileShootBtn.TextSize = 28
MobileShootBtn.TextColor3 = Color3.new(1, 1, 1)
MobileShootBtn.Font = Enum.Font.SourceSansBold
MobileShootBtn.Visible = false
MobileShootBtn.Active = true
MobileShootBtn.Draggable = true

local ShootCorner = Instance.new("UICorner", MobileShootBtn)
ShootCorner.CornerRadius = UDim.new(1, 0)

local ShootStroke = Instance.new("UIStroke", MobileShootBtn)
ShootStroke.Color = Color3.new(1, 1, 1)
ShootStroke.Thickness = 2

task.spawn(function()
    while true do
        if MobileShootBtn.Visible ~= _G.MOBILE_SHOOT_GUI then
            MobileShootBtn.Visible = _G.MOBILE_SHOOT_GUI
        end
        task.wait(0.2)
    end
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
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= PLAYER and v.Character and v.Character:FindFirstChild("Head") then
            local pos, onScreen = CC:WorldToViewportPoint(v.Character.Head.Position)
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
        BillboardGui.Size = UDim2.new(0, 200, 0, 30)
        BillboardGui.ExtentsOffset = Vector3.new(0, 3.5, 0)
        
        local TextLabel = Instance.new('TextLabel', BillboardGui)
        TextLabel.BackgroundTransparency = 1
        TextLabel.Size = UDim2.new(1, 0, 1, 0)
        TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        TextLabel.TextStrokeTransparency = 0
        TextLabel.TextSize = 13
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
local function TriggerAutoShoot()
    if not _G.AIM_ENABLED then return end
    local currentTarget = GetClosestPlayer()
    if currentTarget and currentTarget.Character and currentTarget.Character:FindFirstChild("HumanoidRootPart") then
        local bodyPart = currentTarget.Character.HumanoidRootPart
        local predictedPosition = bodyPart.Position + (bodyPart.Velocity * PREDICTION_COEF)
        CC.CFrame = CFrame.new(CC.CFrame.Position, predictedPosition)
        task.wait()
        local x = CC.ViewportSize.X / 2
        local y = CC.ViewportSize.Y / 2
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        task.wait(0.05)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end
end

MobileShootBtn.MouseButton1Click:Connect(TriggerAutoShoot)

UserInputService.InputBegan:Connect(function(i, g)
    if g then return end
    if i.KeyCode == Enum.KeyCode.R then
        _G.AIM_ENABLED = not _G.AIM_ENABLED
        if ToggleLabels["AIM_ENABLED"] then
            ToggleLabels["AIM_ENABLED"]()
        end
        if not _G.AIM_ENABLED then
            AIM_LOCK = false
            TARGET = nil
        end
    end
    if i.UserInputType == Enum.UserInputType.MouseButton2 and _G.AIM_ENABLED then
        AIM_LOCK = true
        TARGET = GetClosestPlayer()
    end
end)

UserInputService.InputEnded:Connect(function(i, g)
    if g then return end
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        AIM_LOCK = false
        TARGET = nil
    end
end)

GunDropBtn.MouseButton1Click:Connect(TeleportToGunAndBack)
UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Enum.KeyCode.T then TeleportToGunAndBack() end
end)


RefreshBtn.MouseButton1Click:Connect(function()
    
    loadstring(game:HttpGet("https://githubusercontent.com"))()
end)
