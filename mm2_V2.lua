PLAYER = game.Players.LocalPlayer
MOUSE = PLAYER:GetMouse()
CC = game.Workspace.CurrentCamera

_G.SHOW_MURDERER = true
_G.SHOW_SHERIFF = true
_G.SHOW_INNOCENTS = true
_G.AIM_ENABLED = true -- Это глобальный тумблер (включается на R)
AIM_LOCK = false -- Это зажим на ПРАВУЮ кнопку мыши
local TARGET = nil
_G.AIM_BIND = 'R'
local PREDICTION_COEF = 0.185
local AIM_SMOOTHNESS = 0.25

-- (Код создания GUI - пропущено для краткости)
if game.CoreGui:FindFirstChild("MM2_Menu") then game.CoreGui.MM2_Menu:Destroy() end
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "MM2_Menu"
-- ... (создание элементов интерфейса)

-- Функция определения роли и обновления ESP
function GetRole(player)
    if not player or not player:FindFirstChild("Backpack") or not player.Character then return "Innocent" end
    if player.Backpack:FindFirstChild("Knife") or player.Character:FindFirstChild("Knife") then return "Murderer" end
    if player.Backpack:FindFirstChild("Gun") or player.Character:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

function GetClosestPlayer()
    local closest = nil
    local shortestDist = math.huge
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= PLAYER and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local humanoid = v.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
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
    end
    return closest
end

function UPDATE_ESP(CHARACTER, PLAYER_OBJ)
    -- ... (логика ESP, обновление Highlights)
end -- ОБРАБОТКА НАЖАТИЙ КЛАВИШ И МЫШИ
game:GetService('UserInputService').InputBegan:Connect(function(i, g)
    if g then return end
    
    -- Кнопка R теперь включает/выключает сам АИМ чит полностью
    if i.KeyCode == Enum.KeyCode.R then
        _G.AIM_ENABLED = not _G.AIM_ENABLED
        if not _G.AIM_ENABLED then
            AIM_LOCK = false
            TARGET = nil
        end
    end
    
    -- Наведение работает ТОЛЬКО если _G.AIM_ENABLED равен true и зажата ПКМ
    if i.UserInputType == Enum.UserInputType.MouseButton2 and _G.AIM_ENABLED then
        AIM_LOCK = true
        TARGET = GetClosestPlayer()
    end
end)

game:GetService('UserInputService').InputEnded:Connect(function(i, g)
    -- Когда отпускаем Правую Кнопку Мыши — перестаем целиться
    if i.UserInputType == Enum.UserInputType.MouseButton2 then
        AIM_LOCK = false
        TARGET = nil
    end
end)

-- ГЛАВНЫЙ ЦИКЛ ОБНОВЛЕНИЯ
game:GetService('RunService').RenderStepped:Connect(function()
    for _, v in pairs(game.Players:GetPlayers()) do
        if v ~= PLAYER and v.Character and v.Character:FindFirstChild('Head') then
            UPDATE_ESP(v.Character, v)
        end
    end
    
    if AIM_LOCK and TARGET and TARGET.Character and TARGET.Character:FindFirstChild("HumanoidRootPart") then
        local root = TARGET.Character.HumanoidRootPart
        local predictedPosition = root.Position + (root.Velocity * PREDICTION_COEF)
        
        -- Актуальный CFrame
        local targetCFrame = CFrame.new(CC.CFrame.Position, predictedPosition)
        CC.CFrame = CC.CFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)
    end
end)
