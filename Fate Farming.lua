--[[

****************************************
*            Fate Farming              * 
****************************************

Created by: Prawellp, sugarplum done updates v0.1.8 to v0.1.9, pot0to

***********
* Version *
*  2.5.11  *
***********
    -> 2.5.11   Fixed RSR spam when BM/R is turned off
                Cleaned up pandora checks
                Added check for do fates getting pushed out of bounds
                Fixing mount and leave after collections fate
                Fixed collections fates table for Living Memory
                Added checks for IsPlayerAvailable to ready and change instance
                Added check for getting pushed out of fate, keep pandora fate targeting mode off when out of fate
                Updated Garlemald and Raktikka fates, credit: Gigglels
                Fixed limsa mender telepot town, removed debug echoes
                Reworked change instance spaghetti, Added limsa mender
                Reworked combat into separate UnexpectedCombat and DoFate states, fixed repair
                Fixed state transition out of combat for collections fates
                Changed targting system to use Pandora FATE Targeting mode again
                Changed order to check for bossfates before npc fates, in order to accommodate fates that are both
                Attempted fixes for leaving collections fate at 100%, fixing some garlemald fates
                Manually vnav stop and clear targets after fate
    -> 2.0.0    State system

*********************
*  Required Plugins *
*********************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : (Main Plugin for everything to work)   https://puni.sh/api/repository/croizat   
    -> VNavmesh :   (for Pathing/Moving)    https://puni.sh/api/repository/veyn       
    -> Pandora :    (for Fate targeting and auto sync [ChocoboS])   https://love.puni.sh/ment.json             
    -> RotationSolver Reborn :  (for Attacking enemys)  https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json       
        -> Target -> activate "Select only Fate targets in Fate" and "Target Fate priority"
        -> Target -> "Engage settings" set to "Previously engaged targets (enagegd on countdown timer)"
    -> TextAdvance: (for interacting with Fate NPCs)
    -> Teleporter :  (for Teleporting to aetherytes [teleport][Exchange][Retainers])
    -> Lifestream :  (for changing Instances [ChangeInstance][Exchange]) https://raw.githubusercontent.com/NightmareXIV/MyDalamudPlugins/main/pluginmaster.json

*********************
*  Optional Plugins *
*********************

This Plugins are Optional and not needed unless you have it enabled in the settings:

    -> AutoRetainer : (for Retainers [Retainers])   https://love.puni.sh/ment.json
    -> Deliveroo : (for gc turn ins [TurnIn])   https://plugins.carvel.li/
    -> Bossmod/BossModReborn: (for AI dodging)  https://puni.sh/api/repository/veyn
                                                https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json
    -> ChatCoordinates : (for setting a flag on the next Fate) available via base /xlplugins

--------------------------------------------------------------------------------------------------------------------------------------------------------------
]]

--#region Settings

--true = yes
--false = no

--Teleport and Voucher
EnableChangeInstance = true --should it Change Instance when there is no Fate (only works on DT fates)
ShouldExchange = true       --should it Exchange Vouchers
    OldV = true             --should it Exchange Old Vouchers (set to false if you want the new Turali ones)

--Utilities
SelfRepair = false          --if false,  will go to Limsa mender
    RepairAmount = 20       --the amount it needs to drop before Repairing (set it to 0 if you don't want it to repair)
ExtractMateria = true       --should it Extract Materia
Food = ""                   --Leave "" Blank if you don't want to use any food
                            --if its HQ include <hq> next to the name "Baked Eggplant <hq>"
--Retainer
Retainers = true            --should it do Retainers
    TurnIn = false              --should it to Turn ins at the GC (requires Deliveroo)
    slots = 5                   --how much inventory space before turning in

--Fate settings
WaitIfBonusBuff = true          --Don't change instances if you have the Twist of Fate bonus buff
CompletionToIgnoreFate = 80     --Percent above which to ignore fate
MinTimeLeftToIgnoreFate = 3*60  --Seconds below which to ignore fate
JoinBossFatesIfActive = true    --Join boss fates if someone is already working on it (to avoid soloing long boss fates). If false, avoid boss fates entirely.
CompletionToJoinBossFate = 20   --Percent above which to join boss fate
fatewait = 0                    --the amount how long it should when before dismounting (0 = at the beginning of the fate 3-5 = should be in the middle of the fate)
useBM = true                    --if you want to use the BossMod dodge/follow mode
    BMorBMR = "BMR"

--Ranged attacks and spells max distance to be usable is 25.49y, 25.5 is "target out of range"
--Melee attacks (auto attacks) max distance is 2.59y, 2.60 is "target out of range"
--ranged and casters have a further max distance so not always running all way up to target
--users can adjust below settings to their liking
MeleeDist = 2.5                 --distance for BMRAI melee
RangedDist = 20                 --distance for BMRAI ranged


--Other stuff
ChocoboS = true                 --should it Activate the Chocobo settings in Pandora (to summon it)
MountToUse = "mount roulette"   --The mount you'd like to use when flying between fates, leave empty for mount roulette 

--Change this value for how much echos u want in chat 
--0 no echos
--1 echo how many bicolor gems you have after every fate
--2 echo how many bicolor gems you have after every fate and the next fate you're moving to
Echo = 2

--#endregion Settings

------------------------------------------------------------------------------------------------------------------------------------------------------

--#region Plugin Checks and Setting Init

--Required Plugin Warning
if not HasPlugin("vnavmesh") then
    yield("/echo [FATE] Please Install vnavmesh")
end
if not HasPlugin("RotationSolverReborn") and not HasPlugin("RotationSolver") then
    yield("/echo [FATE] Please Install Rotation Solver Reborn")
end
if not HasPlugin("PandorasBox") then
    yield("/echo [FATE] Please Install Pandora's Box")
end
if not HasPlugin("TextAdvance") then
    yield("/echo [FATE] Please Install TextAdvance")
end

--Optional Plugin Warning
if EnableChangeInstance == true  then
    if HasPlugin("Lifestream") == false then
        yield("/echo [FATE] Please Install Lifestream or Disable ChangeInstance in the settings")
    end
end
if Retainers then
    if not HasPlugin("AutoRetainer") then
        yield("/echo [FATE] Please Install AutoRetainer")
    end
    if TurnIn then
        if not HasPlugin("Deliveroo") then
            yield("/echo [FATE] Please Install Deliveroo")
        end
    end
end
if ExtractMateria == true then
    if HasPlugin("YesAlready") == false then
        yield("/echo [FATE] Please Install YesAlready")
    end 
end   
if useBM then
    if HasPlugin("BossModReborn") == false and HasPlugin("BossMod") == false then
        yield("/echo [FATE] Please Install BossMod")
    else
        if HasPlugin("BossModReborn") then
            BMorBMR = "BMR"
        else
            BMorBMR = "BM"
        end
    end
end
if not HasPlugin("ChatCoordinates") then
    yield("/echo [FATE] ChatCoordinates is not installed. Map will not show flag when moving to next Fate.")
end

--Chocobo settings
if ChocoboS == true then
    PandoraSetFeatureState("Auto-Summon Chocobo", true) 
    PandoraSetFeatureConfigState("Auto-Summon Chocobo", "Use whilst in combat", true)
elseif ChocoboS == false then
    PandoraSetFeatureState("Auto-Summon Chocobo", false) 
    PandoraSetFeatureConfigState("Auto-Summon Chocobo", "Use whilst in combat", false)
end

--Fate settings
PandoraSetFeatureState("Auto-Sync FATEs", true)
PandoraSetFeatureState("FATE Targeting Mode", true)
PandoraSetFeatureState("Action Combat Targeting", false)
yield("/at y")

--snd property
function setSNDProperty(propertyName, value)
    local currentValue = GetSNDProperty(propertyName)
    if currentValue ~= value then
        SetSNDProperty(propertyName, tostring(value))
        LogInfo("[SetSNDProperty] " .. propertyName .. " set to " .. tostring(value))
    end
end

setSNDProperty("UseItemStructsVersion", true)
setSNDProperty("UseSNDTargeting", true)
setSNDProperty("StopMacroIfTargetNotFound", false)
setSNDProperty("StopMacroIfCantUseItem", false)
setSNDProperty("StopMacroIfItemNotFound", false)
setSNDProperty("StopMacroIfAddonNotFound", false)
setSNDProperty("StopMacroIfAddonNotVisible", false)

--vnavmesh building
if not NavIsReady() then
    yield("/echo [FATE] Building Mesh Please wait...")
end
while not NavIsReady() do
    yield("/wait 1")
end
if NavIsReady() then
    yield("/echo [FATE] Mesh is Ready!")
end

--#endregion Plugin Checks and Setting Init

--#region Data

CharacterCondition = {
    dead=2,
    mounted=4,
    inCombat=26,
    casting=27,
    occupied31=31,
    occupiedShopkeeper=32,
    occupied=33,
    occupiedMateriaExtraction=39,
    transition=45,
    jumping=48,
    occupiedSummoningBell=50,
    mounting=64,
    flying=77
}

FatesData = {
    {
        zoneName = "Coerthas Central Highlands",
        zoneId = 155,
        aetheryteList = {
            { aetheryteName="Camp Dragonhead", x=223.98718, y=315.7854, z=-234.85168 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Coerthas Western Highlands",
        zoneId = 397,
        aetheryteList = {
            { aetheryteName="Falcon's Nest", x=474.87585, y=217.94458, z=708.5221 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Mor Dhona",
        zoneId = 156,
        aetheryteList = {
            { aetheryteName="Revenant's Toll", x=40.024292, y=24.002441, z=-668.0247 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Sea of Clouds",
        zoneId = 401,
        aetheryteList = {
            { aetheryteName="Camp Cloudtop", x=-615.7473, y=-118.36426, z=546.5934 },
            { aetheryteName="Ok' Zundu", x=-613.1533, y=-49.485046, z=-415.03015 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Azys Lla",
        zoneId = 402,
        aetheryteList = {
            { aetheryteName="Helix", x=-722.8046, y=-182.29956, z=-593.40814 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Dravanian Forelands",
        zoneId = 398,
        aetheryteList = {
            { aetheryteName="Tailfeather", x=532.6771, y=-48.722107, z=30.166992 },
            { aetheryteName="Anyx Trine", x=-304.12756, y=-16.70868, z=32.059082 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Dravanian Hinterlands",
        zoneId=399,
        tpZoneId = 478,
        aetheryteList = {
            { aetheryteName="Idyllshire", x=71.94617, y=211.26111, z=-18.905945 }
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Churning Mists",
        zoneId=400,
        aetheryteList = {
            { aetheryteName="Moghome", x=259.20496, y=-37.70508, z=596.85657 },
            { aetheryteName="Zenith", x=-584.9546, y=52.84192, z=313.43542 },
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Lakeland",
        zoneId = 813,
        aetheryteList = {
            { aetheryteName="The Ostall Imperative", x=-735, y=53, z=-230 },
            { aetheryteName="Fort Jobb", x=753, y=24, z=-28 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="Pick-up Sticks", npcName="Crystarium Botanist" }
            },
            otherNpcFates= {},
            bossFates= {
                "Calm a Chameleon",
                "A Beast among Men",
                "Draconian Measures",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Kholusia",
        zoneId = 814,
        aetheryteList = {
            { aetheryteName="Stilltide", x=668, y=29, z=289 },
            { aetheryteName="Wright", x=-244, y=20, z=385 },
            { aetheryteName="Tomra", x=-426, y=419, z=-623 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="Ironbeard Builders - Rebuilt", npcName="Tholl Engineer" }
            },
            otherNpcFates= {},
            bossFates= {
                "Not Today (FATE)",
                "A Finale Most Formidable",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Amh Araeng",
        zoneId = 815,
        aetheryteList = {
            { aetheryteName="Mord Souq", x=246, y=12, z=-220 },
            { aetheryteName="Twine", x=-511, y=47, z=-212 },
            { aetheryteName="The Inn at Journey's Head", x=399, y=-24, z=307 },
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {
                "Bayawak Attack",
                "The Elderblade",
                "The Odd Couple",
            },
            blacklistedFates= {
                "Tolba No. 1", -- pathing is really bad to enemies
            }
        }
    },
    {
        zoneName = "Il Mheg",
        zoneId = 816,
        aetheryteList = {
            { aetheryteName="Lydha Lran", x=-344, y=48, z=512 },
            { aetheryteName="Wolekdorf", x=380, y=87, z=-687 },
            { aetheryteName="Pla Enni", x=-72, y=103, z=-857 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="Twice Upon a Time", npcName="Nectar-seeking Pixie" }
            },
            otherNpcFates= {
                { fateName="Once Upon a Time", npcName="Nectar-seeking Pixie" },
            },
            bossFates= {
                "Thrice Upon a Time",
                "Locus Terribilis",
                "Mad Magic",
                "Brute Fuath",
                "Breaking the Fuath Wall",
                "Go Fuath a Conqueror",
                "Fuath to Be Reckoned With",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Rak'tika Greatwood",
        zoneId = 817,
        aetheryteList = {
            { aetheryteName="Slitherbough", x=-103, y=-19, z=297 },
            { aetheryteName="Fanow", x=382, y=21, z=-194 },
        },
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
            bossFates= {
                "Attack of the Killer Tomatl",
                "I'll Be Bark",
                "Tojil War",
                "Tojil Annihilation",
                "Tojil Carnage",
                "Tojil Eclipse",
                "Attack the Block",
                "Queen of the Harpies",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "The Tempest",
        zoneId = 818,
        aetheryteList = {
            { aetheryteName="The Ondo Cups", x=561, y=352, z=-199 },
            { aetheryteName="The Macarenses Angle", x=-141, y=-280, z=218 },
        },
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
            bossFates= {
                "Ondo of Blood",
                "The Devil in the Deep Blue Sea",
                "The Head, the Tail, the Whole Damned Thing",
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
        aetheryteList = {
            { aetheryteName="The Archeion", x=443, y=170, z=-476 },
            { aetheryteName="Sharlayan Hamlet", x=8, y=-27, z=-46 },
            { aetheryteName="Aporia", x=-729, y=-27, z=302 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="Sheaves on the Wind", npcName="Vexed Researcher" },
                { fateName="Moisture Farming", npcName="Well-moisturized Researcher" }
            },
            otherNpcFates= {},
            bossFates= {
                "Let It Grow",
                "Incident Files: Steamed Vegetable",
                "The Frailty of Life",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Thavnair",
        zoneId = 957,
        aetheryteList = {
            { aetheryteName="Yedlihmad", x=193, y=6, z=629 },
            { aetheryteName="The Great Work", x=-527, y=4, z=36 },
            { aetheryteName="Palaka's Stand", x=405, y=5, z=-244 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="Full Petal ALchemist: Perilous Pickings", npcName="???" }
            },
            otherNpcFates= {},
            bossFates= {
                "The Accursed Kanabhuti",
                "Return of the Tyrant",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Garlemald",
        zoneId = 958,
        aetheryteList = {
            { aetheryteName="Camp Broken Glass", x=-408, y=24, z=479 },
            { aetheryteName="Tertium", x=518, y=-35, z=-178 },
        },
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
            bossFates= {
                "Artificial Malevolence: 15 Minutes to Comply",
                "Roses Are Red, Violence is Due",
                "Artificial Malevolence: Mighty Metatron",
                "The Man with the Golden Son",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Mare Lamentorum",
        zoneId = 959,
        aetheryteList = {
            --{ aetheryteName="Sinus Lacrimarum", x=-566, y=134, z=650 },
            { aetheryteName="Sinus Lacrimarum",  x=-0.10, y=116.80, z=311.89938 },
            { aetheryteName="Bestways Burrow", x=0, y=-128, z=-512 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="What a Thrill", npcName="Thrillingway" }
            },
            otherNpcFates= {
                { fateName="Lepus Lamentorum: Dynamite Disaster", npcName="Warringway" },
                { fateName="Lepus Lamentorum: Cleaner Catastrophe", npcName="Fallingway" },
            },
            bossFates= {
                "The Stones of Silence",
                "Lepus Lamentorum: Crazy Contraption",
                "Head Empty, Only Thoughts"
            },
            blacklistedFates= {
                "Hunger Strikes", --really bad line of sight with rocks, get stuck not doing anything quite often
            }
        }
    },
    {
        zoneName = "Ultima Thule",
        zoneId = 960,
        aetheryteList = {
            { aetheryteName="Reah Tahra", x=-544, y=74, z=269 },
            { aetheryteName="Abode of the Ea", x=64, y=272, z=-657 },
            { aetheryteName="Base omicron", x=-489, y=437, z=333 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="Omicron Recall: Comms Expansion", npcName="N-6205" }
            },
            otherNpcFates= {
                { fateName="Wings of Glory", npcName="Ahl Ein's Kin" },
            },
            bossFates= {
                "Far from the Madding Horde",
                "Nevermore",
                "Omicron Recall: Killing Order",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Elpis",
        zoneId = 961,
        aetheryteList = {
            { aetheryteName="Anagnorisis", x=159, y=11, z=126 },
            { aetheryteName="The Twelve Wonders", x=-633, y=-19, z=542 },
            { aetheryteName="Poieten Oikos", x=-529, y=161, z=-222 },
        },
        fatesList= {
            collectionsFates= {
                { fateName="So Sorry, Sokles", npcName="Flora Overseer" }
            },
            otherNpcFates= {
                { fateName="Grand Designs: Unknown Execution", npcName="Meletos the Inscrutable" },
                { fateName="Grand Designs: Aigokeros", npcName="Meletos the Inscrutable" },
                { fateName="Nature's Staunch Protector", npcName="Monoceros Monitor" },
            },
            bossFates= {
                "Grand Designs: Io",
                "The Rustling of Murderous Leaves",
                "Grand Designs: The Newest of New",
                "Eurydike: All Bark, No Bite",
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName = "Urqopacha",
        zoneId = 1187,
        aetheryteList = {
            { aetheryteName="Wachunpelo", x=335, y=-160, z=-415 },
            { aetheryteName="Worlar's Echo", x=465, y=115, z=635 },
        },
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {
                { fateName="Pasture Expiration Date", npcName="Tsivli Stoutstrider" },
                { fateName="Gust Stop Already", npcName="Mourning Yok Huy" },
                { fateName="Lay Off the Horns", npcName="Yok Huy Vigilkeeper" },
                { fateName="Birds Up", npcName="Coffee Farmer" },
                { fateName="Salty Showdown", npcName="Chirwagur Sabreur" }
            },
            bossFates= {
                "Panaq Attack",
                "Big Storm Coming",
                "Fire Suppression"
            },
            blacklistedFates= {
                "Young Volcanoes",
                "Wolf Parade" -- multiple Pelupelu Peddler npcs, rng whether it tries to talk to the right one
            }
        }
    },
    {
        zoneName="Kozama'uka",
        zoneId=1188,
        aetheryteList={
            { aetheryteName="Ok'hanu", x=-170, y=6, z=-470 },
            { aetheryteName="Many Fires", x=541, y=117, z=203 },
            { aetheryteName="Earthenshire", x=-477, y=124, z=311 }
        },
        fatesList={
            collectionsFates={
                { fateName="Borne on the Backs of Burrowers", npcName="Moblin Forager" },
                { fateName="Combing the Area", npcName="Hanuhanu Combmaker" }
            },
            otherNpcFates= {},
            bossFates= {
                "Sayona Your Prayers"
            },
            blacklistedFates= {
                "Mole Patrol"
            }
        }
    },
    {
        zoneName="Yak T'el",
        zoneId=1189,
        aetheryteList={
            { aetheryteName="Iq Br'aax", x=-400, y=24, z=-431 },
            { aetheryteName="Mamook", x=720, y=-132, z=527 }
        },
        fatesList= {
            collectionsFates= {
                { fateName="Escape Shroom", npcName="Hoobigo Forager" }
            },
            otherNpcFates= {
                --{ fateName=, npcName="Xbr'aal Hunter" }, 2 npcs names same thing....
                { fateName="Le Selva se lo Llevó", npcName="Xbr'aal Hunter" },
                { fateName="Stabbing Gutward", npcName="Doppro Spearbrother" },
                --{ fateName=, npcName="Xbr'aal Sentry" }, -- 2 npcs named same thing.....
            },
            bossFates= {
                "Moths are Tough"
            },
            blacklistedFates= {
                "The Departed",
                "Porting Is Such Sweet Sorrow" -- defence fate
            }
        }
    },
    {
        zoneName="Shaaloani",
        zoneId=1190,
        aetheryteList= {
            { aetheryteName="Hhusatahwi", x=390, y=0, z=465 },
            { aetheryteName="Sheshenewezi Springs", x=-295, y=19, z=-115 },
            { aetheryteName="Mehwahhetsoan", x=310, y=-15, z=-567 }
        },
        fatesList= {
            collectionsFates= {
                { fateName="Gonna Have Me Some Fur", npcName="Tonawawtan Trapper" },
                { fateName="The Serpentlord Sires", npcName="Br'uk Vaw of the Setting Sun" }
            },
            otherNpcFates= {
                { fateName="The Dead Never Die", npcName="Tonawawtan Worker" },
                { fateName="Ain't What I Herd", npcName="Hhetsarro Herder" },
                { fateName="Helms off to the Bull", npcName="Hhetsarro Herder" },
                { fateName="A Raptor Runs Through It", npcName="Hhetsarro Angler" },
                { fateName="The Serpentlord Suffers", npcName="Br'uk Vaw of the Setting Sun" },
                { fateName="That's Me and the Porter", npcName="Pelupelu Peddler" },
            },
            bossFates= {
                "The Serpentlord Seethes",
                "Breaking the Jaw",
                "Helms off to the Bull", -- boss NPC fate, Hhetsarro Herder
                "The Dead Never Die", -- boss NPC fate, Tonawawtan Worker
            },
            blacklistedFates= {}
        }
    },
    {
        zoneName="Heritage Found",
        zoneId=1191,
        aetheryteList= {
            { aetheryteName="Yyasulani Station", x=515, y=145, z=210 },
            { aetheryteName="The Outskirts", x=-221, y=32, z=-583 },
            { aetheryteName="Electrope Strike", x=-222, y=31, z=123 }
        },
        fatesList= {
            collectionsFates= {
                { fateName="License to Dill", npcName="Tonawawtan Provider" },
            },
            otherNpcFates= {
                { fateName="It's Super Defective", npcName="Novice Hunter" },
                { fateName="Running of the Katobleps", npcName="Novice Hunter" },
                { fateName="Ware the Wolves", npcName="Imperiled Hunter" },
                { fateName="Domo Arigato", npcName="Perplexed Reforger" },
                { fateName="Old Stampeding Grounds", npcName="Driftdowns Reforger" },
                { fateName="Pulling the Wool", npcName="Panicked Courier" }
            },
            bossFates= {
                "A Scythe to an Axe Fight",
                "(Got My Eye) Set on You"
            },
            blacklistedFates= {
                "When It's So Salvage" -- { fateName="When It's So Salvage", npcName="Refined Reforger" }
            }
        }
    },
    {
        zoneName="Living Memory",
        zoneId=1192,
        aetheryteList= {
            { aetheryteName="Leynode Mnemo", x=0, y=56, z=796 },
            { aetheryteName="Leynode Pyro", x=659, y=27, z=-285 },
            { aetheryteName="Leynode Aero", x=-253, y=56, z=-400 }
        },
        fatesList= {
            collectionsFates= {
                { fateName="Seeds of Tomorrow", npcName="Unlost Sentry GX" },
                { fateName="Scattered Memories", npcName="Unlost Sentry GX" }
            },
            otherNpcFates= {
                { fateName="Canal Carnage", npcName="Unlost Sentry GX" },
                { fateName="Mascot March", npcName="The Grand Marshal" }
            },
            bossFates= {
                "Feed Me, Sentries",
                "Slime to Die",
                "Critical Corruption",
                "Horse in the Round",
                "Mascot Murder"
            },
            blacklistedFates= {}
        }
    }
}

--#endregion Data

--#region Fate Functions
function IsCollectionsFate(fateName)
    for i, collectionsFate in ipairs(SelectedZone.fatesList.collectionsFates) do
        if collectionsFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsBossFate(fateName)
    for i, bossFate in ipairs(SelectedZone.fatesList.bossFates) do
        if bossFate == fateName then
            return true
        end
    end
    return false
end

function IsOtherNpcFate(fateName)
    for i, otherNpcFate in ipairs(SelectedZone.fatesList.otherNpcFates) do
        if otherNpcFate.fateName == fateName then
            return true
        end
    end
    return false
end

function IsBlacklistedFate(fateName)
    for i, blacklistedFate in ipairs(SelectedZone.fatesList.blacklistedFates) do
        if blacklistedFate == fateName then
            return true
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

function IsFateActive(fateId)
    local activeFates = GetActiveFates()
    for i = 0, activeFates.Count-1 do
        if fateId == activeFates[i] then
            return true
        end
    end
    return false
end

function EorzeaTimeToUnixTime(eorzeaTime)
    return eorzeaTime/(144/7) -- 24h Eorzea Time equals 70min IRL
end

--[[
    Given two fates, picks the better one based on priority progress -> is bonus -> time left -> distance
]]
function SelectNextFateHelper(tempFate, nextFate)
    if tempFate.timeLeft < MinTimeLeftToIgnoreFate or tempFate.progress > CompletionToIgnoreFate then
        return nextFate
    else
        if nextFate == nil then
                LogInfo("[FATE] Selecting #"..tempFate.fateId.." because no other options so far.")
                return tempFate
        -- elseif nextFate.startTime == 0 and tempFate.startTime > 0 then -- nextFate is an unopened npc fate
        --     LogInfo("[FATE] Selecting #"..tempFate.fateId.." because other fate #"..nextFate.fateId.." is an unopened npc fate.")
        --     return tempFate
        -- elseif tempFate.startTime == 0 and nextFate.startTime > 0 then -- tempFate is an unopened npc fate
        --     return nextFate
        else -- select based on progress
            if tempFate.progress > nextFate.progress then
                LogInfo("[FATE] Selecting #"..tempFate.fateId.." because other fate #"..nextFate.fateId.." has less progress.")
                return tempFate
            elseif tempFate.progress < nextFate.progress then
                LogInfo("[FATE] Selecting #"..nextFate.fateId.." because other fate #"..tempFate.fateId.." has less progress.")
                return nextFate
            else
                if nextFate.isBonusFate and tempFate.isBonusFate then
                    if tempFate.timeLeft < nextFate.timeLeft then -- select based on time left
                        LogInfo("[FATE] Selecting #"..tempFate.fateId.." because other fate #"..nextFate.fateId.." has more time left.")
                        return tempFate
                    elseif tempFate.timeLeft > nextFate.timeLeft then
                        LogInfo("[FATE] Selecting #"..tempFate.fateId.." because other fate #"..nextFate.fateId.." has more time left.")
                        return nextFate
                    else
                        tempFatePlayerDistance = GetDistanceToPoint(tempFate.x, tempFate.y, tempFate.z)
                        nextFatePlayerDistance = GetDistanceToPoint(nextFate.x, nextFate.y, nextFate.z)
                        if tempFatePlayerDistance < nextFatePlayerDistance then
                            LogInfo("[FATE] Selecting #"..tempFate.fateId.." because other fate #"..nextFate.fateId.." is farther.")
                            return tempFate
                        elseif tempFatePlayerDistance > nextFatePlayerDistance then
                            LogInfo("[FATE] Selecting #"..nextFate.fateId.." because other fate #"..nextFate.fateId.." is farther.")
                            return nextFate
                        else
                            if tempFate.fateId < nextFate.fateId then
                                return tempFate
                            else
                                return nextFate
                            end
                        end
                    end
                elseif nextFate.isBonusFate then
                    return nextFate
                elseif tempFate.isBonusFate then
                    return tempFate
                end
            end
        end
    end
    return nextFate
end

--Gets the Location of the next Fate. Prioritizes anything with progress above 0, then by shortest time left
function SelectNextFate()
    local fates = GetActiveFates()

    local nextFate = nil
    for i = 0, fates.Count-1 do
        local tempFate = {
            fateId = fates[i],
            fateName = GetFateName(fates[i]),
            progress = GetFateProgress(fates[i]),
            duration = GetFateDuration(fates[i]),
            startTime = GetFateStartTimeEpoch(fates[i]),
            x = GetFateLocationX(fates[i]),
            y = GetFateLocationY(fates[i]),
            z = GetFateLocationZ(fates[i]),
            isBonusFate = GetFateIsBonus(fates[i]),
        }
        tempFate.npcName = GetFateNpcName(tempFate.fateName)
        LogInfo("[FATE] Considering fate #"..tempFate.fateId.." "..tempFate.fateName)

        local currentTime = EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp())
        if tempFate.startTime == 0 then
            tempFate.timeLeft = 900
        else
            tempFate.timeElapsed = currentTime - tempFate.startTime
            tempFate.timeLeft = tempFate.duration - tempFate.timeElapsed
        end
        LogInfo("[FATE] Time left on fate #:"..tempFate.fateId..": "..math.floor(tempFate.timeLeft//60).."min, "..math.floor(tempFate.timeLeft%60).."s")
        
        if not (tempFate.x == 0 and tempFate.z == 0) then -- sometimes game doesn't send the correct coords
            if not IsBlacklistedFate(tempFate.fateName) then -- check fate is not blacklisted for any reason
                if IsBossFate(tempFate.fateName) then
                    if JoinBossFatesIfActive and tempFate.progress >= CompletionToJoinBossFate then
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else
                        LogInfo("[FATE] Skipping fate #"..tempFate.fateId.." "..tempFate.fateName.." due to boss fate with not enough progress.")
                    end
                elseif IsOtherNpcFate(tempFate.fateName) or IsCollectionsFate(tempFate.fateName) then
                    if tempFate.startTime > 0 then -- if someone already opened this fate, then treat is as all the other fates
                        nextFate = SelectNextFateHelper(tempFate, nextFate)
                    else -- no one has opened this fate yet
                        if nextFate == nil then -- pick this if there's nothing else
                            nextFate = tempFate
                        elseif tempFate.isBonusFate then
                            nextFate = SelectNextFateHelper(tempFate, nextFate)
                        elseif nextFate.startTime == 0 then -- both fates are unopened npc fates
                            nextFate = SelectNextFateHelper(tempFate, nextFate)
                        end
                    end
                elseif tempFate.duration ~= 0 then -- else is normal fate. avoid unlisted talk to npc fates
                    nextFate = SelectNextFateHelper(tempFate, nextFate)
                end
                LogInfo("[FATE] Finished considering fate #"..tempFate.fateId.." "..tempFate.fateName)
            end
        end
    end

    LogInfo("[FATE] Finished considering all fates")

    if nextFate == nil then
        LogInfo("[FATE] No eligible fates found.")
        if Echo == 2 then
            yield("/echo [FATE] No eligible fates found.")
        end
    else
        LogInfo("[FATE] Final selected fate #"..nextFate.fateId.." "..nextFate.fateName)
    end
    yield("/wait 1")

    return nextFate
end

function RandomAdjustCoordinates(x, y, z, maxDistance)
    local angle = math.random() * 2 * math.pi
    local x_adjust = maxDistance * math.random()
    local z_adjust = maxDistance * math.random()

    local randomX = x + (x_adjust * math.cos(angle))
    local randomY = y + maxDistance
    local randomZ = z + (z_adjust * math.sin(angle))

    return randomX, randomY, randomZ
end

--#endregion Fate Functions

--#region Movement Functions

function TeleportToClosestAetheryteToFate(playerPosition, nextFate)
    teleportTimePenalty = 200 -- to account for how long teleport takes you

    local aetheryteForClosestFate = nil
    local closestTravelDistance = GetDistanceToPoint(nextFate.x, nextFate.y, nextFate.z)
    LogInfo("[FATE] Direct flight distance is: "..closestTravelDistance)
    for j, aetheryte in ipairs(SelectedZone.aetheryteList) do
        local distanceAetheryteToFate = DistanceBetween(aetheryte.x, aetheryte.y, aetheryte.z, nextFate.x, nextFate.y, nextFate.z)
        local comparisonDistance = distanceAetheryteToFate + teleportTimePenalty
        LogInfo("[FATE] Distance via "..aetheryte.aetheryteName.." adjusted for tp penalty is "..tostring(comparisonDistance))

        if comparisonDistance < closestTravelDistance then
            LogInfo("[FATE] Updating closest aetheryte to "..aetheryte.aetheryteName)
            closestTravelDistance = comparisonDistance
            aetheryteForClosestFate = aetheryte
        end
    end

    if aetheryteForClosestFate ~=nil then
        TeleportTo(aetheryteForClosestFate.aetheryteName)
    end
end

function TeleportTo(aetheryteName)
    while EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp()) - LastTeleportTimeStamp < 5 do
        LogInfo("[FATE] Too soon since last teleport. Waiting...")
        yield("/wait 5")
    end

    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.transition) do
        LogInfo("[FATE] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
    LastTeleportTimeStamp = EorzeaTimeToUnixTime(GetCurrentEorzeaTimestamp())
end

function ChangeInstance()
    --Change Instance

    if LifestreamIsBusy() or not IsPlayerAvailable() or SuccessiveInstanceChanges >= 3 then
        yield("/wait 10")
        SuccessiveInstanceChanges = 0
        return
    end

    yield("/target aetheryte") -- search for nearby aetheryte
    if not HasTarget() or GetTargetName() ~= "aetheryte" then -- if no aetheryte within targeting range, teleport to it
        local closestAetheryte = nil
        local closestAetheryteDistance = math.maxinteger
        for i, aetheryte in ipairs(SelectedZone.aetheryteList) do
            -- GetDistanceToPoint is implemented with raw distance instead of distance squared
            local distanceToAetheryte = GetDistanceToPoint(aetheryte.x, aetheryte.y, aetheryte.z)
            if distanceToAetheryte < closestAetheryteDistance then
                closestAetheryte = aetheryte
                closestAetheryteDistance = distanceToAetheryte
            end
        end
        TeleportTo(closestAetheryte.aetheryteName)
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("[FATE] State Change: Dismounting")
        return
    end

    if GetDistanceToTarget() > 10 then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
            return
        end
    else
        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
            return
        end
    end

    local nextInstance = (GetZoneInstance() % 3) + 1
    yield("/li "..nextInstance) -- start instance transfer
    yield("/wait 1") -- wait for instance transfer to register
    State = CharacterState.ready
    LogInfo("[FATE] State Change: Ready")
end

function Mount()
    if GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.movingToFate
        LogInfo("[FATE] State Change: MovingToFate "..NextFate.fateName)
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield("/gaction jump")
    else
        if not IsPlayerCasting() and not GetCharacterCondition(CharacterCondition.mounting) and not GetCharacterCondition(CharacterCondition.jumping) then
            if MountToUse == "mount roulette" then
                yield('/gaction "mount roulette"')
            else
                yield('/mount "' .. MountToUse)
            end
        end
    end
    yield("/wait 1")
end

function Dismount()
    if PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.flying) then
        local x1 = GetPlayerRawXPos()
        local y1 = GetPlayerRawYPos()
        local z1 = GetPlayerRawZPos()

        yield('/ac dismount')
        yield("/wait 2")

        local x2 = GetPlayerRawXPos()
        local y2 = GetPlayerRawYPos()
        local z2 = GetPlayerRawZPos()

        if GetCharacterCondition(CharacterCondition.flying) and DistanceBetween(x1, y1, z1, x2, y2, z2) < 2 then
            LogInfo("[FATE] Unable to dismount here. Moving to another spot.")
            local random_x, random_y, random_z = RandomAdjustCoordinates(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), 10)
            local nearestPointX = QueryMeshNearestPointX(random_x, random_y, random_z, 100, 100)
            local nearestPointY = QueryMeshNearestPointY(random_x, random_y, random_z, 100, 100)
            local nearestPointZ = QueryMeshNearestPointZ(random_x, random_y, random_z, 100, 100)
            if nearestPointX ~= nil and nearestPointY ~= nil and nearestPointZ ~= nil then
                PathfindAndMoveTo(nearestPointX, nearestPointY, nearestPointZ)
            end
            yield("/wait 1")
        end
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
    else
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
    end
end

--Paths to the Fate NPC Starter
function MoveToNPC()
    yield("/target "..NextFate.npcName)
    if HasTarget() and GetTargetName()==NextFate.npcName then
        if GetDistanceToTarget() > 5 then
            if NextFate.npcX ~= nil then
                PathfindAndMoveTo(NextFate.npcX, NextFate.npcY, NextFate.npcZ, GetCharacterCondition(CharacterCondition.flying))
            else
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying))
            end
        else
            yield("/vnav stop")
        end
        return
    end
end

--Paths to the Fate
function MoveToFate()
    SuccessiveInstanceChanges = 0

    if not IsPlayerAvailable() then
        return
    end

    if not PathIsRunning() and IsInFate() and GetFateProgress(GetNearestFate()) < 100 then
        State = CharacterState.doFate
        LogInfo("[FATE] State Change: DoFate")
        return
    end

    if NextFate == nil then
        yield("/vnav stop")
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end

    if (PathIsRunning() or PathfindInProgress()) and GetCharacterCondition(CharacterCondition.mounted) then
        local x1 = GetPlayerRawXPos()
        local y1 = GetPlayerRawYPos()
        local z1 = GetPlayerRawZPos()

        yield("/wait 5")

        local x2 = GetPlayerRawXPos()
        local y2 = GetPlayerRawYPos()
        local z2 = GetPlayerRawZPos()

        if DistanceBetween(x1, y1, z1, x2, y2, z2) < 3 then
            yield("/vnav stop")
            PathfindAndMoveTo(x2, y2 + 10, z2)
        end
        return
    end

    if GetDistanceToPoint(NextFate.x, GetPlayerRawYPos(), NextFate.z) < 30 then
        if GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.dismounting
            LogInfo("[FATE] State Change: Dismounting")
            return
        end
        
        if (IsOtherNpcFate(NextFate.fateName) or IsCollectionsFate(NextFate.fateName)) and NextFate.startTime == 0 then
            State = CharacterState.interactWithNpc
            LogInfo("[FATE] State Change: InteractWithFateNpc")
            return
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.mounting
        LogInfo("[FATE] State Change: Mounting")
        return
    end

    LogInfo("[FATE] Moving to fate #"..NextFate.fateId.." "..NextFate.fateName)
    if Echo == 2 then
        yield("/echo [FATE] Moving to fate #"..NextFate.fateId.." "..NextFate.fateName)
    end

    local nearestLandX, nearestLandY, nearestLandZ = RandomAdjustCoordinates(NextFate.x, NextFate.y, NextFate.z, 29)

    if HasPlugin("ChatCoordinates") then
        SetMapFlag(SelectedZone.zoneId, nearestLandX, nearestLandY, nearestLandZ)
    end

    TeleportToClosestAetheryteToFate(playerPosition, NextFate)
    LogInfo("[FATE] Moving to "..nearestLandX..", "..nearestLandY..", "..nearestLandZ)
    yield("/vnavmesh stop")
    yield("/wait 1")
    PathfindAndMoveTo(nearestLandX, nearestLandY, nearestLandZ, HasFlightUnlocked(SelectedZone.zoneId))
end

function InteractWithFateNpc()
    PandoraSetFeatureState("Auto-Sync FATEs", false)
    LogInfo("[FATE] Disabling Pandora Auto-Sync FATEs")

    if (IsInFate() or GetCharacterCondition(CharacterCondition.inCombat)) and NextFate.npcX ~= nil then
        yield("/wait 1")
        yield("/lsync") -- there's a milisecond between when the fate starts and the lsync command becomes available, so Pandora's lsync won't trigger
        yield("/wait 1")
        State = CharacterState.doFate
        LogInfo("[FATE] State Change: DoFate")
    elseif NextFate == nil or not IsFateActive(NextFate.fateId) then
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
    elseif PathfindInProgress() or PathIsRunning() then
        if HasTarget() and GetTargetName() == NextFate.npcName and GetDistanceToTarget() < 5 then
            yield("/vnav stop")
        end
        return
    else
        -- if target is already selected earlier during pathing, avoids having to target and move again
        if (not HasTarget() or GetTargetName()~=NextFate.npcName) then
            yield("/target "..NextFate.npcName)
            return
        end

        NextFate.npcX = GetTargetRawXPos()
        NextFate.npcY = GetTargetRawYPos()
        NextFate.npcZ = GetTargetRawZPos()

        if GetDistanceToPoint(NextFate.npcX, NextFate.npcY, NextFate.npcZ) > 5 then
            MoveToNPC()
            return
        end

        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
        elseif not GetCharacterCondition(CharacterCondition.occupied) then
            yield("/interact")
        end
    end
end

function CollectionsFateTurnIn()
    if PandoraGetFeatureEnabled("FATE Targeting Mode") then
        PandoraSetFeatureState("FATE Targeting Mode", false)
        LogInfo("[FATE] Turning of Pandora FATE Targeting Mode")
    end

    if not IsInFate() then
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
    end

    if (not HasTarget() or GetTargetName()~=NextFate.npcName) then
        yield("/target "..NextFate.npcName)
        return
    end

    if GetDistanceToPoint(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos()) > 5 then
        if not (PathfindInProgress() or PathIsRunning()) then
            MoveToNPC()
        end
    else
        yield("/vnav stop")
        yield("/interact")
        yield("/wait 3")

        if GetFateProgress(NextFate.fateId) < 100 then
            State = CharacterState.doFate
            LogInfo("[FATE] State Change: DoFate")
        else
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end

        if NextFate ~=nil and NextFate.npcName ~=nil and GetTargetName() == NextFate.npcName then
            LogInfo("[FATE] Attempting to clear target.")
            ClearTarget()
            yield("/wait 1")
        end
    end
end

--#endregion

--#region Combat Functions

--Paths to the enemy (for Meele)
function EnemyPathing()
    while HasTarget() and GetDistanceToTarget() > 3.5 do
        local enemy_x = GetTargetRawXPos()
        local enemy_y = GetTargetRawYPos()
        local enemy_z = GetTargetRawZPos()
        if PathIsRunning() == false then
            PathfindAndMoveTo(enemy_x, enemy_y, enemy_z)
        end
        yield("/wait 0.1")
    end
end

function AvoidEnemiesWhileFlying()
    --If you get attacked it flies up
    if GetCharacterCondition(CharacterCondition.inCombat) then
        Name = GetCharacterName()
        PlocX = GetPlayerRawXPos(Name)
        PlocY = GetPlayerRawYPos(Name)+40
        PlocZ = GetPlayerRawZPos(Name)
        yield("/gaction jump")
        yield("/wait 0.5")
        yield("/vnavmesh stop")
        yield("/wait 1")
        PathfindAndMoveTo(PlocX, PlocY, PlocZ, true)
        PathStop()
        yield("/wait 2")
    end
end

function SetMaxDistance()
    local ClassJob = GetClassJobId()
    MaxDistance = MeleeDist --default to melee distance
    --ranged and casters have a further max distance so not always running all way up to target
    if ClassJob == 5 or ClassJob == 23 or -- Archer/Bard
        ClassJob == 6 or ClassJob == 24 or -- Conjurer/White Mage
        ClassJob == 7 or ClassJob == 25 or -- Thaumaturge/Black Mage
        ClassJob == 26 or ClassJob == 27 or ClassJob == 28 or -- Arcanist/Summoner/Scholar
        ClassJob == 31 or -- Machinist
        ClassJob == 33 or -- Astrologian
        ClassJob == 35 or -- Red Mage
        ClassJob == 38 or -- Dancer
        ClassJob == 40 or -- Sage
        ClassJob == 42 -- Pictomancer
    then
        MaxDistance = RangedDist
    end
end

function TurnOnCombatMods()
    if not CombatModsOn then
        CombatModsOn = true
        -- turn on RSR in case you have the RSR 30 second out of combat timer set
        yield("/rotation manual")
        Class = GetClassJobId()
        
        if Class == 21 or Class == 37 or Class == 19 or Class == 32 or Class == 24 then -- white mage holy OP, or tank classes
            yield("/rotation settings aoetype 2") -- aoe
        else
            yield("/rotation settings aoetype 1") -- cleave
        end
        yield("/wait 1")

        if not bossModAIActive and useBM then
            SetMaxDistance()
            
            if BMorBMR == "BMR" then
                yield("/bmrai on")
                yield("/bmrai followtarget on")
                yield("/bmrai followcombat on")
                yield("/bmrai followoutofcombat on")
                yield("/bmrai maxdistancetarget " .. MaxDistance)
            else
                yield("/vbmai on")
                --yield("/vbmai followtarget on")
                --yield("/vbmai followcombat on")
                --yield("/vbmai followoutofcombat on")
            end
            bossModAIActive = true
        elseif not useBM then
            TurnOffBM()
        end

        yield("/wait 1")
    end
end

function TurnOffCombatMods()
    if CombatModsOn then
        LogInfo("[FATE] Turning off combat mods")
        CombatModsOn = false
        -- no need to turn RSR off

        TurnOffBM()
    end
end

function TurnOffBM()
    -- turn of BMR so you don't start engaging other mobs
    if useBM and bossModAIActive then
        if BMorBMR == "BMR" then
            yield("/bmrai off")
            yield("/bmrai followtarget off")
            yield("/bmrai followcombat off")
            yield("/bmrai followoutofcombat off")
        else
            yield("/vbmai off")
            --yield("/vbmai followtarget off")
            --yield("/vbmai followcombat off")
            --yield("/vbmai followoutofcombat off")
        end
        bossModAIActive = false
    end
end

function HandleUnexpectedCombat()
    if GetCharacterCondition(CharacterCondition.dead) then
        State = CharacterState.dead
        LogInfo("[FATE] State Change: Dead")
        return
    elseif not GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/vnav stop")
        ClearTarget()
        TurnOffCombatMods()
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    end

    TurnOnCombatMods()

    -- targets whatever is trying to kill you
    if not HasTarget() then
        yield("/battletarget")
    end

    --Paths to enemys when Bossmod is disabled
    if not useBM then
        EnemyPathing()
    end

    -- pathfind closer if enemies are too far
    if HasTarget() then
        if GetDistanceToTarget() > MaxDistance then
            if not (PathfindInProgress() or PathIsRunning()) then
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
            end
        else
            if PathfindInProgress() or PathIsRunning() then
                yield("/vnav stop")
            else
                --inch closer 3 seconds
                PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
                yield("/wait 3")
            end
        end
    end
    yield("/wait 1")
end

function DoFate()
    if not PandoraGetFeatureEnabled("FATE Targeting Mode") then
        PandoraSetFeatureState("FATE Targeting Mode", true)
        LogInfo("Turning on Pandora FATE Targeting Mode")
    end

    if GetCharacterCondition(CharacterCondition.dead) then
        State = CharacterState.dead
        LogInfo("[FATE] State Change: Dead")
        return
    elseif not IsInFate() and GetFateProgress(NextFate.fateId) < 100 and GetDistanceToPoint(NextFate.x, NextFate.y, NextFate.z) < 50 and
        not GetCharacterCondition(CharacterCondition.mounted)
    then -- got pushed out of fate. go back
        yield("/vnav stop")
        yield("/wait 1")
        PathfindAndMoveTo(NextFate.x, NextFate.y, NextFate.z)
        return
    elseif not IsInFate() or (IsInFate() and GetFateProgress(GetNearestFate()) == 100) then -- leave turn in fates after they reach 100
        yield("/vnav stop")
        ClearTarget()
        TurnOffCombatMods()
        State = CharacterState.ready
        LogInfo("[FATE] State Change: Ready")
        return
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("[FATE] State Change: Dismounting")
        return
    elseif IsCollectionsFate(NextFate.fateName) then
        -- random turn in 10% of the time
        local r = math.random()
        LogInfo("[FATE] Random turn in number: "..r)
        if r < 0.03 or GetFateProgress(NextFate.fateId) == 100 then
            yield("/vnav stop")
            State = CharacterState.collectionsFateTurnIn
            LogInfo("[FATE] State Change: CollectionsFatesTurnIn")
        end
    end

    -- do not target fate npc during combat
    if NextFate ~=nil and NextFate.npcName ~=nil and GetTargetName() == NextFate.npcName then
        LogInfo("[FATE] Attempting to clear target.")
        ClearTarget()
        yield("/wait 1")
    end

    TurnOnCombatMods()

    GemAnnouncementLock = false

    -- switches to targeting forlorns for bonus (if present)
    yield("/target Forlorn Maiden")
    yield("/target The Forlorn")

    -- targets whatever is trying to kill you
    if not HasTarget() then
        yield("/battletarget")
    end

    --Paths to enemys when Bossmod is disabled
    if not useBM then
        EnemyPathing()
    end

    -- pathfind closer if enemies are too far
    if not GetCharacterCondition(CharacterCondition.inCombat) then
        yield("/wait 1") -- give pandora a chance to find the enemy
        if HasTarget() then
            if GetDistanceToTarget() > MaxDistance then
                if not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
                end
            else
                if PathfindInProgress() or PathIsRunning() then
                    yield("/vnav stop")
                else
                    --inch closer 3 seconds
                    PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
                    yield("/wait 3")
                end
            end
        else
            yield("/targetenemy")
        end
    else
        if GetDistanceToTarget() <= MaxDistance and PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end
    end
    yield("/wait 1")
end

--#endregion

--#region State Transition Functions

function FoodCheck()
    --food usage
    if not HasStatusId(48) and Food ~= "" then
        yield("/item " .. Food)
    end
end

function Ready()
    FoodCheck()

    if (not IsInFate() or (IsInFate() and GetFateProgress(GetNearestFate()) == 100)) and
        GetCharacterCondition(CharacterCondition.inCombat) and not State == CharacterState.unexpectedCombat
    then
        State = CharacterState.unexpectedCombat
        LogInfo("[FATE] State Change: UnexpectedCombat")
    elseif GetCharacterCondition(CharacterCondition.dead) then
        State = CharacterState.dead
        LogInfo("[FATE] State Change: Dead")
    elseif not IsPlayerAvailable() then
        return
    elseif RepairAmount > 0 and NeedsRepair(RepairAmount) then
        State = CharacterState.repair
        LogInfo("[FATE] State Change: Repair")
    elseif ExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo("[FATE] State Change: ExtractMateria")
    elseif NextFate == nil and WaitIfBonusBuff and (HasStatusId(1288) or HasStatusId(1289)) then
        yield("/wait 10")
    elseif ShouldExchange and (BicolorGemCount >= 1400) then
        State = CharacterState.exchangingVouchers
        LogInfo("[FATE] State Change: ExchangingVouchers")
    elseif Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.processRetainers
        LogInfo("[FATE] State Change: ProcessingRetainers")
    elseif NextFate == nil and EnableChangeInstance and GetZoneInstance() > 0 then
        State = CharacterState.changingInstances
        LogInfo("[FATE] State Change: ChangingInstances")
    elseif NextFate == nil then
        yield("/wait 10")
    else
        State = CharacterState.movingToFate
        LogInfo("[FATE] State Change: MovingtoFate "..NextFate.fateName)
    end

    if not GemAnnouncementLock and Echo >= 1 then
        GemAnnouncementLock = true
        if BicolorGemCount >= 1400 then
            yield("/echo [FATE] You're almost capped with "..tostring(BicolorGemCount).."/1500 gems! <se.3>")
        else
            yield("/echo [FATE] Gems: "..tostring(BicolorGemCount).."/1500")
        end
    end
end

DeathAnnouncementLock = false
function HandleDeath()
    if CombatModsOn then
        TurnOffCombatMods()
    end

    if GetCharacterCondition(CharacterCondition.dead) then --Condition Dead
        if Echo and not DeathAnnouncementLock then
            DeathAnnouncementLock = true
            yield("/echo [FATE] You have died. Returning to home aetheryte.")
        end

        if IsAddonVisible("SelectYesno") then --rez addon yes
            yield("/callback SelectYesno true 0")
            yield("/wait 0.1")
        end
    elseif GetCharacterCondition(CharacterCondition.casting) or GetCharacterCondition(CharacterCondition.transition) then
        return
    else
        if IsInZone(SelectedZone.zoneId) then
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
            DeathAnnouncementLock = false
        else
            TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
        end
    end
end

function ExchangeOldVouchers()
    if not IsInZone(962) then
        TeleportTo("Old Sharlayan")
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        return
    end

    local gadfrid = { x=74.17, y=5.15, z=-37.44}
    if GetDistanceToPoint(gadfrid.x, gadfrid.y, gadfrid.z) > 5 then
        PathfindAndMoveTo(gadfrid.x, gadfrid.y, gadfrid.z)
    else
        if not HasTarget() or GetTargetName() ~= "Gadfrid" then
            yield("/target Gadfrid")
        elseif not GetCharacterCondition(CharacterCondition.occupiedShopkeeper) then
            yield("/interact")
        end
    end
end

function ExchangeNewVouchers()
    if not IsInZone(1186) then
        TeleportTo("Solution Nine")
        return
    end

    local beryl = { x=-198.47, y=0.92, z=-6.95 }
    local nexusArcade = { x=-157.74, y=0.29, z=17.43 }
    if GetDistanceToPoint(beryl.x, beryl.y, beryl.z) > (DistanceBetween(nexusArcade.x, nexusArcade.y, nexusArcade.z, beryl.x, beryl.y, beryl.z) + 10) then
        yield("/li nexus arcade")
        return
    elseif GetDistanceToPoint(beryl.x, beryl.y, beryl.z) > 5 then
        if IsAddonVisible("TelepotTown") then
            yield("/callback TelepotTown false -1")
        elseif not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(beryl.x, beryl.y, beryl.z)
        end
    else
        if not HasTarget() or GetTargetName() ~= "Beryl" then
            yield("/target Beryl")
        elseif not GetCharacterCondition(CharacterCondition.occupiedShopkeeper) then
            yield("/interact")
        end
    end
end

function ExchangeVouchers()
    if BicolorGemCount >= 1400 then
        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            return
        end

        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency false 0 5 "..(BicolorGemCount//100))
            return
        end

        if OldV then
            ExchangeOldVouchers()
        else
            ExchangeNewVouchers()
        end
    else
        if IsAddonVisible("ShopExchangeCurrency") then
            yield("/callback ShopExchangeCurrency true -1")
            return
        end

        if not IsInZone(SelectedZone.zoneId) then
            TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
            return
        else
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
            return
        end
    end
end

function ProcessRetainers()
    LogInfo("[FATE] Handling retainers...")
    if ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then
    
        if PathfindInProgress() or PathIsRunning() then
            return
        end

        if not IsInZone(129) then
            TeleportTo("Limsa Lominsa Lower Decks")
            return
        end

        local summoningBell = {
            x = -122.72,
            y = 18.00,
            z = 20.39
        }
        if GetDistanceToPoint(summoningBell.x, summoningBell.y, summoningBell.z) > 4.5 then
            PathfindAndMoveTo(summoningBell.x, summoningBell.y, summoningBell.z)
            return
        end

        if not HasTarget() or GetTargetName() ~= "Summoning Bell" then
            yield("/target Summoning Bell")
            return
        end

        if not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            yield("/interact")
            if IsAddonVisible("RetainerList") then
                yield("/ays e")
                yield("/echo [FATE] Processing retainers")
                yield("/wait 1")
            end
        end
    else
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
        elseif IsInZone(SelectedZone.zoneId) then
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
        end
    end
end

function TurnIn()
    yield("/autoduty turnin")
    yield("/wait 1")
    while GetCharacterCondition(CharacterCondition.casting) do
        yield("/wait 0.1")
    end
    yield("/wait 1")
    while GetCharacterCondition(CharacterCondition.transition) do
        yield("/wait 0.1")
    end
    yield("/wait 1")
    while DeliverooIsTurnInRunning() do
        yield("/wait 1")
    end
    yield("/wait 1")

    if not IsInZone(SelectedZone.zoneId) then
        TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
    end
end

function Repair()
    if IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
        return
    end

    if IsAddonVisible("Repair") then
        if not NeedsRepair(RepairAmount) then
            yield("/callback Repair true -1") -- if you don't need repair anymore, close the menu
        else
            yield("/callback Repair true 0") -- select repair
        end
        return
    end

    -- if occupied by repair, then just wait
    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtraction) then
        LogInfo("[FATE] Repairing...")
        yield("/wait 1")
        return
    end

    if SelfRepair then
        if GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.dismounting
            LogInfo("[FATE] State Change: Dismounting")
            return
        end

        if NeedsRepair(RepairAmount) then
            if not IsAddonVisible("Repair") then
                LogInfo("[FATE] Opening repair menu...")
                yield("/generalaction repair")
            end
        else
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    else
        if NeedsRepair(RepairAmount) then
            if not IsInZone(129) then
                TeleportTo("Limsa Lominsa Lower Decks")
                return
            end

            local mender = { npcName="Alistair", x=-246.87, y=16.19, z=49.83 }
            local aethernetshard = { x=-213.95, y=15.99, z=49.35 }
            if GetDistanceToPoint(mender.x, mender.y, mender.z) > (DistanceBetween(aethernetshard.x, aethernetshard.y, aethernetshard.z, mender.x, mender.y, mender.z) + 10) then
                yield("/li Hawkers' Alley")
            elseif GetDistanceToPoint(mender.x, mender.y, mender.z) > 5 then
                if IsAddonVisible("TelepotTown") then
                    yield("/callback TelepotTown false -1")
                elseif not (PathfindInProgress() or PathIsRunning()) then
                    PathfindAndMoveTo(mender.x, mender.y, mender.z)
                end
            else
                if not HasTarget() or GetTargetName() ~= mender.npcName then
                    yield("/target "..mender.npcName)
                elseif not GetCharacterCondition(CharacterCondition.occupiedShopkeeper) then
                    yield("/interact")
                end
            end
        else
            if not IsInZone(SelectedZone.zoneId) then
                TeleportTo(SelectedZone.aetheryteList[1].aetheryteName)
                return
            else
                State = CharacterState.ready
                LogInfo("[FATE] State Change: Ready")
            end
        end
    end
end

function ExtractMateria()
    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("[FATE] State Change: Dismounting")
        return
    end

    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtraction) then
        return
    end

    if CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        if not IsAddonVisible("Materialize") then
            yield("/generalaction \"Materia Extraction\"")
            return
        end

        LogInfo("[FATE] Extracting materia...")
            
        if IsAddonVisible("MaterializeDialog") then
            yield("/pcall MaterializeDialog true 0")
        else
            yield("/pcall Materialize true 2")
        end
    else
        if IsAddonVisible("Materialize") then
            yield("/pcall Materialize true -1")
        else
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

CharacterState = {
    ready = Ready,
    dead = HandleDeath,
    exchangingVouchers = ExchangeVouchers,
    processRetainers = ProcessRetainers,
    turnIn = TurnIn,
    movingToFate = MoveToFate,
    interactWithNpc = InteractWithFateNpc,
    collectionsFateTurnIn = CollectionsFateTurnIn,
    mounting = Mount,
    dismounting = Dismount,
    changingInstances = ChangeInstance,
    -- inCombat = HandleCombat,
    unexpectedCombat = HandleUnexpectedCombat,
    doFate = DoFate,
    extractMateria = ExtractMateria,
    repair = Repair
}

--#endregion State Transition Functions

--#region Main

GemAnnouncementLock = false
AvailableFateCount = 0
SuccessiveInstanceChanges = 0
LastInstanceChangeTimestamp = 0
SetMaxDistance()

local selectedZoneId = GetZoneID()
for i, zone in ipairs(FatesData) do
    if selectedZoneId == zone.zoneId then
        SelectedZone = zone
    end
end
if SelectedZone == nil then
    yield("/echo [FATE] Current zone is only partially supported. Will not teleport back on death or leaving.")
    SelectedZone = {
        zoneName = "Unknown Zone Name",
        zoneId = selectedZoneId,
        aetheryteList = {},
        fatesList= {
            collectionsFates= {},
            otherNpcFates= {},
            bossFates= {},
            blacklistedFates= {
            }
        }
    }
end

LastTeleportTimeStamp = 0

State = CharacterState.ready

LogInfo("[FATE] Starting fate farming script.")
NextFate = nil
while true do
    if NavIsReady() then
        if GetCharacterCondition(CharacterCondition.dead) then
            State = CharacterState.dead
            LogInfo("[FATE] State Change: Dead")
        elseif not IsInFate() and
            GetCharacterCondition(CharacterCondition.inCombat) and not GetCharacterCondition(CharacterCondition.mounted)
        then
            State = CharacterState.unexpectedCombat
            LogInfo("[FATE] State Change: UnexpectedCombat")
        end

        if State == CharacterState.ready or State == CharacterState.movingToFate then
            NextFate = SelectNextFate()
        end
        
        BicolorGemCount = GetItemCount(26807)

        if not (GetCharacterCondition(CharacterCondition.transition) or
            GetCharacterCondition(CharacterCondition.jumping) or
            GetCharacterCondition(CharacterCondition.mounting))
        then
            State()
        end
    end
    yield("/wait 0.1")
end

--#endregion Main