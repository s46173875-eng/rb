PLAYER  = game.Players.LocalPlayer
MOUSE   = PLAYER:GetMouse()
CC      = game.Workspace.CurrentCamera

ENABLED      = false
ESP_ENABLED  = false

_G.FREE_FOR_ALL = true

_G.ESP_BIND    = ',' -- Клавиша "Б" на клавиатуре (запятая в английской раскладке)
_G.CHANGE_AIM  = 'm' -- Переключение головы/торса на английскую "M"
_G.AIM_AT = 'Head'

-- === НАСТРОЙКИ КРУГА FOV И ПЛАВНОСТИ ===
local FOV_RADIUS = 90 -- Небольшой аккуратный радиус круга
local FOV_COLOR = Color3.fromRGB(255, 255, 255) -- Белый цвет круга
local AIM_SMOOTHNESS = 0.15 -- Плавность наводки (чем меньше, тем мягче ведет)

-- Создаем визуальный круг FOV через библиотеку Drawing специально для Xeno
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
FOVCircle.Radius = FOV_RADIUS
FOVCircle.Color = FOV_COLOR
FOVCircle.Thickness = 1
FOVCircle.Filled = false
FOVCircle.Visible = true
FOVCircle.Transparency = 0.7 -- Слегка полупрозрачный, чтобы не мешал обзору

-- Постоянное центрирование круга при изменении разрешения экрана
CC:GetPropertyChangedSignal("ViewportSize"):Connect(function()
 FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
end)

wait(1)

-- Функция проверки, находится ли цель внутри белого круга FOV
function IsInFOV(position)
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

function GetNearestPlayerToMouse()
 local closestPlayer = false
 local shortestDistance = math.huge

 for _, v in pairs(game.Players:GetPlayers()) do
  if v ~= PLAYER and v.Character and v.Character:FindFirstChild(_G.AIM_AT) then
   if _G.FREE_FOR_ALL or v.TeamColor ~= PLAYER.TeamColor then
    local AIM = v.Character[_G.AIM_AT]
    local inFov, distToCenter = IsInFOV(AIM.Position)
    if inFov and distToCenter < shortestDistance then
     shortestDistance = distToCenter
     closestPlayer = v
    end
   end
  end
 end
 return closestPlayer
end

GUI_MAIN                           = Instance.new('ScreenGui', game.CoreGui)
GUI_TARGET                         = Instance.new('TextLabel', GUI_MAIN)
GUI_AIM_AT                         = Instance.new('TextLabel', GUI_MAIN)

GUI_MAIN.Name                      = 'AIMBOT'

GUI_TARGET.Size                    = UDim2.new(0,200,0,30)
GUI_TARGET.BackgroundTransparency  = 0.5
GUI_TARGET.BackgroundColor         = BrickColor.new('Fossil')
GUI_TARGET.BorderSizePixel         = 0
GUI_TARGET.Position                = UDim2.new(0.5,-100,0,0)
GUI_TARGET.Text                    = 'AIMBOT : OFF'
GUI_TARGET.TextColor3              = Color3.new(1,1,1)
GUI_TARGET.TextStrokeTransparency  = 1
GUI_TARGET.TextWrapped             = true
GUI_TARGET.FontSize                = 'Size24'
GUI_MAIN.ResetOnSpawn             = false
GUI_TARGET.Font                    = 'SourceSansBold'

GUI_AIM_AT.Size                    = UDim2.new(0,200,0,20)
GUI_AIM_AT.BackgroundTransparency  = 0.5
GUI_AIM_AT.BackgroundColor         = BrickColor.new('Fossil')
GUI_AIM_AT.BorderSizePixel         = 0
GUI_AIM_AT.Position                = UDim2.new(0.5,-100,0,30)
GUI_AIM_AT.Text                    = 'AIMING : HEAD'
GUI_AIM_AT.TextColor3              = Color3.new(1,1,1)
GUI_AIM_AT.TextStrokeTransparency  = 1
GUI_AIM_AT.TextWrapped             = true
GUI_AIM_AT.FontSize                = 'Size18'
GUI_AIM_AT.Font                    = 'SourceSansBold'

local TRACK = false

-- ФУНКЦИЯ ESP: АККУРАТНЫЙ КОНТУР И МАЛЕНЬКИЙ НИК
function CREATE(CHARACTER)
 if not CHARACTER then return end
 
 -- 1. Создаем красивую обводку (Highlight) вокруг тела
 if not CHARACTER:FindFirstChild('ESP_Highlight') then
  local Highlight = Instance.new('Highlight')
  Highlight.Name = 'ESP_Highlight'
  Highlight.Parent = CHARACTER
  Highlight.FillColor = Color3.fromRGB(255, 0, 0)      -- Красная заливка тела
  Highlight.FillTransparency = 0.6                     -- Полупрозрачная
  Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) -- Белый контур вокруг игрока
  Highlight.OutlineTransparency = 0                    -- Четкий контур
  Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop -- Видно сквозь стены
 end

 -- 2. Создаем маленький аккуратный ник над головой без красных квадратов
 local Head = CHARACTER:FindFirstChild('Head')
 if Head and not Head:FindFirstChild('ESP_Tag') then
  local BillboardGui = Instance.new('BillboardGui')
  BillboardGui.Name = 'ESP_Tag'
  BillboardGui.Parent = Head
  BillboardGui.AlwaysOnTop = true
  BillboardGui.Size = UDim2.new(0, 100, 0, 20)
  BillboardGui.ExtentsOffset = Vector3.new(0, 2.5, 0) -- Высота над головой
  
  local TextLabel = Instance.new('TextLabel')
  TextLabel.Parent = BillboardGui
  TextLabel.BackgroundTransparency = 1
  TextLabel.Size = UDim2.new(1, 0, 10, 0)
  TextLabel.Text = CHARACTER.Name:upper()
  TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255) -- Белый цвет текста
  TextLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0) -- Черная обводка букв, чтобы читалось везде
  TextLabel.TextStrokeTransparency = 0
  TextLabel.FontSize = Enum.FontSize.Size10             -- Сделали ник маленьким
  TextLabel.Font = Enum.Font.SourceSansBold
 end
end

function CLEAR()
 for _, v in pairs(game.Players:GetPlayers()) do
  if v.Character then
   local highlight = v.Character:FindFirstChild('ESP_Highlight')
   if highlight then highlight:Destroy() end
   
   local head = v.Character:FindFirstChild('Head')
   if head then
    local tag = head:FindFirstChild('ESP_Tag')
    if tag then tag:Destroy() end
   end
  end
 end
end

function FIND()
 CLEAR()
 TRACK = true
 spawn(function()
  while wait(0.1) do -- Оптимизированная частота обновления
   if TRACK then
    for i, v in pairs(game.Players:GetChildren()) do
     if v ~= PLAYER and v.Character and v.Character:FindFirstChild('Head') then
      if _G.FREE_FOR_ALL == false then
       if v.TeamColor ~= PLAYER.TeamColor then
        CREATE(v.Character)
       end
      else
       CREATE(v.Character)
      end
     end
    end
   end
  end
 end)
end

MOUSE.Button2Down:connect(function()
 ENABLED = true
end)

MOUSE.Button2Up:connect(function()
 ENABLED = false
end)

MOUSE.KeyDown:connect(function(KEY)
 KEY = KEY:lower()
 if KEY == _G.ESP_BIND then
  if ESP_ENABLED == false then
   FIND()
   ESP_ENABLED = true
   print('ESP : ON')
  elseif ESP_ENABLED == true then
   wait()
   CLEAR()
   TRACK = false
   ESP_ENABLED = false
   print('ESP : OFF')
  end
 end
end)

MOUSE.KeyDown:connect(function(KEY)
 KEY = KEY:lower()
 if KEY == _G.CHANGE_AIM then
  if _G.AIM_AT == 'Head' then
   _G.AIM_AT = 'Torso'
   GUI_AIM_AT.Text = 'AIMING : TORSO'
  elseif _G.AIM_AT == 'Torso' then
   _G.AIM_AT = 'Head'
   GUI_AIM_AT.Text = 'AIMING : HEAD'
  end
 end
end)

game:GetService('RunService').RenderStepped:connect(function()
 FOVCircle.Position = Vector2.new(CC.ViewportSize.X / 2, CC.ViewportSize.Y / 2)
 
 if ENABLED then
  local TARGET = GetNearestPlayerToMouse()
  if (TARGET) then
   local AIM = TARGET.Character:FindFirstChild(_G.AIM_AT)
   if AIM then
    -- Плавная доводка камеры (Lerp) вместо резких рывков
    local targetCFrame = CFrame.new(CC.CoordinateFrame.p, AIM.CFrame.p)
    CC.CoordinateFrame = CC.CoordinateFrame:Lerp(targetCFrame, AIM_SMOOTHNESS)
   end
   GUI_TARGET.Text = 'AIMBOT : '.. TARGET.Name:sub(1, 5)
  else
   GUI_TARGET.Text = 'AIMBOT : OFF'
  end
 end
end)

repeat
 wait()
 if ESP_ENABLED == true then
  FIND()
 end
until ESP_ENABLED == false
