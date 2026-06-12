-- ULTIMATE BLOX FRUIT SCRIPT - FULLY WORKING (CodeX)
-- Auto Farm, 1 Hit Kill, Auto Collect, Teleport Boss, Fast Attack, No Clip

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Settings
local autoFarm = false
local oneHitKill = false
local autoCollect = false
local teleportBoss = false
local fastAttack = false
local noClip = false

-- GUI
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local dragHandle = Instance.new("TextLabel")
local farmBtn = Instance.new("TextButton")
local oneHitBtn = Instance.new("TextButton")
local collectBtn = Instance.new("TextButton")
local bossBtn = Instance.new("TextButton")
local fastBtn = Instance.new("TextButton")
local noclipBtn = Instance.new("TextButton")

screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "BloxFruitUltimate"

mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 220, 0, 320)
mainFrame.Position = UDim2.new(0.5, -110, 0.6, -160)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 3
mainFrame.BorderColor3 = Color3.new(1, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true

dragHandle.Parent = mainFrame
dragHandle.Size = UDim2.new(1, 0, 0, 35)
dragHandle.Text = "🔥 BLOX FRUIT ULTIMATE 🔥"
dragHandle.TextColor3 = Color3.new(1, 0.5, 0)
dragHandle.BackgroundColor3 = Color3.new(0.2, 0, 0)
dragHandle.TextScaled = true

local function createBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 200, 0, 38)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.new(1, 1, 0)
    return btn
end

farmBtn = createBtn("⚔️ AUTO FARM: OFF", 45, Color3.new(0.2, 0.6, 0.2))
oneHitBtn = createBtn("💀 1 HIT KILL: OFF", 90, Color3.new(0.2, 0.6, 0.2))
collectBtn = createBtn("📦 AUTO COLLECT: OFF", 135, Color3.new(0.2, 0.6, 0.2))
bossBtn = createBtn("👑 TELEPORT BOSS: OFF", 180, Color3.new(0.2, 0.6, 0.2))
fastBtn = createBtn("⚡ FAST ATTACK: OFF", 225, Color3.new(0.2, 0.6, 0.2))
noclipBtn = createBtn("🌀 NO CLIP: OFF", 270, Color3.new(0.2, 0.6, 0.2))

-- Get all enemies (better detection)
local function getAllEnemies()
    local enemies = {}
    local searchFolders = {"Enemies", "Mobs", "Bosses", "NPCs", "Marines", "Pirates", "Animals", "Island"}
    for _, folderName in pairs(searchFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and child:FindFirstChild("HumanoidRootPart") then
                    if child ~= Character and not child:IsDescendantOf(Character) then
                        table.insert(enemies, child)
                    end
                end
            end
        end
    end
    for _, child in pairs(Workspace:GetChildren()) do
        if child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and child:FindFirstChild("HumanoidRootPart") then
            if child ~= Character and not child:IsDescendantOf(Character) then
                local found = false
                for _, e in pairs(enemies) do
                    if e == child then found = true break end
                end
                if not found then
                    table.insert(enemies, child)
                end
            end
        end
    end
    return enemies
end

-- 1 Hit Kill (instant kill all enemies)
local function killAll()
    if not oneHitKill then return end
    local enemies = getAllEnemies()
    for _, enemy in pairs(enemies) do
        if enemy and enemy:FindFirstChild("Humanoid") and enemy.Humanoid.Health > 0 then
            enemy.Humanoid.Health = 0
        end
    end
end

-- Auto Farm (teleport + attack)
local function farmLoop()
    if not autoFarm then return end
    local enemies = getAllEnemies()
    if #enemies == 0 then return end
    
    local nearest = nil
    local shortestDist = math.huge
    for _, enemy in pairs(enemies) do
        local root = enemy:FindFirstChild("HumanoidRootPart")
        if root and Character and Character:FindFirstChild("HumanoidRootPart") then
            local dist = (root.Position - Character.HumanoidRootPart.Position).Magnitude
            if dist < shortestDist then
                shortestDist = dist
                nearest = enemy
            end
        end
    end
    
    if nearest and nearest.HumanoidRootPart then
        -- Teleport to enemy
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        end
        wait(0.05)
        -- Attack methods
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            wait(0.02)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:FireServer("Tap")
        end)
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:FireServer("Click")
        end)
    end
end

-- Fast Attack (no cooldown)
local function fastAttackLoop()
    if not fastAttack then return end
    pcall(function()
        local args = {[1] = "KenHaki", [2] = {}}
        ReplicatedStorage.Remotes.CommF_:FireServer(unpack(args))
        ReplicatedStorage.Remotes.CommF_:FireServer("FlashStep")
    end)
end

-- Auto Collect items
local function collectLoop()
    if not autoCollect then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("fruit") or name:find("chest") or name:find("drop") or name:find("beli") or name:find("material") then
                local cd = v:FindFirstChild("ClickDetector")
                if cd and Character and Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (v:GetPivot().Position - Character.HumanoidRootPart.Position).Magnitude
                    if dist < 80 then
                        fireclickdetector(cd)
                        wait(0.05)
                    end
                end
            end
        end
    end
end

-- Teleport to boss
local function teleportLoop()
    if not teleportBoss then return end
    local bossNames = {"Dragon", "Don Swan", "Magma", "Awakened Ice Admiral", "Darkbeard", "Cake Queen", "Dough King", "Rip_indra", "Stone"}
    for _, name in pairs(bossNames) do
        local boss = Workspace:FindFirstChild(name)
        if boss and boss:FindFirstChild("HumanoidRootPart") and Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CFrame = boss.HumanoidRootPart.CFrame * CFrame.new(0, 5, 8)
            break
        end
    end
end

-- No Clip (walk through walls)
local function noclipLoop()
    if not noClip then return end
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CanCollide = false
    end
end

-- Main loop
spawn(function()
    while true do
        if autoFarm then farmLoop() end
        if oneHitKill then killAll() end
        if autoCollect then collectLoop() end
        if teleportBoss then teleportLoop() end
        if fastAttack then fastAttackLoop() end
        if noClip then noclipLoop() end
        wait(0.15)
    end
end)

-- Reset collision when no clip off
spawn(function()
    while true do
        if not noClip and Character and Character:FindFirstChild("HumanoidRootPart") then
            Character.HumanoidRootPart.CanCollide = true
        end
        wait(1)
    end
end)

-- Button toggles
farmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    farmBtn.Text = autoFarm and "⚔️ AUTO FARM: ON" or "⚔️ AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = autoFarm and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

oneHitBtn.MouseButton1Click:Connect(function()
    oneHitKill = not oneHitKill
    oneHitBtn.Text = oneHitKill and "💀 1 HIT KILL: ON" or "💀 1 HIT KILL: OFF"
    oneHitBtn.BackgroundColor3 = oneHitKill and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

collectBtn.MouseButton1Click:Connect(function()
    autoCollect = not autoCollect
    collectBtn.Text = autoCollect and "📦 AUTO COLLECT: ON" or "📦 AUTO COLLECT: OFF"
    collectBtn.BackgroundColor3 = autoCollect and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

bossBtn.MouseButton1Click:Connect(function()
    teleportBoss = not teleportBoss
    bossBtn.Text = teleportBoss and "👑 TELEPORT BOSS: ON" or "👑 TELEPORT BOSS: OFF"
    bossBtn.BackgroundColor3 = teleportBoss and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

fastBtn.MouseButton1Click:Connect(function()
    fastAttack = not fastAttack
    fastBtn.Text = fastAttack and "⚡ FAST ATTACK: ON" or "⚡ FAST ATTACK: OFF"
    fastBtn.BackgroundColor3 = fastAttack and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

noclipBtn.MouseButton1Click:Connect(function()
    noClip = not noClip
    noclipBtn.Text = noClip and "🌀 NO CLIP: ON" or "🌀 NO CLIP: OFF"
    noclipBtn.BackgroundColor3 = noClip and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

-- Drag for mobile
mainFrame.TouchMoved:Connect(function(touch)
    mainFrame.Position = mainFrame.Position + UDim2.new(0, touch.Delta.X, 0, touch.Delta.Y)
end)

print("ULTIMATE BLOX FRUIT SCRIPT LOADED. DRAG MENU. ENABLE FEATURES.")
