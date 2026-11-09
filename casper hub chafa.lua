-- ============================================================
-- CASPER HUB NO PREMIUM (Xeno Compatible)
-- Enfoque: Auto Farm, Auto Skill, Auto Retry
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- CONFIGURACIÓN
local Config = {
    AutoFarm = false,
    FlySpeed = 600,
    FlyHeight = 230,
    AutoSkill = false,
    AutoRetry = false
}

-- CREAR INTERFAZ GRÁFICA NATIVA (Sin descargas)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CasperHubNoPremium"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 300)
MainFrame.Position = UDim2.new(0, 20, 0, 100)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
Title.Text = "CASPER Hub no premium"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15
Title.Parent = MainFrame
local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- Función para crear botones
local function CreateToggle(name, yPos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 210, 0, 35)
    Btn.Position = UDim2.new(0, 20, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Btn.Text = name .. ": OFF"
    Btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    Btn.Font = Enum.Font.GothamMedium
    Btn.TextSize = 13
    Btn.Parent = MainFrame
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 6)
    BtnCorner.Parent = Btn
    
    Btn.MouseButton1Click:Connect(function()
        if name == "Auto Farm" then
            Config.AutoFarm = not Config.AutoFarm
            Btn.Text = name .. ": " .. (Config.AutoFarm and "ON" or "OFF")
            Btn.BackgroundColor3 = Config.AutoFarm and Color3.fromRGB(46, 125, 80) or Color3.fromRGB(40, 40, 45)
        elseif name == "Auto Skill" then
            Config.AutoSkill = not Config.AutoSkill
            Btn.Text = name .. ": " .. (Config.AutoSkill and "ON" or "OFF")
            Btn.BackgroundColor3 = Config.AutoSkill and Color3.fromRGB(46, 125, 80) or Color3.fromRGB(40, 40, 45)
        elseif name == "Auto Retry" then
            Config.AutoRetry = not Config.AutoRetry
            Btn.Text = name .. ": " .. (Config.AutoRetry and "ON" or "OFF")
            Btn.BackgroundColor3 = Config.AutoRetry and Color3.fromRGB(46, 125, 80) or Color3.fromRGB(40, 40, 45)
        end
    end)
end

CreateToggle("Auto Farm", 50)
CreateToggle("Auto Skill", 95)
CreateToggle("Auto Retry", 140)

-- LÓGICA DEL AUTO FARM BÁSICO
local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetTitan()
    local titans = workspace:FindFirstChild("Titans")
    if not titans then return nil end
    local closest = nil
    local minDist = math.huge
    local myRoot = GetRoot()
    if not myRoot then return nil end
    
    for _, titan in ipairs(titans:GetChildren()) do
        if titan:IsA("Model") then
            local hum = titan:FindFirstChildOfClass("Humanoid")
            local nape = titan:FindFirstChild("Hitboxes") and titan.Hitboxes:FindFirstChild("Hit") and titan.Hitboxes.Hit:FindFirstChild("Nape")
            if hum and hum.Health > 0 and nape then
                local dist = (nape.Position - myRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = titan
                end
            end
        end
    end
    return closest
end

-- Bucle del Auto Farm
task.spawn(function()
    while task.wait() do
        if Config.AutoFarm then
            local root = GetRoot()
            local titan = GetTitan()
            if root and titan then
                local nape = titan.Hitboxes.Hit.Nape
                local targetPos = nape.Position + Vector3.new(0, Config.FlyHeight, 0)
                local dist = (targetPos - root.Position).Magnitude
                
                if dist > 5 then
                    -- Mover al titán
                    local dir = (targetPos - root.Position).Unit
                    root.CFrame = root.CFrame + dir * (Config.FlySpeed * RunService.Heartbeat:Wait())
                else
                    -- Atacar
                    pcall(function()
                        local post = game:GetService("ReplicatedStorage").Assets.Remotes.POST
                        post:FireServer("Attacks", "Slash", true)
                        post:FireServer("Hitboxes", "Register", nape, 143 + math.random()*10, 0.26 + math.random()*0.25)
                        post:FireServer("Attacks", "Slash", false)
                    end)
                end
            end
        end
    end
end)

-- Lógica del Auto Skill (Presiona 1, 2, 3, 4, 5)
task.spawn(function()
    while task.wait(1) do
        if Config.AutoSkill then
            local keys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four, Enum.KeyCode.Five}
            for _, key in ipairs(keys) do
                pcall(function()
                    VirtualInputManager:SendKeyEvent(true, key, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, key, false, game)
                end)
            end
        end
    end
end)

-- Lógica de Auto Retry (Busca el texto "MISSION COMPLETED" y hace clic)
task.spawn(function()
    while task.wait(1) do
        if Config.AutoRetry then
            for _, gui in ipairs(PlayerGui:GetDescendants()) do
                if (gui:IsA("TextLabel") or gui:IsA("TextButton")) and gui.Text == "MISSION COMPLETED" and gui.Visible then
                    local retryBtn = gui.Parent:FindFirstChild("Retry", true)
                    if retryBtn and retryBtn:IsA("GuiButton") then
                        pcall(function()
                            retryBtn:FireServer() -- Usando el método nativo de Xeno
                        end)
                    end
                    break
                end
            end
        end
    end
end)

print("[CASPER Hub no premium] Cargado correctamente. Interfaz nativa habilitada.")
