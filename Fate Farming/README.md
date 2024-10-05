# Fate Farming
Fate farming script with the following features:
- Can purchase Bicolor Gemstone Vouchers (both old and new) when your gemstones are almost capped
- Priority system for Fate selection:  most progress > is bonus fate > least time left > distance
- Can prioritize Forlorns when they show up during Fate
- Can do all fates, including NPC collection fates
- Revives upon death and gets back to fate farming
- Attempts to change instances when there are no fates left in the zone
- Can process your retainers and Grand Company turn ins, then get back to fate farming

## New to Something Need Doing (SND)
![SND Basics](img/SNDBasics.png)

## Installing Dependency Plugins
### Required Plugins
| Plugin Name | Purpose | Repo |
|-------------|---------|------|
| Something Need Doing [Expanded Edition] | main plugin that runs the code | https://puni.sh/api/repository/croizat |
| VNavmesh | pathing and moving | https://puni.sh/api/repository/veyn |
| RotationSolver Reborn | targeting and attacking enemies | https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json |
| TextAdvance | interacting with Fate NPCs | comes with Dalamud |
| Teleporter | teleporting to aetherytes | comes with Dalamud |
| Lifestream | changing instances | https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json |

### Optional Plugins
| Plugin Name | Purpose | Repo |
|-------------|---------|------|
| BossModReborn | AI for dodging mechanics | https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json |
| ChatCoordinates | puts a flag on your map so you can see where you're going next | comes with Dalamud |
| AutoRetainer | handles retainers when they're ready, then gets back to Fate farming | https://love.puni.sh/ment.json |
| Deliveroo | turns in gear to your Grand Company when your retainers come back with too much and clog your inventory | https://plugins.carvel.li/ |

## Settings
### Script Settings
The script contains several settings you can mess around with to minmax gem income. This section is constantly changing, so check back whenever you update!
![Script Settings](img/ScriptSettings.png)

### RSR Settings
| | |
|--|--|
| ![RSR Engage Settings](img/RSREngageSettings.png) | Select "All Targets that are in range for any abilities (Tanks/Autoduty)" regardless of whether you're a tank |
| ![RSR Map Specific Priorities](img/RSRMapSpecificPriorities.png) | Add "Forlorn Maiden" and "The Forlorn" to Prio Targets |
| ![RSR Gap Closer Distance](img/RSRGapCloserDistance.png) | Recommended for melees: gapcloser distance = 20y |

## Discord
https://discord.gg/punishxiv > ffxiv-snd (channel) > pot0to's fate script (thread)