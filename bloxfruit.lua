-- Blox Fruits WORKING Auto Farm + 1 Hit Kill (CodeX)
-- Fixed for all enemies, no dummy dependency

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Settings
local autoFarm = false
local oneHitKill = false
local autoCollect = false
local teleportBoss = false

-- GUI
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local dragHandle = Instance.new("TextLabel")
local farmBtn = Instance.new("TextButton")
local oneHitBtn = Instance.new("TextButton")
local collectBtn = Instance.new("TextButton")
local bossBtn = Instance.new("TextButton")

screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "BloxFruitFixed"

mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 200, 0, 220)
mainFrame.Position = UDim2.new(0.5, -100, 0.7, -110)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.3
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(1, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true

dragHandle.Parent = mainFrame
dragHandle.Size = UDim2.new(1, 0, 0, 30)
dragHandle.Text = "☠️ BLOX FRUIT WORKING ☠️"
dragHandle.TextColor3 = Color3.new(1, 0, 0)
dragHandle.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
dragHandle.TextScaled = true

local function createBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 180, 0, 35)
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

-- Get all enemies (dynamic)
local function getAllEnemies()
    local enemies = {}
    -- Check all folders that contain enemies
    local possibleFolders = {"Enemies", "Mobs", "Bosses", "NPCs", "Marines", "Pirates", "Animals"}
    for _, folderName in pairs(possibleFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and child ~= Character then
                    table.insert(enemies, child)
                end
            end
        end
    end
    -- Also check direct children of Workspace
    for _, child in pairs(Workspace:GetChildren()) do
        if child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and child ~= Character and not table.find(enemies, child) then
            table.insert(enemies, child)
        end
    end
    return enemies
end

-- 1 Hit Kill (works on all enemies)
local function killAll()
    if not oneHitKill then return end
    local enemies = getAllEnemies()
    for _, enemy in pairs(enemies) do
        if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            enemy.Humanoid.Health = 0
        end
    end
end

-- Auto Farm (attack nearest enemy)
local function farmLoop()
    if not autoFarm then return end
    local enemies = getAllEnemies()
    if #enemies == 0 then return end
    
    local nearest = nil
    local shortestDist = math.huge
    for _, enemy in pairs(enemies) do
        if enemy:FindFirstChild("HumanoidRootPart") then
            local dist = (enemy.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = enemy
            end
        end
    end
    
    if nearest and nearest.HumanoidRootPart then
        -- Teleport to enemy
        Character.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        wait(0.1)
        -- Attack
        local args = {
            [1] = "Tap",
            [2] = {}
        }
        ReplicatedStorage.Remotes.CommF_:FireServer(unpack(args))
        -- Alternative attack method
        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
        wait(0.05)
        game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
    end
end

-- Auto Collect
local function collectLoop()
    if not autoCollect then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and (v.Name:lower():find("fruit") or v.Name:lower():find("chest") or v.Name:lower():find("drop")) then
            local clickDetector = v:FindFirstChild("ClickDetector")
            if clickDetector and Character and Character:FindFirstChild("HumanoidRootPart") then
                local dist = (v:GetPivot().Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < 60 then
                    fireclickdetector(clickDetector)
                end
            end
        end
    end
end

-- Teleport to nearest boss
local function teleportLoop()
    if not teleportBoss then return end
    local bosses = {}
    local bossNames = {"Dragon", "Don Swan", "Magma", "Awakened Ice Admiral", "Darkbeard", "Cake Queen", "Dough King"}
    for _, name in pairs(bossNames) do
        local boss = Workspace:FindFirstChild(name)
        if boss and boss:FindFirstChild("HumanoidRootPart") then
            table.insert(bosses, boss)
        end
    end
    if #bosses > 0 then
        Character.HumanoidRootPart.CFrame = bosses[1].HumanoidRootPart.CFrame * CFrame.new(0, 5, 5)
    end
end

-- Main loop
spawn(function()
    while true do
        farmLoop()
        killAll()
        collectLoop()
        teleportLoop()
        wait(0.2)
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

-- Drag support
mainFrame.TouchMoved:Connect(function(touch)
    mainFrame.Position = mainFrame.Position + UDim2.new(0, touch.Delta.X, 0, touch.Delta.Y)
end)

print("WORKING script loaded. Drag top bar. Tap buttons to enable.")
