--[[

********************************************************************************
*                              Umbral Gathering                                *
********************************************************************************

Does DiademV2 gathering until umbral weather happens, then gathers umbral node
and goes fishing until umbral weather disappears.

********************************************************************************
*                               Version 1.2.2                                 *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)

    ->  1.2.2   Fixed stuck checks
                Force AutoHook to swap baits
                Credit: anon. Turned off bait purchase if fishing option is
                    turned off, reworked how next node is selected so certain
                    umbral nodes can be commented out, added silex and barbgrass
                    routes
                Fix for UmbralGatheringSlot
                Added UmbralGatheringSlot
                Move SkillCheck out from if statement, so now it checks
                    every time. This is hopefully compatible with Pandora
                Added extra logging around skills
                Fixed DoFish

********************************************************************************
*                               Required Plugins                               *
********************************************************************************

Plugins that are needed for it to work:

    -> Something Need Doing [Expanded Edition] : Main Plugin for everything to work   (https://puni.sh/api/repository/croizat)
    -> VNavmesh :   For Pathing/Moving    (https://puni.sh/api/repository/veyn)
    -> TextAdvance: For interacting with NPCs
    -> Autohook:    For fishing during umbral weather

********************************************************************************
*                                Optional Plugins                              *
********************************************************************************

This Plugins are optional and not needed unless you have it enabled in the settings:

    -> Teleporter :  (for Teleporting to Ishgard/Firmament if you're not already in that zone)

]]

--#region Settings

--[[
********************************************************************************
*                                   Settings                                   *
********************************************************************************
]]

Food = ""                   --Leave "" Blank if you don't want to use any food. If its HQ include <hq> next to the name "Baked Eggplant <hq>"
Potion = ""                 --Leave "" Blank if you don't want to use any potions.

Retainers = true

-- How long to wait before mounting up for the next node. Actual value will be a
-- random number in between MaxWait and MinWait
MaxWait = 10
MinWait = 3

SelectedRoute = "MinerSilex"
-- Select which route you would like to do.
-- Options are:
-- "RedRoute"           -> MIN perception route, 8 node loop
-- "PinkRoute"          -> BTN perception route, 8 node loop
-- "MinerIslands"       -> MIN, all the islands
-- "MinerSilex"      -> MIN, the first two islands
-- "BotanistIslands"    -> BTN, all the islands
-- "BotanistBarbgrass"   -> BTN, the first two islands
-- "Random"             -> Randomizes the route each time

-- This will let you tell the script WHICH item you want to gather. (So if I was gathering the 4th item from the top, I would input 4)
-- This will NOT work with Pandora's Gathering, as a fair warning in itself.
-- Options : 1 | 2 | 3 | 4 | 7 | 8 (1st slot... 2nd slot... ect)
RegularGatheringSlot = 4
UmbralGatheringSlot = 1

TargetType = 1
-- This will let you tell the script which target to use Aethercannon.
-- Options : 0 | 1 | 2 | 3 (Option: 0 is don't use cannon, Option: 1 is any target, Option: 2 only sprites, Option: 3 is don't include sprites)

PrioritizeUmbral = false
DoFish = false -- If false will continuously leave and re-enter the diadem when finishing an Umbral Node to take advantage of the node reset, if true will go fish after finishing an Umbral Node while the window is up

CapGP = true
-- Bountiful Yield 2 (Min) | Bountiful Harvest 2 (Btn) [+x (based on gathering) to that hit on the node (only once)]
-- If you want this to let your gp cap between rounds, then true
-- If you would like it to use a skill on a node before getting to the final one, so you don't waste GP, set to false

BuffYield2 = true -- Kings Yield 2 (Min) | Bountiful Yield 2 (Btn) [+2 to all hits]
BuffGift2 = true -- Mountaineer's Gift 2 (Min) | Pioneer's Gift 2 (Btn) [+30% to perception hit]
BuffGift1 = true -- Mountaineer's Gift 1 (Min) | Pioneer's Gift 1 (Btn) [+10% to perception hit]
BuffTidings2 = true -- Nald'thal's Tidings (Min) | Nophica's Tidings (Btn) [+1 extra if perception bonus is hit]
-- Here you can select which buffs get activated whenever you get to the mega node (aka the node w/ +5 Integrity)
-- These are all togglable with true | false
-- They will go off in the order they are currently typed out, so keep that in mind for GP Usage if that's something you want to consider

SelfRepair = true                              --if false, will go to Limsa mender
RepairAmount = 1                               --the amount it needs to drop before Repairing (set it to 0 if you don't want it to repair)
ShouldAutoBuyDarkMatter = true                  --Automatically buys a 99 stack of Grade 8 Dark Matter from the Limsa gil vendor if you're out
ShouldExtractMateria = true                           --should it Extract Materia
--When do you want to repair your own gear? From 0-100 (it's in percentage, but enter a whole value

debug = false
-- This is for debugging

--#endregion Settings

--[[
********************************************************************************
*           Code: Don't touch this unless you know what you're doing           *
********************************************************************************
]]

--#region Gathering Nodes

UmbralWeatherNodes = {
    flare = {
        weatherName = "Umbral Flare",
        weatherId = 133,
        gatheringNode =
        {
            itemName = "Grade 4 Skybuilders' Umbral Flarerock",
            x = -429.93103, y = 330.51987, z = -593.2373,
            nodeName = "Clouded Mineral Deposit",
            class = "Miner"
        },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Crimson Namitaro",
            baitName = "Diadem Crane Fly",
            baitId = 30280,
            x = 370.88373, y = 255.67848, z = 525.73334,
            fishingX = 372.32, fishingY = 254.9, fishingZ = 521.2,
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/jNhD+K4YuvZiAHtQrN683cQNk02CdRQ9FD5Q4sgnLopeitusu8t871COWbDneBkEvzU0aDr95aPhxRj+sWaXlnJW6nGcr6+qHdV2wJIdZnltXWlUwtczinSjgsMi7pVt8cqN4aj0oIZXQe+vKQWl5/T3NKw78IDb6Tw3WJynTtQGrH1zzVOME0dRa7B7XCsq1zFHi2PYA+WXoGiMOBzvsi87M19W284A6Nr3gQrdL5jmkurfR6au5l81KxQXLO4DAoQMA2qrdiHJ9vYeyZ8g/8tD3Bx4GXZLZBpZrkekPTNR+GkHZCZaapRtERbA29ae4fdS4RX1gWkCRQs+f4HhfMMyY221V4m+YM918+s7q8W73KN9eu/txzXLBNuUN+yaVARgIunC86VD+GVL5DVDfMUnqbNKBhS5hH8RqwbZ1ZLNilYMqO1S32eqFNj1xdwAVPSHW9XetWHuUTKof5fIvtrstdCW0kMWCiaJLAMFvflcp+ARlyVZo2rKm1n3thHUv8cBNG4T9DiUmEyN4d7LUr8Z7wEBg3EOLWGfWG4v1+sGf5Q6Pg2L5vFIKCv1GUR6hvlmso96eRDxqvda6kSqF+hyhWseFtZAbaV0tththzTWltNRyZ46yKFZLDbjD6UfZlttMvU1wfbja2y+F+FqBwbUCh/vAEk4gdX1COYtJBDYloRfHYex7fub6FuLdiVL/lhkbWP9/NIVsAugcbKM75+NHwThsJ3PFCpjc5HsDeS/VluW/SrkxIB2R/A6sfjdyjOD5eslYXmJOm/d2sZ/sVtRkgDqhIagOc6mVLFZvgGp7PdQ7WEHBmdofrsGfRPgoK1Q+irTRcIP4WeHE7VOVgQ8jWo9K7M5ZCn3Xe1Y5Z2ug9IK1Vs/U9SzToOasWq2xSdiauwaLd6zg6zYCC6a+zMxDj7VH2gov9OPT2/iFi9W0AB1HdWX2Gb5WQgFHU7oy953pMc7U3s/V0uXaeC+BV5XAa795j93c2M9S7gSEUYcT6vkhSTj1SMTt1A4zYGlgW09/dvTW9qFj9IY9LT1PbwuF9Dahk+Vmn1Qi58i2v0wWa7wfJjcMlBjys+kZ38nvnfzevPLf2e5/zXaRb3s8DFwSUA6EJjGQ2A5DQsOAJQH3M06zHts1/IZkNyS62Ax+l4gOe0lRsoLlQ8qbK7EtZTFBbaGZkie0dzZdtxwbapFib405Ms40CrOtrIqe2khbQP34eAjzhhNwZAxXKmN4e+emM2tHVT/2LwybPu4c+Tkx9s/jP/9XcRgXXj0kmM1GMjdJrvPbHxvaYcE8NuKD2lhx9wrRwdPB0ygifpDYhLo4XkSmLrMYIIMs4JnL6kJscFsXv2wTnK1wOmAKJmTy70ut70EQsyhJfJKyGC9+FmYkCSElWBmhnXoQh4Ae/ANZ6dm46xIAAA=="
        }
    },
    duststorms = {
        weatherName = "Umbral Duststorms",
        weatherId = 134,
        gatheringNode =
        {
            itemName = "Grade 4 Skybuilders' Umbral Dirtleaf",
            x = 384.0722, y = 294.2122, z = 583.4051,
            nodeName = "Clouded Lush Vegetation Patch",
            class = "Botanist"
        },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Marrella",
            baitName = "Diadem Hoverworm",
            baitId = 30281,
            x = 589.21, y=188.84, z=-571.89,
            fishingX=599.23, fishingY=185.36, fishingZ=-579.41,
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/bOBD+K4YuezEBPahXbq6TuAGcbFCn2MNiDxRF2YRl0aWott4i/71DSYwlW46DwNjL5mR6OPPNQ6OPQ/2yJpUSU1Kqcpotratf1k1BkpxN8ty6UrJiY0tvznnB9pup2bqDlRvFY+tRciG52llXDkjLm580r1KW7sVa/7nBuheCrjRYvXD1qsYJorE12z6tJCtXIgeJY9s95Neha4w47FnYZ4OZrqqNiQA7Nj4TgrESec6o6hg6XTX3vFshU05yAxA4uAeAW7VbXq5udqzsOPIPIvT9XoSBKTJZs8WKZ+oT4XWcWlAawUIRugZUAGtLf4zbRY1b1EeiOCso68QTHNoF/Yq5xlTyf9mUqObRG6+H1u5Bvb3W+mlFck7W5S35LqQG6AlMOt64L//CqPjOQN/RRTI+cc+DKdgnvpyRTZ3ZpFjmTJYG1W1MvdDGR+H2oKJnwLr5qSRpXyVd6iex+EG2d4WquOKimBFemAIgeObzSrJ7VpZkCa4ta2w91EFYDwJeuHGDsNuCRFdiAG8uSvVuvEdIhA1HaCHrxH7jsd7fx7PYwusgST6tpGSFulCWB6gXy3Uw2qOMB73XWrdCUla/R6BmuLAWplpad4vtRhBi00oLJbb6VebFcqEYWDjdLNt2m8jLJNeFq6P9WvBvFdO4VmY7mccoRRkmIcKuFyNCPYa8wAYGyryQEGoB3pyX6s9M+4D+/7tpZJ2ACbDN7lSM15ykbDP6rF++H0JuNOQD/JL8sxBrDWKI5C9G6v9aDhm8HC8ZyUuoafO/3ewWuxU1FcBOqAnKYC6UFMXyAqi210GdsyUrUiJ3+2PwjQjXogLlg0wbDTeIXxSOwj5W6cUwoPUk+faUp9B3vReVU756Sq94a/V0X08yxeSUVMsVDAkbfdZAYww1fD1GQMPUh5ledFh7YKzwQj8+Po1fOVj1CGA4yrTZF/at4pKl4EpV+rzTM8aJ3ntbL53vjY8WeFcLvPeZd9gtiTwH27aP/Ih4CMcZRkkW2ChlYeb5mDghyaznfwy9tXPoEL3BTItP09tMAr2N8Gix3iUVz1Ng2z9GsxWcD6NbwiTv87OeGT/I74P8Lt75H2z3v2Y7xtIAx4GLgphECDtBihKPhigMPVh7buDbdoftGn4DsusTXWy/gehgluQlKUjep7x7AoNxnpMjujtZprsUBmlOYaaG2uggGoXJRlRFR21gHMB+fHj58vo330g7rmRG4NTO9UTWXlH92D9zyfTBcuCjxNC3jv/8G8X+mvDuy4E21pKpLnJd3+51ob0k6GUj3qsNNXWnAZ0wSZyIUcT8MEA4dWIU0yREASEOzmInyGhaN2CD24b4dZPAnWp0XcEXJwV3ghEavb3NOt7d0AkpjWzo9yiDw94JUIRZgtwwpTiMUzegkfX8G7s7jfLfEgAA"
        }
    },
    levin = {
        weatherName = "Umbral Levin",
        weatherId = 135,
        gatheringNode =
        {
            itemName = "Grade 4 Skybuilders' Umbral Levinsand",
            x = 620.3156, y = 252.7179, z = -397.3386,
            nodeName = "Clouded Rocky Outcrop",
            class = "Miner"
        },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Meganeura",
            baitName = "Diadem Red Balloon", -- mooched from Grade 4 Skybuilders' Ghost Faerie
            baitId = 30279,
            x = 365.84, y = -193.35, z = -222.72,
            fishingX = 369.91, fishingY = -195.22, fishingZ = -209.88,
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS3OjRhD+KyouuYgqHsPLN1lrK66SHZflrRxSOQzQSFNCjHYYnFW2/N+3BxgLJGTFu04u8Y3q6f76QfN1D9+MSSX5lJaynGZL4+KbcVXQOIdJnhsXUlQwNtThnBWwP0z10Q0+OWE0Nu4F44LJnXFho7S8+prkVQrpXqz0nxusW86TlQKrHxz1VOP44diYbR9XAsoVz1FiW1YP+XXoGiMKehbW2WCmq2qjIyC2Rc6EoK14nkMiO4Z2V80575aLlNFcA/g26QGQVu2alaurHZQdR95BhJ7Xi9DXRaZrWKxYJi8pq+NUglILFpIma0RFsLb0x7hd1KhFvaeSQZFAJx7/0M7vV8zRpoL9DVMqm1evvR5aOwf1dlvrxxXNGV2X1/SJCwXQE+h03HFf/gAJfwLUt1WRtE/S86ALdsmWM7qpM5sUyxxEqVGdxtQNLHIUbg8qfEasq69S0PZTUqV+5Iu/6PamkBWTjBczygpdABPf+bwScAtlSZfo2jDGxl0dhHHH8YMbNwi7LUpUJQbw5ryUP4x3j4nAcISGaZw4bzzW5/t4Flv8HATNp5UQUMh3yvIA9d1yHYz2KONB77XWNRcJ1N8RqmkurIWpktbdYjkB8mLTSgvJt+pTZsVyIQEt7G6WbbtNxPsk14Wro/1csC8VKFwjirOMxEFohmlMTBJBZoaxH5uh7YVpFIV2HKYG4s1ZKX/LlA/s/z+aRlYJ6ADb7E7F+InRFDajB0hHlzTPOS8U6B0XG5r/yvlawWgq+R3oej9Z1Clm0q1rK2qSJXaguEgbL6TgRf2ptVov8ymjeYnG/xTVcjuoc1hCkVKxe0tcNcInXqGyTqmn4fjRi8JR2McqvRgGtB4F257yFHiO+6JyyldP6RVvrZ5q4UkmQUxptVzhPrBRYwX7dKi3640Be6OeW+qhQ9ANlXrR8aR9ZWiq8a75RzfQA3ypmIAUsWWlZpnaHw676k3Nc74ZPt75f/rOO8yVZikyVeKauCpRZK4ISYvEnplR1/JJ4AKNwXj+U1NXu2MOURfuq+Q0dc0EUteIjBbrXVyxPEUm/WU0WyH3j64pCNbnXvssrf0kL32w3QfbfbDd/2PCdfc0n4Zu6HkmBIBsZ/uBSePYNz0nBjcIsixzgg7bNfyGZPevEt3JAt2kuB6zBDdlrIpy3yhMNrwqemrIaF50eIdy+xfYUHmqREZxQOeKF9ubphd5Z+6KHloO/FsY+mXxk78ahiDf9Odhv/z/8MqvjJVkqopc17d7CWhXf/XYiPdqQ+3cHbReYmdJSM0kAdsk1A7MOM4sMwv82A8pdiD169ZrcNsQP29ivCmN5vDEipE50s2FlxBW0gJPem12C0taQCVo/3aSAlgUosC0Xd/FGU+IGWZObJLM9QhJApdYifH8HeK2JzeyEgAA"
        }
    },
    tempest = {
        weatherName = "Umbral Tempest",
        weatherId = 136,
        gatheringNode =
        {
            itemName = "Grade 4 Skybuilders' Umbral Galewood",
            x = -604.29, y = 333.82, z=442.46,
            nodeName = "Clouded Mature Tree",
            class = "Botanist"
        },
        fishingNode = {
            itemName = "Grade 4 Artisanal Skybuilders' Griffin",
            baitName = "Diadem Hoverworm", -- mooched from Grade 4 Skybuilders' Ghost Faerie
            baitId = 30281,
            x = -417.17, y = -206.7, z = 165.31,
            fishingX = -411.73, fishingY = -207.15, fishingZ = 166.06,
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/bOBD+K4YuezEBvR+5uW7iBnCzQe1iD4seKGloE5ZFl5Laeov89w4lMZZsOW7a7F42J8vDmW8eGn4c6rsxqUoxpUVZTNnKuPpuXOc0zmCSZcZVKSsYG2pxznM4LKZ66Raf7DAaG/eSC8nLvXFlobS4/pZkVQrpQaz0Hxqs90IkawVWP9jqqcbxw7Ex2y3XEoq1yFBimWYP+WnoGiMKehbmxWCm62qrI3At070QgrYSWQZJ2TG0umr2ZbdCppxmGsC33B6A26rd8GJ9vYei48g7itDzehH6ush0A4s1Z+Ubyus4laDQgkVJkw2iIlhb+lPcLmrUot7TkkOeQCce/9jO71fM1qaS/wNTWjavXns9traP6u201ss1zTjdFDf0i5AKoCfQ6TjjvvwDJOILoL6liqR9uj0PumBv+GpGt3Vmk3yVgSw0qt2YOoHpnoTbgwofEOv6Wylpu5VUqZdi8ZXubvOy4iUX+YzyXBeA4DufVxLeQ1HQFbo2jLFxVwdh3AnccOMGYb9DiarEAN5cFOUv491jIjAcoUGMM+uNx3r9EM9ih9tB0mxaSQl5+UJZHqG+WK6D0Z5kPOi91roRMoF6H6Ga5sJamCpp3S2mHWKITSstSrFTW5nnq0UJaGF1s2zbbSJfJrkuXB3tx5x/rkDhGhGkoRVbjDDP84nrxAmJIjMi4Ns2Tf0gpbFnIN6cF+WfTPnA/v+7aWSVgA6wze5cjG85TWE7eqc231chtwryDn9p9k6IjQLRRPIX0M3hXFGrmEe3qq2oSdW1AsVE2nhRSpHXG63VejydGM0KNP5ZVNPpoM5hBXlK5f45cdUIb0WFyjqlnobtR48KJ2GfqvRiGNBaSr475ynwbOdR5ZyvntIT3lo91cATVoKc0mq1xmlgqw4V7IChzq7nBeyM+tRSDx16bojUi07P2SeOTHW4a/bRDfQBPldcQorYZaVOMjU9HHfVs5rncjO8vvP/9J13eIt6LvMixyY0djzixk5AQtMOiBs5cZqkvhmllvHwSRNXO2EOERdOq+554ppJJK6RO1ps9nHFsxR59I/RbI3MP7qhIHmfea2LtPabvPTKdq9s98p2/48TrjulubFtJn5MGAPkOAaMhD7+BbzGWNRMUy9KOmzX8BuS3b9KdGcLdJvicMwTnJOxKsp9ozDZiirvqSGjedHxDcrpX19D5amSjOIBnSlebO+ZXuRduCl6aDnwZWHog8VvfmgYgnzWd4fD6P/LA78yVpKpKnJd3+4VoB381WMjPqgNtXOn9RjQILDCmFjMDYlr+gGhLGEkdlzLsRi1Q9+sW6/BbUP8uI3xnjRawnYH2EFkpNsLLyG8oDmu9RtNcsbwztVzHXjoHMKQYOMCcS1s/YiykOBAxrwYrDhkkfHwAyNEPC6wEgAA"
        }
    }
}

MinerRoutes = {
    MinerIslands = true,
    MinerSilex = true,
    RedRoute = true
}

BotanistRoutes = {
    BotanistIslands = true,
    BotanistBarbgrass = true,
    PinkRoute = true
}

GatheringRoute =
{
    MinerIslands = {
        {x = -570.90, y = 45.80, z = -242.08, nodeName = "Mineral Deposit"},
        {x = -512.28, y = 35.19, z = -256.92, nodeName = "Mineral Deposit"},
        {x = -448.87, y = 32.54, z = -256.16, nodeName = "Mineral Deposit"},
        {x = -403.11, y = 11.01, z = -300.24, nodeName = "Rocky Outcrop"}, -- Fly Issue #1
        {x = -363.65, y = -1.19, z = -353.93, nodeName = "Rocky Outcrop"}, -- Fly Issue #2
        {x = -337.34, y = -0.38, z = -418.02, nodeName = "Mineral Deposit"},
        {x = -290.76, y = 0.72, z = -430.48, nodeName = "Mineral Deposit"},
        {x = -240.05, y = -1.41, z = -483.75, nodeName = "Mineral Deposit"},
        {x = -166.13, y = -0.08, z = -548.23, nodeName = "Mineral Deposit"},
        {x = -128.41, y = -17.00, z = -624.14, nodeName = "Mineral Deposit"},
        {x = -66.68, y = -14.72, z = -638.76, nodeName = "Rocky Outcrop"},
        {x = 10.22, y = -17.85, z = -613.05, nodeName = "Rocky Outcrop"},
        {x = 25.99, y = -15.64, z = -613.42, nodeName = "Mineral Deposit"},
        {x = 68.06, y = -30.67, z = -582.67, nodeName = "Mineral Deposit"},
        {x = 130.55, y = -47.39, z = -523.51, nodeName = "Mineral Deposit"}, -- End of Island #1
        {x = 215.01, y = 303.25, z = -730.10, nodeName = "Rocky Outcrop"}, -- Waypoint #1 on 2nd Island (Issue)
        {x = 279.23, y = 295.35, z = -656.26, nodeName = "Mineral Deposit"},
        {x = 331.00, y = 293.96, z = -707.63, nodeName = "Rocky Outcrop"}, -- End of Island #2
        {x = 458.50, y = 203.43, z = -646.38, nodeName = "Rocky Outcrop"},
        {x = 488.12, y = 204.48, z = -633.06, nodeName = "Mineral Deposit"},
        {x = 558.27, y = 198.54, z = -562.51, nodeName = "Mineral Deposit"},
        {x = 540.63, y = 195.18, z = -526.46, nodeName = "Mineral Deposit"}, -- End of Island #3
        {x = 632.28, y = 253.53, z = -423.41, nodeName = "Rocky Outcrop"}, -- Sole Node on Island #4
        {x = 714.05, y = 225.84, z = -309.27, nodeName = "Rocky Outcrop"},
        {x = 678.74, y = 225.05, z = -268.64, nodeName = "Rocky Outcrop"},
        {x = 601.80, y = 226.65, z = -229.10, nodeName = "Rocky Outcrop"},
        {x = 651.10, y = 228.77, z = -164.80, nodeName = "Mineral Deposit"},
        {x = 655.21, y = 227.67, z = -115.23, nodeName = "Mineral Deposit"},
        {x = 648.83, y = 226.19, z = -74.00, nodeName = "Mineral Deposit"}, -- End of Island #5
        {x = 472.23, y = -20.99, z = 207.56, nodeName = "Rocky Outcrop"},
        {x = 541.18, y = -8.41, z = 278.78, nodeName = "Rocky Outcrop"},
        {x = 616.091, y = -31.53, z = 315.97, nodeName = "Mineral Deposit"},
        {x = 579.87, y = -26.10, z = 349.43, nodeName = "Rocky Outcrop"},
        {x = 563.04, y = -25.15, z = 360.33, nodeName = "Mineral Deposit"},
        {x = 560.68, y = -18.44, z = 411.57, nodeName = "Mineral Deposit"},
        {x = 508.90, y = -29.67, z = 458.51, nodeName = "Mineral Deposit"},
        {x = 405.96, y = 1.82, z = 454.30, nodeName = "Mineral Deposit"},
        {x = 260.22, y = 91.10, z = 530.69, nodeName = "Rocky Outcrop"},
        {x = 192.97, y = 95.66, z = 606.13, nodeName = "Rocky Outcrop"},
        {x = 90.06, y = 94.07, z = 605.29, nodeName = "Mineral Deposit"},
        {x = 39.54, y = 106.38, z = 627.32, nodeName = "Mineral Deposit"},
        {x = -46.11, y = 116.03, z = 673.04, nodeName = "Mineral Deposit"},
        {x = -101.43, y = 119.30, z = 631.55, nodeName = "Mineral Deposit"}, -- End of Island #6?
        {x = -328.20, y = 329.41, z = 562.93, nodeName = "Rocky Outcrop"},
        {x = -446.48, y = 327.07, z = 542.64, nodeName = "Rocky Outcrop"},
        {x = -526.76, y = 332.83, z = 506.12, nodeName = "Rocky Outcrop"},
        {x = -577.23, y = 331.88, z = 519.38, nodeName = "Mineral Deposit"},
        {x = -558.09, y = 334.52, z = 448.38, nodeName = "Mineral Deposit"}, -- End of Island #7
        {x = -729.13, y = 272.73, z = -62.52, nodeName = "Mineral Deposit"}
    },

    BotanistIslands =
    {
        {x = -202, y = -2, z = -310, nodeName = "Mature Tree"},
        {x = -262, y = -2, z = -346, nodeName = "Mature Tree"},
        {x = -323, y = -5, z = -322, nodeName = "Mature Tree"},
        {x = -372, y = 16, z = -290, nodeName = "Lush Vegetation Patch"},
        {x = -421, y = 23, z = -201, nodeName = "Lush Vegetation Patch"},
        {x = -471, y = 28, z = -193, nodeName = "Mature Tree"},
        {x = -549, y = 29, z = -211, nodeName = "Mature Tree"},
        {x = -627, y = 285, z = -141, nodeName = "Lush Vegetation Patch"},
        {x = -715, y = 271, z = -49, nodeName = "Mature Tree"},

        {x = -45, y = -48, z = -501, nodeName = "Lush Vegetation Patch"},
        {x = -63, y = -48, z = -535, nodeName = "Lush Vegetation Patch"},
        {x = -137, y = -7, z = -481, nodeName = "Lush Vegetation Patch"},
        {x = -191, y = -2, z = -422, nodeName = "Mature Tree"},
        {x = -149, y = -5, z = -389, nodeName = "Mature Tree"},
        {x = 114, y = -49, z = -515, nodeName = "Mature Tree"},
        {x = 46, y = -47, z = -500, nodeName = "Mature Tree"},

        {x = 101, y = -48, z = -535, nodeName = "Lush Vegetation Patch"},
        {x = 58, y = -37, z = -577, nodeName = "Lush Vegetation Patch"},
        {x = -6, y = -20, z = -641, nodeName = "Lush Vegetation Patch"},
        {x = -65, y = -19, z = -610, nodeName = "Mature Tree"},
        {x = -125, y = -19, z = -621, nodeName = "Mature Tree"},
        {x = -169, y = -7, z = -550, nodeName = "Lush Vegetation Patch"},

        {x = 454, y = 207, z = -615, nodeName = "Lush Vegetation Patch"},
        {x = 573, y = 191, z = -513, nodeName = "Mature Tree"},
        {x = 584, y = 191, z = -557, nodeName = "Lush Vegetation Patch"},
        {x = 540, y = 199, z = -617, nodeName = "Lush Vegetation Patch"},
        {x = 482, y = 192, z = -674, nodeName = "Lush Vegetation Patch"},

        {x = 433, y = -15, z = 274, nodeName = "Mature Tree"},
        {x = 467, y = -13, z = 268, nodeName = "Lush Vegetation Patch"},
        {x = 440, y = -25, z = 208, nodeName = "Mature Tree"},
        {x = 553, y = -32, z = 419, nodeName = "Lush Vegetation Patch"},
        {x = 564, y = -31, z = 339, nodeName = "Lush Vegetation Patch"},
        {x = 529, y = -10, z = 279, nodeName = "Lush Vegetation Patch"},
        {x = 474, y = -24, z = 197, nodeName = "Lush Vegetation Patch"},
    },
    RedRoute =
    {
        {x = -161.2715, y = -3.5233, z = -378.8041, nodeName = "Rocky Outcrop", antistutter = 0}, -- Start of the route
        {x = -169.3415, y = -7.1092, z = -518.7053, nodeName = "Mineral Deposit", antistutter = 0}, -- Around the tree (Rock + Bones?)
        {x = -78.5548, y = -18.1347, z = -594.6666, nodeName = "Mineral Deposit", antistutter = 0}, -- Log + Rock (Problematic)
        {x = -54.6772, y = -45.7177, z = -521.7173, nodeName = "Mineral Deposit", antistutter = 0}, -- Down the hill
        {x = -22.5868, y = -26.5050, z = -534.9953, nodeName = "Rocky Outcrop", antistutter = 0}, -- up the hill (rock + tree)
        {x = 59.4516, y = -41.6749, z = -520.2413, nodeName = "Rocky Outcrop", antistutter = 0}, -- Spaces out nodes on rock (hate this one)
        {x = 102.3, y = -47.3, z = -500.1, nodeName = "Mineral Deposit", antistutter = 0}, -- Over the gap
        {x = -209.1468, y = -3.9325, z = -357.9749, nodeName = "Mineral Deposit", antistutter = 1},
    },
    PinkRoute =
    {
        {x = -248.6381, y = -1.5664, z = -468.8910, nodeName = "Lush Vegetation Patch", antistutter = 0},
        {x = -338.3759, y = -0.4761, z = -415.3227, nodeName = "Lush Vegetation Patch", antistutter = 0},
        {x = -366.2651, y = -1.8514, z = -350.1429, nodeName = "Lush Vegetation Patch", antistutter = 0},
        {x = -431.2000, y = 27.5000, z = -256.7000, nodeName = "Mature Tree", antistutter = 0}, --tree node
        {x = -473.4957, y = 31.5405, z = -244.1215, nodeName = "Mature Tree", antistutter = 0},
        {x = -536.5187, y = 33.2307, z = -253.3514, nodeName = "Lush Vegetation Patch", antistutter = 0},
        {x = -571.2896, y = 35.2772, z = -236.6808, nodeName = "Lush Vegetation Patch", antistutter = 0},
        {x = -215.1211, y = -1.3262, z = -494.8219, nodeName = "Lush Vegetation Patch", antistutter = 1}
    },

    MinerSilex = {
        {x = 279.23, y = 295.35, z = -656.26, nodeName = "Mineral Deposit"},
        {x = 331.00, y = 293.96, z = -707.63, nodeName = "Rocky Outcrop"}, -- End of Island #2
        {x = 458.50, y = 203.43, z = -646.38, nodeName = "Rocky Outcrop"},
        {x = 488.12, y = 204.48, z = -633.06, nodeName = "Mineral Deposit"},
        {x = 558.27, y = 198.54, z = -562.51, nodeName = "Mineral Deposit"},
        {x = 540.63, y = 195.18, z = -526.46, nodeName = "Mineral Deposit"}, -- End of Island #3
        {x = 632.28, y = 253.53, z = -423.41, nodeName = "Rocky Outcrop"}, -- Sole Node on Island #4
        {x = 714.05, y = 225.84, z = -309.27, nodeName = "Rocky Outcrop"},
    },

    BotanistBarbgrass = {
        {x = -202, y = -2, z = -310, nodeName = "Mature Tree"},
        {x = -262, y = -2, z = -346, nodeName = "Mature Tree"},
        {x = -323, y = -5, z = -322, nodeName = "Mature Tree"},
        {x = -372, y = 16, z = -290, nodeName = "Lush Vegetation Patch"},
        {x = -421, y = 23, z = -201, nodeName = "Lush Vegetation Patch"},
        {x = -471, y = 28, z = -193, nodeName = "Mature Tree"},
        {x = -549, y = 29, z = -211, nodeName = "Mature Tree"},
        {x = -627, y = 285, z = -141, nodeName = "Lush Vegetation Patch"},
    },
}

MobTable =
{
    {
        {"Proto-noctilucale"},
        {"Diadem Bloated Bulb"},
        {"Diadem Melia"},
        {"Diadem Icetrap"},
        {"Diadem Werewood"},
        {"Diadem Biast"},
        {"Diadem Ice Bomb"},
        {"Diadem Zoblyn"},
        {"Diadem Ice Golem"},
        {"Diadem Golem"},
        {"Corrupted Sprite"},
    },
    {
        {"Corrupted Sprite"},
    },
    {
        {"Proto-noctilucale"},
        {"Diadem Bloated Bulb"},
        {"Diadem Melia"},
        {"Diadem Icetrap"},
        {"Diadem Werewood"},
        {"Diadem Biast"},
        {"Diadem Ice Bomb"},
        {"Diadem Zoblyn"},
        {"Diadem Ice Golem"},
        {"Diadem Golem"}
    }
}

spawnisland_table =
{
    {x = -605.7039, y = 312.0701, z = -159.7864, antistutter = 0},
}

local Mender = {
    npcName = "Merchant & Mender",
    x = -639.8871, y = 285.3894, z = -136.52252
}

--#endregion Gathering Nodes

--#region States
CharacterCondition = {
    mounted=4,
    gathering=6,
    casting=27,
    occupiedInEvent=31,
    occupiedInQuestEvent=32,
    occupied=33,
    boundByDutyDiadem=34,
    occupiedMateriaExtractionAndRepair=39,
    gathering42=42,
    fishing=43,
    betweenAreas=45,
    jumping48=48,
    occupiedSummoningBell=50,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    jumpPlatform=61,
    mounting64=64,
    beingMoved=70,
    flying=77
}

function Ready()

    if not IsInZone(DiademZoneId) and State ~= CharacterState.diademEntry then
        State = CharacterState.diademEntry
        LogInfo("[UmbralGathering] State Change: Diadem Entry")
    elseif DoFish and (GetItemCount(30279) < 30 or GetItemCount(30280) < 30 or GetItemCount(30281) < 30) then
        State = CharacterState.buyFishingBait
        LogInfo("[UmbralGathering] State Change: BuyFishingBait")
    elseif RepairAmount > 0 and NeedsRepair(RepairAmount) then
        State = CharacterState.repair
        LogInfo("[UmbralGathering] State Change: Repair")
    elseif ShouldExtractMateria and CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.extractMateria
        LogInfo("[FATE] State Change: ExtractMateria")
    elseif not HasStatusId(48) and Food ~= "" then
        LogInfo("[UmbralGathering] Attempting food")
        yield("/item " .. Food)
        yield("/wait 1")
    elseif not HasStatusId(49) and Potion ~= "" then
        LogInfo("[UmbralGathering] Attempting potion")
        yield("/item " .. Potion)
        yield("/wait 1")
    elseif GetDiademAetherGaugeBarCount() > 0 and TargetType > 0 then
        ClearTarget()
        State = CharacterState.fireCannon
        LogInfo("State Change: Fire Cannon")
    else
        State = CharacterState.moveToNextNode
        LogInfo("[UmbralGathering] State Change: MoveToNextNode")
    end
end

function ExtractMateria()
    if GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
        yield("/wait 0.5")
        return
    end

    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        return
    end

    if CanExtractMateria(100) and GetInventoryFreeSlotCount() > 1 then
        if not IsAddonVisible("Materialize") then
            yield("/generalaction \"Materia Extraction\"")
            return
        end

        LogInfo("[FATE] Extracting materia...")

        if IsAddonVisible("MaterializeDialog") then
            yield("/callback MaterializeDialog true 0")
        else
            yield("/callback Materialize true 2 0")
        end
    else
        if IsAddonVisible("Materialize") then
            yield("/callback Materialize true -1")
        else
            State = CharacterState.ready
            LogInfo("[FATE] State Change: Ready")
        end
    end
end

-- because there's this one stupid tree on the starting platform between the
-- spawn point and the launch platform that you always get stuck on
function DodgeTree()
    while GetDistanceToPoint(-652.28, 293.78, -176.22) > 5 do
        PathfindAndMoveTo(-652.28, 293.78, -176.22, true)
        yield("/wait 3")
    end
    while GetDistanceToPoint(-628.01, 276.3, -190.51) > 5 and not GetCharacterCondition(CharacterCondition.jumpPlatform) do
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(-628.01, 276.3, -190.51, true)
        end
        yield("/wait 1")
    end
    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end
    while GetCharacterCondition(CharacterCondition.jumpPlatform) do
        yield("/wait 1")
    end
end

function ProcessRetainers()
    if ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then

        if PathfindInProgress() or PathIsRunning() then
            return
        end

        local summoningBell = { x=36, y=-17, z=164 }
        if GetDistanceToPoint(summoningBell.x, summoningBell.y, summoningBell.z) > 4.5 then
            if not PathfindInProgress() and not PathIsRunning() then
                PathfindAndMoveTo(summoningBell.x, summoningBell.y, summoningBell.z)
            end
            return
        end

        if PathfindInProgress() or PathIsRunning() then
            yield("/vnav stop")
        end

        if not HasTarget() or GetTargetName() ~= "Summoning Bell" then
            yield("/target Summoning Bell")
            return
        end

        if not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            yield("/interact")
            if IsAddonVisible("RetainerList") then
                yield("/ays e")
                yield("/wait 1")
            end
        end
    else
        if IsAddonVisible("RetainerList") then
            yield("/callback RetainerList true -1")
        elseif not GetCharacterCondition(CharacterCondition.occupiedSummoningBell) then
            State = CharacterState.ready
            LogInfo("[UmbralGathering] State Change: Ready")
        end
    end
end

--#endregion States

--#region Movement
function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[UmbralGathering] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[UmbralGathering] Teleporting...")
        yield("/wait 1")
    end
    yield("/wait 1")
end

function EnterDiadem()
    UmbralGathered = false
    NextNodeId = 1
    JustEntered = true

    if IsInZone(DiademZoneId) and IsPlayerAvailable() then
        if not NavIsReady() then
            yield("/echo Waiting for navmesh...")
            yield("/wait 1")
        elseif GetCharacterCondition(CharacterCondition.betweenAreas) or GetCharacterCondition(CharacterCondition.beingMoved) then
            -- wait to instance in
        else
            yield("/wait 3")
            LastStuckCheckTime = os.clock()
            LastStuckCheckPosition = { x = GetPlayerRawXPos(), y = GetPlayerRawYPos(), z = GetPlayerRawZPos() }
            State = CharacterState.ready
            LogInfo("[UmbralGathering] State Change: Ready")
        end
        return
    end

    if Retainers and ARRetainersWaitingToBeProcessed() and GetInventoryFreeSlotCount() > 1 then
        State = CharacterState.processRetainers
        LogInfo("[UmbralGathering] State Change: ProcessingRetainers")
        return
    end

    local aurvael = {
        npcName = "Aurvael",
        x = -18.60,
        y = -16,
        z = 138.99
    }

    if GetDistanceToPoint(aurvael.x, aurvael.y, aurvael.z) > 5 then
        if not (PathfindInProgress() or PathIsRunning()) then
            PathfindAndMoveTo(aurvael.x, aurvael.y, aurvael.z)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
    end

    if IsAddonVisible("ContentsFinderConfirm") then
        yield("/callback ContentsFinderConfirm true 8")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("SelectString") then
        yield("/callback SelectString true 0")
    elseif IsAddonVisible("Talk") then
        yield("/click Talk Click")
    elseif HasTarget() and GetTargetName() == "Aurvael" then
        yield("/interact")
    else
        yield("/target "..aurvael.npcName)
    end
    yield("/wait 1")
end

function Mount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.moveToNextNode
        LogInfo("[UmbralGathering] State Change: MoveToNextNode")
    else
        yield('/gaction "mount roulette"')
        yield("/wait 2")
    end
    yield("/wait 1")
end

function AetherCannonMount()
    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.fireCannon
        LogInfo("[UmbralGathering] State Change: FireCannon")
    else
        yield('/gaction "mount roulette"')
    end
    yield("/wait 1")
end

function Dismount()
    if PathIsRunning() or PathfindInProgress() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.flying) then
        yield('/ac dismount')

        local now = os.clock()
        if now - LastStuckCheckTime > 1 then
            local x = GetPlayerRawXPos()
            local y = GetPlayerRawYPos()
            local z = GetPlayerRawZPos()

            if GetCharacterCondition(CharacterCondition.flying) and GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 2 then
                LogInfo("[UmbralGathering] Unable to dismount here. Moving to another spot.")
                local random_x, random_y, random_z = RandomAdjustCoordinates(x, y, z, 10)
                local nearestPointX = QueryMeshNearestPointX(random_x, random_y, random_z, 100, 100)
                local nearestPointY = QueryMeshNearestPointY(random_x, random_y, random_z, 100, 100)
                local nearestPointZ = QueryMeshNearestPointZ(random_x, random_y, random_z, 100, 100)
                if nearestPointX ~= nil and nearestPointY ~= nil and nearestPointZ ~= nil then
                    PathfindAndMoveTo(nearestPointX, nearestPointY, nearestPointZ, GetCharacterCondition(CharacterCondition.flying))
                    yield("/wait 1")
                end
            end

            LastStuckCheckTime = now
            LastStuckCheckPosition = {x=x, y=y, z=z}
        end
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield('/ac dismount')
    else
        if NextNode.isFishingNode then
            State = CharacterState.fishing
            LogInfo("[UmbralGathering] State Change: Fishing")
        else
            State = CharacterState.gathering
            LogInfo("[UmbralGathering] State Change: Gathering")
        end
    end
    yield("/wait 1")
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

function RandomWait()
    local duration = math.random() * (MaxWait - MinWait)
    duration = duration + MinWait
    duration = math.floor(duration * 1000) / 1000
    yield("/wait "..duration)
end

function GetRandomRouteType()
    local routeNames = {}
    for routeName, _ in pairs(GatheringRoute) do
        table.insert(routeNames, routeName)
    end
    local randomIndex = math.random(#routeNames)

    return routeNames[randomIndex]
end

function SelectNextNode()
    local weather = GetActiveWeatherID()
    if not UmbralGathered and PrioritizeUmbral and (weather >= 133 and weather <= 136) then -- and not UmbralGathered then
        for _, umbralWeather in pairs(UmbralWeatherNodes) do
            if umbralWeather.weatherId == weather then
                umbralWeather.gatheringNode.isUmbralNode = true
                umbralWeather.gatheringNode.isFishingNode = false
                umbralWeather.gatheringNode.umbralWeatherName = umbralWeather.weatherName
                LogInfo("[UmbralGathering] Selected umbral gathering node for "..umbralWeather.weatherName..": "..umbralWeather.gatheringNode.nodeName)
                return umbralWeather.gatheringNode
            end
        end
    elseif PrioritizeUmbral and (weather >= 133 and weather <= 136) then -- and UmbralGathered then
        if DoFish then
            for _, umbralWeather in pairs(UmbralWeatherNodes) do
                if umbralWeather.weatherId == weather then
                    umbralWeather.fishingNode.isUmbralNode = true
                    umbralWeather.fishingNode.isFishingNode = true
                    umbralWeather.fishingNode.umbralWeatherName = umbralWeather.weatherName
                    LogInfo("[UmbralGathering] Selected umbral fishing node for "..umbralWeather.weatherName)
                    return umbralWeather.fishingNode
                end
            end
        else
            LeaveDuty()
            State = CharacterState.diademEntry
            LogInfo("[UmbralGathering] Diadem Entry")
        end
    end

    -- default
    GatheringRoute[RouteType][NextNodeId].isUmbralNode = false
    GatheringRoute[RouteType][NextNodeId].isFishingNode = false
    LogInfo("[UmbralGathering] Selected regular gathering node: "..GatheringRoute[RouteType][NextNodeId].nodeName)
    return GatheringRoute[RouteType][NextNodeId]

end

function MoveToNextNode()
    NextNodeCandidate = SelectNextNode()
    if (NextNodeCandidate == nil) then
        State = CharacterState.ready
        LogInfo("[UmbralGathering] State Change: Ready")
        return
    elseif (NextNodeCandidate.x ~= NextNode.x or NextNodeCandidate.y ~= NextNode.y or NextNodeCandidate.z ~= NextNode.z) then
        yield("/vnav stop")
        NextNode = NextNodeCandidate
        if NextNode.isUmbralNode then
            yield("/echo Umbral weather "..NextNode.umbralWeatherName.." detected")
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.nextNodeMount
        LogInfo("[UmbralGathering] State Change: Mounting")
        return
    elseif NextNode.isFishingNode and GetClassJobId() ~= 18 then
        yield("/gs change Fisher")
        yield("/wait 3")
        return
    elseif not NextNode.isUmbralNode and JustEntered then
        DodgeTree()
        JustEntered = false
        return
    end

    JustEntered = false
    if NextNode.isUmbralNode and not NextNode.isFishingNode and
            ((NextNode.class == "Miner" and GetClassJobId() ~= 16) or
                    (NextNode.class == "Botanist" and GetClassJobId() ~= 17))
    then
        yield("/gs change "..NextNode.class)
        yield("/wait 3")
    elseif not NextNode.isUmbralNode and MinerRoutes[RouteType] and GetClassJobId() ~= 16 then
        yield("/gs change Miner")
        yield("/wait 3")
    elseif not NextNode.isUmbralNode and BotanistRoutes[RouteType] and GetClassJobId() ~= 17 then
        yield("/gs change Botanist")
        yield("/wait 3")
    elseif GetDistanceToPoint(NextNode.x, NextNode.y, NextNode.z) < 3 then -- hard enter gathering if soft gathering missed
        if NextNode.isFishingNode then
            State = CharacterState.fishing
            LogInfo("[UmbralGathering] State Change: Fishing")
            return
        else
            State = CharacterState.gathering
            LogInfo("[UmbralGathering] State Change: Gathering")
            return
        end
    elseif GetDistanceToPoint(NextNode.x, NextNode.y, NextNode.z) <= 20 then -- soft enter gathering upon approach to make target repathing more natural
        if not NextNode.isFishingNode then
            if HasTarget() and GetTargetName() == NextNode.nodeName then
                if GetCharacterCondition(CharacterCondition.mounted) then
                        yield("/vnav flytarget")
                else
                    yield("/vnav movetarget")
                end

                State = CharacterState.gathering
                LogInfo("[UmbralGathering] State Change: Gathering")
                return
            else
                yield("/target "..NextNode.nodeName)
            end
        end
    elseif not (PathfindInProgress() or PathIsRunning()) then
        PathfindAndMoveTo(NextNode.x, NextNode.y, NextNode.z, true)
    end

    local now = os.clock()
    if now - LastStuckCheckTime > 10 then
        local x = GetPlayerRawXPos()
        local y = GetPlayerRawYPos()
        local z = GetPlayerRawZPos()

        local randomX, _, randomZ = RandomAdjustCoordinates(x, y, z, 10)

        if GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 3 then
            yield("/vnav stop")
            yield("/wait 1")
            LogInfo("[UmbralGathering] Antistuck")
            PathfindAndMoveTo(randomX, y, randomZ)
        end

        LastStuckCheckTime = now
        LastStuckCheckPosition = {x=x, y=y, z=z}
    end
end
--#endregion Movement

--#region Gathering

function SkillCheck()
    local class = GetClassJobId()
    if class == 16 then -- Miner Skills
        Yield2 = "\"King's Yield II\""
        Gift2 = "\"Mountaineer's Gift II\""
        Gift1 = "\"Mountaineer's Gift I\""
        Tidings2 = "\"Nald'thal's Tidings\""
        Bountiful2 = "\"Bountiful Yield II\""
    elseif class == 17 then -- Botanist Skills
        Yield2 = "\"Blessed Harvest II\""
        Gift2 = "\"Pioneer's Gift II\""
        Gift1 = "\"Pioneer's Gift I\""
        Tidings2 = "\"Nophica's Tidings\""
        Bountiful2 = "\"Bountiful Harvest II\""
    else
        yield("/echo Cannot find gathering skills for class #"..class)
        yield("/snd stop")
    end
end

function UseSkill(SkillName)
    yield("/ac "..SkillName)
    yield("/wait 1")
end

function Gather()
    local visibleNode = ""
    if IsAddonVisible("_TargetInfoMainTarget") then
        visibleNode = GetNodeText("_TargetInfoMainTarget", 3)
    elseif IsAddonVisible("_TargetInfo") then
        visibleNode = GetNodeText("_TargetInfo", 34)
    end

    if not HasTarget() or GetTargetName() ~= NextNode.nodeName then
        yield("/target "..NextNode.nodeName)
        yield("/wait 1")
        if not HasTarget() then
            -- yield("/echo Could not find "..NextNode.nodeName)
            if NextNode.isUmbralNode then
                if not DoFish then
                    RandomWait()
                    LeaveDuty()
                    State = CharacterState.diademEntry
                    return
                end
                UmbralGathered = true
            else
                if NextNodeId >= #GatheringRoute[RouteType] then
                    if SelectedRoute == "Random" then
                        RouteType = GetRandomRouteType()
                        yield("/echo New random route selected : "..RouteType)
                    end
                    NextNodeId = 1
                else
                    NextNodeId = NextNodeId + 1
                end
                NextNode = GatheringRoute[RouteType][NextNodeId]
            end
            RandomWait()
            LastStuckCheckTime = os.clock()
            LastStuckCheckPosition = { x = GetPlayerRawXPos(), y = GetPlayerRawYPos(), z = GetPlayerRawZPos() }
            State = CharacterState.ready
            LogInfo("[UmbralGathering] State Change: Ready")
        end
        return
    end

    if GetDistanceToTarget() < 5 and GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("[UmbralGathering] State Change: Dismount")
        return
    end

    if GetDistanceToTarget() >= 3.5 then
        if not (PathfindInProgress() or PathIsRunning()) then
            LogInfo("[UmbralGathering] Gathering move closer")
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying))
        end
        return
    end

    if (PathfindInProgress() or PathIsRunning()) then
        yield("/vnav stop")
        return
    end

    if not GetCharacterCondition(CharacterCondition.gathering) then
        yield("/interact")
        return
    end

    SkillCheck()

    -- proc the buffs you need
    if (NextNode.isUmbralNode and not NextNode.isFishingNode) or visibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        LogInfo("[UmbralGathering] This is a Max Integrity Node, time to start buffing/smacking")
        if BuffYield2 and GetGp() >= 500 and not HasStatusId(219) and GetLevel() >= 40 then
            LogInfo("[UmbralGathering] Using skill yield2")
            UseSkill(Yield2)
            return
        elseif BuffGift2 and GetGp() >= 300 and not HasStatusId(759) and GetLevel() >= 50 then
            LogInfo("[UmbralGathering] Using skill gift2")
            UseSkill(Gift2) -- Mountaineer's Gift 2 (Min)
            return
        elseif BuffTidings2 and GetGp() >= 200 and not HasStatusId(2667) and GetLevel() >= 81 then
            LogInfo("[UmbralGathering] Using skill tidings2")
            UseSkill(Tidings2) -- Nald'thal's Tidings (Min)
            return
        elseif BuffGift1 and GetGp() >= 50 and not HasStatusId(2666) and GetLevel() >= 15 then
            LogInfo("[UmbralGathering] Using skill gift1")
            UseSkill(Gift1) -- Mountaineer's Gift 1 (Min)
            return
        elseif BuffBYieldHarvest2 and GetGp() >= 100 and not HasStatusId(1286) and GetLevel() >= 68 then
            LogInfo("[UmbralGathering] Using skill bountiful2")
            UseSkill(Bountiful2)
            return
        end
        -- elseif visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        --     LogInfo("[Diadem Gathering] [Node Type] Normal Node")
        --     DGatheringLoop = true
    end

    if (GetGp() >= (GetMaxGp() - 30)) and (GetLevel() >= 68) and visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        LogInfo("[UmbralGathering] Popping Yield 2 Buff")
        UseSkill(Bountiful2)
        return
    end

    if IsAddonVisible("Gathering") and IsAddonReady("Gathering") then
        if GetTargetName():sub(1, 7) == "Clouded" then
            local callback = "/callback Gathering true "..(UmbralGatheringSlot-1)
            LogInfo("[UmbralGathering] "..callback)
            yield(callback)
        else
            LogInfo("[UmbralGathering] /callback Gathering true "..RegularGatheringSlot-1)
            yield("/callback Gathering true "..RegularGatheringSlot-1)
        end
    end
end

function GoFishing()
    local weather = GetActiveWeatherID()
    if not (weather >= 133 and weather <= 136) then
        if GetCharacterCondition(CharacterCondition.fishing) then
            yield("/ac Quit")
            yield("/wait 1")
        else
            State = CharacterState.ready
            LogInfo("[UmbralGathering] State Change: ready")
        end
        return
    end

    if GetCharacterCondition(CharacterCondition.fishing) then
        if (PathfindInProgress() or PathIsRunning()) then
            yield("/vnav stop")
        end
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("[UmbralGathering] State Change: Dismounting")
        return
    end

    if GetDistanceToPoint(NextNode.fishingX, NextNode.fishingY, NextNode.fishingZ) > 1 and not PathfindInProgress() and not PathIsRunning() then
        PathfindAndMoveTo(NextNode.fishingX, NextNode.fishingY, NextNode.fishingZ)
        return
    end

    DeleteAllAutoHookAnonymousPresets()
    UseAutoHookAnonymousPreset(NextNode.autohookPreset)
    yield("/wait 1")
    yield("/ac Cast")
end

function BuyFishingBait()
    if GetItemCount(30279) >= 30 and GetItemCount(30280) >= 30 and GetItemCount(30281) >= 30 then
        if IsAddonVisible("Shop") then
            yield("/callback Shop true -1")
        else
            State = CharacterState.moveToNextNode
            LogInfo("[UmbralGathering] State Change: MoveToNextNode")
        end
        return
    end

    if GetDistanceToPoint(Mender.x, Mender.y, Mender.z) > 100 then
        LeaveDuty()
        State = CharacterState.diademEntry
        LogInfo("[UmbralGathering] Diadem Entry")
        return
    end

    if not HasTarget() or GetTargetName() ~= Mender.npcName then
        yield("/target "..Mender.npcName)
        return
    end

    if GetDistanceToPoint(Mender.x, Mender.y, Mender.z) > 5 then
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(Mender.x, Mender.y, Mender.z)
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if IsAddonVisible("SelectIconString") then
        yield("/callback SelectIconString true 0")
    elseif IsAddonVisible("SelectYesno") then
        yield("/callback SelectYesno true 0")
    elseif IsAddonVisible("Shop") then
        if GetItemCount(30279) < 30 then
            yield("/callback Shop true 0 4 99 0")
        elseif GetItemCount(30280) < 30 then
            yield("/callback Shop true 0 5 99 0")
        elseif GetItemCount(30281) < 30 then
            yield("/callback Shop true 0 6 99 0")
        end
    else
        yield("/interact")
    end
end

function FireCannon()
    if GetDiademAetherGaugeBarCount() == 0 then
        State = CharacterState.ready
        LogInfo("[UmbralGathering] State Change: Ready")
        return
    end

    if GetClassJobId() ~= 16 and GetClassJobId() ~= 17 then
        yield("/gs change Miner")
        yield("/wait 3")
        return
    end

    local now = os.clock()
    if now - LastStuckCheckTime > 10 then
        local x = GetPlayerRawXPos()
        local y = GetPlayerRawYPos()
        local z = GetPlayerRawZPos()

        local randomX, _, randomZ = RandomAdjustCoordinates(x, y, z, 10)

        if GetDistanceToPoint(LastStuckCheckPosition.x, LastStuckCheckPosition.y, LastStuckCheckPosition.z) < 3 then
            yield("/vnav stop")
            yield("/wait 1")
            LogInfo("[UmbralGathering] Antistuck")
            PathfindAndMoveTo(randomX, y, randomZ)
        end

        LastStuckCheckTime = now
        LastStuckCheckPosition = {x=x, y=y, z=z}
    end

    if not HasTarget() then
        for i=1, #MobTable[TargetType] do
            yield("/target "..MobTable[TargetType][i][1])
            yield("/wait 0.03")
            if HasTarget() then
                LogInfo("[UmbralGathering] Found cannon target")
                return
            end
        end

        State = CharacterState.moveToNextNode
        LogInfo("[UmbralGathering] State Change: MoveToNextNode")
        return
    end

    yield("/wait 0.5")
    if not HasTarget() then
        LogInfo("[UmbralGathering] Target does not stick. Skipping...")
        State = CharacterState.moveToNextNode
        LogInfo("[UmbralGathering] State Change: MoveToNextNode")
        return
    end

    if GetDistanceToTarget() > 10 then
        if GetDistanceToTarget() > 50 and not GetCharacterCondition(CharacterCondition.mounted) then
            State = CharacterState.aetherCannonMount
            LogInfo("[UmbralGathering] State Change: Aether Cannon Mount")
        elseif not PathfindInProgress() and not PathIsRunning() then
            LogInfo("[UmbralGathering] Too far from target, moving closer")
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.mounted))
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        yield("/ac dismount")
        yield("/wait 1")
        return
    end

    if GetTargetHP() > 0 then
        yield("/gaction \"Duty Action I\"")
        yield("/wait 1")
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
    if GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) then
        LogInfo("[UmbralGatherer] Repairing...")
        yield("/wait 1")
        return
    end

    if SelfRepair then
        if GetItemCount(33916) > 0 then
            if GetCharacterCondition(CharacterCondition.mounted) then
                Dismount()
                LogInfo("[UmbralGatherer] State Change: Dismounting")
                return
            end

            if IsAddonVisible("Shop") then
                yield("/callback Shop true -1")
                return
            end

            if NeedsRepair(RepairAmount) then
                if not IsAddonVisible("Repair") then
                    LogInfo("[UmbralGatherer] Opening repair menu...")
                    yield("/generalaction repair")
                end
            else
                State = CharacterState.ready
                LogInfo("[UmbralGathering] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if not HasTarget() or GetTargetName() ~= Mender.npcName then
                yield("/target "..Mender.npcName)
                yield("/wait 1")
                if not HasTarget() or GetTargetName() ~= Mender.npcName then
                    LeaveDuty() -- leave and reenter next to mender
                    State = CharacterState.diademEntry
                    LogInfo("[UmbralGathering] Diadem Entry")
                else
                    yield("/interact")
                end
                return
            end

            if GetDistanceToPoint(Mender.x, Mender.y, Mender.z) > 3.5 then
                if not (PathIsRunning() or PathfindInProgress()) then
                    PathfindAndMoveTo(Mender.x, Mender.y, Mender.z)
                end
                return
            else
                if PathIsRunning() or PathfindInProgress() then
                    yield("/vnav stop")
                end
            end

            if IsAddonVisible("SelectIconString") then
                yield("/callback SelectIconString true 0")
            elseif IsAddonVisible("Shop") then
                yield("/callback Shop true 0 14 99")
            end
        else
            yield("/echo Out of Dark Matter and ShouldAutoBuyDarkMatter is false. Switching to Mender.")
            SelfRepair = false
        end
    else
        if NeedsRepair(RepairAmount) then
            if not HasTarget() or GetTargetName() ~= Mender.npcName then
                yield("/target "..Mender.npcName)
                yield("/wait 1")
                if not HasTarget() or GetTargetName() ~= Mender.npcName then
                    LeaveDuty() -- leave and reenter next to mender
                    State = CharacterState.diademEntry
                    LogInfo("[UmbralGathering] Diadem Entry")
                else
                    yield("/interact")
                end
                return
            end

            if GetDistanceToPoint(Mender.x, Mender.y, Mender.z) > 3.5 then
                if not (PathIsRunning() or PathfindInProgress()) then
                    PathfindAndMoveTo(Mender.x, Mender.y, Mender.z)
                end
                return
            else
                if PathIsRunning() or PathfindInProgress() then
                    yield("/vnav stop")
                end
            end

            if IsAddonVisible("SelectIconString") then
                yield("/callback SelectIconString true 1")
                return
            end

            yield("/interact")
        else
            State = CharacterState.ready
            LogInfo("[UmbralGatherer] State Change: Ready")
        end
    end
end
--#endregion Gathering

CharacterState = {
    ready = Ready,
    processRetainers = ProcessRetainers,
    diademEntry = EnterDiadem,
    nextNodeMount = Mount,
    aetherCannonMount = AetherCannonMount,
    dismounting = Dismount,
    moveToNextNode = MoveToNextNode,
    gathering = Gather,
    fishing = GoFishing,
    fireCannon = FireCannon,
    buyFishingBait = BuyFishingBait,
    repair = Repair,
    extractMateria = ExtractMateria
}

FoundationZoneId = 418
FirmamentZoneId = 886
DiademZoneId = 939

if SelectedRoute == "Random" then
    RouteType = GetRandomRouteType()
elseif GatheringRoute[SelectedRoute] then
    RouteType = SelectedRoute
else
    yield("/echo Invalid SelectedRoute : " .. RouteType)
end
yield("/echo SelectedRoute : " .. RouteType)
if MinerRoutes[RouteType] and GetClassJobId() ~= 16 then
    yield("/gs change Miner")
elseif BotanistRoutes[RouteType] and GetClassJobId() ~= 17 then
    yield("/gs change Botanist")
end
yield("/wait 3")

SetSNDProperty("StopMacroIfTargetNotFound", "false")
if not (IsInZone(FoundationZoneId) or IsInZone(FirmamentZoneId) or IsInZone(DiademZoneId)) then
    TeleportTo("Foundation")
end
if IsInZone(FoundationZoneId) then
    yield("/target aetheryte")
    yield("/wait 1")
    if GetTargetName() == "aetheryte" then
        yield("/interact")
    end
    repeat
        yield("/wait 1")
    until IsAddonVisible("SelectString")
    yield("/callback SelectString true 2")
    repeat
        yield("/wait 1")
    until IsInZone(FirmamentZoneId)
end
if IsInZone(DiademZoneId) then
    JustEntered = GetDistanceToPoint(Mender.x, Mender.y, Mender.z) < 50
else
    JustEntered = true
end

LastStuckCheckTime = os.clock()
LastStuckCheckPosition = { x = GetPlayerRawXPos(), y = GetPlayerRawYPos(), z = GetPlayerRawZPos() }

State = CharacterState.ready
NextNodeId = 1
NextNode = GatheringRoute[RouteType][NextNodeId]
while true do
    if GetInventoryFreeSlotCount() == 0 then
        if IsInZone(DiademZoneId) then
            LeaveDuty()
        end
        yield("/snd stop")
    elseif not IsInZone(DiademZoneId) and State ~= CharacterState.diademEntry and State ~= CharacterState.processRetainers then
        State = CharacterState.diademEntry
    end
    if not (IsPlayerCasting() or
            GetCharacterCondition(CharacterCondition.betweenAreas) or
            GetCharacterCondition(CharacterCondition.jumping48) or
            GetCharacterCondition(CharacterCondition.jumpPlatform) or
            GetCharacterCondition(CharacterCondition.mounting57) or
            GetCharacterCondition(CharacterCondition.mounting64) or
            GetCharacterCondition(CharacterCondition.beingMoved) or
            GetCharacterCondition(CharacterCondition.occupiedMateriaExtractionAndRepair) or
            LifestreamIsBusy())
    then
        State()
    end
    yield("/wait 0.1")
end