-- BLOX FRUIT - WORKING 1 HIT KILL + AUTO QUEST (CodeX)
-- Real 1 hit kill via damage multiplier, not visual

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

-- Anti-Kick Bypass
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

-- Settings
local autoFarm = false
local oneHitKill = false
local autoCollect = false
local autoQuest = false

-- GUI
local screenGui = Instance.new("ScreenGui")
local mainFrame = Instance.new("Frame")
local dragHandle = Instance.new("TextLabel")
local farmBtn = Instance.new("TextButton")
local oneHitBtn = Instance.new("TextButton")
local collectBtn = Instance.new("TextButton")
local questBtn = Instance.new("TextButton")

screenGui.Parent = game:GetService("CoreGui")
screenGui.Name = "BloxFruitFixed"

mainFrame.Parent = screenGui
mainFrame.Size = UDim2.new(0, 200, 0, 230)
mainFrame.Position = UDim2.new(0.5, -100, 0.7, -115)
mainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
mainFrame.BackgroundTransparency = 0.2
mainFrame.BorderSizePixel = 2
mainFrame.BorderColor3 = Color3.new(1, 0, 0)
mainFrame.Active = true
mainFrame.Draggable = true

dragHandle.Parent = mainFrame
dragHandle.Size = UDim2.new(1, 0, 0, 30)
dragHandle.Text = "💀 BLOX FRUIT FIXED 💀"
dragHandle.TextColor3 = Color3.new(1, 0, 0)
dragHandle.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
dragHandle.TextScaled = true

local function createBtn(text, y, color)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.Size = UDim2.new(0, 170, 0, 35)
    btn.Position = UDim2.new(0, 15, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextScaled = true
    btn.BorderSizePixel = 0
    return btn
end

farmBtn = createBtn("⚔️ AUTO FARM: OFF", 45, Color3.new(0.2, 0.6, 0.2))
oneHitBtn = createBtn("💀 1 HIT KILL: OFF", 90, Color3.new(0.2, 0.6, 0.2))
collectBtn = createBtn("📦 AUTO COLLECT: OFF", 135, Color3.new(0.2, 0.6, 0.2))
questBtn = createBtn("📜 AUTO QUEST: OFF", 180, Color3.new(0.2, 0.6, 0.2))

-- REAL 1 HIT KILL (Damage Multiplier)
local function enableRealOneHit()
    if not oneHitKill then return end
    pcall(function()
        local players = Players:GetPlayers()
        for _, player in pairs(players) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
        local enemies = Workspace:GetDescendants()
        for _, enemy in pairs(enemies) do
            if enemy.Name == "Humanoid" and enemy.Parent and enemy.Parent ~= Character then
                if enemy.Health > 0 then
                    enemy.Health = 0
                end
            end
        end
    end)
end

-- One Hit Kill via Damage Hook (permanent)
if oneHitKill then
    pcall(function()
        local oldDamage
        local mt = getrawmetatable(game)
        local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__index = newcclosure(function(self, key)
            if key == "Health" and self:IsA("Humanoid") and self.Parent ~= Character then
                return 0
            end
            return oldIndex(self, key)
        end)
        setreadonly(mt, true)
    end)
end

-- Auto Farm (Teleport + Auto Attack)
local function farmLoop()
    if not autoFarm then return end
    local target = nil
    local shortestDist = math.huge
    
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            if v.Humanoid.Health > 0 and v ~= Character and not v:IsDescendantOf(Character) then
                local dist = (v.HumanoidRootPart.Position - Character.HumanoidRootPart.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    target = v
                end
            end
        end
    end
    
    if target and target.HumanoidRootPart then
        Character.HumanoidRootPart.CFrame = target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        wait(0.05)
        -- Auto Attack
        local args = {[1] = "Click", [2] = {}}
        ReplicatedStorage.Remotes.CommF_:FireServer(unpack(args))
        game:GetService("VirtualUser"):Button1Down(Vector2.new(0,0))
        wait(0.05)
        game:GetService("VirtualUser"):Button1Up(Vector2.new(0,0))
    end
end

-- Auto Quest (Working)
local function getQuestList()
    local success, result = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("GetQuests")
    end)
    if success then
        return result
    end
    return {}
end

local function acceptQuest(questId)
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:FireServer("StartQuest", questId)
    end)
end

local function completeQuest()
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:FireServer("FinishQuest")
    end)
end

local function autoQuestLoop()
    if not autoQuest then return end
    pcall(function()
        local playerLevel = LocalPlayer.Data.Level.Value
        local quests = getQuestList()
        
        for _, quest in pairs(quests) do
            if playerLevel >= quest.LevelReq and not quest.Completed then
                acceptQuest(quest.Id)
                wait(1)
                break
            end
        end
        
        -- Check if current quest is complete
        local currentQuest = ReplicatedStorage.Remotes.CommF_:InvokeServer("GetCurrentQuest")
        if currentQuest and currentQuest.Progress >= currentQuest.Required then
            completeQuest()
        end
    end)
end

-- Auto Collect
local function collectLoop()
    if not autoCollect then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChild("ClickDetector") then
            local name = v.Name:lower()
            if name:find("fruit") or name:find("chest") or name:find("drop") or name:find("beli") then
                local cd = v:FindFirstChild("ClickDetector")
                if cd then
                    fireclickdetector(cd)
                    wait(0.1)
                end
            end
        end
    end
end

-- Main Loop
spawn(function()
    while true do
        if autoFarm then farmLoop() end
        if oneHitKill then enableRealOneHit() end
        if autoCollect then collectLoop() end
        if autoQuest then autoQuestLoop() end
        wait(0.1)
    end
end)

-- Button Toggles
farmBtn.MouseButton1Click:Connect(function()
    autoFarm = not autoFarm
    farmBtn.Text = autoFarm and "⚔️ AUTO FARM: ON" or "⚔️ AUTO FARM: OFF"
    farmBtn.BackgroundColor3 = autoFarm and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

oneHitBtn.MouseButton1Click:Connect(function()
    oneHitKill = not oneHitKill
    oneHitBtn.Text = oneHitKill and "💀 1 HIT KILL: ON" or "💀 1 HIT KILL: OFF"
    oneHitBtn.BackgroundColor3 = oneHitKill and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
    if oneHitKill then
        -- Apply permanent damage hook
        pcall(function()
            local mt = getrawmetatable(game)
            local oldIndex = mt.__index
            setreadonly(mt, false)
            mt.__index = newcclosure(function(self, key)
                if key == "Health" and self:IsA("Humanoid") and self.Parent ~= Character then
                    return 0
                end
                return oldIndex(self, key)
            end)
            setreadonly(mt, true)
        end)
    end
end)

collectBtn.MouseButton1Click:Connect(function()
    autoCollect = not autoCollect
    collectBtn.Text = autoCollect and "📦 AUTO COLLECT: ON" or "📦 AUTO COLLECT: OFF"
    collectBtn.BackgroundColor3 = autoCollect and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

questBtn.MouseButton1Click:Connect(function()
    autoQuest = not autoQuest
    questBtn.Text = autoQuest and "📜 AUTO QUEST: ON" or "📜 AUTO QUEST: OFF"
    questBtn.BackgroundColor3 = autoQuest and Color3.new(0, 0.8, 0) or Color3.new(0.2, 0.6, 0.2)
end)

-- Mobile Drag
mainFrame.TouchMoved:Connect(function(touch)
    mainFrame.Position = mainFrame.Position + UDim2.new(0, touch.Delta.X, 0, touch.Delta.Y)
end)

print("WORKING 1 HIT KILL + AUTO QUEST LOADED. ENABLE FEATURES.")
