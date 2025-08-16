--[=====[
[[SND Metadata]]
author: pot0to
version: 3.1.0
description: >-
  Fate farming script with the following features:

  - Can purchase Bicolor Gemstone Vouchers (both old and new) when your gemstones are almost capped

  - Priority system for Fate selection: distance w/ teleport > most progress > is bonus fate > least time left > distance

  - Will prioritize Forlorns when they show up during Fate

  - Can do all fates, including NPC collection fates

  - Revives upon death and gets back to fate farming

  - Attempts to change instances when there are no fates left in the zone

  - Can process your retainers and Grand Company turn ins, then get back to fate farming

  - Autobuys gysahl greens and grade 8 dark matter when you run out

  - Has companion scripts dedicated to atma farming, or you can write your own! (See section for companion scripts)
plugin_dependencies:
- Lifestream
- vnavmesh
- TextAdvance
configs:
  Food:
    default: 
    description: Leave blank if you don't want to use any food. If its HQ include <hq> next to the name "Baked Eggplant <hq>"
    type: string
  Potion:
    default:
    description: Leave blank if you don't want to use any potions. If its HQ include <hq> next to the name "Superior Spiritbond Potion <hq>"
    type: string
  Chocobo Companion Stance:
    default: "Healer"
    description: Options - Follow/Free/Defender/Healer/Attacker/None. Will not summon chocobo if set to "None"
    type: string
  Buy Gysahl Greens?:
    default: true
    description: Automatically buys a 99 stack of Gysahl Greens from the Limsa gil vendor if none in inventory
    type: boolean
  Ignore FATE if progress is over (%):
    default: 80
    type: int
    min: 0
    max: 100
    required: true
  Ignore FATE if duration is less than (mins):
    default: 3
    type: int
    min: 0
    max: 100
    required: true
  Ignore FATE if duration is less than (mins):
    default: 3
    type: int
    min: 0
    max: 100
    required: true
  Ignore boss FATEs until progress is at least (%):
    default: 0
    type: int
    min: 0
    max: 100
    required: true
  Ignore Special FATEs until progress is at least (%):
    default: 20
    type: int
    min: 0
    max: 100
    required: true
  Do collection FATEs?:
    default: true
    type: boolean
  Do only bonus FATEs?:
    default: false
    type: boolean
  Max melee distance:
    default: 2.5
    type: float
    min: 0
    max: 30
    required: true
  Max ranged distance:
    default: 20
    type: float
    min: 0
    max: 30
    required: true
  Forlorns:
    default: All
    type: string
    description: Options - All/Small/None
    required: true
  Change instances if no FATEs?:
    default: true
    type: boolean
  Exchange bicolor gemstones for:
    default: Turali Bicolor Gemstone Voucher
    type: string
    description: Leave blank if you don't want to spend your bicolors
  Self repair?:
    default: true
    description: If checked, will attempt to repair your gear. If not checked, will go to Limsa mender.
    type: boolean
  Pause for retainers?:
    default: true
    type: boolean
  Dump extra gear at GC?:
    default: true
    type: boolean
    description: Used with retainers, in case they come back with too much stuff and clog your inventory.
  Return on death?:
    default: true
    type: boolean
    description: Auto accept the box to return to home aetheryte when you die.
  Echo logs:
    default: All
    type: string
    description: Options - All/Gems/None
  Rotation Plugin:
    default: "Any"
    type: string
    description: Options - Any/Wrath/RotationSolver/BossMod/BossModReborn. What Rotation Plugin to use.
  Dodging Plugin:
    default: "Any"
    type: string
    description: Options - Any/BossMod/BossModReborn/None. What Dodging Plugin to use. If your RotationPlugin is BossModReborn/BossMod, then this will be overriden
  Multi-Zone Farming:
    default: false
    type: boolean
    description: Enable automatic zone switching when no FATEs are available. Automatically detects your current expansion and cycles through all zones within that expansion (ARR, HW, SB, ShB, EW, DT)
[[End Metadata]]
--]=====]
--[[

********************************************************************************
*                                  Changelog                                   *
********************************************************************************

    -> 3.1.0    by: n0way02 (https://ko-fi.com/n0way02)    
                Added Multi-Zone Farming option to automatically cycle through zones when no FATEs available.
                Supports ALL expansions: ARR, Heavensward, Stormblood, Shadowbringers, Endwalker, and Dawntrail.
                Automatically detects current expansion and cycles only within that expansion's zones.
                Multi-zone triggers immediately when "No eligible fates found" and takes priority over instance changes.
                Fixed bugs where the script would stop when no FATEs were available in expansion zones.
    -> 3.0.9    By Allison.
                Fix standing in place after fate finishes bug.
                Add config options for Rotation Plugin and Dodging Plugin (Fixed bug when multiple solvers present at once)
                Update description to more accurately reflect script. 
                Cleaned up metadata + changed description to more accurately reflect script.
                Small change to combat related distance to target checks to more accurately reflect how FFXIV determines if abilities are usable (no height). Hopefully fixes some max distance checks during combat.
                Small Bugfixes.
    -> 3.0.6    Adding metadata
    -> 3.0.5    Fixed repair function
    -> 3.0.4    Remove noisy logging
    -> 3.0.2    Fixed HasPlugin check
    -> 3.0.1    Fixed typo causing it to crash
    -> 3.0.0    Updated for SND2

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat
    -> VNavmesh :   (for Pathing/Moving)    https://puni.sh/api/repository/veyn
    -> Some form of rotation plugin for attacking enemies. Options are:
        -> RotationSolver Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json       
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyn's BossMod: https://puni.sh/api/repository/veyn
        -> Wrath Combo: https://love.puni.sh/ment.json
    -> Some form of AI dodging. Options are: 
        -> BossMod Reborn: https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
        -> Veyn's BossMod: https://puni.sh/api/repository/veyn
    -> TextAdvance: (for interacting with Fate NPCs) https://github.com/NightmareXIV/MyDalamudPlugins/raw/main/pluginmaster.json
    -> Lifestream :  (for changing Instances [ChangeInstance][Exchange]) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json

********************************************************************************
*                                Optional Plugins                              *
********************************************************************************

This Plugins are Optional and not needed unless you have it enabled in the settings:

    -> AutoRetainer : (for Retainers [Retainers])   https://love.puni.sh/ment.json
    -> Deliveroo : (for gc turn ins [TurnIn])   https://plugins.carvel.li/
    -> YesAlready : (for extracting materia)

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

import("System.Numerics")

--#region Data

CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDuty34=34,
    occupiedMateriaExtractionAndRepair=39,
    betweenAreas=45,
    jumping48=48,
    jumping61=61,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

ClassList =
{
    gla = { classId=1, className="Gladiator", isMelee=true, isTank=true },
    pgl = { classId=2, className="Pugilist", isMelee=true, isTank=false },
    mrd = { classId=3, className="Marauder", isMelee=true, isTank=true },
    lnc = { classId=4, className="Lancer", isMelee=true, isTank=false },
    arc = { classId=5, className="Archer", isMelee=false, isTank=false },
    cnj = { classId=6, className="Conjurer", isMelee=false, isTank=false },
    thm = { classId=7, className="Thaumaturge", isMelee=false, isTank=false },
    pld = { classId=19, className="Paladin", isMelee=true, isTank=true },
    mnk = { classId=20, className="Monk", isMelee=true, isTank=false },
    war = { classId=21, className="Warrior", isMelee=true, isTank=true },
    drg = { classId=22, className="Dragoon", isMelee=true, isTank=false },
    brd = { classId=23, className="Bard", isMelee=false, isTank=false },
    whm = { classId=24, className="White Mage", isMelee=false, isTank=false },
    blm = { classId=25, className="Black Mage", isMelee=false, isTank=false },
    acn = { classId=26, className="Arcanist", isMelee=false, isTank=false },
    smn = { classId=27, className="Summoner", isMelee=false, isTank=false },
    sch = { classId=28, className="Scholar", isMelee=false, isTank=false },
    rog = { classId=29, className="Rogue", isMelee=false, isTank=false },
    nin = { classId=30, className="Ninja", isMelee=true, isTank=false },
    mch = { classId=31, className="Machinist", isMelee=false, isTank=false},
    drk = { classId=32, className="Dark Knight", isMelee=true, isTank=true },
    ast = { classId=33, className="Astrologian", isMelee=false, isTank=false },
    sam = { classId=34, className="Samurai", isMelee=true, isTank=false },
    rdm = { classId=35, className="Red Mage", isMelee=false, isTank=false },
    blu = { classId=36, className="Blue Mage", isMelee=false, isTank=false },
    gnb = { classId=37, className="Gunbreaker", isMelee=true, isTank=true },
    dnc = { classId=38, className="Dancer", isMelee=false, isTank=false },
    rpr = { classId=39, className="Reaper", isMelee=true, isTank=false },
    sge = { classId=40, className="Sage", isMelee=false, isTank=false },
    vpr = { classId=41, className="Viper", isMelee=true, isTank=false },
    pct = { classId=42, className="Pictomancer", isMelee=false, isTank=false }
}

BicolorExchangeData =
{
    {
        shopKeepName = "Gadfrid",
        zoneName = "Old Sharlayan",
        zoneId = 962,
        aetheryteName = "Old Sharlayan",
        position=Vector3(78, 5, -37),
        shopItems =
        {
            { itemName = "Bicolor Gemstone Voucher", itemIndex = 8, price = 100 },
            { itemName = "Ovibos Milk", itemIndex = 9, price = 2 },
            { itemName = "Hamsa Tenderloin", itemIndex = 10, price = 2 },
            { itemName = "Yakow Chuck", itemIndex = 11, price = 2 },
            { itemName = "Bird of Elpis Breast", itemIndex = 12, price = 2 },
            { itemName = "Egg of Elpis", itemIndex = 13, price = 2 },
            { itemName = "Amra", itemIndex = 14, price = 2 },
            { itemName = "Dynamis Crystal", itemIndex = 15, price = 2 },
            { itemName = "Almasty Fur", itemIndex = 16, price = 2 },
            { itemName = "Gaja Hide", itemIndex = 17, price = 2 },
            { itemName = "Luncheon Toad Skin", itemIndex = 18, price = 2 },
            { itemName = "Saiga Hide", itemIndex = 19, price = 2 },
            { itemName = "Kumbhira Skin", itemIndex = 20, price = 2 },
            { itemName = "Ophiotauros Hide", itemIndex = 21, price = 2 },
            { itemName = "Berkanan Sap", itemIndex = 22, price = 2 },
            { itemName = "Dynamite Ash", itemIndex = 23, price = 2 },
            { itemName = "Lunatender Blossom", itemIndex = 24, price = 2 },
            { itemName = "Mousse Flesh", itemIndex = 25, price = 2 },
            { itemName = "Petalouda Scales", itemIndex = 26, price = 2 },
        }
    },
    {
        shopKeepName = "Beryl",
        zoneName = "Solution Nine",
        zoneId = 1186,
        aetheryteName = "Solution Nine",
        position=Vector3(-198.47, 0.92, -6.95),
        miniAethernet = {
            name = "Nexus Arcade",
            position=Vector3(-157.74, 0.29, 17.43)
        },
        shopItems =
        {
            { itemName = "Turali Bicolor Gemstone Voucher", itemIndex = 6, price = 100 },
            { itemName = "Alpaca Fillet", itemIndex = 7, price = 3 },
            { itemName = "Swampmonk Thigh", itemIndex = 8, price = 3 },
            { itemName = "Rroneek Chuck", itemIndex = 9, price = 3 },
            { itemName = "Megamaguey Pineapple", itemIndex = 10, price = 3 },
            { itemName = "Branchbearer Fruit", itemIndex = 11, price = 3 },
            { itemName = "Nopalitender Tuna", itemIndex = 12, price = 3 },
            { itemName = "Rroneek Fleece", itemIndex = 13, price = 3 },
            { itemName = "Silver Lobo Hide", itemIndex = 14, price = 3 },
            { itemName = "Hammerhead Crocodile Skin", itemIndex = 15, price = 3 },
            { itemName = "Br'aax Hide", itemIndex = 16, price = 3 },
            { itemName = "Gomphotherium Skin", itemIndex = 17, price = 3 },
            { itemName = "Gargantua Hide", itemIndex = 18, price = 3 },
            { itemName = "Ty'aitya Wingblade", itemIndex = 19, price = 3 },
            { itemName = "Poison Frog Secretions", itemIndex = 20, price = 3 },
            { itemName = "Alexandrian Axe Beak Wing", itemIndex = 21, price = 3 },
            { itemName = "Lesser Apollyon Shell", itemIndex = 22, price = 3 },
            { itemName = "Tumbleclaw Weeds", itemIndex = 23, price = 3 },
        }
    }
}

FatesData = {
    {
        zoneName = "Middle La Noscea",
        zoneId = 134,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Thwack-a-Mole" , npcName="Troubled Tiller" },
                { fateName="Yellow-bellied Greenbacks", npcName="Yellowjacket Drill Sergeant"},
                { fateName="The Orange Boxes", npcName="Farmer in Need" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Lower La Noscea",
        zoneId = 135,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Away in a Bilge Hold" , npcName="Yellowjacket Veteran" },
                { fateName="Fight the Flower", npcName="Furious Farmer" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Central Thanalan",
        zoneId = 141,
        fatesList = {
            collectionsFates= {
                { fateName="Let them Eat Cactus", npcName="Hungry Hobbledehoy"},
            },
            otherNpcFates= {
                { fateName="A Few Arrows Short of a Quiver" , npcName="Crestfallen Merchant" },
                { fateName="Wrecked Rats", npcName="Coffer & Coffin Heavy" },
                { fateName="Something to Prove", npcName="Cowardly Challenger" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Eastern Thanalan",
        zoneId = 145,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Attack on Highbridge: Denouement" , npcName="Brass Blade" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Southern Thanalan",
        zoneId = 146,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        },
        flying = false
    },
    {
        zoneName = "Outer La Noscea",
        zoneId = 180,
        fatesList = {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        },
        flying = false
    },
    {
        zoneName = "Coerthas Central Highlands",
        zoneId = 155,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "He Taketh It with His Eyes" --behemoth
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Coerthas Western Highlands",
        zoneId = 397,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Mor Dhona",
        zoneId = 156,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Sea of Clouds",
        zoneId = 401,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Azys Lla",
        zoneId = 402,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Dravanian Forelands",
        zoneId = 398,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "Coeurls Chase Boys Chase Coeurls" --coeurlregina
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Dravanian Hinterlands",
        zoneId=399,
        tpZoneId = 478,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Churning Mists",
        zoneId=400,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Fringes",
        zoneId = 612,
        fatesList= {
            collectionsFates= {
                { fateName="Showing The Recruits What For", npcName="Storm Commander Bharbennsyn" },
                { fateName="Get Sharp", npcName="M Tribe Youth" },
            },
            otherNpcFates= {
                { fateName="The Mail Must Get Through", npcName="Storm Herald" },
                { fateName="The Antlion's Share", npcName="M Tribe Ranger" },
                { fateName="Double Dhara", npcName="Resistence Fighter" },
                { fateName="Keeping the Peace", npcName="Resistence Fighter" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Peaks",
        zoneId = 620,
        fatesList= {
            collectionsFates= {
                { fateName="Fletching Returns", npcName="Sorry Sutler" }
            },
            otherNpcFates= {
                { fateName="Resist, Die, Repeat", npcName="Wounded Fighter" },
                { fateName="And the Bandits Played On", npcName="Frightened Villager" },
                { fateName="Forget-me-not", npcName="Coldhearth Resident" },
                { fateName="Of Mice and Men", npcName="Furious Farmer" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "The Magitek Is Back", --escort
                "A New Leaf" --escort
            }
        }
    },
    {
        zoneName = "The Lochs",
        zoneId = 621,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "A Horse Outside" --ixion
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Ruby Sea",
        zoneId = 613,
        fatesList= {
            collectionsFates= {
                { fateName="Treasure Island", npcName="Blue Avenger" },
                { fateName="The Coral High Ground", npcName="Busy Beachcomber" }
            },
            otherNpcFates= {
                { fateName="Another One Bites The Dust", npcName="Pirate Youth" },
                { fateName="Ray Band", npcName="Wounded Confederate" },
                { fateName="Bilge-hold Jin", npcName="Green Confederate" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Yanxia",
        zoneId = 614,
        fatesList= {
            collectionsFates= {
                { fateName="Rice and Shine", npcName="Flabbergasted Farmwife" },
                { fateName="More to Offer", npcName="Ginko" }
            },
            otherNpcFates= {
                { fateName="Freedom Flies", npcName="Kinko" },
                { fateName="A Tisket, a Tasket", npcName="Gyogun of the Most Bountiful Catch" }
            },
            specialFates = {
                "Foxy Lady" --foxyyy
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Azim Steppe",
        zoneId = 622,
        fatesList= {
            collectionsFates= {
                { fateName="The Dataqi Chronicles: Duty", npcName="Altani" }
            },
            otherNpcFates= {
                { fateName="Rock for Food", npcName="Oroniri Youth" },
                { fateName="Killing Dzo", npcName="Olkund Dzotamer" },
                { fateName="They Shall Not Want", npcName="Mol Shepherd" },
                { fateName="A Good Day to Die", npcName="Qestiri Merchant" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Lakeland",
        zoneId = 813,
        fatesList= {
            collectionsFates= {
                { fateName="Pick-up Sticks", npcName="Crystarium Botanist" }
            },
            otherNpcFates= {
                { fateName="Subtle Nightshade", npcName="Artless Dodger" },
                { fateName="Economic Peril", npcName="Jobb Guard" }
            },
            fatesWithContinuations = {
                "Behind Anemone Lines"
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Kholusia",
        zoneId = 814,
        fatesList= {
            collectionsFates= {
                { fateName="Ironbeard Builders - Rebuilt", npcName="Tholl Engineer" }
            },
            otherNpcFates= {},
            fatesWithContinuations = {},
            specialFates = {
                "A Finale Most Formidable" --formidable
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Amh Araeng",
        zoneId = 815,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {
                "Tolba No. 1", -- pathing is really bad to enemies
            }
        }
    },
    {
        zoneName = "Il Mheg",
        zoneId = 816,
        fatesList= {
            collectionsFates= {
                { fateName="Twice Upon a Time", npcName="Nectar-seeking Pixie" }
            },
            otherNpcFates= {
                { fateName="Once Upon a Time", npcName="Nectar-seeking Pixie" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Rak'tika Greatwood",
        zoneId = 817,
        fatesList= {
            collectionsFates= {
                { fateName="Picking up the Pieces", npcName="Night's Blessed Missionary" },
                { fateName="Pluck of the Draw", npcName="Myalna Bowsing" },
                { fateName="Monkeying Around", npcName="Fanow Warder" }
            },
            otherNpcFates= {
                { fateName="Queen of the Harpies", npcName="Fanow Huntress" },
                { fateName="Shot Through the Hart", npcName="Qilmet Redspear" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Tempest",
        zoneId = 818,
        fatesList= {
            collectionsFates= {
                { fateName="Low Coral Fiber", npcName="Teushs Ooan" },
                { fateName="Pearls Apart", npcName="Ondo Spearfisher" }
            },
            otherNpcFates= {
                { fateName="Where has the Dagon", npcName="Teushs Ooan" },
                { fateName="Ondo of Blood", npcName="Teushs Ooan" },
                { fateName="Lookin' Back on the Track", npcName="Teushs Ooan" },
            },
            fatesWithContinuations = {},
            specialFates = {
                "The Head, the Tail, the Whole Damned Thing" --archaeotania
            },
            blacklistedFates= {
                "Coral Support", -- escort fate
                "The Seashells He Sells", -- escort fate
            }
        }
    },
    {
        zoneName = "Labyrinthos",
        zoneId = 956,
        fatesList= {
            collectionsFates= {
                { fateName="Sheaves on the Wind", npcName="Vexed Researcher" },
                { fateName="Moisture Farming", npcName="Well-moisturized Researcher" }
            },
            otherNpcFates= {},
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Thavnair",
        zoneId = 957,
        fatesList= {
            collectionsFates= {
                { fateName="Full Petal Alchemist: Perilous Pickings", npcName="Sajabaht" }
            },
            otherNpcFates= {},
            specialFates = {
                "Devout Pilgrims vs. Daivadipa" --daveeeeee
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Garlemald",
        zoneId = 958,
        fatesList= {
            collectionsFates= {
                { fateName="Parts Unknown", npcName="Displaced Engineer" }
            },
            otherNpcFates= {
                { fateName="Artificial Malevolence: 15 Minutes to Comply", npcName="Keltlona" },
                { fateName="Artificial Malevolence: The Drone Army", npcName="Ebrelnaux" },
                { fateName="Artificial Malevolence: Unmanned Aerial Villains", npcName="Keltlona" },
                { fateName="Amazing Crates", npcName="Hardy Refugee" }
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Mare Lamentorum",
        zoneId = 959,
        fatesList= {
            collectionsFates= {
                { fateName="What a Thrill", npcName="Thrillingway" }
            },
            otherNpcFates= {
                { fateName="Lepus Lamentorum: Dynamite Disaster", npcName="Warringway" },
                { fateName="Lepus Lamentorum: Cleaner Catastrophe", npcName="Fallingway" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "Hunger Strikes", --really bad line of sight with rocks, get stuck not doing anything quite often
            }
        }
    },
    {
        zoneName = "Ultima Thule",
        zoneId = 960,
        fatesList= {
            collectionsFates= {
                { fateName="Omicron Recall: Comms Expansion", npcName="N-6205" }
            },
            otherNpcFates= {
                { fateName="Wings of Glory", npcName="Ahl Ein's Kin" },
                { fateName="Omicron Recall: Secure Connection", npcName="N-6205"},
                { fateName="Only Just Begun", npcName="Myhk Nehr" }
            },
            specialFates = {
                "Omicron Recall: Killing Order" --chi
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Elpis",
        zoneId = 961,
        fatesList= {
            collectionsFates= {
                { fateName="So Sorry, Sokles", npcName="Flora Overseer" }
            },
            otherNpcFates= {
                { fateName="Grand Designs: Unknown Execution", npcName="Meletos the Inscrutable" },
                { fateName="Grand Designs: Aigokeros", npcName="Meletos the Inscrutable" },
                { fateName="Nature's Staunch Protector", npcName="Monoceros Monitor" },
            },
            fatesWithContinuations = {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Urqopacha",
        zoneId = 1187,
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Pasture Expiration Date", npcName="Tsivli Stoutstrider" },
                { fateName="Gust Stop Already", npcName="Mourning Yok Huy" },
                { fateName="Lay Off the Horns", npcName="Yok Huy Vigilkeeper" },
                { fateName="Birds Up", npcName="Coffee Farmer" },
                { fateName="Salty Showdown", npcName="Chirwagur Sabreur" },
                { fateName="Fire Suppression", npcName="Tsivli Stoutstrider"} ,
                { fateName="Panaq Attack", npcName="Pelupelu Peddler" }
            },
            fatesWithContinuations = {
                { fateName="Salty Showdown", continuationIsBoss=true }
            },
            blacklistedFates= {
                "Young Volcanoes",
                "Wolf Parade", -- multiple Pelupelu Peddler npcs, rng whether it tries to talk to the right one
                "Panaq Attack" -- multiple Pelupleu Peddler npcs
            }
        }
    },
    {
        zoneName="Kozama'uka",
        zoneId=1188,
        fatesList={
            collectionsFates={
                { fateName="Borne on the Backs of Burrowers", npcName="Moblin Forager" },
                { fateName="Combing the Area", npcName="Hanuhanu Combmaker" },
                
            },
            otherNpcFates= {
                { fateName="There's Always a Bigger Beast", npcName="Hanuhanu Angler" },
                { fateName="Toucalibri at That Game", npcName="Hanuhanu Windscryer" },
                { fateName="Putting the Fun in Fungicide", npcName="Bagnobrok Craftythoughts" },
                { fateName="Reeds in Need", npcName="Hanuhanu Farmer" },
                { fateName="Tax Dodging", npcName="Pelupelu Peddler" },

            },
            fatesWithContinuations = {},
            blacklistedFates= {
                "Mole Patrol",
                "Tax Dodging" -- multiple Pelupelu Peddlers
            }
        }
    },
    {
        zoneName="Yak T'el",
        zoneId=1189,
        fatesList= {
            collectionsFates= {
                { fateName="Escape Shroom", npcName="Hoobigo Forager" }
            },
            otherNpcFates= {
                --{ fateName=, npcName="Xbr'aal Hunter" }, 2 npcs names same thing....
                { fateName="La Selva se lo Llevó", npcName="Xbr'aal Hunter" },
                { fateName="Stabbing Gutward", npcName="Doppro Spearbrother" },
                { fateName="Porting is Such Sweet Sorrow", npcName="Hoobigo Porter" }
                -- { fateName="Stick it to the Mantis", npcName="Xbr'aal Sentry" }, -- 2 npcs named same thing.....
            },
            fatesWithContinuations = {
                "Stabbing Gutward"
            },
            blacklistedFates= {
                "The Departed"
            }
        }
    },
    {
        zoneName="Shaaloani",
        zoneId=1190,
        fatesList= {
            collectionsFates= {
                { fateName="Gonna Have Me Some Fur", npcName="Tonawawtan Trapper" },
                { fateName="The Serpentlord Sires", npcName="Br'uk Vaw of the Setting Sun" }
            },
            otherNpcFates= {
                { fateName="The Dead Never Die", npcName="Tonawawtan Worker" }, --22 boss
                { fateName="Ain't What I Herd", npcName="Hhetsarro Herder" }, --23 normal
                { fateName="Helms off to the Bull", npcName="Hhetsarro Herder" }, --22 boss
                { fateName="A Raptor Runs Through It", npcName="Hhetsarro Angler" }, --24 tower defense
                { fateName="The Serpentlord Suffers", npcName="Br'uk Vaw of the Setting Sun" },
                { fateName="That's Me and the Porter", npcName="Pelupelu Peddler" },
            },
            fatesWithContinuations = {
                "The Serpentlord Sires"
            },
            specialFates = {
                "The Serpentlord Seethes" -- big snake fate
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName="Heritage Found",
        zoneId=1191,
        fatesList= {
            collectionsFates= {
                { fateName="License to Dill", npcName="Tonawawtan Provider" },
                { fateName="When It's So Salvage", npcName="Refined Reforger" }
            },
            otherNpcFates= {
                { fateName="It's Super Defective", npcName="Novice Hunter" },
                { fateName="Running of the Katobleps", npcName="Novice Hunter" },
                { fateName="Ware the Wolves", npcName="Imperiled Hunter" },
                { fateName="Domo Arigato", npcName="Perplexed Reforger" },
                { fateName="Old Stampeding Grounds", npcName="Driftdowns Reforger" },
                { fateName="Pulling the Wool", npcName="Panicked Courier" }
            },
            fatesWithContinuations = {
                { fateName="Domo Arigato", continuationIsBoss=false }
            },
            blacklistedFates= {
                "When It's So Salvage", -- terrain is terrible
                "print('I hate snakes')"
            }
        }
    },
    {
        zoneName="Living Memory",
        zoneId=1192,
        fatesList= {
            collectionsFates= {
                { fateName="Seeds of Tomorrow", npcName="Unlost Sentry GX" },
                { fateName="Scattered Memories", npcName="Unlost Sentry GX" }
            },
            otherNpcFates= {
                { fateName="Canal Carnage", npcName="Unlost Sentry GX" },
                { fateName="Mascot March", npcName="The Grand Marshal" }
            },
            fatesWithContinuations =
            {
                { fateName="Plumbers Don't Fear Slimes", continuationIsBoss=true },
                { fateName="Mascot March", continuationIsBoss=true }
            },
            specialFates =
            {
                "Mascot Murder"
            },
            blacklistedFates= {
            }
        }
    }
}

--#endregion Data

--#region Utils
function mysplit(inputstr)
  for str in string.gmatch(inputstr, "[^%.]+") do
    return str
  end
end

function load_type(type_path)
    local assembly = mysplit(type_path)
    luanet.load_assembly(assembly)
    local type_var = luanet.import_type(type_path)
    return type_var
end

EntityWrapper = load_type('SomethingNeedDoing.LuaMacro.Wrappers.EntityWrapper')

function GetBuddyTimeRemaining()
    return Instances.Buddy.CompanionInfo.TimeLeft
end

function SetMapFlag(zoneId, position)
    Dalamud.Log("[FATE] Setting map flag to zone #"..zoneId..", (X: "..position.X..", "..position.Z.." )")
    Instances.Map.Flag:SetFlagMapMarker(zoneId, position.X, position.Z)
end

function GetZoneInstance()
    local instanceId = nil
    
    -- Try multiple possible APIs for instance detection
    if InstancedContent and InstancedContent.PublicInstance then
        instanceId = InstancedContent.PublicInstance.InstanceId
        Dalamud.Log("[FATE] GetZoneInstance() via InstancedContent.PublicInstance.InstanceId: "..tostring(instanceId))
    elseif Svc.ClientState and Svc.ClientState.LocalPlayer then
        -- Try alternative method if available
        instanceId = 1 -- Default to instance 1 if we can't detect
        Dalamud.Log("[FATE] GetZoneInstance() fallback to default instance: "..tostring(instanceId))
    else
        instanceId = 0 -- No instance support
        Dalamud.Log("[FATE] GetZoneInstance() no instance support detected: "..tostring(instanceId))
    end
    
    return instanceId or 0
end

function GetTargetName()
    if Svc.Targets.Target == nil then
        return ""
    else
        return Svc.Targets.Target.Name:GetText()
    end
end

function AttemptToTargetClosestFateEnemy()
    --Svc.Targets.Target = Svc.Objects.OrderBy(DistanceToObject).FirstOrDefault(o => o.IsTargetable && o.IsHostile() && !o.IsDead && (distance == 0 || DistanceToObject(o) <= distance) && o.Struct()->FateId > 0);
    local closestTarget = nil
    local closestTargetDistance = math.maxinteger
    for i=0, Svc.Objects.Length-1 do
        local obj = Svc.Objects[i]
        if obj ~= nil and obj.IsTargetable and obj:IsHostile() and
            not obj.IsDead and EntityWrapper(obj).FateId > 0
        then
                local dist = GetDistanceToPoint(obj.Position)
                if dist < closestTargetDistance then
                    closestTargetDistance = dist
                    closestTarget = obj
                end
        end
    end
    if closestTarget ~= nil then
        Svc.Targets.Target = closestTarget
    end
end

-- Calculates a point on the line from 'start' to 'end',
-- stopping 'd' units before reaching 'end'
function MoveToTargetHitbox()
    if Svc.Targets.Target == nil then
        return
    end

    -- Vector from start to end
    local distance = GetDistanceToTarget()

    -- Distance between start and end
    if distance == 0 then
        return
    end

    -- Scale direction vector to (distance - d)
    local newDistance = distance - GetTargetHitboxRadius()
    if newDistance <= 0 then
        return
    end

    -- Calculate normalized direction vector
    local norm = (Svc.Targets.Target.Position - Svc.ClientState.LocalPlayer.Position) / distance
    local edgeOfHitbox = (norm*newDistance) + Svc.ClientState.LocalPlayer.Position
    local newPos = nil
    local halfExt = 10
    while newPos == nil do
        newPos = IPC.vnavmesh.PointOnFloor(edgeOfHitbox, false, halfExt)
        halfExt = halfExt + 10
    end
    yield("/vnav moveto "..newPos.X.." "..newPos.Y.." "..newPos.Z)
end

function HasPlugin(name)
    for plugin in luanet.each(Svc.PluginInterface.InstalledPlugins) do
        if plugin.InternalName == name then
            return true
        end
    end
    return false
end
--#endregion Utils

--#region Fate Functions
function IsCollectionsFate(fateName)
    for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if collectionsFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsBossFate(fate)
    return fate.IconId == 60722
end

function IsOtherNpcFate(fateName)
    for i, otherNpcFate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if otherNpcFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsSpecialFate(fateName)
    if SelectedZone.fatesList.specialFates == nil then
        return false
    end
    for i, specialFate in ipairs(SelectedZone.fatesList.specialFates) do
        if specialFate == fateName then
            return true
        end
    end
end

function IsBlacklistedFate(fateName)
    for i, blacklistedFate in ipairs(SelectedZone.fatesList.blacklistedFates) do
        if blacklistedFate == fateName then
            return true
        end
    end
    if not JoinCollectionsFates then
        for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
            if collectionsFate.fateName == fateName then
                return true
            end
        end
    end
    return false
end

function GetFateNpcName(fateName)
    for i, fate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
    for i, fate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if fate.fateName == fateName then
            return fate.npcName
        end
    end
end

function IsFateActive(fate)
    if fate.State == nil then
        return false
    else
        return fate.State ~= FateState.Ending and fate.State ~= FateState.Ended and fate.State ~= FateState.Failed
    end
end

function InActiveFate()
    local activeFates = Fates.GetActiveFates()
    for i=0, activeFates.Count-1 do
        if activeFates[i].InFate == true and IsFateActive(activeFates[i]) then
            return true
        end
    end
    return false
end

function SelectNextZone()
    local nextZone = nil
    local nextZoneId = Svc.ClientState.TerritoryType

    for i, zone in ipairs(FatesData) do
        if nextZoneId == zone.zoneId then
            nextZone = zone
        end
    end
    if nextZone == nil then
        yield("/echo [FATE] Current zone is only partially supported. No data on npc fates.")
        nextZone = {
            zoneName = "",
            zoneId = nextZoneId,
            fatesList= {
                collectionsFates= {},
                otherNpcFates= {},
                bossFates= {},
                blacklistedFates= {},
                fatesWithContinuations = {}
            }
        }
    end

    nextZone.zoneName = nextZone.zoneName
    nextZone.aetheryteList = {}
    local aetherytes = GetAetherytesInZone(nextZone.zoneId)
    for _, aetheryte in ipairs(aetherytes) do
        local aetherytePos = Instances.Telepo:GetAetherytePosition(aetheryte.AetheryteId)
        local aetheryteTable = {
            aetheryteName = GetAetheryteName(aetheryte),
            aetheryteId = aetheryte.AetheryteId,
            position = aetherytePos,
            aetheryteObj = aetheryte
        }
        table.insert(nextZone.aetheryteList, aetheryteTable)
    end

    if nextZone.flying == nil then
        nextZone.flying = true
    end

    return nextZone
end

function BuildFateTable(fateObj)
    Dalamud.Log("[FATE] Enter->BuildFateTable")
    local fateTable = {
        fateObject = fateObj,
        fateId = fateObj.Id,
        fateName = fateObj.Name,
        duration = fateObj.Duration,
        startTime = fateObj.StartTimeEpoch,
        position = fateObj.Location,
        isBonusFate = fateObj.IsBonus,
    }

    fateTable.npcName = GetFateNpcName(fateTable.fateName)

    local currentTime = EorzeaTimeToUnixTime(Instances.Framework.EorzeaTime)
    if fateTable.startTime == 0 then
        fateTable.timeLeft = 900
    else
        fateTable.timeElapsed = currentTime - fateTable.startTime
        fateTable.timeLeft = fateTable.duration - fateTable.timeElapsed
    end

    fateTable.isCollectionsFate = IsCollectionsFate(fateTable.fateName)
    fateTable.isBossFate = IsBossFate(fateTable.fateObject)
    fateTable.isOtherNpcFate = IsOtherNpcFate(fateTable.fateName)
    fateTable.isSpecialFate = IsSpecialFate(fateTable.fateName)
    fateTable.isBlacklistedFate = IsBlacklistedFate(fateTable.fateName)

    fateTable.continuationIsBoss = false
    fateTable.hasContinuation = false
    for _, continuationFate in ipairs(SelectedZone.fatesList.fatesWithContinuations) do
        if fateTable.fateName == continuationFate.fateName then
            fateTable.hasContinuation = true
            fateTable.continuationIsBoss = continuationFate.continuationIsBoss
        end
    end

    return fateTable
end

--[[
    Selects the better fate based on the priority order defined in FatePriority.
    Default Priority order is "DistanceTeleport" -> "Progress" -> "Bonus" -> "TimeLeft" -> "Distance"
]]
function SelectNextFateHelper(tempFate, nextFate)
    if nextFate == nil then
        Dalamud.Log("[FATE] nextFate is nil")
        return tempFate
    elseif BonusFatesOnly then
        Dalamud.Log("[FATE] only doing bonus fates")
        --Check if WaitForBonusIfBonusBuff is true, and have eithe buff, then set BonusFatesOnlyTemp to true
        if not tempFate.isBonusFate and nextFate ~= nil and nextFate.isBonusFate then
            return nextFate
        elseif tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return tempFate
        elseif not tempFate.isBonusFate and (nextFate == nil or not nextFate.isBonusFate) then
            return nil
        end
        -- if both are bonus fates, go through the regular fate selection process
    end

    if tempFate.timeLeft < MinTimeLeftToIgnoreFate or tempFate.fateObject.Progress > CompletionToIgnoreFate then
        Dalamud.Log("[FATE] Ignoring fate #"..tempFate.fateId.." due to insufficient time or high completion.")
        return nextFate
    elseif nextFate == nil then
        Dalamud.Log("[FATE] Selecting #"..tempFate.fateId.." because no other options so far.")
        return tempFate
    elseif nextFate.timeLeft < MinTimeLeftToIgnoreFate or nextFate.fateObject.Progress > CompletionToIgnoreFate then
        Dalamud.Log("[FATE] Ignoring fate #"..nextFate.fateId.." due to insufficient time or high completion.")
        return tempFate
    end

    -- Evaluate based on priority (Loop through list return first non-equal priority)
    for _, criteria in ipairs(FatePriority) do
        if criteria == "Progress" then
            Dalamud.Log("[FATE] Comparing progress: "..tempFate.fateObject.Progress.." vs "..nextFate.fateObject.Progress)
            if tempFate.fateObject.Progress > nextFate.fateObject.Progress then return tempFate end
            if tempFate.fateObject.Progress < nextFate.fateObject.Progress then return nextFate end
        elseif criteria == "Bonus" then
            Dalamud.Log("[FATE] Checking bonus status: "..tostring(tempFate.isBonusFate).." vs "..tostring(nextFate.isBonusFate))
            if tempFate.isBonusFate and not nextFate.isBonusFate then return tempFate end
            if nextFate.isBonusFate and not tempFate.isBonusFate then return nextFate end
        elseif criteria == "TimeLeft" then
            Dalamud.Log("[FATE] Comparing time left: "..tempFate.timeLeft.." vs "..nextFate.timeLeft)
            if tempFate.timeLeft > nextFate.timeLeft then return tempFate end
            if tempFate.timeLeft < nextFate.timeLeft then return nextFate end
        elseif criteria == "Distance" then
            local tempDist = GetDistanceToPoint(tempFate.position)
            local nextDist = GetDistanceToPoint(nextFate.position)
            Dalamud.Log("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        elseif criteria == "DistanceTeleport" then
            local tempDist = GetDistanceToPointWithAetheryteTravel(tempFate.position)
            local nextDist = GetDistanceToPointWithAetheryteTravel(nextFate.position)
            Dalamud.Log("[FATE] Comparing distance: "..tempDist.." vs "..nextDist)
            if tempDist < nextDist then return tempFate end
            if tempDist > nextDist then return nextFate end
        end
    end

    -- Fallback: Select fate with the lower ID
    Dalamud.Log("[FATE] Selecting lower ID fate: "..tempFate.fateId.." vs "..nextFate.fateId)
    return (tempFate.fateId < nextFate.fateId) and tempFate or nextFate
end

--Gets the Location of the next Fate. Prioritizes anything with progress above 0, then by shortest time left
function SelectNextFate()
    local fates = Fates.GetActiveFates()
    if fates == nil then
        return
    end

    local nextFate = nil
    for i = 0, fates.Count-1 do
        Dalamud.Log("[FATE] Building fate table")
        local tempFate = BuildFateTable(fates[i])
        Dalamud.Log("[FATE] Considering fate #"..tempFate.fateId.." "..tempFate.fateName)
        Dalamud.Log("[FATE] Time left on fate #:"..tempFate.fateId..": "..math.floor(tempFate.timeLeft//60).."min, "..math.floor(tempFate.timeLeft%60).."s")

        if not (tempFate.position.X == 0 and tempFate.position.Z == 0) then -- sometimes game doesn't send the correct coords
            if not tempFate.isBlacklistedFate then -- check fate is not blacklisted for any reason
                if tempFate.isBossFate then
                    Dalamud.Log("[FATE] Is a boss fate")
                    if (tempFate.isSpecialFate and tempFate.fateObject.Progress >= CompletionToJoinSpecialBossFates) or
                        (not tempFate.isSpecialFate and tempFate.fateObject.Progress >= CompletionToJoinBossFate) then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        Dalamud.Log("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to boss fate with not enough progress.")
                    end
                elseif (tempFate.isOtherNpcFate or tempFate.isCollectionsFate) and tempFate.startTime == 0 then
                    Dalamud.Log("[FATE] Is not an npc or collections fate")
                    if nextFate == nil then -- pick this if there's nothing else
                        Dalamud.Log("[FATE] Selecting this fate because there's nothing else so far")
                        nextFate = tempFate
                    elseif tempFate.isBonusFate then
                        Dalamud.Log("[FATE] tempFate.isBonusFate")
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    elseif nextFate.startTime == 0 then -- both fates are unopened npc fates
                        Dalamud.Log("[FATE] Both fates are unopened npc fates")
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        Dalamud.Log("[FATE] else")
                    end
                elseif tempFate.duration ~= 0 then -- else is normal fate. avoid unlisted talk to npc fates
                    Dalamud.Log("[FATE] Normal fate")
                    nextFate = SelectNextFateHelper(tempFate, nextFate)
                else
                    Dalamud.Log("[FATE] Fate duration was zero.")
                end
                Dalamud.Log("[FATE] Finished considering fate #"..tempFate.fateId.." "..tempFate.fateName)
            else
                Dalamud.Log("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to blacklist.")
            end
        else
            Dalamud.Log("[FATE] FATE coords were zeroed out")
        end
    
    end

    Dalamud.Log("[FATE] Finished considering all fates")

    if nextFate == nil then
        Dalamud.Log("[FATE] No eligible fates found.")
        if Echo == "All" then
            yield("/echo [FATE] No eligible fates found.")
        end
    else
        Dalamud.Log("[FATE] Final selected fate #"..nextFate.fateId.." "..nextFate.fateName)
    end
    yield("/wait 0.211")

    return nextFate
end

function AcceptNPCFateOrRejectOtherYesno()
    if Addons.GetAddon("SelectYesno").Ready then
        local dialogBox = GetNodeText("SelectYesno", 1, 2)
        if type(dialogBox) == "string" and dialogBox:find("The recommended level for this FATE is") then
            yield("/callback SelectYesno true 0") --accept fate
        else
            yield("/callback SelectYesno true 1") --decline all other boxes
        end
    end
end

--#endregion Fate Functions

--#region Movement Functions

function DistanceBetween(pos1, pos2)
    return Vector3.Distance(pos1, pos2)
end

function GetDistanceToPoint(vec3)
    return DistanceBetween(Svc.ClientState.LocalPlayer.Position, vec3)
end

function GetDistanceToTarget()
    if Svc.Targets.Target ~= nil then
        return GetDistanceToPoint(Svc.Targets.Target.Position)
    else
        return math.maxinteger
    end
end


function GetDistanceToTargetFlat()
    if Svc.Targets.Target ~= nil then
        return GetDistanceToPointFlat(Svc.Targets.Target.Position)
    else
        return math.maxinteger
    end
end

function GetDistanceToPointFlat(vec3)
    return DistanceBetweenFlat(Svc.ClientState.LocalPlayer.Position, vec3)
end

function DistanceBetweenFlat(pos1, pos2)
    local flat1 = Vector3(pos1.X, 0, pos1.Z)
    local flat2 = Vector3(pos2.X, 0, pos2.Z)
    return Vector3.Distance(flat1, flat2)
end


function RandomAdjustCoordinates(position, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = position.X + (x_adjust * math.cos(angle))
    local randomY = position.Y + maxDistance
    local randomZ = position.Z + (z_adjust * math.sin(angle))

    return Vector3(randomX, randomY, randomZ)
end

function GetAetherytesInZone(zoneId)
    local aetherytesInZone = {}
    for _, aetheryte in ipairs(Svc.AetheryteList) do
        if aetheryte.TerritoryId == zoneId then
            table.insert(aetherytesInZone, aetheryte)
        end
    end
    return aetherytesInZone
end

function GetAetheryteName(aetheryte)
    local name = aetheryte.AetheryteData.Value.PlaceName.Value.Name:GetText()
    if name == nil then
        return ""
    else
        return name
    end
end

function DistanceFromClosestAetheryteToPoint(vec3, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, vec3)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        Dalamud.Log("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            Dalamud.Log("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end

    return closestTravelDistance
end

function GetDistanceToPointWithAetheryteTravel(vec3)
    -- Get the direct flight distance (no aetheryte)
    local directFlightDistance = GetDistanceToPoint(vec3)
    Dalamud.Log("[FATE] Direct flight distance is: " .. directFlightDistance)

    -- Get the distance to the closest aetheryte, including teleportation penalty
    local distanceToAetheryte = DistanceFromClosestAetheryteToPoint(vec3, 200)
    Dalamud.Log("[FATE] Distance via closest Aetheryte is: " .. (distanceToAetheryte or "nil"))

    -- Return the minimum distance, either via direct flight or via the closest aetheryte travel
    if distanceToAetheryte == nil then
        return directFlightDistance
    else
        return math.min(directFlightDistance, distanceToAetheryte)
    end
end

function GetClosestAetheryte(position, teleportTimePenalty)
    local closestAetheryte = nil
    local closestTravelDistance = math.maxinteger
    for _, aetheryte in ipairs(SelectedZone.aetheryteList) do
        Dalamud.Log("[FATE] Considering aetheryte "..aetheryte.aetheryteName)
        local distanceAetheryteToFate = DistanceBetween(aetheryte.position, position)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        Dalamud.Log("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            Dalamud.Log("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            closestAetheryte = aetheryte
        end
    end
    if closestAetheryte ~= nil then
        Dalamud.Log("[FATE] Final selected aetheryte is: "..closestAetheryte.aetheryteName)
    else
        Dalamud.Log("[FATE] Closest aetheryte is nil")
    end

    return closestAetheryte
end

function GetClosestAetheryteToPoint(position, teleportTimePenalty)
    local directFlightDistance = GetDistanceToPoint(position)
    Dalamud.Log("[FATE] Direct flight distance is: "..directFlightDistance)
    local closestAetheryte = GetClosestAetheryte(position, teleportTimePenalty)
    if closestAetheryte ~= nil then
        local closestAetheryteDistance = DistanceBetween(position, closestAetheryte.position) + teleportTimePenalty

        if closestAetheryteDistance < directFlightDistance then
            return closestAetheryte
        end
    end
    return nil
end

function TeleportToClosestAetheryteToFate(nextFate)
    local aetheryteForClosestFate = GetClosestAetheryteToPoint(nextFate.position, 200)
    if aetheryteForClosestFate ~=nil then
        TeleportTo(aetheryteForClosestFate.aetheryteName)
        return true
    end
    return false
end

function AcceptTeleportOfferLocation(destinationAetheryte)
    if Addons.GetAddon("_NotificationTelepo").Ready then
        local location = GetNodeText("_NotificationTelepo", 3, 4)
        yield("/callback _Notification true 0 16 "..location)
        yield("/wait 1")
    end

    if Addons.GetAddon("SelectYesno").Ready then
        local teleportOfferMessage = GetNodeText("SelectYesno", 1, 2)
        if type(teleportOfferMessage) == "string" then
            local teleportOfferLocation = teleportOfferMessage:match("Accept Teleport to (.+)%?")
            if teleportOfferLocation ~= nil then
                if string.lower(teleportOfferLocation) == string.lower(destinationAetheryte) then
                    yield("/callback SelectYesno true 0") -- accept teleport
                    return
                else
                    Dalamud.Log("Offer for "..teleportOfferLocation.." and destination "..destinationAetheryte.." are not the same. Declining teleport.")
                end
            end
            yield("/callback SelectYesno true 2") -- decline teleport
            return
        end
    end
end

function TeleportTo(aetheryteName)
    AcceptTeleportOfferLocation(aetheryteName)

    while EorzeaTimeToUnixTime(Instances.Framework.EorzeaTime) - LastTeleportTimeStamp < 5 do
        Dalamud.Log("[FATE] Too soon since last teleport. Waiting...")
        yield("/wait 5.001")
    end

    yield("/li tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while Svc.Condition[CharacterCondition.casting] do
        Dalamud.Log("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while Svc.Condition[CharacterCondition.betweenAreas] do
        Dalamud.Log("[FATE] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    LastTeleportTimeStamp = EorzeaTimeToUnixTime(Instances.Framework.EorzeaTime)
end

function ChangeToNextZone()
    if not EnableMultiZone then
        return false
    end
    
    Dalamud.Log("[FATE] Multi-Zone: Switching to next zone")
    CurrentMultiZoneIndex = (CurrentMultiZoneIndex % #MultiZoneOrder) + 1
    local nextZone = MultiZoneOrder[CurrentMultiZoneIndex]
    
    Dalamud.Log("[FATE] Multi-Zone: Moving to "..nextZone.fateZoneName.." (ID: "..nextZone.zoneId..")")
    if Echo == "All" then
        yield("/echo [FATE] Multi-Zone: Moving to "..nextZone.fateZoneName)
    end
    
    -- Reset instance changes counter
    SuccessiveInstanceChanges = 0
    
    -- Find aetheryte for the zone
    local aetherytes = GetAetherytesInZone(nextZone.zoneId)
    if aetherytes and #aetherytes > 0 then
        local aetheryteName = GetAetheryteName(aetherytes[1])
        TeleportTo(aetheryteName)
        
        -- Update SelectedZone to the new zone
        SelectedZone = SelectNextZone()
        Dalamud.Log("[FATE] Multi-Zone: Now in "..SelectedZone.zoneName)
        
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return true
    else
        Dalamud.Log("[FATE] Multi-Zone: ERROR - No aetherytes found for "..nextZone.fateZoneName)
        yield("/echo [FATE] Multi-Zone: ERROR - No aetherytes found for "..nextZone.fateZoneName)
        return false
    end
end

function ChangeInstance()
    Dalamud.Log("[FATE] ChangeInstance() called - SuccessiveInstanceChanges: "..SuccessiveInstanceChanges..", NumberOfInstances: "..NumberOfInstances)
    if SuccessiveInstanceChanges >= NumberOfInstances then
        if EnableMultiZone then
            -- Try to change zones instead of stopping
            if ChangeToNextZone() then
                return
            end
        end
        
        if CompanionScriptMode then
            local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))
            if WaitingForFateRewards == nil and not shouldWaitForBonusBuff then
                StopScript = true
            else
                Dalamud.Log("[Fate Farming] Waiting for buff or fate rewards")
                yield("/wait 3")
            end
        else
            yield("/wait 10")
            SuccessiveInstanceChanges = 0
        end
        return
    end

    yield("/target aetheryte") -- search for nearby aetheryte
    if Svc.Targets.Target == nil or GetTargetName() ~= "aetheryte" then -- if no aetheryte within targeting range, teleport to it
        Dalamud.Log("[FATE] Aetheryte not within targetable range")
        local closestAetheryte = nil
        local closestAetheryteDistance = math.maxinteger
        for i, aetheryte in ipairs(SelectedZone.aetheryteList) do
            -- GetDistanceToPoint is implemented with raw distance instead of distance squared
            local distanceToAetheryte = GetDistanceToPoint(aetheryte.position)
            if distanceToAetheryte < closestAetheryteDistance then
                closestAetheryte = aetheryte
                closestAetheryteDistance = distanceToAetheryte
            end
        end
        if closestAetheryte ~= nil then
            TeleportTo(closestAetheryte.aetheryteName)
        end
        return
    end

    if WaitingForFateRewards ~= nil then
        yield("/wait 10")
        return
    end

    if GetDistanceToTarget() > 10 then
        Dalamud.Log("[FATE] Targeting aetheryte, but greater than 10 distance")
        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
            if Svc.Condition[CharacterCondition.flying] and SelectedZone.flying then
                yield("/vnav flytarget")
            else
                yield("/vnav movetarget")
            end
        elseif GetDistanceToTarget() > 20 and not Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.mounting
            Dalamud.Log("[FATE] State Change: Mounting")
        end
        return
    end

    Dalamud.Log("[FATE] Within 10 distance")
    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
        return
    end

    if Svc.Condition[CharacterCondition.mounted] then
        State = CharacterState.changeInstanceDismount
        Dalamud.Log("[FATE] State Change: ChangeInstanceDismount")
        return
    end

    Dalamud.Log("[FATE] Transferring to next instance")
    local nextInstance = (GetZoneInstance() % 2) + 1
    yield("/li "..nextInstance) -- start instance transfer
    yield("/wait 1") -- wait for instance transfer to register
    State = CharacterState.ready
    SuccessiveInstanceChanges = SuccessiveInstanceChanges + 1
    Dalamud.Log("[FATE] State Change: Ready")
end

function WaitForContinuation()
    if InActiveFate() then
        Dalamud.Log("WaitForContinuation IsInFate")
        local nextFateId = Fates.GetNearestFate()
        if nextFateId ~= CurrentFate.fateObject then
            CurrentFate = BuildFateTable(nextFateId)
            State = CharacterState.doFate
            Dalamud.Log("[FATE] State Change: DoFate")
        end
    elseif os.clock() - LastFateEndTime > 30 then
        Dalamud.Log("WaitForContinuation Abort")
        Dalamud.Log("Over 30s since end of last fate. Giving up on part 2.")
        TurnOffCombatMods()
        State = CharacterState.ready
        Dalamud.Log("State Change: Ready")
    else
        Dalamud.Log("WaitForContinuation Else")
        if BossFatesClass ~= nil then
            local currentClass = Player.Job.Id
            Dalamud.Log("WaitForContinuation "..CurrentFate.fateName)
            if not Player.IsPlayerOccupied then
                if CurrentFate.continuationIsBoss and currentClass ~= BossFatesClass.classId then
                    Dalamud.Log("WaitForContinuation SwitchToBoss")
                    yield("/gs change "..BossFatesClass.className)
                elseif not CurrentFate.continuationIsBoss and currentClass ~= MainClass.classId then
                    Dalamud.Log("WaitForContinuation SwitchToMain")
                    yield("/gs change "..MainClass.className)
                end
            end
        end

        yield("/wait 1")
    end
end

function FlyBackToAetheryte()
    NextFate = SelectNextFate()
    if NextFate ~= nil then
        yield("/vnav stop")
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    local closestAetheryte = GetClosestAetheryte(Svc.ClientState.LocalPlayer.Position, 0)
    if closestAetheryte == nil then
        DownTimeWaitAtNearestAetheryte = false
        yield("/echo Could not find aetheryte in the area. Turning off feature to fly back to aetheryte.")
        return
    end
    -- if you get any sort of error while flying back, then just abort and tp back
    if Addons.GetAddon("_TextError").Ready and GetNodeText("_TextError", 1) == "Your mount can fly no higher." then
        yield("/vnav stop")
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    yield("/target aetheryte")

    if Svc.Targets.Target ~= nil and GetTargetName() == "aetheryte" and GetDistanceToTarget() <= 20 then
        if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
            yield("/vnav stop")
        end

        if Svc.Condition[CharacterCondition.flying] then
            yield("/ac dismount") -- land but don't actually dismount, to avoid running chocobo timer
        elseif Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        else
            if MountToUse == "mount roulette" then
                yield('/gaction "mount roulette"')
            else
                yield('/mount "' .. MountToUse)
            end
        end
        return
    end
    
    if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
        Dalamud.Log("[FATE] ClosestAetheryte.y: "..closestAetheryte.position.Y)
        if closestAetheryte ~= nil then
            SetMapFlag(SelectedZone.zoneId, closestAetheryte.position)
            IPC.vnavmesh.PathfindAndMoveTo(closestAetheryte.position, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying)
        end
    end

    if not Svc.Condition[CharacterCondition.mounted] then
        Mount()
        return
    end
end

function Mount()
    if MountToUse == "mount roulette" then
        yield('/gaction "mount roulette"')
    else
        yield('/mount "' .. MountToUse)
    end
    yield("/wait 1")
end

function MountState()
    if Svc.Condition[CharacterCondition.mounted] then
        yield("/wait 1") -- wait a second to make sure you're firmly on the mount
        State = CharacterState.moveToFate
        Dalamud.Log("[FATE] State Change: MoveToFate")
    else
        Mount()
    end
end

function Dismount()
    if Svc.Condition[CharacterCondition.flying] then
        yield('/ac dismount')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then

            if Svc.Condition[CharacterCondition.flying] and GetDistanceToPoint(LastStuckCheckPosition) < 2 then
                Dalamud.Log("[FATE] Unable to dismount here. Moving to another spot.")
                local random = RandomAdjustCoordinates(Svc.ClientState.LocalPlayer.Position, 10)
                local nearestFloor = IPC.vnavmesh.PointOnFloor(random, true, 100)
                if nearestFloor ~= nil then
                    IPC.vnavmesh.PathfindAndMoveTo(nearestFloor, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying)
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
        end
    elseif Svc.Condition[CharacterCondition.mounted] then
        yield('/ac dismount')
    end
end

function MiddleOfFateDismount()
    if not IsFateActive(CurrentFate.fateObject) then
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    if Svc.Targets.Target ~= nil then
        if GetDistanceToTarget() > (MaxDistance + GetTargetHitboxRadius() + 5) then
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                Dalamud.Log("[FATE] MiddleOfFateDismount IPC.vnavmesh.PathfindAndMoveTo")
                if Svc.Condition[CharacterCondition.flying] then
                    yield("/vnav flytarget")
                else
                    yield("/vnav movetarget")
                end
            end
        else
            if Svc.Condition[CharacterCondition.mounted] then
                Dalamud.Log("[FATE] MiddleOfFateDismount Dismount()")
                Dismount()
            else
                yield("/vnav stop")
                State = CharacterState.doFate
                Dalamud.Log("[FATE] State Change: DoFate")
            end
        end
    else
        AttemptToTargetClosestFateEnemy()
    end
end

function NpcDismount()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
    else
        State = CharacterState.interactWithNpc
        Dalamud.Log("[FATE] State Change: InteractWithFateNpc")
    end
end

function ChangeInstanceDismount()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
    else
        State = CharacterState.changingInstances
        Dalamud.Log("[FATE] State Change: ChangingInstance")
    end
end

--Paths to the Fate NPC Starter
function MoveToNPC()
    yield("/target "..CurrentFate.npcName)
    if Svc.Targets.Target ~= nil and GetTargetName()==CurrentFate.npcName then
        if GetDistanceToTarget() > 5 then
            yield("/vnav movetarget")
        end
    end
end

--Paths to the Fate. CurrentFate is set here to allow MovetoFate to change its mind,
--so CurrentFate is possibly nil.
function MoveToFate()
    SuccessiveInstanceChanges = 0

    if not Player.Available then
        return
    end

    if CurrentFate~=nil and not IsFateActive(CurrentFate.fateObject) then
        Dalamud.Log("[FATE] Next Fate is dead, selecting new Fate.")
        yield("/vnav stop")
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    NextFate = SelectNextFate()
    if NextFate == nil then -- when moving to next fate, CurrentFate == NextFate
        yield("/vnav stop")
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    elseif CurrentFate == nil or NextFate.fateId ~= CurrentFate.fateId then
        yield("/vnav stop")
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.position)
        return
    end

    -- change to secondary class if it's a boss fate
    if BossFatesClass ~= nil then
        local currentClass = Player.Job.Id
        if CurrentFate.isBossFate and currentClass ~= BossFatesClass.classId then
            yield("/gs change "..BossFatesClass.className)
            return
        elseif not CurrentFate.isBossFate and currentClass ~= MainClass.classId then
            yield("/gs change "..MainClass.className)
            return
        end
    end

    -- upon approaching fate, pick a target and switch to pathing towards target
    if GetDistanceToPoint(CurrentFate.position) < 60 then
        if Svc.Targets.Target ~= nil then
            Dalamud.Log("[FATE] Found FATE target, immediate rerouting")
            yield("/wait 0.1")
            MoveToTargetHitbox()
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) then
                State = CharacterState.interactWithNpc
                Dalamud.Log("[FATE] State Change: Interact with npc")
            -- if GetTargetName() == CurrentFate.npcName then
            --     State = CharacterState.interactWithNpc
            -- elseif GetTargetFateID() == CurrentFate.fateId then
            --     State = CharacterState.middleOfFateDismount
            --     Dalamud.Log("[FATE] State Change: MiddleOfFateDismount")
            else
                State = CharacterState.MiddleOfFateDismount
                Dalamud.Log("[FATE] State Change: MiddleOfFateDismount")
            end
            return
        else
            if (CurrentFate.isOtherNpcFate or CurrentFate.isCollectionsFate) and not InActiveFate() then
                yield("/target "..CurrentFate.npcName)
            else
                AttemptToTargetClosestFateEnemy()
            end
            yield("/wait 0.5") -- give it a moment to make sure the target sticks
            return
        end
    end

    -- check for stuck
    if (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) and Svc.Condition[CharacterCondition.mounted] then
        local now = os.clock()
        if now - LastStuckCheckTime > 10 then

            if GetDistanceToPoint(LastStuckCheckPosition) < 3 then
                yield("/vnav stop")
                yield("/wait 1")
                Dalamud.Log("[FATE] Antistuck")
                local up10 = Svc.ClientState.LocalPlayer.Position + Vector3(0, 10, 0)
                IPC.vnavmesh.PathfindAndMoveTo(up10, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying) -- fly up 10 then try again
            end
            
            LastStuckCheckTime = now
            LastStuckCheckPosition = Svc.ClientState.LocalPlayer.Position
        end
        return
    end

    if not MovingAnnouncementLock then
        Dalamud.Log("[FATE] Moving to fate #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        MovingAnnouncementLock = true
        if Echo == "All" then
            yield("/echo [FATE] Moving to fate #"..CurrentFate.fateId.." "..CurrentFate.fateName)
        end
    end

    if TeleportToClosestAetheryteToFate(CurrentFate) then
        Dalamud.Log("Executed teleport to closer aetheryte")
        return
    end

    local nearestFloor = CurrentFate.position
    if not (CurrentFate.isCollectionsFate or CurrentFate.isOtherNpcFate) then
        nearestFloor = RandomAdjustCoordinates(CurrentFate.position, 10)
    end

    if GetDistanceToPoint(nearestFloor) > 5 then
        if not Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.mounting
            Dalamud.Log("[FATE] State Change: Mounting")
            return
        elseif not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
            if Player.CanFly and SelectedZone.flying then
                yield("/vnav flyflag")
            else
                yield("/vnav moveflag")
            end
        end
    else
        State = CharacterState.MiddleOfFateDismount
    end
end

function InteractWithFateNpc()
    if InActiveFate() or CurrentFate.startTime > 0 then
        yield("/vnav stop")
        State = CharacterState.doFate
        Dalamud.Log("[FATE] State Change: DoFate")
        yield("/wait 1") -- give the fate a second to register before dofate and lsync
    elseif not IsFateActive(CurrentFate.fateObject) then
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
    elseif IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        if Svc.Targets.Target ~= nil and GetTargetName() == CurrentFate.npcName and GetDistanceToTarget() < (5*math.random()) then
            yield("/vnav stop")
        end
        return
    else
        -- if target is already selected earlier during pathing, avoids having to target and move again
        if (Svc.Targets.Target == nil or GetTargetName()~=CurrentFate.npcName) then
            yield("/target "..CurrentFate.npcName)
            return
        end

        if Svc.Condition[CharacterCondition.mounted] then
            State = CharacterState.npcDismount
            Dalamud.Log("[FATE] State Change: NPCDismount")
            return
        end

        if GetDistanceToPoint(Svc.Targets.Target.Position) > 5 then
            MoveToNPC()
            return
        end

        if Addons.GetAddon("SelectYesno").Ready then
            AcceptNPCFateOrRejectOtherYesno()
        elseif not Svc.Condition[CharacterCondition.occupied] then
            yield("/interact")
        end
    end
end

function CollectionsFateTurnIn()
    AcceptNPCFateOrRejectOtherYesno()

    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateObject) then
        CurrentFate = nil
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end

    if (Svc.Targets.Target == nil or GetTargetName()~=CurrentFate.npcName) then
        TurnOffCombatMods()
        yield("/target "..CurrentFate.npcName)
        yield("/wait 1")

        -- if too far from npc to target, then head towards center of fate
        if (Svc.Targets.Target == nil or GetTargetName()~=CurrentFate.npcName and CurrentFate.fateObject.Progress ~= nil and CurrentFate.fateObject.Progress < 100) then
            if not IPC.vnavmesh.PathfindInProgress() and not IPC.vnavmesh.IsRunning() then
                IPC.vnavmesh.PathfindAndMoveTo(CurrentFate.position, false)
            end
        else
            yield("/vnav stop")
        end
        return
    end

    if GetDistanceToTarget() > 5 then
        if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
            MoveToNPC()
        end
    else
        if Inventory.GetItemCount(CurrentFate.fateObject.EventItem) >= 7 then
            GotCollectionsFullCredit = true
        end

        yield("/vnav stop")
        yield("/interact")
        yield("/wait 3")

        if CurrentFate.fateObject.Progress < 100 then
            TurnOnCombatMods()
            State = CharacterState.doFate
            Dalamud.Log("[FATE] State Change: DoFate")
        else
            if GotCollectionsFullCredit then
                State = CharacterState.unexpectedCombat
                Dalamud.Log("[FATE] State Change: UnexpectedCombat")
            end
        end

        if CurrentFate ~=nil and CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
            Dalamud.Log("[FATE] Attempting to clear target.")
            ClearTarget()
            yield("/wait 1")
        end
    end
end

--#endregion

--#region Combat Functions

function GetClassJobTableFromName(classString)
    if classString == nil or classString == "" then
        return nil
    end

    for classJobId=1, 42 do
        local job = Player.GetJob(classJobId)
        if job.Name == classString then
            return job
        end
    end
    
    Dalamud.Log("[FATE] Cannot recognize combat job for boss fates.")
    return nil
end

function SummonChocobo()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
        return
    end

    if ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft then
        if Inventory.GetItemCount(4868) > 0 then
            yield("/item Gysahl Greens")
            yield("/wait 3")
            yield('/cac "'..ChocoboStance..' stance"')
        elseif ShouldAutoBuyGysahlGreens then
            State = CharacterState.autoBuyGysahlGreens
            Dalamud.Log("[FATE] State Change: AutoBuyGysahlGreens")
            return
        end
    end
    State = CharacterState.ready
    Dalamud.Log("[FATE] State Change: Ready")
end

function AutoBuyGysahlGreens()
    if Inventory.GetItemCount(4868) > 0 then -- don't need to buy
        if Addons.GetAddon("Shop").Ready then
            yield("/callback Shop true -1")
        elseif Svc.ClientState.TerritoryType == SelectedZone.zoneId then
            yield("/item Gysahl Greens")
        else
            State = CharacterState.ready
            Dalamud.Log("State Change: ready")
        end
        return
    else
        if Svc.ClientState.TerritoryType ~=  129 then
            yield("/vnav stop")
            TeleportTo("Limsa Lominsa Lower Decks")
            return
        else
            local gysahlGreensVendor = { position=Vector3(-62.1, 18.0, 9.4), npcName="Bango Zango" }
            if GetDistanceToPoint(gysahlGreensVendor.position) > 5 then
                if not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) then
                    IPC.vnavmesh.PathfindAndMoveTo(gysahlGreensVendor.position, false)
                end
            elseif Svc.Targets.Target ~= nil and GetTargetName() == gysahlGreensVendor.npcName then
                yield("/vnav stop")
                if Addons.GetAddon("SelectYesno").Ready then
                    yield("/callback SelectYesno true 0")
                elseif Addons.GetAddon("SelectIconString").Ready then
                    yield("/callback SelectIconString true 0")
                    return
                elseif Addons.GetAddon("Shop").Ready then
                    yield("/callback Shop true 0 2 99")
                    return
                elseif not Svc.Condition[CharacterCondition.occupied] then
                    yield("/interact")
                    yield("/wait 1")
                    return
                end
            else
                yield("/vnav stop")
                yield("/target "..gysahlGreensVendor.npcName)
            end
        end
    end
end

function ClearTarget()
    Svc.Targets.Target = nil
end

function GetTargetHitboxRadius()
    if Svc.Targets.Target ~= nil then
        return Svc.Targets.Target.HitboxRadius
    else
        return 0
    end
end

function GetPlayerHitboxRadius()
    if Svc.ClientState.LocalPlayer ~= nil then
        return Svc.ClientState.LocalPlayer.HitboxRadius
    else
        return 0
    end
end

function TurnOnAoes()
    if not AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation off")
            yield("/rotation auto on")
            Dalamud.Log("[FATE] TurnOnAoes /rotation auto on")

            if RSRAoeType == "Off" then
                yield("/rotation settings aoetype 0")
            elseif RSRAoeType == "Cleave" then
                yield("/rotation settings aoetype 1")
            elseif RSRAoeType == "Full" then
                yield("/rotation settings aoetype 2")
            end
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationAoePreset)
        end
        AoesOn = true
    end
end

function TurnOffAoes()
    if AoesOn then
        if RotationPlugin == "RSR" then
            yield("/rotation settings aoetype 1")
            yield("/rotation manual")
            Dalamud.Log("[FATE] TurnOffAoes /rotation manual")
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationSingleTargetPreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationSingleTargetPreset)
        end
        AoesOn = false
    end
end

function TurnOffRaidBuffs()
    if AoesOn then
        if RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationHoldBuffPreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationHoldBuffPreset)
        end
    end
end

function SetMaxDistance()
    --ranged and casters have a further max distance so not always running all way up to target
    if not Player.Job.IsMeleeDPS or not Player.Job.IsTank then
        MaxDistance = RangedDist
        Dalamud.Log("[FATE] Setting max distance to "..RangedDist)
    else
        MaxDistance = MeleeDist --default to melee distance
        Dalamud.Log("[FATE] Setting max distance to "..MeleeDist)
    end
end

function TurnOnCombatMods(rotationMode)
    if not CombatModsOn then
        CombatModsOn = true
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        if RotationPlugin == "RSR" then
            if rotationMode == "manual" then
                yield("/rotation manual")
                Dalamud.Log("[FATE] TurnOnCombatMods /rotation manual")
            else
                yield("/rotation off")
                yield("/rotation auto on")
                Dalamud.Log("[FATE] TurnOnCombatMods /rotation auto on")
            end
        elseif RotationPlugin == "BMR" then
            yield("/bmrai setpresetname "..RotationAoePreset)
        elseif RotationPlugin == "VBM" then
            yield("/vbm ar toggle "..RotationAoePreset)
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto on")
        end
        
        if not AiDodgingOn then
            SetMaxDistance()
            
            if DodgingPlugin == "BMR" then
                yield("/bmrai on")
                yield("/bmrai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/bmrai followcombat on")
                -- yield("/bmrai followoutofcombat on")
                yield("/bmrai maxdistancetarget " .. MaxDistance)
            elseif DodgingPlugin == "VBM" then
                yield("/vbmai on")
                yield("/vbmai followtarget on") -- overrides navmesh path and runs into walls sometimes
                yield("/vbmai followcombat on")
                -- yield("/bmrai followoutofcombat on")
                yield("/vbmai maxdistancetarget " .. MaxDistance)
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions on") --This Disables VBM AI Auto-Target
                end
            end
            AiDodgingOn = true
        end
    end
end

function TurnOffCombatMods()
    if CombatModsOn then
        Dalamud.Log("[FATE] Turning off combat mods")
        CombatModsOn = false

        if RotationPlugin == "RSR" then
            yield("/rotation off")
            Dalamud.Log("[FATE] TurnOffCombatMods /rotation off")
        elseif RotationPlugin == "BMR" or RotationPlugin == "VBM" then
            yield("/bmrai setpresetname nil")
        elseif RotationPlugin == "Wrath" then
            yield("/wrath auto off")
        end

        -- turn off BMR so you don't start following other mobs
        if AiDodgingOn then
            if DodgingPlugin == "BMR" then
                yield("/bmrai off")
                yield("/bmrai followtarget off")
                yield("/bmrai followcombat off")
                yield("/bmrai followoutofcombat off")
            elseif DodgingPlugin == "VBM" then
                yield("/vbm ar disable")
                yield("/vbmai off")
                yield("/vbmai followtarget off")
                yield("/vbmai followcombat off")
                yield("/vbmai followoutofcombat off")
                if RotationPlugin ~= "VBM" then
                    yield("/vbmai ForbidActions off") --This Enables VBM AI Auto-Target
                end
            end
            AiDodgingOn = false
        end
    end
end

function HandleUnexpectedCombat()
    TurnOnCombatMods("manual")

    local nearestFate = Fates.GetNearestFate()
    if InActiveFate() and nearestFate.Progress < 100 then
        CurrentFate = BuildFateTable(nearestFate)
        State = CharacterState.doFate
        Dalamud.Log("[FATE] State Change: DoFate")
        return
    elseif not Svc.Condition[CharacterCondition.inCombat] then
        yield("/vnav stop")
        ClearTarget()
        TurnOffCombatMods()
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        local randomWait = (math.floor(math.random()*MaxWait * 1000)/1000) + MinWait -- truncated to 3 decimal places
        yield("/wait "..randomWait)
        return
    end

    -- if Svc.Condition[CharacterCondition.mounted] then
    --     if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
    --         IPC.vnavmesh.PathfindAndMoveTo(Svc.ClientState.Location, true)
    --     end
    --     yield("/wait 10")
    --     return
    -- end

    -- targets whatever is trying to kill you
    if Svc.Targets.Target == nil then
        yield("/battletarget")
    end

    -- pathfind closer if enemies are too far
    if Svc.Targets.Target ~= nil then
        if GetDistanceToTargetFlat() > (MaxDistance + GetTargetHitboxRadius() + GetPlayerHitboxRadius()) then
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                if Player.CanFly and SelectedZone.flying then
                    yield("/vnav flytarget")
                else
                    MoveToTargetHitbox()
                end
            end
        else
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            elseif not Svc.Condition[CharacterCondition.inCombat] then
                --inch closer 3 seconds
                if Svc.Condition[CharacterCondition.flying] and SelectedZone.flying then
                    yield("/vnav flytarget")
                else
                    MoveToTargetHitbox()
                end
                yield("/wait 3")
            end
        end
    end
    yield("/wait 1")
end



function DoFate()
    Dalamud.Log("[FATE] DoFate")
    if WaitingForFateRewards == nil or WaitingForFateRewards.fateId ~= CurrentFate.fateId then
        WaitingForFateRewards = CurrentFate
        Dalamud.Log("[FATE] WaitingForFateRewards DoFate: "..tostring(WaitingForFateRewards.fateId))
    end
    local currentClass = Player.Job
    -- switch classes (mostly for continutation fates that pop you directly into the next one)
    if CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= BossFatesClass.classId and not Player.IsBusy then
        TurnOffCombatMods()
        yield("/gs change "..BossFatesClass.className)
        yield("/wait 1")
        return
    elseif not CurrentFate.isBossFate and BossFatesClass ~= nil and currentClass ~= MainClass.classId and not Player.IsBusy then
        TurnOffCombatMods()
        yield("/gs change "..MainClass.className)
        yield("/wait 1")
        return
    elseif InActiveFate() and (CurrentFate.fateObject.MaxLevel < Player.Job.Level) and not Player.IsLevelSynced then
        yield("/lsync")
        yield("/wait 0.5") -- give it a second to register
    elseif IsFateActive(CurrentFate.fateObject) and not InActiveFate() and CurrentFate.fateObject.Progress ~= nil and CurrentFate.fateObject.Progress < 100 and (GetDistanceToPoint(CurrentFate.position) < CurrentFate.fateObject.Radius + 10) and not Svc.Condition[CharacterCondition.mounted] and not (IPC.vnavmesh.IsRunning() or IPC.vnavmesh.PathfindInProgress()) then -- got pushed out of fate. go back
        yield("/vnav stop")
        yield("/wait 1")
        Dalamud.Log("[FATE] pushed out of fate going back!")
        IPC.vnavmesh.PathfindAndMoveTo(CurrentFate.position, Svc.Condition[CharacterCondition.flying] and SelectedZone.flying)
        return
    elseif not IsFateActive(CurrentFate.fateObject) or CurrentFate.fateObject.Progress == 100 then
        yield("/vnav stop")
        ClearTarget()
        if not Dalamud.Log("[FATE] HasContintuation check") and CurrentFate.hasContinuation then
            LastFateEndTime = os.clock()
            State = CharacterState.waitForContinuation
            Dalamud.Log("[FATE] State Change: WaitForContinuation")
            return
        else
            DidFate = true
            Dalamud.Log("[FATE] No continuation for "..CurrentFate.fateName)
            local randomWait = (math.floor(math.random() * (math.max(0, MaxWait - 3)) * 1000)/1000) + MinWait -- truncated to 3 decimal places
            yield("/wait "..randomWait)
            TurnOffCombatMods()
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
        return
    elseif Svc.Condition[CharacterCondition.mounted] then
        State = CharacterState.MiddleOfFateDismount
        Dalamud.Log("[FATE] State Change: MiddleOfFateDismount")
        return
    elseif CurrentFate.isCollectionsFate then
        yield("/wait 1") -- needs a moment after start of fate for GetFateEventItem to populate
        if Inventory.GetItemCount(CurrentFate.fateObject.EventItem) >= 7 or (GotCollectionsFullCredit and CurrentFate.fateObject.Progress == 100) then
            yield("/vnav stop")
            State = CharacterState.collectionsFateTurnIn
            Dalamud.Log("[FATE] State Change: CollectionsFatesTurnIn")
        end
    end

    Dalamud.Log("[FATE] DoFate->Finished transition checks")

    -- do not target fate npc during combat
    if CurrentFate.npcName ~=nil and GetTargetName() == CurrentFate.npcName then
        Dalamud.Log("[FATE] Attempting to clear target.")
        ClearTarget()
        yield("/wait 1")
    end

    TurnOnCombatMods("auto")

    GemAnnouncementLock = false

    -- switches to targeting forlorns for bonus (if present)
    if not IgnoreForlorns then
        yield("/target Forlorn Maiden")
        if not IgnoreBigForlornOnly then
            yield("/target The Forlorn")
        end
    end

    if (GetTargetName() == "Forlorn Maiden" or GetTargetName() == "The Forlorn") then
        if IgnoreForlorns or (IgnoreBigForlornOnly and GetTargetName() == "The Forlorn") then
            ClearTarget()
        elseif not Svc.Targets.Target.IsDead then
            if not ForlornMarked then
                yield("/enemysign attack1")
                if Echo == "All" then
                    yield("/echo Found Forlorn! <se.3>")
                end
                TurnOffAoes()
                ForlornMarked = true
            end
        else
            ClearTarget()
            TurnOnAoes()
        end
    else
        TurnOnAoes()
    end

    -- targets whatever is trying to kill you
    if Entity.Target == nil then
        yield("/battletarget")
    end

    -- clears target
    if Entity.Target ~= nil and Entity.Target.FateId ~= CurrentFate.fateId and not Entity.Target.IsInCombat then
        Entity.Target:ClearTarget()
    end

    -- do not interrupt casts to path towards enemies
    if Svc.Condition[CharacterCondition.casting] then
        return
    end

    --hold buff thingy
    if CurrentFate.fateObject.Progress ~= nil and CurrentFate.fateObject.Progress >= PercentageToHoldBuff then
        TurnOffRaidBuffs()
    end

    -- pathfind closer if enemies are too far
    if not Svc.Condition[CharacterCondition.inCombat] then
        if Svc.Targets.Target ~= nil then
            if GetDistanceToTargetFlat() <= (MaxDistance + GetTargetHitboxRadius() + GetPlayerHitboxRadius()) then
                if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                    yield("/vnav stop")
                    yield("/wait 5.002") -- wait 5s before inching any closer
                elseif (GetDistanceToTargetFlat() > (1 + GetTargetHitboxRadius() + GetPlayerHitboxRadius())) and not Svc.Condition[CharacterCondition.casting] then -- never move into hitbox
                    yield("/vnav movetarget")
                    yield("/wait 1") -- inch closer by 1s
                end
            elseif not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                yield("/wait 5.003") -- give 5s for enemy AoE casts to go off before attempting to move closer
                if (Svc.Targets.Target ~= nil and not Svc.Condition[CharacterCondition.inCombat]) and not Svc.Condition[CharacterCondition.casting] then
                    MoveToTargetHitbox()
                end
            end
            return
        else
            AttemptToTargetClosestFateEnemy()
            yield("/wait 1") -- wait in case target doesn't stick
            if (Svc.Targets.Target == nil) and not Svc.Condition[CharacterCondition.casting] then
                IPC.vnavmesh.PathfindAndMoveTo(CurrentFate.position, false)
            end
        end
    else
        if Svc.Targets.Target ~= nil and (GetDistanceToTargetFlat() <= (MaxDistance + GetTargetHitboxRadius() + GetPlayerHitboxRadius())) then
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            end
        elseif not CurrentFate.isBossFate then
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                yield("/wait 5.004")
                if Svc.Targets.Target ~= nil and not Svc.Condition[CharacterCondition.casting] then
                    if Svc.Condition[CharacterCondition.flying] and SelectedZone.flying then
                        yield("/vnav flytarget")
                    else
                        MoveToTargetHitbox()
                    end
                end
            end
        end
    end
end

--#endregion

--#region State Transition Functions

function Ready()
    FoodCheck()
    PotionCheck()

    CombatModsOn = false -- expect RSR to turn off after every fate
    GotCollectionsFullCredit = false
    ForlornMarked = false
    MovingAnnouncementLock = false

    local shouldWaitForBonusBuff = WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289))
    local needsRepair = Inventory.GetItemsInNeedOfRepairs(RemainingDurabilityToRepair)
    local spiritbonded = Inventory.GetSpiritbondedItems()

    NextFate = SelectNextFate()
    if CurrentFate ~= nil and not IsFateActive(CurrentFate.fateObject) then
        CurrentFate = nil
    end

    if CurrentFate == nil then
        Dalamud.Log("[FATE] CurrentFate is nil")
    else
        Dalamud.Log("[FATE] CurrentFate is "..CurrentFate.fateName)
    end

    if NextFate == nil then
        Dalamud.Log("[FATE] NextFate is nil")
    else
        Dalamud.Log("[FATE] NextFate is "..NextFate.fateName)
    end

    if not Dalamud.Log("[FATE] Ready -> Player.Available") and not Player.Available then
        return
    elseif not Dalamud.Log("[FATE] Ready -> Repair") and RemainingDurabilityToRepair > 0 and needsRepair.Count > 0 and
        (not shouldWaitForBonusBuff or (SelfRepair and Inventory.GetItemCount(33916) > 0)) then
        State = CharacterState.repair
        Dalamud.Log("[FATE] State Change: Repair")
    elseif not Dalamud.Log("[FATE] Ready -> ExtractMateria") and ShouldExtractMateria and spiritbonded.Count > 0 and Inventory.GetFreeInventorySlots() > 1 then
        State = CharacterState.extractMateria
        Dalamud.Log("[FATE] State Change: ExtractMateria")
    elseif (not Dalamud.Log("[FATE] Ready -> WaitBonusBuff") and NextFate == nil and shouldWaitForBonusBuff) and DownTimeWaitAtNearestAetheryte then
        if Svc.Targets.Target == nil or GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 20 then
            State = CharacterState.flyBackToAetheryte
            Dalamud.Log("[FATE] State Change: FlyBackToAetheryte")
        else
            yield("/wait 10")
        end
        return
    elseif not Dalamud.Log("[FATE] Ready -> ExchangingVouchers") and
        ShouldExchangeBicolorGemstones and (BicolorGemCount >= 1400) and not shouldWaitForBonusBuff
    then
        if WaitingForFateRewards == nil then
            State = CharacterState.exchangingVouchers
            Dalamud.Log("[FATE] State Change: ExchangingVouchers")
        else
            Dalamud.Log("[FATE] Waiting for fate rewards: "..WaitingForFateRewards.fateId)
        end
    elseif not Dalamud.Log("[FATE] Ready -> ProcessRetainers") and WaitingForFateRewards == nil and
        Retainers and ARRetainersWaitingToBeProcessed() and Inventory.GetFreeInventorySlots() > 1  and not shouldWaitForBonusBuff
    then
        State = CharacterState.processRetainers
        Dalamud.Log("[FATE] State Change: ProcessingRetainers")
    elseif not Dalamud.Log("[FATE] Ready -> GC TurnIn") and ShouldGrandCompanyTurnIn and
        Inventory.GetFreeInventorySlots() < InventorySlotsLeft and not shouldWaitForBonusBuff
    then
        State = CharacterState.gcTurnIn
        Dalamud.Log("[FATE] State Change: GCTurnIn")
    elseif not Dalamud.Log("[FATE] Ready -> TeleportBackToFarmingZone") and Svc.ClientState.TerritoryType ~=  SelectedZone.zoneId then
        TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
        return
    elseif not Dalamud.Log("[FATE] Ready -> SummonChocobo") and ShouldSummonChocobo and GetBuddyTimeRemaining() <= ResummonChocoboTimeLeft and
        (not shouldWaitForBonusBuff or Inventory.GetItemCount(4868) > 0) then
        State = CharacterState.summonChocobo
    elseif not Dalamud.Log("[FATE] Ready -> NextFate nil") and NextFate == nil then
        if EnableMultiZone and not shouldWaitForBonusBuff then
            -- Multi-zone: try to change zone directly when no fates
            Dalamud.Log("[FATE] Multi-Zone: No FATEs found, attempting zone change")
            if Echo == "All" then
                yield("/echo [FATE] Multi-Zone: No eligible FATEs found, switching zones")
            end
            if ChangeToNextZone() then
                return
            end
            -- If zone change failed, fall through to instance change
        end
        local currentInstance = GetZoneInstance()
        Dalamud.Log("[FATE] Instance check - EnableChangeInstance: "..tostring(EnableChangeInstance)..", ZoneInstance: "..tostring(currentInstance)..", shouldWaitForBonusBuff: "..tostring(shouldWaitForBonusBuff))
        if EnableChangeInstance and currentInstance > 0 and not shouldWaitForBonusBuff then
            Dalamud.Log("[FATE] Conditions met for instance change!")
            State = CharacterState.changingInstances
            Dalamud.Log("[FATE] State Change: ChangingInstances")
            return
        elseif CompanionScriptMode and not shouldWaitForBonusBuff then
            if WaitingForFateRewards == nil then
                StopScript = true
                Dalamud.Log("[FATE] StopScript: Ready")
            else
                Dalamud.Log("[FATE] Waiting for fate rewards")
            end
        elseif (Svc.Targets.Target == nil or GetTargetName() ~= "aetheryte" or GetDistanceToTarget() > 20) and DownTimeWaitAtNearestAetheryte then
            State = CharacterState.flyBackToAetheryte
            Dalamud.Log("[FATE] State Change: FlyBackToAetheryte")
        else
            if not Svc.Condition[CharacterCondition.mounted] then
                Mount()
            end
            yield("/wait 10")
        end
        return
    elseif CompanionScriptMode and DidFate and not shouldWaitForBonusBuff then
        if WaitingForFateRewards == nil then
            StopScript = true
            Dalamud.Log("[FATE] StopScript: DidFate")
        else
            Dalamud.Log("[FATE] Waiting for fate rewards")
        end
    elseif not Dalamud.Log("[FATE] Ready -> MovingToFate") then -- and ((CurrentFate == nil) or (GetFateProgress(CurrentFate.fateId) == 100) and NextFate ~= nil) then
        CurrentFate = NextFate
        SetMapFlag(SelectedZone.zoneId, CurrentFate.position)
        State = CharacterState.moveToFate
        Dalamud.Log("[FATE] State Change: MovingtoFate "..CurrentFate.fateName)
    end

    if not GemAnnouncementLock and (Echo == "All" or Echo == "Gems") then
        GemAnnouncementLock = true
        if BicolorGemCount >= 1400 then
            yield("/echo [FATE] You're almost capped with "..tostring(BicolorGemCount).."/1500 gems! <se.3>")
        else
            yield("/echo [FATE] Gems: "..tostring(BicolorGemCount).."/1500")
        end
    end
end


function HandleDeath()
    CurrentFate = nil

    if CombatModsOn then
        TurnOffCombatMods()
    end

    if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
        yield("/vnav stop")
    end

    if Svc.Condition[CharacterCondition.dead] then --Condition Dead
        if ReturnOnDeath then
            if Echo and not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                if Echo == "All" then
                    yield("/echo [FATE] You have died. Returning to home aetheryte.")
                end
            end

            if Addons.GetAddon("SelectYesno").Ready then --rez addon yes
                yield("/callback SelectYesno true 0")
                yield("/wait 0.1")
            end
        else
            if Echo and not DeathAnnouncementLock then
                DeathAnnouncementLock = true
                if Echo == "All" then
                    yield("/echo [FATE] You have died. Waiting until script detects you're alive again...")
                end
            end
            yield("/wait 1")
        end
    else
        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        DeathAnnouncementLock = false
    end
end

function ExecuteBicolorExchange()
    CurrentFate = nil

    if BicolorGemCount >= 1400 then
        if Addons.GetAddon("SelectYesno").Ready then
            yield("/callback SelectYesno true 0")
            return
        end

        if Addons.GetAddon("ShopExchangeCurrency").Ready then
            yield("/callback ShopExchangeCurrency false 0 "..SelectedBicolorExchangeData.item.itemIndex.." "..(BicolorGemCount//SelectedBicolorExchangeData.item.price))
            return
        end

        if Svc.ClientState.TerritoryType ~=  SelectedBicolorExchangeData.zoneId then
            TeleportTo(SelectedBicolorExchangeData.aetheryteName)
            return
        end
    
        if SelectedBicolorExchangeData.miniAethernet ~= nil and
            GetDistanceToPoint(SelectedBicolorExchangeData.position) > (DistanceBetween(SelectedBicolorExchangeData.miniAethernet.position, SelectedBicolorExchangeData.position) + 10) then
            Dalamud.Log("Distance to shopkeep is too far. Using mini aetheryte.")
            yield("/li "..SelectedBicolorExchangeData.miniAethernet.name)
            yield("/wait 1") -- give it a moment to register
            return
        elseif Addons.GetAddon("TelepotTown").Ready then
            Dalamud.Log("TelepotTown open")
            yield("/callback TelepotTown false -1")
        elseif GetDistanceToPoint(SelectedBicolorExchangeData.position) > 5 then
            Dalamud.Log("Distance to shopkeep is too far. Walking there.")
            if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                Dalamud.Log("Path not running")
                IPC.vnavmesh.PathfindAndMoveTo(SelectedBicolorExchangeData.position, false)
            end
        else
            Dalamud.Log("[FATE] Arrived at Shopkeep")
            if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
                yield("/vnav stop")
            end
    
            if Svc.Targets.Target == nil or GetTargetName() ~= SelectedBicolorExchangeData.shopKeepName then
                yield("/target "..SelectedBicolorExchangeData.shopKeepName)
            elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                yield("/interact")
            end
        end
    else
        if Addons.GetAddon("ShopExchangeCurrency").Ready then
            Dalamud.Log("[FATE] Attemping to close shop window")
            yield("/callback ShopExchangeCurrency true -1")
            return
        elseif Svc.Condition[CharacterCondition.occupiedInEvent] then
            Dalamud.Log("[FATE] Character still occupied talking to shopkeeper")
            yield("/wait 0.5")
            return
        end

        State = CharacterState.ready
        Dalamud.Log("[FATE] State Change: Ready")
        return
    end
end

function ProcessRetainers()
    CurrentFate = nil

    Dalamud.Log("[FATE] Handling retainers...")
    if ARRetainersWaitingToBeProcessed() and Inventory.GetFreeInventorySlots() > 1 then
    
        if IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning() then
            return
        end

        if Svc.ClientState.TerritoryType ~=  129 then
            yield("/vnav stop")
            TeleportTo("Limsa Lominsa Lower Decks")
            return
        end

        local summoningBell = {
            name="Summoning Bell",
            position=Vector3(-122.72, 18.00, 20.39)
        }
        if GetDistanceToPoint(summoningBell.position) > 4.5 then
            IPC.vnavmesh.PathfindAndMoveTo(summoningBell.position, false)
            return
        end

        if Svc.Targets.Target == nil or GetTargetName() ~= summoningBell.name then
            yield("/target "..summoningBell.name)
            return
        end

        if not Svc.Condition[CharacterCondition.occupiedSummoningBell] then
            yield("/interact")
            if Addons.GetAddon("RetainerList").Ready then
                yield("/ays e")
                if Echo == "All" then
                    yield("/echo [FATE] Processing retainers")
                end
                yield("/wait 1")
            end
        end
    else
        if Addons.GetAddon("RetainerList").Ready then
            yield("/callback RetainerList true -1")
        elseif not Svc.Condition[CharacterCondition.occupiedSummoningBell] then
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
    end
end

function GrandCompanyTurnIn()
    if Inventory.GetFreeInventorySlots() <= InventorySlotsLeft then
        local gcZoneIds = {
            129, --Limsa Lominsa
            132, --New Gridania
            130 --"Ul'dah - Steps of Nald"
        }
        if Svc.ClientState.TerritoryType ~=  gcZoneIds[Player.GrandCompany] then
            yield("/li gc")
            yield("/wait 1")
        elseif IPC.Deliveroo.IsTurnInRunning() then
            return
        else
            yield("/deliveroo enable")
        end
    else
        State = CharacterState.ready
        Dalamud.Log("State Change: Ready")
    end
end

function Repair()
    local needsRepair = Inventory.GetItemsInNeedOfRepairs(RemainingDurabilityToRepair)
    if Addons.GetAddon("SelectYesno").Ready then
        yield("/callback SelectYesno true 0")
        return
    end

    if Addons.GetAddon("Repair").Ready then
        if needsRepair.Count == nil or needsRepair.Count == 0 then
            yield("/callback Repair true -1") -- if you don't need repair anymore, close the menu
        else
            yield("/callback Repair true 0") -- select repair
        end
        return
    end

    -- if occupied by repair, then just wait
    if Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] then
        Dalamud.Log("[FATE] Repairing...")
        yield("/wait 1")
        return
    end

    local hawkersAlleyAethernetShard = { x=-213.95, y=15.99, z=49.35 }
    if SelfRepair then
        if Inventory.GetItemCount(33916) > 0 then
            if Addons.GetAddon("Shop").Ready then
                yield("/callback Shop true -1")
                return
            end

            if Svc.ClientState.TerritoryType ~=  SelectedZone.zoneId then
                TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
                return
            end

            if Svc.Condition[CharacterCondition.mounted] then
                Dismount()
                Dalamud.Log("[FATE] State Change: Dismounting")
                return
            end

            if needsRepair.Count > 0 then
                if not Addons.GetAddon("Repair").Ready then
                    Dalamud.Log("[FATE] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.ready
                Dalamud.Log("[FATE] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if Svc.ClientState.TerritoryType ~=  129 then
                if Echo == "All" then
                    yield("/echo Out of Dark Matter! Purchasing more from Limsa Lominsa.")
                end
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local darkMatterVendor = { npcName="Unsynrael", x=-257.71, y=16.19, z=50.11, wait=0.08 }
            if GetDistanceToPoint(darkMatterVendor.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, darkMatterVendor.position) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif Addons.GetAddon("TelepotTown").Ready then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(darkMatterVendor.position) > 5 then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    IPC.vnavmesh.PathfindAndMoveTo(darkMatterVendor.position, false)
                end
            else
                if Svc.Targets.Target == nil or GetTargetName() ~= darkMatterVendor.npcName then
                    yield("/target "..darkMatterVendor.npcName)
                elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                    yield("/interact")
                elseif Addons.GetAddon("SelectYesno").Ready then
                    yield("/callback SelectYesno true 0")
                elseif Addons.GetAddon("Shop") then
                    yield("/callback Shop true 0 40 99")
                end
            end
        else
            if Echo == "All" then
                yield("/echo Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to Limsa mender.")
            end
            SelfRepair = false
        end
    else
        if needsRepair.Count > 0 then
            if Svc.ClientState.TerritoryType ~= 129 then
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end
            
            local mender = { npcName="Alistair", x=-246.87, y=16.19, z=49.83 }
            if GetDistanceToPoint(mender.position) > (DistanceBetween(hawkersAlleyAethernetShard.position, mender.position) + 10) then
                yield("/li Hawkers' Alley")
                yield("/wait 1") -- give it a moment to register
            elseif Addons.GetAddon("TelepotTown").Ready then
                yield("/callback TelepotTown false -1")
            elseif GetDistanceToPoint(mender.position) > 5 then
                if not (IPC.vnavmesh.PathfindInProgress() or IPC.vnavmesh.IsRunning()) then
                    IPC.vnavmesh.PathfindAndMoveTo(mender.position, false)
                end
            else
                if Svc.Targets.Target == nil or GetTargetName() ~= mender.npcName then
                    yield("/target "..mender.npcName)
                elseif not Svc.Condition[CharacterCondition.occupiedInQuestEvent] then
                    yield("/interact")
                end
            end
        else
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
    end
end

function ExtractMateria()
    if Svc.Condition[CharacterCondition.mounted] then
        Dismount()
        Dalamud.Log("[FATE] State Change: Dismounting")
        return
    end

    if Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] then
        return
    end

    if Inventory.GetSpiritbondedItems().Count > 0 and Inventory.GetFreeInventorySlots() > 1 then
        if not Addons.GetAddon("Materialize").Ready then
            yield("/generalaction \"Materia Extraction\"")
            return
        end

        Dalamud.Log("[FATE] Extracting materia...")
            
        if Addons.GetAddon("MaterializeDialog").Ready then
            yield("/callback MaterializeDialog true 0")
        else
            yield("/callback Materialize true 2 0")
        end
    else
        if Addons.GetAddon("Materialize").Ready then
            yield("/callback Materialize true -1")
        else
            State = CharacterState.ready
            Dalamud.Log("[FATE] State Change: Ready")
        end
    end
end

--#endregion State Transition Functions

--#region Misc Functions

function EorzeaTimeToUnixTime(eorzeaTime)
    return eorzeaTime/(144/7) -- 24h Eorzea Time equals 70min IRL
end

function HasStatusId(statusId)
    local statusList = Svc.ClientState.LocalPlayer.StatusList
    if statusList == nil then
        return false
    end
    for i=0, statusList.Length-1 do
        if statusList[i].StatusId == statusId then
            return true
        end
    end
    return false
end

function FoodCheck()
    --food usage
    if not HasStatusId(48) and Food ~= "" then
        yield("/item " .. Food)
    end
end

function PotionCheck()
    --pot usage
    if not HasStatusId(49) and Potion ~= "" then
        yield("/item " .. Potion)
    end
end

function GetNodeText(addonName, nodePath, ...)
    local addon = Addons.GetAddon(addonName)
    repeat
        yield("/wait 0.1")
    until addon.Ready
    return addon:GetNode(nodePath, ...).Text
end

function ARRetainersWaitingToBeProcessed()
    local offlineCharacterData = IPC.AutoRetainer.GetOfflineCharacterData(Svc.ClientState.LocalContentId)
    for i=0, offlineCharacterData.RetainerData.Count-1 do
        local retainer = offlineCharacterData.RetainerData[i]
        if retainer.HasVenture and retainer.VentureEndsAt <= os.time() then
            return true
        end
    end
    return false
end

--#endregion Misc Functions

CharacterState = {
    ready = Ready,
    dead = HandleDeath,
    unexpectedCombat = HandleUnexpectedCombat,
    mounting = MountState,
    npcDismount = NpcDismount,
    MiddleOfFateDismount = MiddleOfFateDismount,
    moveToFate = MoveToFate,
    interactWithNpc = InteractWithFateNpc,
    collectionsFateTurnIn = CollectionsFateTurnIn,
    doFate = DoFate,
    waitForContinuation = WaitForContinuation,
    changingInstances = ChangeInstance,
    changeInstanceDismount = ChangeInstanceDismount,
    flyBackToAetheryte = FlyBackToAetheryte,
    extractMateria = ExtractMateria,
    repair = Repair,
    exchangingVouchers = ExecuteBicolorExchange,
    processRetainers = ProcessRetainers,
    gcTurnIn = GrandCompanyTurnIn,
    summonChocobo = SummonChocobo,
    autoBuyGysahlGreens = AutoBuyGysahlGreens
}

--#region Main

Dalamud.Log("[FATE] Starting fate farming script.")

Food = Config.Get("Food")
Potion = Config.Get("Potion")
ResummonChocoboTimeLeft         = 3 * 60        --Resummons chocobo if there's less than this many seconds left on the timer, so it doesn't disappear on you in the middle of a fate.
ChocoboStance = Config.Get("Chocobo Companion Stance") -- Options: Follow, Free, Defender, Healer, Attacker, None. Do not summon if None.
ShouldSummonChocobo = ChocoboStance == "Follow"
    or ChocoboStance == "Free"
    or ChocoboStance == "Defender"
    or ChocoboStance == "Healer"
    or ChocoboStance == "Attacker"

ShouldAutoBuyGysahlGreens = Config.Get("Buy Gysahl Greens?")    --
MountToUse                          = "mount roulette"       --The mount you'd like to use when flying between fates
FatePriority                        = {"DistanceTeleport", "Progress", "Bonus", "TimeLeft", "Distance"}

--Fate Combat Settings
CompletionToIgnoreFate = Config.Get("Ignore FATE if progress is over (%)")
MinTimeLeftToIgnoreFate = Config.Get("Ignore FATE if duration is less than (mins)")*60
CompletionToJoinBossFate = Config.Get("Ignore boss FATEs until progress is at least (%)")
CompletionToJoinSpecialBossFates = Config.Get("Ignore Special FATEs until progress is at least (%)")
ClassForBossFates = ""            --If you want to use a different class for boss fates, set this to the 3 letter abbreviation
                                                        --for the class. Ex: "PLD"
JoinCollectionsFates = Config.Get("Do collection FATEs?")
BonusFatesOnly = Config.Get("Do only bonus FATEs?")         --If true, will only do bonus fates and ignore everything else

MeleeDist = Config.Get("Max melee distance")
RangedDist = Config.Get("Max ranged distance")

RotationPlugin = Config.Get("Rotation Plugin")
if RotationPlugin == "Any" then
    if HasPlugin("Wrath") then
        RotationPlugin = "Wrath"
    elseif HasPlugin("RotationSolver") then
        RotationPlugin = "RSR"
    elseif HasPlugin("BossModReborn") then
        RotationPlugin = "BMR"
    elseif HasPlugin("BossMod") then
        RotationPlugin = "VBM"
    end
elseif RotationPlugin == "Wrath" and HasPlugin("Wrath") then
    RotationPlugin = "Wrath"
elseif RotationPlugin == "RotationSolver" and HasPlugin("RotationSolver") then
    RotationPlugin = "RSR"
elseif RotationPlugin == "BossModReborn" and HasPlugin("BossModReborn") then
    RotationPlugin = "BMR"
elseif RotationPlugin == "BossMod" and HasPlugin("BossMod") then
    RotationPlugin = "VBM"
else
    StopScript = true
end
    RSRAoeType                      = "Full"        --Options: Cleave/Full/Off

    -- For BMR/VBM/Wrath
    RotationSingleTargetPreset      = ""            --Preset name with single target strategies (for forlorns). TURN OFF AUTOMATIC TARGETING FOR THIS PRESET
    RotationAoePreset               = ""            --Preset with AOE + Buff strategies.
    RotationHoldBuffPreset          = ""            --Preset to hold 2min burst when progress gets to seleted %
    PercentageToHoldBuff            = 65            --Ideally you'll want to make full use of your buffs, higher than 70% will still waste a few seconds if progress is too fast.

    IgnoreForlorns = false
IgnoreBigForlornOnly = false
Forlorns = Config.Get("Forlorns")
if Forlorns == "None" then
    IgnoreForlorns = true
elseif Forlorns == "Small" then
    IgnoreBigForlornOnly = true
end

--Post Fate Settings
MinWait                             = 3             --Min number of seconds it should wait until mounting up for next fate.
MaxWait                             = 10            --Max number of seconds it should wait until mounting up for next fate.
                                                        --Actual wait time will be a randomly generated number between MinWait and MaxWait.
DownTimeWaitAtNearestAetheryte      = false         --When waiting for fates to pop, should you fly to the nearest Aetheryte and wait there?
EnableChangeInstance = Config.Get("Change instances if no FATEs?")
WaitIfBonusBuff = true          --Don't change instances if you have the Twist of Fate bonus buff
NumberOfInstances = 2
EnableMultiZone = Config.Get("Multi-Zone Farming")

-- Multi-Zone Orders by Expansion
MultiZoneExpansions = {
    -- A Realm Reborn (ARR) - Zones 134-180
    ARR = {
        { fateZoneName = "Middle La Noscea", zoneId = 134 },
        { fateZoneName = "Lower La Noscea", zoneId = 135 },
        { fateZoneName = "Central Thanalan", zoneId = 141 },
        { fateZoneName = "Eastern Thanalan", zoneId = 145 },
        { fateZoneName = "Southern Thanalan", zoneId = 146 },
        { fateZoneName = "Coerthas Central Highlands", zoneId = 155 },
        { fateZoneName = "Mor Dhona", zoneId = 156 },
        { fateZoneName = "Outer La Noscea", zoneId = 180 }
    },
    -- Heavensward (HW) - Zones 397-402
    HW = {
        { fateZoneName = "Coerthas Western Highlands", zoneId = 397 },
        { fateZoneName = "The Dravanian Forelands", zoneId = 398 },
        { fateZoneName = "The Dravanian Hinterlands", zoneId = 399 },
        { fateZoneName = "The Churning Mists", zoneId = 400 },
        { fateZoneName = "The Sea of Clouds", zoneId = 401 },
        { fateZoneName = "Azys Lla", zoneId = 402 }
    },
    -- Stormblood (SB) - Zones 612-622
    SB = {
        { fateZoneName = "The Fringes", zoneId = 612 },
        { fateZoneName = "The Ruby Sea", zoneId = 613 },
        { fateZoneName = "Yanxia", zoneId = 614 },
        { fateZoneName = "The Peaks", zoneId = 620 },
        { fateZoneName = "The Lochs", zoneId = 621 },
        { fateZoneName = "The Azim Steppe", zoneId = 622 }
    },
    -- Shadowbringers (ShB) - Zones 813-818
    ShB = {
        { fateZoneName = "Lakeland", zoneId = 813 },
        { fateZoneName = "Kholusia", zoneId = 814 },
        { fateZoneName = "Amh Araeng", zoneId = 815 },
        { fateZoneName = "Il Mheg", zoneId = 816 },
        { fateZoneName = "The Rak'tika Greatwood", zoneId = 817 },
        { fateZoneName = "The Tempest", zoneId = 818 }
    },
    -- Endwalker (EW) - Zones 956-961
    EW = {
        { fateZoneName = "Labyrinthos", zoneId = 956 },
        { fateZoneName = "Thavnair", zoneId = 957 },
        { fateZoneName = "Garlemald", zoneId = 958 },
        { fateZoneName = "Mare Lamentorum", zoneId = 959 },
        { fateZoneName = "Ultima Thule", zoneId = 960 },
        { fateZoneName = "Elpis", zoneId = 961 }
    },
    -- Dawntrail (DT) - Zones 1187-1192
    DT = {
        { fateZoneName = "Urqopacha", zoneId = 1187 },
        { fateZoneName = "Kozama'uka", zoneId = 1188 },
        { fateZoneName = "Yak T'el", zoneId = 1189 },
        { fateZoneName = "Shaaloani", zoneId = 1190 },
        { fateZoneName = "Heritage Found", zoneId = 1191 },
        { fateZoneName = "Living Memory", zoneId = 1192 }
    }
}

-- Determine which expansion the current zone belongs to
function GetExpansionFromZoneId(zoneId)
    if zoneId >= 134 and zoneId <= 180 then
        return "ARR"
    elseif zoneId >= 397 and zoneId <= 402 then
        return "HW"
    elseif zoneId >= 612 and zoneId <= 622 then
        return "SB"
    elseif zoneId >= 813 and zoneId <= 818 then
        return "ShB"
    elseif zoneId >= 956 and zoneId <= 961 then
        return "EW"
    elseif zoneId >= 1187 and zoneId <= 1192 then
        return "DT"
    else
        return nil -- Unknown expansion
    end
end

-- Current expansion and zone tracking
CurrentExpansion = nil
MultiZoneOrder = {}
CurrentMultiZoneIndex = 1
ShouldExchangeBicolorGemstones = Config.Get("Exchange bicolor gemstones?")
ItemToPurchase = Config.Get("Exchange bicolor gemstones for")
ShouldExchangeBicolorGemstones = true
if ItemToPurchase == "" or ItemToPurchase == nil then
    ShouldExchangeBicolorGemstones = false
end
SelfRepair = Config.Get("Self repair?")
RemainingDurabilityToRepair     = 10            --the amount it needs to drop before Repairing (set it to 0 if you don't want it to repair)
ShouldAutoBuyDarkMatter         = true          --Automatically buys a 99 stack of Grade 8 Dark Matter from the Limsa gil vendor if you're out
ShouldExtractMateria                = true          --should it Extract Materia
Retainers = Config.Get("Pause for retainers?")
ShouldGrandCompanyTurnIn = Config.Get("Dump extra gear at GC?")         --should it do Turn ins at the GC (requires Deliveroo)
    InventorySlotsLeft              = 5             --how much inventory space before turning in

ReturnOnDeath = Config.Get("Return on death?")

Echo = Config.Get("Echo logs")
CompanionScriptMode                 = false         --Set to true if you are using the fate script with a companion script (such as the Atma Farmer)

-- Get user-configured plugin
local dodgeConfig = Config.Get("Dodging Plugin")  -- Options: Any / BossModReborn / BossMod / None

-- Resolve "any" or specific plugin if available
if dodgeConfig == "Any" then
    if HasPlugin("BossModReborn") then
        DodgingPlugin = "BMR"
    elseif HasPlugin("BossMod") then
        DodgingPlugin = "VBM"
    else
        DodgingPlugin = "None"
    end
elseif dodgeConfig == "BossModReborn" and HasPlugin("BossModReborn") then
    DodgingPlugin = "BMR"
elseif dodgeConfig == "BossMod" and HasPlugin("BossMod") then
    DodgingPlugin = "VBM"
else
    DodgingPlugin = "None"
end

-- Override if RotationPlugin already uses a dodging plugin
if RotationPlugin == "BMR" then
    DodgingPlugin = "BMR"
elseif RotationPlugin == "VBM" then
    DodgingPlugin = "VBM"
end

-- Final warning if no dodging plugin is active
if DodgingPlugin == "None" then
    yield("/echo [FATE] Warning: you do not have an AI dodging plugin configured, so your character will stand in AOEs. Please install either Veyn's BossMod or BossMod Reborn")
end

if Retainers and not HasPlugin("AutoRetainer") then
    Retainers = false
    yield("/echo [FATE] Warning: you have enabled the feature to process retainers, but you do not have AutoRetainer installed.")
end

if ShouldGrandCompanyTurnIn and not HasPlugin("Deliveroo") then
    ShouldGrandCompanyTurnIn = false
    yield("/echo [FATE] Warning: you have enabled the feature to process GC turn ins, but you do not have Deliveroo installed.")
end

if not CompanionScriptMode then
    yield("/at y")
end

StopScript = false
DidFate = false
GemAnnouncementLock = false
DeathAnnouncementLock = false
MovingAnnouncementLock = false
SuccessiveInstanceChanges = 0
LastInstanceChangeTimestamp = 0
LastTeleportTimeStamp = 0
GotCollectionsFullCredit = false -- needs 7 items for  full
-- variable to track collections fates that you have completed but are still active.
-- will not leave area or change instance if value ~= 0
WaitingForFateRewards = nil
LastFateEndTime = os.clock()
LastStuckCheckTime = os.clock()
LastStuckCheckPosition = Player.Entity.Position
MainClass = Player.Job
BossFatesClass = nil
if ClassForBossFates ~= "" then
    BossFatesClass = GetClassJobTableFromName(ClassForBossFates)
end
SetMaxDistance()

SelectedZone = SelectNextZone()
if SelectedZone.zoneName ~= "" and Echo == "All" then
    yield("/echo [FATE] Farming "..SelectedZone.zoneName)
end
Dalamud.Log("[FATE] Farming Start for "..SelectedZone.zoneName)

-- Initialize multi-zone based on current expansion
if EnableMultiZone then
    CurrentExpansion = GetExpansionFromZoneId(SelectedZone.zoneId)
    if CurrentExpansion and MultiZoneExpansions[CurrentExpansion] then
        MultiZoneOrder = MultiZoneExpansions[CurrentExpansion]
        -- Find current zone index within the expansion
        for i, zone in ipairs(MultiZoneOrder) do
            if zone.zoneId == SelectedZone.zoneId then
                CurrentMultiZoneIndex = i
                break
            end
        end
        Dalamud.Log("[FATE] Multi-Zone enabled for "..CurrentExpansion.." expansion with "..#MultiZoneOrder.." zones")
        Dalamud.Log("[FATE] Current zone: "..SelectedZone.zoneName.." (Index: "..CurrentMultiZoneIndex..")")
        if Echo == "All" then
            yield("/echo [FATE] Multi-Zone: "..CurrentExpansion.." expansion detected ("..#MultiZoneOrder.." zones)")
        end
    else
        Dalamud.Log("[FATE] Multi-Zone enabled but current zone not supported for multi-zone")
        if Echo == "All" then
            yield("/echo [FATE] Multi-Zone: Current zone not supported for multi-zone cycling")
        end
        EnableMultiZone = false -- Disable if not in supported expansion
    end
end


if ShouldExchangeBicolorGemstones ~= false then
    for _, shop in ipairs(BicolorExchangeData) do
        for _, item in ipairs(shop.shopItems) do
            if item.itemName == ItemToPurchase then
                SelectedBicolorExchangeData = {
                    shopKeepName = shop.shopKeepName,
                    zoneId = shop.zoneId,
                    aetheryteName = shop.aetheryteName,
                    miniAethernet = shop.miniAethernet,
                    position = shop.position,
                    item = item
                }
            end
        end
    end
    if SelectedBicolorExchangeData == nil then
        yield("/echo [FATE] Cannot recognize bicolor shop item "..ItemToPurchase.."! Please make sure it's in the BicolorExchangeData table!")
        StopScript = true
    end
end

State = CharacterState.ready
CurrentFate = nil
if InActiveFate() then
    CurrentFate = BuildFateTable(Fates.GetNearestFate())
end

if ShouldSummonChocobo and GetBuddyTimeRemaining() > 0 then
    yield('/cac "'..ChocoboStance..' stance"')
end

while not StopScript do
    local nearestFate = Fates.GetNearestFate()
    if not IPC.vnavmesh.IsReady() then
        yield("/echo [FATE] Waiting for vnavmesh to build...")
        Dalamud.Log("[FATE] Waiting for vnavmesh to build...")
        repeat
            yield("/wait 1")
        until IPC.vnavmesh.IsReady()
    end
    if State ~= CharacterState.dead and Svc.Condition[CharacterCondition.dead] then
        State = CharacterState.dead
        Dalamud.Log("[FATE] State Change: Dead")
    elseif State ~= CharacterState.unexpectedCombat and State ~= CharacterState.doFate and
        State ~= CharacterState.waitForContinuation and State ~= CharacterState.collectionsFateTurnIn and
        (not InActiveFate() or (InActiveFate() and IsCollectionsFate(nearestFate.Name) and nearestFate.Progress == 100)) and
        Svc.Condition[CharacterCondition.inCombat]
    then
        State = CharacterState.unexpectedCombat
        Dalamud.Log("[FATE] State Change: UnexpectedCombat")
    end
    
    BicolorGemCount = Inventory.GetItemCount(26807)

    if not (Player.Entity.IsCasting or
        Svc.Condition[CharacterCondition.betweenAreas] or
        Svc.Condition[CharacterCondition.jumping48] or
        Svc.Condition[CharacterCondition.jumping61] or
        Svc.Condition[CharacterCondition.mounting57] or
        Svc.Condition[CharacterCondition.mounting64] or
        Svc.Condition[CharacterCondition.beingMoved] or
        Svc.Condition[CharacterCondition.occupiedMateriaExtractionAndRepair] or
        IPC.Lifestream.IsBusy())
    then
        if WaitingForFateRewards ~= nil and not WaitingForFateRewards.fateObject.State == FateState.Ended then
            WaitingForFateRewards = nil
            Dalamud.Log("[FATE] WaitingForFateRewards: "..tostring(WaitingForFateRewards.fateId))
        end
        State()
    end
    yield("/wait 0.1")
end
yield("/vnav stop")

if Player.Job.Id ~= MainClass.Id then
    yield("/gs change "..MainClass.Name)
end
--#endregion Main
