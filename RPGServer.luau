local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local HttpService = game:GetService("HttpService")

local Shared = ReplicatedStorage:WaitForChild("RPGShared")
local Config = require(Shared:WaitForChild("RPGConfig"))
local Definitions = require(Shared:WaitForChild("RPGDefinitions"))
local Store = DataStoreService:GetDataStore(Config.DataStoreName)

local remotes = ReplicatedStorage:FindFirstChild("RPGRemotes") or Instance.new("Folder")
remotes.Name = "RPGRemotes"
remotes.Parent = ReplicatedStorage
local Action = remotes:FindFirstChild("Action") or Instance.new("RemoteEvent")
Action.Name = "Action"
Action.Parent = remotes
local State = remotes:FindFirstChild("State") or Instance.new("RemoteEvent")
State.Name = "State"
State.Parent = remotes
local Notice = remotes:FindFirstChild("Notice") or Instance.new("RemoteEvent")
Notice.Name = "Notice"
Notice.Parent = remotes

local profiles = {}
local cooldowns = {}
local resourcesFolder = workspace:FindFirstChild("RPG_Resources") or Instance.new("Folder")
resourcesFolder.Name = "RPG_Resources"
resourcesFolder.Parent = workspace
local enemiesFolder = workspace:FindFirstChild("RPG_Enemies") or Instance.new("Folder")
enemiesFolder.Name = "RPG_Enemies"
enemiesFolder.Parent = workspace

local function defaultProfile()
	return {gold = Config.StartingGold, level = 1, xp = 0, health = Config.StartingHealth, inventory = {}, skills = {Gathering = 1, Combat = 1, Crafting = 1}, daily = {date = os.date("%Y-%m-%d"), gathered = 0, defeated = 0, crafted = 0}, listings = {}}
end

local function notify(player, message)
	Notice:FireClient(player, message)
end

local function addItem(profile, item, amount)
	profile.inventory[item] = (profile.inventory[item] or 0) + amount
end

local function addXP(player, amount, skill)
	local profile = profiles[player]
	if not profile then return end
	profile.xp += amount
	if skill then profile.skills[skill] = (profile.skills[skill] or 1) + math.floor(amount / 100) end
	local needed = profile.level * 100
	if profile.xp >= needed then
		profile.xp -= needed
		profile.level += 1
		profile.health = Config.StartingHealth + profile.level * 5
		notify(player, "Level up! You are now level " .. profile.level)
	end
end

local function pushState(player)
	if profiles[player] then State:FireClient(player, profiles[player]) end
end

local function nearbyPart(player, folder, maxDistance)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return nil end
	local best, distance
	for _, part in folder:GetChildren() do
		if part:IsA("BasePart") and part:GetAttribute("Ready") ~= false then
			local current = (root.Position - part.Position).Magnitude
			if current <= maxDistance and (not distance or current < distance) then best, distance = part, current end
		end
	end
	return best
end

local function spawnResource(resourceType, position)
	local data = Definitions.Resources[resourceType]
	local part = Instance.new("Part")
	part.Name = resourceType
	part.Size = Vector3.new(3, 3, 3)
	part.Position = position
	part.Anchored = true
	part.Material = Enum.Material.Neon
	part.Color = data.color
	part:SetAttribute("ResourceType", resourceType)
	part:SetAttribute("Ready", true)
	part.Parent = resourcesFolder
end

local function spawnEnemy(enemyType, position)
	local data = Definitions.Enemies[enemyType]
	local part = Instance.new("Part")
	part.Name = enemyType
	part.Size = Vector3.new(4, 5, 4)
	part.Position = position
	part.Anchored = true
	part.Color = data.color
	part:SetAttribute("EnemyType", enemyType)
	part:SetAttribute("Health", data.health)
	part.Parent = enemiesFolder
end

local function initializeWorld()
	if #resourcesFolder:GetChildren() == 0 then
		for i = 1, 8 do spawnResource(i % 3 == 1 and "Herb" or i % 3 == 2 and "Ore" or "Wood", Vector3.new((i - 4) * 8, 2, 20 + (i % 2) * 8)) end
	end
	if #enemiesFolder:GetChildren() == 0 then
		spawnEnemy("MireWolf", Vector3.new(0, 3, 55))
		spawnEnemy("Bandit", Vector3.new(25, 3, 65))
		spawnEnemy("StoneGolem", Vector3.new(-28, 3, 80))
	end
end

local function gather(player)
	local node = nearbyPart(player, resourcesFolder, Config.InteractionRange)
	if not node then notify(player, "Move closer to a glowing resource."); return end
	local profile = profiles[player]
	local data = Definitions.Resources[node:GetAttribute("ResourceType")]
	node:SetAttribute("Ready", false)
	node.Transparency = 1
	addItem(profile, data.item, 1)
	profile.daily.gathered += 1
	addXP(player, data.xp, "Gathering")
	notify(player, "+1 " .. data.displayName)
	task.delay(data.respawn, function() if node.Parent then node.Transparency = 0; node:SetAttribute("Ready", true) end end)
end

local function attack(player)
	local now = os.clock()
	if now - (cooldowns[player] or 0) < Config.AttackCooldown then return end
	cooldowns[player] = now
	local enemy = nearbyPart(player, enemiesFolder, Config.AttackRange)
	if not enemy then notify(player, "No enemy in range."); return end
	local typeName = enemy:GetAttribute("EnemyType")
	local data = Definitions.Enemies[typeName]
	local health = enemy:GetAttribute("Health") - (Config.BaseDamage + profiles[player].skills.Combat * 2)
	if health <= 0 then
		profiles[player].gold += data.rewardGold
		profiles[player].daily.defeated += 1
		addXP(player, data.rewardXP, "Combat")
		notify(player, "Defeated " .. data.displayName .. " (+" .. data.rewardGold .. " gold)")
		local position = enemy.Position
		enemy:Destroy()
		task.delay(Config.EnemyRespawnSeconds, function() spawnEnemy(typeName, position) end)
	else
		enemy:SetAttribute("Health", health)
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if humanoid then humanoid:TakeDamage(data.damage) end
		notify(player, data.displayName .. " has " .. health .. " HP")
	end
end

local function craft(player, recipeName)
	local recipe = Definitions.Recipes[recipeName]
	local profile = profiles[player]
	if not recipe then return end
	for item, amount in recipe.ingredients do if (profile.inventory[item] or 0) < amount then notify(player, "Missing materials for " .. recipe.displayName); return end end
	for item, amount in recipe.ingredients do profile.inventory[item] -= amount end
	addItem(profile, recipeName, recipe.output)
	profile.daily.crafted += 1
	addXP(player, recipe.xp, "Crafting")
	notify(player, "Crafted " .. recipe.displayName)
end

local function handleAction(player, action, value)
	if not profiles[player] then return end
	if action == "Gather" then gather(player) elseif action == "Attack" then attack(player) elseif action == "Craft" then craft(player, value) elseif action == "Sell" then
		local item = value
		if (profiles[player].inventory[item] or 0) > 0 then profiles[player].inventory[item] -= 1; profiles[player].gold += 12; notify(player, "Sold 1 " .. item .. " for 12 gold") end
	elseif action == "Heal" then
		if profiles[player].gold >= 20 then profiles[player].gold -= 20; profiles[player].health = Config.StartingHealth + profiles[player].level * 5; notify(player, "Restored health") end
	end
	pushState(player)
end

Action.OnServerEvent:Connect(handleAction)

local function loadPlayer(player)
	local profile = defaultProfile()
	local success, saved = pcall(function() return Store:GetAsync("player_" .. player.UserId) end)
	if success and type(saved) == "table" then for key, value in saved do profile[key] = value end end
	profiles[player] = profile
	pushState(player)
end

local function savePlayer(player)
	local profile = profiles[player]
	if profile then pcall(function() Store:SetAsync("player_" .. player.UserId, profile) end) end
end

Players.PlayerAdded:Connect(loadPlayer)
Players.PlayerRemoving:Connect(function(player) savePlayer(player); profiles[player] = nil; cooldowns[player] = nil end)
task.spawn(function() while true do task.wait(Config.AutosaveSeconds); for player in profiles do savePlayer(player) end end end)
task.spawn(function() while true do task.wait(Config.StatePushSeconds); for player in profiles do pushState(player) end end end)
initializeWorld()
