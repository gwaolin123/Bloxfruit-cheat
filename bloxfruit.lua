-- ULTIMATE BLOX FRUIT SCRIPT - FULLY WORKING + BYPASS + AUTO QUEST (CodeX)
-- Anti-Kick, Anti-Ban, Auto Quest, Auto Farm

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Bypass / Anti-Ban
local function bypassKick()
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "Ban" then
                return nil
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function antiReport()
    pcall(function()
        local mt = getrawmetatable(game)
        local old = mt.__namecall
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}
            if tostring(self):find("Report") or tostring(args[1]):find("report") then
                return nil
            end
            return old(self, ...)
        end)
        setreadonly(mt, true)
    end)
end

local function antiTeleportKick()
    pcall(function()
        game:GetService("Players").LocalPlayer.OnTeleport:Connect(function(state)
            if state == Enum.TeleportState.Teleporting then
                wait(0.1)
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end
        end)
    end)
end

bypassKick()
antiReport()
antiTeleportKick()

-- Settings
local autoFarm = false
local oneHitKill = false
local autoCollect = false
local teleportBoss = false
local fastAttack = false
local noClip = false
local autoQuest = false

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
local questBtn = Instance.new("TextButton")

screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "BloxFruitUltimateV2"

mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 240, 0, 360)
mainFrame.Position = UDim2.new(0.5, -120, 0.55, -180)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.15
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
    btn.Size = UDim2.new(0, 210, 0, 38)
    btn.Position = UDim2.new(0, 15, 0, y)
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
questBtn = createBtn("📜 AUTO QUEST: OFF", 315, Color3.new(0.2, 0.6, 0.2))

-- Auto Quest System
local function getCurrentQuest()
    local success, data = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetQuest")
    end)
    if success and data then
        return data
    end
    return nil
end

local function startQuest(questName)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:FireServer("StartQuest", questName)
    end)
end

local function getQuestEnemy()
    local quest = getCurrentQuest()
    if quest and quest.Enemy then
        return quest.Enemy
    end
    return nil
end

local function autoQuestLoop()
    if not autoQuest then return end
    local currentQuest = getCurrentQuest()
    if not currentQuest then
        -- Auto accept nearest quest based on level
        local level = LocalPlayer.Data.Level.Value
        if level < 50 then
            startQuest("BanditQuest1")
        elseif level < 150 then
            startQuest("MarineQuest2")
        elseif level < 300 then
            startQuest("SkyExp1Quest")
        elseif level < 500 then
            startQuest("FrostQuest")
        elseif level < 750 then
            startQuest("MagmaQuest")
        elseif level < 1000 then
            startQuest("FishQuest")
        elseif level < 1250 then
            startQuest("PirateQuest3")
        elseif level < 1500 then
            startQuest("MarineQuest3")
        else
            startQuest("EliteQuest")
        end
    end
end

-- Get all enemies (filter by quest if enabled)
local function getAllEnemies()
    local enemies = {}
    local questEnemyName = autoQuest and getQuestEnemy()
    local searchFolders = {"Enemies", "Mobs", "Bosses", "NPCs", "Marines", "Pirates", "Animals", "Island"}
    
    for _, folderName in pairs(searchFolders) do
        local folder = Workspace:FindFirstChild(folderName)
        if folder then
            for _, child in pairs(folder:GetChildren()) do
                if child:FindFirstChild("Humanoid") and child.Humanoid.Health > 0 and child:FindFirstChild("HumanoidRootPart") then
                    if child ~= Character and not child:IsDescendantOf(Character) then
                        if autoQuest and questEnemyName then
                            if child.Name:lower():find(questEnemyName:lower()) then
                                table.insert(enemies, child)
                            end
                        else
                            table.insert(enemies, child)
                        end
                    end
                end
            end
        end
    end
    
    if not autoQuest or not questEnemyName then
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
    end
    return enemies
end

-- 1 Hit Kill
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
        local hrp = Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = nearest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
        end
        wait(0.05)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0,0))
            wait(0.02)
            VirtualUser:Button1Up(Vector2.new(0,0))
        end)
        pcall(function()
            ReplicatedStorage.Remotes.CommF_:FireServer("Tap")
            ReplicatedStorage.Remotes.CommF_:FireServer("Click")
        end)
    end
end

-- Fast Attack
local function fastAttackLoop()
    if not fastAttack then return end
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:FireServer("KenHaki")
        ReplicatedStorage.Remotes.CommF_:FireServer("FlashStep")
    end)
end

-- Auto Collect
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

-- No Clip
local function noclipLoop()
    if not noClip then return end
    if Character and Character:FindFirstChild("HumanoidRootPart") then
        Character.HumanoidRootPart.CanCollide = false
    end
end

-- Main loop
spawn(function()
    while true do
        if autoQuest then autoQuestLoop() end
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

questBtn.MouseButton1Click:Connect(function()
    autoQuest = not autoQuest
    questBtn.Text = autoQuest and "📜 AUTO QUEST: ON" or "📜 AUTO QUEST: OFF"
    questBtn.BackgroundColor3 = autoQuest and Color3.new(0, 0.7, 0) or Color3.new(0.2, 0.6, 0.2)
end)

-- Drag for mobile
mainFrame.TouchMoved:Connect(function(touch)
    mainFrame.Position = mainFrame.Position + UDim2.new(0, touch.Delta.X, 0, touch.Delta.Y)
end)

print("ULTIMATE BLOX FRUIT + BYPASS + AUTO QUEST LOADED. ENABLE FEATURES.")
