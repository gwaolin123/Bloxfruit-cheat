-- Blox Fruits Mobile Optimized Script (CodeX Executor)
-- Drag menu with finger, toggle features by tapping

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Settings
local autoFarm = false
local oneHitKill = false
local autoCollect = false
local teleportBoss = false

-- Create draggable GUI
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local dragHandle = Instance.new("TextLabel")
local farmBtn = Instance.new("TextButton")
local oneHitBtn = Instance.new("TextButton")
local collectBtn = Instance.new("TextButton")
local bossBtn = Instance.new("TextButton")

screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "BloxFruitMobile"

mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 180, 0, 200)
mainFrame.Position = UDim2.new(0.5, -90, 0.7, -100)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(1, 0.5, 0)
mainFrame.Active = true
mainFrame.Draggable = true

dragHandle.Parent = mainFrame
dragHandle.Size = UDim2.new(1, 0, 0, 30)
dragHandle.Text = "☰ BLOX FRUIT (drag here)"
dragHandle.TextColor3 = Color3.new(1, 1, 0)
dragHandle.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
dragHandle.TextScaled = true

local function createBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 160, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    return btn
end

farmBtn = createBtn("⚔️ AUTO FARM: OFF", 40, Color3.new(0.2, 0.6, 0.2))
oneHitBtn = createBtn("💀 1 HIT KILL: OFF", 80, Color3.new(0.2, 0.6, 0.2))
collectBtn = createBtn("📦 AUTO COLLECT: OFF", 120, Color3.new(0.2, 0.6, 0.2))
bossBtn = createBtn("👑 TELEPORT BOSS: OFF", 160, Color3.new(0.2, 0.6, 0.2))

-- 1 Hit Kill
local function killAll()
    if not oneHitKill then return end
    for _, v in pairs(Workspace.Enemies:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            v.Humanoid.Health = 0
        end
    end
    for _, v in pairs(Workspace.Bosses:GetChildren()) do
        if v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
            v.Humanoid.Health = 0
        end
    end
end

-- Auto Farm (nearest enemy)
local function farmLoop()
    if not autoFarm then return end
    local enemy = Workspace.Enemies:FindFirstChild("Dummy") or Workspace.Enemies:FindFirstChild("Zombie") or Workspace.Enemies:FindFirstChild("Marine")
    if not enemy then return end
    if enemy and enemy:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = enemy.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        wait(0.1)
        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
        wait(0.05)
        game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
    end
end

-- Auto Collect
local function collectLoop()
    if not autoCollect then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if (v.Name == "Fruit" or v.Name == "Chest" or v.Name == "Drop") and v:FindFirstChild("ClickDetector") then
            if Character and Character:FindFirstChild("HumanoidRootPart") then
                local dist = (v.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < 50 then
                    fireclickdetector(v.ClickDetector)
                end
            end
        end
    end
end

-- Teleport to boss
local function teleportLoop()
    if not teleportBoss then return end
    local boss = Workspace.Bosses:FindFirstChild("Dragon") or Workspace.Bosses:FindFirstChild("Don Swan") or Workspace.Bosses:FindFirstChild("Magma")
    if boss and boss:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
    end
end

-- Main loop
spawn(function()
    while true do
        farmLoop()
        killAll()
        collectLoop()
        teleportLoop()
        wait(0.3)
    end
end)

-- Button toggles
farmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    farmBtn.Text = autoFarm and "⚔️ AUTO FARM: ON" or "⚔️ AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = autoFarm and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

oneHitBtn.MouseButton1Click:Connect(function()
    oneHitKill = not oneHitKill
    oneHitBtn.Text = oneHitKill and "💀 1 HIT KILL: ON" or "💀 1 HIT KILL: OFF"
    oneHitBtn.BackgroundColor3 = oneHitKill and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

collectBtn.MouseButton1Click:Connect(function()
    autoCollect = not autoCollect
    collectBtn.Text = autoCollect and "📦 AUTO COLLECT: ON" or "📦 AUTO COLLECT: OFF"
    collectBtn.BackgroundColor3 = autoCollect and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

bossBtn.MouseButton1Click:Connect(function()
    teleportBoss = not teleportBoss
    bossBtn.Text = teleportBoss and "👑 TELEPORT BOSS: ON" or "👑 TELEPORT BOSS: OFF"
    bossBtn.BackgroundColor3 = teleportBoss and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

-- Auto-detect mobile touch for dragging (already draggable via frame)
mainFrame.TouchMoved:Connect(function(touch)
    mainFrame.Position = mainFrame.Position + UDim2.new(0, touch.Delta.X, 0, touch.Delta.Y)
end)

print("Mobile script loaded. Drag the top bar to move menu. Tap buttons to toggle.")