local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local config = {
    Enabled = true,
    FlickKey = Enum.KeyCode.C,
    FOV = 1500,
    Smoothness = 1,
    Prediction = 0.01,
    Hitbox = "Head",
    FlickDuration = 0.1,
    Cooldown = 0.2
}

local currentTarget = nil
local mouse = Players.LocalPlayer:GetMouse()
local lastFlickTime = 0

local function getClosestToMouse()
    if not config.Enabled then return nil end
    
    local closestPlayer, closestDistance = nil, config.FOV
    local localPlayer = Players.LocalPlayer
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local char = player.Character
            local targetPart = char:FindFirstChild(config.Hitbox) or char:FindFirstChild("HumanoidRootPart")
            
            if targetPart then
                local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local mouseDistance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if mouseDistance < closestDistance then
                        closestPlayer = player
                        closestDistance = mouseDistance
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

local function flickAndShoot()
    if not config.Enabled or tick() - lastFlickTime < config.Cooldown then return end
    
    currentTarget = getClosestToMouse()
    if currentTarget and currentTarget.Character then
        lastFlickTime = tick()
        
        local targetPart = currentTarget.Character:FindFirstChild(config.Hitbox)
        if targetPart then
            local targetPos = targetPart.Position + (targetPart.Velocity * config.Prediction)
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
            
            mouse1press()
            task.wait()
            mouse1release()
        end
        
        task.delay(config.FlickDuration, function()
            currentTarget = nil
        end)
    end
end

local ui = Instance.new("ScreenGui")
ui.Name = "FrostWare"
ui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 160, 0, 100)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.Parent = ui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 20)
title.Position = UDim2.new(0, 0, 0, 5)
title.Text = "FROSTWARE"
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextColor3 = Color3.fromRGB(100, 200, 255)
title.BackgroundTransparency = 1
title.Parent = frame

local divider = Instance.new("Frame")
divider.Size = UDim2.new(0.9, 0, 0, 1)
divider.Position = UDim2.new(0.05, 0, 0, 25)
divider.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
divider.BackgroundTransparency = 0.5
divider.BorderSizePixel = 0
divider.Parent = frame

local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0.9, 0, 0, 30)
toggle.Position = UDim2.new(0.05, 0, 0, 35)
toggle.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
toggle.Text = config.Enabled and "ACTIVE" or "INACTIVE"
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 12
toggle.TextColor3 = Color3.new(1, 1, 1)
toggle.ZIndex = 2
toggle.Parent = frame

local frostEffect = Instance.new("Frame")
frostEffect.Size = UDim2.new(1, 0, 1, 0)
frostEffect.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
frostEffect.BackgroundTransparency = 0.95
frostEffect.BorderSizePixel = 0
frostEffect.ZIndex = 1
frostEffect.Parent = toggle

local keybind = Instance.new("TextLabel")
keybind.Size = UDim2.new(1, 0, 0, 20)
keybind.Position = UDim2.new(0, 0, 0, 70)
keybind.Text = "BIND: [C]"
keybind.Font = Enum.Font.GothamMedium
keybind.TextSize = 12
keybind.TextColor3 = Color3.fromRGB(150, 220, 255)
keybind.BackgroundTransparency = 1
keybind.Parent = frame

toggle.MouseButton1Click:Connect(function()
    config.Enabled = not config.Enabled
    toggle.BackgroundColor3 = config.Enabled and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(50, 50, 60)
    toggle.Text = config.Enabled and "ACTIVE" or "INACTIVE"
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == config.FlickKey then
        flickAndShoot()
    end
end)
