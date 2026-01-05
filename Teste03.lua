-- Carregando a biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- [[ CONFIGURAÇÃO E VARIÁVEIS ]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Config = {
    Aimbot = false,
    ESP = false,
    FOV = 150,
    CircleVisible = false
}

-- [[ CÍRCULO DE FOV ]]
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

-- [[ JANELA PRINCIPAL RAYFIELD ]]
local Window = Rayfield:CreateWindow({
   Name = "KA Hub | Premium Edition",
   LoadingTitle = "Carregando Interface...",
   LoadingSubtitle = "by Sirius",
   ConfigurationSaving = { Enabled = true, FolderName = "KA_Hub_Config", FileName = "Config" },
   KeySystem = true, 
   KeySettings = {
      Title = "Sistema de Chave",
      Subtitle = "Acesse o Hub",
      Note = "A chave é: hub",
      Key = {"hub"} 
   }
})

local MainTab = Window:CreateTab("Combate", 4483362458) -- Ícone de alvo

-- [[ ELEMENTOS DA INTERFACE ]]

MainTab:CreateToggle({
   Name = "Ativar Aimbot",
   CurrentValue = false,
   Callback = function(Value)
      Config.Aimbot = Value
   end,
})

MainTab:CreateToggle({
   Name = "Mostrar Círculo FOV",
   CurrentValue = false,
   Callback = function(Value)
      Config.CircleVisible = Value
      FOVCircle.Visible = Value
   end,
})

MainTab:CreateSlider({
   Name = "Raio do FOV",
   Range = {50, 800},
   Increment = 10,
   Suffix = "px",
   CurrentValue = 150,
   Callback = function(Value)
      Config.FOV = Value
      FOVCircle.Radius = Value
   end,
})

local VisualTab = Window:CreateTab("Visuais", 4483362458)

VisualTab:CreateToggle({
   Name = "Ativar ESP (Highlights)",
   CurrentValue = false,
   Callback = function(Value)
      Config.ESP = Value
      if not Value then
          -- Limpa o ESP quando desligar
          for _, player in pairs(Players:GetPlayers()) do
              if player.Character and player.Character:FindFirstChild("ESPHighlight") then
                  player.Character.ESPHighlight:Destroy()
              end
          end
      end
   end,
})

-- [[ LÓGICA DO AIMBOT ]]
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = Config.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Verifica se o jogador está vivo (opcional, dependendo do jogo)
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    target = player
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- [[ LÓGICA DO ESP ]]
local function UpdateESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("ESPHighlight")
            if Config.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ESPHighlight"
                    highlight.Parent = player.Character
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end

-- [[ LOOP PRINCIPAL (RENDERSTEPPED) ]]
RunService.RenderStepped:Connect(function()
    -- Atualiza Círculo
    FOVCircle.Position = UserInputService:GetMouseLocation()
    
    -- Executa Aimbot
    if Config.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            -- Suavização leve pode ser adicionada aqui
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
    
    -- Executa ESP
    UpdateESP()
end)

Rayfield:Notify({
   Title = "Script Ativado",
   Content = "KA Hub carregado com sucesso!",
   Duration = 5,
   Image = 4483362458,
})
