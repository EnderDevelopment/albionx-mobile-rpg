# Roblox Mobile RPG Script

AlbionX: Mobile RPG is a Roblox mobile RPG script foundation for a long-session adventure game. It provides a server-authoritative RPG gameplay loop with gathering, crafting, combat, enemy respawns, resource respawns, specialization progression, persistent player data, gold, experience, inventory, and a touch-friendly mobile HUD.

## Install

1. Open the experience in Roblox Studio.
2. In `ReplicatedStorage`, create a folder named `RPGShared`.
3. Inside `RPGShared`, create these ModuleScripts:
   - `RPGConfig`
   - `RPGDefinitions`
4. In `ServerScriptService`, create a Script named `RPGServer`.
5. In `StarterPlayer > StarterPlayerScripts`, create a LocalScript named `RPGMobileClient`.
6. Paste each supplied project file into the matching Roblox object.
7. Publish the experience before testing persistent player data.
8. In Game Settings, enable Studio Access to API Services if you want to test DataStore loading and saving in Studio.
9. Customize the values in `RPGConfig` and add map art around the generated gameplay areas as needed.

The server creates the `RPGRemotes`, `RPG_Resources`, and `RPG_Enemies` folders during runtime. The client creates the mobile HUD and action buttons automatically.

## Use

1. Start a Play test.
2. Move toward the glowing resource nodes near the starting area.
3. Press `GATHER` when a resource is within interaction range.
4. Gather Moon Herbs, Iron Ore, and Ancient Wood.
5. Use `POTION`, `SWORD`, or `PACK` to craft items when you have the required materials.
6. Move toward an enemy camp and press `ATTACK` to fight nearby enemies.
7. Defeat Mire Wolves, Bandits, and Stone Golems to earn gold and combat experience.
8. Sell Moon Herbs or Iron Ore with the selling buttons.
9. Press `REST` to spend gold and restore health.
10. Continue gathering, crafting, fighting, leveling skills, and improving your character.

The project includes Gathering, Combat, and Crafting specializations. Player profiles save gold, level, experience, health, inventory, skills, daily activity counters, and listings through Roblox DataStoreService. New resources, recipes, enemies, rewards, and progression values can be added through the shared definition and configuration modules.

---

More Roblox script projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/773a9b26-95dd-45b3-9fbe-b7d2486dba81?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=773a9b26-95dd-45b3-9fbe-b7d2486dba81
