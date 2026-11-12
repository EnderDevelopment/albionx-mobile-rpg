local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("RPGRemotes")
local Action = remotes:WaitForChild("Action")
local State = remotes:WaitForChild("State")
local Notice = remotes:WaitForChild("Notice")

local gui = Instance.new("ScreenGui")
gui.Name = "RPGMobileHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function label(parent, text, size, position, color)
	local object = Instance.new("TextLabel")
	object.BackgroundTransparency = 1
	object.Text = text
	object.TextColor3 = color or Color3.new(1, 1, 1)
	object.TextScaled = true
	object.Font = Enum.Font.GothamBold
	object.Size = size
	object.Position = position
	object.Parent = parent
	return object
end

local panel = Instance.new("Frame")
panel.Size = UDim2.fromScale(0.94, 0.2)
panel.Position = UDim2.fromScale(0.03, 0.03)
panel.BackgroundColor3 = Color3.fromRGB(20, 25, 34)
panel.BackgroundTransparency = 0.08
panel.Parent = gui
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = panel
local title = label(panel, "FRONTIER RPG", UDim2.fromScale(0.4, 0.22), UDim2.fromScale(0.03, 0.05), Color3.fromRGB(255, 211, 100))
title.TextXAlignment = Enum.TextXAlignment.Left
local stats = label(panel, "Loading profile...", UDim2.fromScale(0.94, 0.3), UDim2.fromScale(0.03, 0.3), Color3.fromRGB(225, 235, 245))
stats.TextXAlignment = Enum.TextXAlignment.Left
local inventory = label(panel, "", UDim2.fromScale(0.94, 0.3), UDim2.fromScale(0.03, 0.64), Color3.fromRGB(170, 200, 190))
inventory.TextXAlignment = Enum.TextXAlignment.Left

local notice = label(gui, "", UDim2.fromScale(0.82, 0.07), UDim2.fromScale(0.09, 0.27), Color3.fromRGB(255, 236, 165))
notice.BackgroundColor3 = Color3.fromRGB(24, 29, 38)
notice.BackgroundTransparency = 0.12
local noticeCorner = Instance.new("UICorner")
noticeCorner.CornerRadius = UDim.new(0, 8)
noticeCorner.Parent = notice

local actions = Instance.new("Frame")
actions.Size = UDim2.fromScale(0.94, 0.3)
actions.Position = UDim2.fromScale(0.03, 0.64)
actions.BackgroundTransparency = 1
actions.Parent = gui
local grid = Instance.new("UIGridLayout")
grid.CellSize = UDim2.fromScale(0.23, 0.42)
grid.CellPadding = UDim2.fromScale(0.02, 0.08)
grid.FillDirectionMaxCells = 4
grid.Parent = actions

local function button(text, color, callback)
	local object = Instance.new("TextButton")
	object.Text = text
	object.TextColor3 = Color3.new(1, 1, 1)
	object.TextScaled = true
	object.Font = Enum.Font.GothamBold
	object.BackgroundColor3 = color
	object.AutoButtonColor = true
	object.Parent = actions
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 10)
	buttonCorner.Parent = object
	object.Activated:Connect(callback)
	return object
end

button("GATHER", Color3.fromRGB(41, 137, 91), function() Action:FireServer("Gather") end)
button("ATTACK", Color3.fromRGB(174, 67, 57), function() Action:FireServer("Attack") end)
button("POTION", Color3.fromRGB(45, 105, 177), function() Action:FireServer("Craft", "HealthPotion") end)
button("SWORD", Color3.fromRGB(115, 91, 55), function() Action:FireServer("Craft", "IronSword") end)
button("PACK", Color3.fromRGB(91, 91, 140), function() Action:FireServer("Craft", "ExplorerPack") end)
button("SELL ORE", Color3.fromRGB(138, 104, 50), function() Action:FireServer("Sell", "IronOre") end)
button("SELL HERB", Color3.fromRGB(57, 130, 83), function() Action:FireServer("Sell", "MoonHerb") end)
button("REST", Color3.fromRGB(91, 100, 116), function() Action:FireServer("Heal") end)

State.OnClientEvent:Connect(function(data)
	local skillText = string.format("Gather %d  Combat %d  Craft %d", data.skills.Gathering or 1, data.skills.Combat or 1, data.skills.Crafting or 1)
	stats.Text = string.format("Level %d   XP %d   Gold %d   %s", data.level, data.xp, data.gold, skillText)
	local items = {}
	for item, amount in data.inventory do if amount > 0 then table.insert(items, item .. " x" .. amount) end end
	inventory.Text = "Bag: " .. (#items > 0 and table.concat(items, "  ") or "empty")
end)

Notice.OnClientEvent:Connect(function(message)
	notice.Text = message
	task.delay(3, function() if notice.Text == message then notice.Text = "" end end)
end)
