local Definitions = {}

Definitions.Resources = {
	Herb = {displayName = "Moon Herb", item = "MoonHerb", xp = 8, respawn = 15, color = Color3.fromRGB(70, 190, 100)},
	Ore = {displayName = "Iron Ore", item = "IronOre", xp = 12, respawn = 22, color = Color3.fromRGB(130, 140, 160)},
	Wood = {displayName = "Ancient Wood", item = "AncientWood", xp = 10, respawn = 18, color = Color3.fromRGB(150, 95, 45)},
}

Definitions.Recipes = {
	HealthPotion = {displayName = "Health Potion", ingredients = {MoonHerb = 2, AncientWood = 1}, output = 1, xp = 20},
	IronSword = {displayName = "Iron Sword", ingredients = {IronOre = 4, AncientWood = 2}, output = 1, xp = 45},
	ExplorerPack = {displayName = "Explorer Pack", ingredients = {MoonHerb = 3, IronOre = 2}, output = 1, xp = 35},
}

Definitions.Enemies = {
	MireWolf = {displayName = "Mire Wolf", health = 65, damage = 8, rewardGold = 18, rewardXP = 35, color = Color3.fromRGB(100, 100, 120)},
	Bandit = {displayName = "Bandit", health = 110, damage = 12, rewardGold = 35, rewardXP = 60, color = Color3.fromRGB(170, 75, 65)},
	StoneGolem = {displayName = "Stone Golem", health = 240, damage = 20, rewardGold = 100, rewardXP = 150, color = Color3.fromRGB(100, 105, 110)},
}

Definitions.Specializations = {"Gathering", "Combat", "Crafting"}
Definitions.DailyGoals = {"Gather 10 resources", "Defeat 5 enemies", "Craft 3 items"}

return Definitions
