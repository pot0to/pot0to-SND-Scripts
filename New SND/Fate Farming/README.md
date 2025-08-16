# Fate Farming Script - Enhanced with Multi-Zone Support

Advanced FATE farming script with multi-zone support for Final Fantasy XIV. Automatically cycles through Dawntrail zones when no FATEs are available, with intelligent prioritization and comprehensive automation features.

## Features

### Core FATE Farming
- **Intelligent FATE Selection**: Priority system based on distance, progress, bonus status, and time remaining
- **Combat Integration**: Works with rotation plugins (RotationSolver, BossMod, Wrath)
- **Auto-targeting**: Prioritizes Forlorns for bonus rewards
- **Collection FATEs**: Handles NPC interaction and item collection automatically

### 🆕 Multi-Zone Support
- **Automatic Zone Cycling**: Seamlessly switches between zones when no FATEs are available
- **Expansion-Aware**: Automatically detects your current expansion and cycles within it
- **Intelligent Fallback**: Uses instance changing as backup if zone switching fails
- **Configurable**: Easy on/off toggle in SND settings
- **Immediate Response**: Triggers instantly when "No eligible fates found"

**Supported Expansions & Zones:**
- **A Realm Reborn (ARR)**: Middle La Noscea, Lower La Noscea, Central Thanalan, Eastern Thanalan, Southern Thanalan, Coerthas Central Highlands, Mor Dhona, Outer La Noscea
- **Heavensward (HW)**: Coerthas Western Highlands, The Dravanian Forelands, The Dravanian Hinterlands, The Churning Mists, The Sea of Clouds, Azys Lla
- **Stormblood (SB)**: The Fringes, The Ruby Sea, Yanxia, The Peaks, The Lochs, The Azim Steppe
- **Shadowbringers (ShB)**: Lakeland, Kholusia, Amh Araeng, Il Mheg, The Rak'tika Greatwood, The Tempest
- **Endwalker (EW)**: Labyrinthos, Thavnair, Garlemald, Mare Lamentorum, Ultima Thule, Elpis
- **Dawntrail (DT)**: Urqopacha, Kozama'uka, Yak T'el, Shaaloani, Heritage Found, Living Memory

### Automation Features
- **Bicolor Gemstone Management**: Auto-purchase vouchers when near cap (1400/1500)
- **Equipment Maintenance**: Auto-repair gear and extract materia
- **Retainer Processing**: Integration with AutoRetainer plugin
- **Grand Company Turn-ins**: Auto-dump excess gear with Deliveroo
- **Chocobo Management**: Auto-summon and maintain companion

### Quality of Life
- **Instance Switching**: Automatically changes instances when no FATEs available
- **Death Recovery**: Auto-return to home aetheryte on death
- **Food & Potions**: Automatic consumption management
- **Teleport Optimization**: Smart aetheryte selection for minimal travel time

## Requirements

### Essential Plugins
- **Something Need Doing (Expanded Edition)** - Main plugin for script execution
- **VNavmesh** - For pathfinding and movement
- **Lifestream** - For teleportation and instance changes
- **TextAdvance** - For FATE NPC interactions

### Combat Plugins (Choose One)
- **RotationSolver Reborn** (Recommended)
- **BossMod Reborn** 
- **Veyn's BossMod**
- **Wrath Combo**

### Dodging Plugins (Recommended)
- **BossMod Reborn**
- **Veyn's BossMod**

### Optional Plugins
- **AutoRetainer** - For retainer management
- **Deliveroo** - For Grand Company turn-ins
- **YesAlready** - For materia extraction

## Installation

1. Install all required plugins from their respective repositories
2. Download the `Fate Farming.lua` script
3. Import into Something Need Doing
4. Configure settings in the SND interface
5. Enable "Multi-Zone Farming" option for automatic zone switching

## Configuration

### Multi-Zone Settings
- **Multi-Zone Farming**: `false` (default) - Enable automatic zone cycling
- **Change instances if no FATEs**: `true` (default) - Fallback to instance changing

### Combat Settings
- **Rotation Plugin**: Choose your preferred combat plugin
- **Dodging Plugin**: Choose your preferred dodging plugin
- **Max melee/ranged distance**: Adjust combat positioning

### Automation Settings
- **Exchange bicolor gemstones**: Set preferred voucher type
- **Self repair**: Enable/disable automatic equipment repair
- **Pause for retainers**: Enable retainer processing
- **Return on death**: Auto-return on character death

## Usage

1. **Navigate to any supported expansion zone** (ARR, HW, SB, ShB, EW, or DT)
2. **Start the script** in Something Need Doing
3. **Enable Multi-Zone** in settings if desired
4. The script will automatically:
   - Detect your current expansion
   - Find and complete FATEs in current zone
   - Switch to next zone within the same expansion when no FATEs available
   - Handle all maintenance tasks (repair, retainers, etc.)
   - Continue cycling through all zones in that expansion

## Important Notes

⚠️ **Multi-Zone Support**: The multi-zone feature works with **ALL major expansions**. The script automatically detects which expansion you're in and cycles through zones within that expansion only.

⚠️ **Plugin Dependencies**: Ensure all required plugins are installed and updated for optimal performance.

⚠️ **Configuration**: Review all settings before first use to match your preferred gameplay style.

## Credits

**Original Script**: [pot0to](https://github.com/pot0to/pot0to-SND-Scripts/blob/main/New%20SND/Fate%20Farming/Fate%20Farming.lua)

**Multi-Zone Enhancement**: [n0way02](https://github.com/n0way02)

## Version History

### v3.1.0 - Multi-Zone Update
- Added Multi-Zone Farming option for ALL expansions (ARR, HW, SB, ShB, EW, DT)
- Automatic expansion detection and zone cycling within the same expansion
- Multi-zone triggers immediately when "No eligible fates found"
- Priority system ensures multi-zone doesn't interfere with retainers/repair/exchanges
- Fixed bugs where script would stop when no available FATEs in expansion zones

### Previous Versions
See changelog in script for complete version history.

## Support

- **Issues**: Report bugs or request features
- **Ko-fi**: Support the developers
  - Original: [pot0to](https://ko-fi.com/pot0to)
  - Multi-Zone: [n0way02](https://ko-fi.com/n0way02)

---

*This script is designed for educational and quality-of-life purposes. Please use responsibly and in accordance with Final Fantasy XIV's Terms of Service.*
