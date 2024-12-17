--[[

********************************************************************************
*                              Umbral Gathering                                *
********************************************************************************

Does DiademV2 gathering until umbral weather happens, then gathers umbral node
and goes fishing until umbral weather disappears.

********************************************************************************
*                               Version 1.0.6                                  *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
        
    ->  1.0.6   Removed jump to fly
                Updated autohook presets to force bait swap
                Fixed DoFish, added DodgeTree()
                Added food and potion check back in
                Fixed starting NodeId after entering Diadem
                Added default change to miner to make sure you can queue in
                Added ability to leave and re-enter after gathering umbral nodes
                    instead of fishing (credit: Estriam)
                Added long route for botanist islands and added ability to
                    select random route after finishing previous route (credit: 
                    Mars375)
                SetSNDProperty("StopMacroIfTargetNotFound", "false")
                Fixed it for autobuy dark matter too
                Fixed bug with repairing via mender
                Fixed mender name for repair function
                Fixed name for merchant & mender
                Logging for mender?
                Added wait for vnav to be ready
                First release

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

SelectedRoute = "Random"
-- Select which route you would like to do. 
    -- Options are:
        -- "RedRoute"     -> MIN perception route, 8 node loop
        -- "PinkRoute"    -> BTN perception route, 8 node loop
        -- "MinerIslands" -> MIN, all the islands
        -- "BotanistIslands" -> BTN, all the islands
        -- "Random" -> Randomizes the route each time

GatheringSlot = 4
-- This will let you tell the script WHICH item you want to gather. (So if I was gathering the 4th item from the top, I would input 4)
-- This will NOT work with Pandora's Gathering, as a fair warning in itself. 
-- Options : 1 | 2 | 3 | 4 | 7 | 8 (1st slot... 2nd slot... ect)

TargetType = 1
-- This will let you tell the script which target to use Aethercannon.
-- Options : 0 | 1 | 2 | 3 (Option: 0 is don't use cannon, Option: 1 is any target, Option: 2 only sprites, Option: 3 is don't include sprites)

PrioritizeUmbral = true
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

PlayerWaitTime = true
-- this is if you want to make it... LESS sus on you just jumping from node to node instantly/firing a cannon off at an enemy and then instantly flying off
-- default is true, just for safety. If you want to turn this off, do so at your own risk.

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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/jNhD+K4YuvZiAHtQrN683cQNk02CdRQ9FDyOJsgnLopeitusu8t87lMRYsuV4GwS9NDdqOPxmOBp9M6Mf1qxWYg6Vqub5yrr6YV2XkBRsVhTWlZI1m1p6846X7LCZma1bXLlRPLUeJBeSq7115aC0uv6eFnXGsoNY6z+1WJ+ESNcarFm4etXgBNHUWuwe15JVa1GgxLHtAfLL0A1GHA5O2Bedma/rrfGAOja94II5JYqCpap30OmruZfNCplxKAxA4NABAO3Ubni1vt6zqmfIP/LQ9wceBibIsGHLNc/VB+CNn1pQGcFSQbpBVATrQn+K20eNO9QHUJyVKev5ExyfC4YRc81Ryf9mc1DtqzdWj0+7R/H2utOPayg4bKob+CakBhgIzHW86VD+maXiG0N9RwfJ2KQDCyZgH/hqAdvmZrNyVTBZGVS3PeqFNj1xdwAVPSHW9XclofuUdKgfxfIv2N2WquaKi3IBvDQBIPjO72rJPrGqghWatqypdd84Yd0L/OCmLcJ+hxIdiRG8O1GpV+M94EXYuIcWsc7stxab/YM/yx1+DhKKeS0lK9Ub3fII9c3uOurtyY1HrTdaN0KmrPmOUM1wYZs1SyV2+qvl5WqpGG46/Qt1mTWTb3OPPlzj2JeSf62ZxrXcNI7t1LWJG4BHKKUegTxzCXUozSFJ/CBJLMS745X6Ldc2MNX/aHNWX8A46NluZJ/38SOHjG0ncwklm9wUew15L+QWil+F2GgQwxm/M2ietRxv8FxJcigqDF/73G3249qJ2ghQJ9RcZDCXSopy9QaottdDvWMrVmYg94eK95MIH0WNykc3bTXcIH5WOHH7VGXgw4jWo+S7c5ZC3/WeVc7ZGii9YK3T03k9yxWTc6hXa+wHtrqsYPKOJXzTMWDCNHVLL3oEPdJBeKEfnxbeF2qorvaGjkyafWZfay5ZhqZUrUubbifO5N7P5dLl3HhPgVelwGvfeY/dIh9fS5aHBBfIbk5mkxhShwSZ56R+FLuOjez2p6G3ruUcozdsX+l5eltIpLcJnSw3+6TmRYZs+8tkscZSMLkBJvmQn3V7+E5+7+T35pn/znb/a7aLAz9OkpiRIPB0LwcxAcfPiJ2keUSzDKI077Fdy29IdkOii/WMd4nosJfkFZRQDClvLvm2EuUEtbkCKU5o72y4bjPsnXmKbTTGSDvTKsy2oi57aiNtAfXj43nLGw67kTZcyxywehe6M+umUj/2L8yVPp4c+Q8x9nvjP/8tcRgXXj0k6MNaMtdBbuLbHxu6YUEvW/FBbSy5+2U3imw3yB2SRllCqB1RkgQ+JakfejnL8yx0gyYRW9zOxS/bBMconA5AsgmZ/PtU63ngBDFEOL2QFOKMUAhzkoQsJZgZoZ16LA4ZWE//AMu8vwXWEgAA"
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
            x = 589.74, y = 188.42, z = -591.81,
            fishingX=593.08, fishingY=187.17, fishingZ=-594.61,
            autohookPreset = "AH4_H4sIAAAAAAAACu1YzW/iOBT/V1Aue8FS4tgh6Y2hLVOJdquhoz2s9mAcByxCzDjOzLCj/u/znI+SQChVhfayPWGen3/vI88/P/uXMy6MmrDc5JNk6Vz9cm4ytkjFOE2dK6MLMXTs5ExmYj8ZN1N3MMJhNHQetVRamp1z5YE0v/nJ0yIW8V5s9Z8rrHul+MqClQNsRyVOEA6d6fZppUW+UilIPNftIL8OXWJEo84K96wzk1WxaTwgnkvOuNCsUmkquGkt9Npq+LxZpWPJ0gYg8EgHgNRqtzJf3exE3jJEDzyktONh0CSZrcV8JRPzicnSTyvIG8HcML4GVACrU3+M20aNatRHZqTIuGj5ExyuC7oZw81SLf8VE2aqT99YPVyND/Lt16ufViyVbJ3fsu9KW4COoAnHH3blXwRX3wXoezZJjU3SsdAk7JNcTtmmjGycLVOh8wYVV0v9kUuO3O1Ahc+AdfPTaFZvJZvqJzX/wbZ3mSmkkSqbMpk1CUDwzWeFFvciz9kSTDvO0HkonXAeFGy4YYWw24LEZqIHb6Zy8268RwhE9HvoIOfEfGWxnN/7M9/CdtAsnRRai8xcKMoD1IvF2uvtUcS91kutW6W5KPcRqDVcWFXN3Kit3bUyW86NgEmvHVBdWWN9mTjacKVjXzP5rRAW1xFxvBAME4RH1EOEUYxCFiVoxHAQj0I/ioDGAW8mc/NnYm1Aqf9d1awNoHHQd3H4io/XksViM/hs99kPpTcW8gF+WfpZqbUFaTjjL8HK/1YOEbycJAlLc0hf9b+ebOe1FlUZIN7IclGDOTdaZcsLoLp+C3UmliKLmd7tT7w3IlyrApQPIq00cBC9KBy5fazS8aFH60nL7SlLI4r9F5VTtjpKr1ir9WxdjxMj9IQVyxX0Axt7rEBh9BV82TFAwZTnlh20CLqng/BHNDo+eF85Q+1p39BRU2ZfxLdCahGDKVPYo822Eydq7221dL42PkrgXSXw3m/eYrc44QENwwARjywQCXyKFsTjiI38OOKJSBJBned/GnqrW84+eoP2lZymt6kGehuQwXy9WxQyjYFt/xhMV3AUDG6Z0LLLz7Y9/CC/D/K7eOV/sN3/mu1YFGPKBUfExUB5lBAUum6CfBIljFPfd6nXYruK34DsukQXuW8gOuglZc4ylnYp755BD5ym7IjuTqbpLoaeWXJonyE31olKYbxRRdZS62kHCI0O71l+95IbWsOFhtjFPLUdWX0bpRE9c5+ksLLn/aHvWeM/f47YXxPefTmwi61kYpNc5rd9XagvCXZYifdqfUXdLkC+CNyYBYh71FahCFAUBhj5PMSYuiEO4E3AFmCFW7v4dbOA69PguoDHJQN3ggEavL3MWtZHmNCYswVyfRIj4sM5HxHGEY98z09YEHscO8+/AWFE55LKEgAA"
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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/jNhD+K4YuvZiAnpSUm+NN3ABOGsRZ9FD0QEkjm7AseikpXXeR/75DSYwlW46b3bSX5kYMZ755aPhxqG/GpCrFlBVlMU2XxsU34ypnUQaTLDMuSlnB2FCbc57DfjPRWze4soNwbNxLLiQvd8aFhdLi6mucVQkke7HSf26wboWIVwqsXthqVePQYGzMto8rCcVKZCixTLOH/Dp0jRH6PQvzbDDTVbXREbiW6Z4JQVuJLIO47BhaXTX7vFshE84yDUAttwfgtmrXvFhd7aDoOPIOIvS8XoRUF5mtYbHiaXnJeB2nEhRasChZvEZUBGtLf4zbRQ1b1HtWcshj6MRDD+1ov2K2NpX8b5iysvn02uuhtX1Qb6e1flyxjLN1cc2ehFQAPYFOxxn35Q8QiydAfUsVSft0ex50wS75csY2dWaTfJmBLDSq3Zg6vukehduDCp4R6+prKVl7lFSpH8XiL7a9ycuKl1zkM8ZzXQCC33xeSbiFomBLdG0YY+OuDsK4E3jgxg3CbosSVYkBvLkoyh/Gu8dEYDhCgxgn9huP9f4+nsUWj4Nk2bSSEvLynbI8QH23XAejPcp40HutdS1kDPU5QjXNhU3XLEqxVaeW58tFCbhpdRNqO2si3yePLlwd2Oecf6lA4Rp+Sm0bDxhhceIS1zEjEpipRWLT8sIkddIgMQ3Em/Oi/C1VPrDV/2h6ViWgA3RM2w9Px/iJswQ2owdIRpcsy4TIFeidkBuW/SrEWsFo1vgd2Hp/iahdzKRbwlbUJOtavqIdbbwopcjrU9VqvVxFKcsKNP6nqKbTQZ3DEvKEyd1b4qoRPokKlXVKPQ2bhi8KR2Efq/RiGNB6lHx7ypPv2c6LyilfPaVXvLV6qoUnaQlyyqrlCq/+jbpBsE+HerseDrA36itKLTpc3LCmFx5fqq/cj+om11SjG+gBvlRcQoLYZaWuLTUqHHbVm5rnfDN8fPP/9Jt3mCv2HOoyixLHcoC4DDwSRIyS1I4dMwnMgLqW8fynpq52nByiLhxN3dPUNZNIXSN3tFjvoopnCTLpL6PZCml+dM1A8j73Wmdp7Sd56YPtPtjug+3+d2wHlCVBkEQkcrwA5zRKSQRuQCLLim0fTAoh67Bdw29Idv8q0Z0s0E2CkzCPcSjGqij3jcJkI6q8p4aM5oWHzyWn/1YNlKdKpgwv6EzxYvuo9ELvzLPQQ8uB3whDfyd+8q/CEOSbfjLsh/8fHvmVsZJMVZHr+nYfAe3or5aNeK821M6d1qNeFEWUAgl8SInrxwFhEYSEMhfs1IPQc5y69RrcNsTPmwgfRaM5PPF8REa6ufARwguW406vzW5hyXKoJOu/TpjvxGGUxMRJ0b+bmhZhYUgJjYIktvw48TzPeP4OKtXzrJ0SAAA="
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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/bOBD+K4YuezEBUaJeublu4gZws0HtYg+LHiiJsgnLoktRbb1F/nuHkhhLthw3bXYvm5OE4cw3Dw2/IfXdmlRKTGmpymm2sq6+W9cFjXM2yXPrSsmKjS29OOcFOyymZukW3pwwGlv3kgvJ1d66wiAtr78leZWy9CDW+g8N1nshkrUGq18c/Vbj+OHYmu2Wa8nKtchBgm27h/w0dI0RBT0L+2Iw03W1NREQbJMLIRgrkecsUR1D3FVzLrsVMuU0NwA+Jj0A0qrd8HJ9vWdlx5F3FKHn9SL0TZHphi3WPFNvKK/j1ILSCBaKJhtABbC29Ke4XdSoRb2nirMiYZ14/GM7v18xx5hK/g+bUtV8euP12No5qrfbWi/XNOd0U97QL0JqgJ7ApOOO+/IPLBFfGOhjXSTjk/Q8mIK94asZ3daZTYpVzmRpUJ3G1A1schJuDyp8AKzrb0rSdivpUi/F4ivd3Raq4oqLYkZ5YQqA4JvPK8nes7KkK3BtWWPrrg7CuhOw4cYNwn4HEl2JAby5KNUv491DImw4QgtZZ9Ybj/X6IZ7FDraDpPm0kpIV6oWyPEJ9sVwHoz3JeNB7rXUjZMLqfQRqhgubrlkosdO7lherhWKwiLsJtZ01kS+TRxeuDuxjwT9XTONatp85kR0HKAl8jAjBKYqcEKMoJGnqZBkN/MACvDkv1Z+Z9gGt/nfTszoBE6Brg9X5GN9ymrLt6J3eZ1+F3GrIO3jS/J0QGw1iOOMvRjeHEaJXIY9uAVtRkyrBgSYdY7xQUhT1nmq1HgdRRvMSjH8W1XY7qHO2YkVK5f45cdUIb0UFyialnobjR48KJ2GfqvRiGNBaSr475ynwHPdR5ZyvntIT3lo93cCTTDE5pdVqDYN/q+cHdMBQZ9dHA+iMekDplw4TN5zpRacj9YnpqOe4IRrTQB/Y54pLlgK2qvTQ0geF4656VvNcbobXb/6ffvMOb7mYuZmThIh4gYOI7fmIOhlGIWM4sRM3oaltPXwyxNUeJoeICw6m5DxxzSQQ14iMFpt9XPE8BR79YzRbA8mPbiiTvM+8+CKt/SYvvbLdK9u9st3/ju1i7GGcOgzhIKSIOCRFMc0oigI7c0hMgjiOO2zX8BuQ3b9KdGcLdJvCOZgncCSGqmj3jcJkK6qipwaM5kXHlyW3f1MNtadKZhQGdK55sb1SepF34VLogeXAT4ShfxO/+U9hCPJZvxgOR/9fPvBrYy2Z6iLX9e1eAdqDv35txAe1oXbutJ7uL99mNsJJkEDrRTaKsJshSrEfuBlOXdepW6/BbUP8uI3hSjRasu2OQQehkWkvuITwkhaw1m80ybMMrlf9GZ/EsRtgglIaMATDz0EhoRlK0zAKIRrPozDjfwACYvDxmxIAAA=="
        }
    }
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
            {x = -209.1468, y = -3.9325, z = -357.9749, nodeName = "Mineral Deposit", antistutter = 1},
            {x = -169.3415, y = -7.1092, z = -518.7053, nodeName = "Mineral Deposit", antistutter = 0}, -- Around the tree (Rock + Bones?)
            {x = -78.5548, y = -18.1347, z = -594.6666, nodeName = "Mineral Deposit", antistutter = 0}, -- Log + Rock (Problematic)
            {x = -54.6772, y = -45.7177, z = -521.7173, nodeName = "Mineral Deposit", antistutter = 0}, -- Down the hill
            {x = -22.5868, y = -26.5050, z = -534.9953, nodeName = "Rocky Outcrop", antistutter = 0}, -- up the hill (rock + tree)
            {x = 59.4516, y = -41.6749, z = -520.2413, nodeName = "Rocky Outcrop", antistutter = 0}, -- Spaces out nodes on rock (hate this one)
            {x = 102.3, y = -47.3, z = -500.1, nodeName = "Mineral Deposit", antistutter = 0}, -- Over the gap
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
        }
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
    jumpPlatform=61,
    betweenAreasForDuty=51,
    boundByDuty56=56,
    mounting57=57,
    mounting64=64,
    beingMoved=70,
    flying=77
}

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

function Ready()
    FoodCheck()
    PotionCheck()
    
    if GetItemCount(30279) < 30 or GetItemCount(30280) < 30 or GetItemCount(30281) < 30 then
        State = CharacterState.buyFishingBait
        LogInfo("[UmbralGathering] State Change: BuyFishingBait")
    elseif RepairAmount > 0 and NeedsRepair(RepairAmount) then
        State = CharacterState.repair
        LogInfo("[UmbralGathering] State Change: Repair")
    elseif GetDiademAetherGaugeBarCount() > 0 and TargetType > 0 then
        State = CharacterState.fireCannon
        LogInfo("State Change: Fire Cannon")
    else
        State = CharacterState.moveToNextNode
        LogInfo("[UmbralGathering] State Change: MoveToNextNode")
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

--#endregion States

--#region Movement
function TeleportTo(aetheryteName)
    yield("/tp "..aetheryteName)
    yield("/wait 1") -- wait for casting to begin
    while GetCharacterCondition(CharacterCondition.casting) do
        LogInfo("[FATE] Casting teleport...")
        yield("/wait 1")
    end
    yield("/wait 1") -- wait for that microsecond in between the cast finishing and the transition beginning
    while GetCharacterCondition(CharacterCondition.betweenAreas) do
        LogInfo("[FATE] Teleporting...")
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
        LogInfo("[FATE] State Change: MoveToNextNode")
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
                LogInfo("Unable to dismount here. Moving to another spot.")
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
            LogInfo("State Change: Fishing")
        else
            State = CharacterState.gathering
            LogInfo("State Change: Gathering")
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
    if PrioritizeUmbral and not UmbralGathered and (weather >= 133 and weather <= 136) then
        for _, umbralWeather in pairs(UmbralWeatherNodes) do
            if umbralWeather.weatherId == weather then
                umbralWeather.gatheringNode.isUmbralNode = true
                umbralWeather.gatheringNode.isFishingNode = false
                umbralWeather.gatheringNode.umbralWeatherName = umbralWeather.weatherName
                LogInfo("Selected umbral gathering node for "..umbralWeather.weatherName..": "..umbralWeather.gatheringNode.nodeName)
                return umbralWeather.gatheringNode
            end
        end
    elseif PrioritizeUmbral and UmbralGathered and (weather >= 133 and weather <= 136) then
        if DoFish then
            for _, umbralWeather in pairs(UmbralWeatherNodes) do
                if umbralWeather.weatherId == weather then
                    umbralWeather.fishingNode.isUmbralNode = true
                    umbralWeather.fishingNode.isFishingNode = true
                    umbralWeather.fishingNode.umbralWeatherName = umbralWeather.weatherName
                    LogInfo("Selected umbral fishing node for "..umbralWeather.weatherName)
                    return umbralWeather.fishingNode
                end
            end
        else
            LeaveDuty()
        end
    else
        GatheringRoute[RouteType][NextNodeId].isUmbralNode = false
        GatheringRoute[RouteType][NextNodeId].isFishingNode = false
        LogInfo("Selected regular gathering node: "..GatheringRoute[RouteType][NextNodeId].nodeName)
        return GatheringRoute[RouteType][NextNodeId]
    end
end

function MoveToNextNode()
    NextNodeCandidate = SelectNextNode()
    if (NextNodeCandidate == nil) then
        State = CharacterState.ready
        LogInfo("State Change: Ready")
        return
    elseif (NextNodeCandidate.x ~= NextNode.x or NextNodeCandidate.y ~= NextNode.y or NextNodeCandidate.z ~= NextNode.z) then
        yield("/vnav stop")
        NextNode = NextNodeCandidate
        if NextNode.isUmbralNode then
            yield("/echo Umbral weather "..NextNode.umbralWeatherName.." detected")
        end
        return
    end

    if not GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.mounting
        LogInfo("State Change: Mounting")
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
    elseif not NextNode.isUmbralNode and (RouteType == "RedRoute" or RouteType == "MinerIslands") and GetClassJobId() ~= 16 then
        yield("/gs change Miner")
        yield("/wait 3")
    elseif not NextNode.isUmbralNode and (RouteType == "PinkRoute" or RouteType == "BotanistIslands") and GetClassJobId() ~= 17 then
        yield("/gs change Botanist")
        yield("/wait 3")
    elseif GetDistanceToPoint(NextNode.x, NextNode.y, NextNode.z) <= 5 then
        yield("/vnav stop")

        if NextNode.isFishingNode then
            State = CharacterState.fishing
            LogInfo("State Change: Fishing")
            return
        else
            State = CharacterState.gathering
            LogInfo("State Change: Gathering")
            return
        end
    elseif GetDistanceToPoint(NextNode.x, NextNode.y, NextNode.z) > 5 and
        not (PathfindInProgress() or PathIsRunning())
    then
        PathfindAndMoveTo(NextNode.x, NextNode.y, NextNode.z, true)
    end
end
--#endregion Movement

--#region Gathering

function SkillCheck()
    if GetClassJobId() == 16 then -- Miner Skills 
        Yield2 = "\"King's Yield II\""
        Gift2 = "\"Mountaineer's Gift II\""
        Gift1 = "\"Mountaineer's Gift I\""
        Tidings2 = "\"Nald'thal's Tidings\""
        Bountiful2 = "\"Bountiful Yield II\""
    elseif GetClassJobId() == 17 then -- Botanist Skills 
        Yield2 = "\"Blessed Harvest II\""
        Gift2 = "\"Pioneer's Gift II\""
        Gift1 = "\"Pioneer's Gift I\""
        Tidings2 = "\"Nophica's Tidings\""
        Bountiful2 = "\"Bountiful Harvest II\""
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
            if NextNode.nodeName:sub(1, 7) == "Clouded" then
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
            State = CharacterState.ready
            LogInfo("State Change: Ready")
        end
        return
    end

    if GetDistanceToTarget() < 5 and GetCharacterCondition(CharacterCondition.mounted) then
        State = CharacterState.dismounting
        LogInfo("State Change: Dismount")
        return
    end

    if GetDistanceToTarget() >= 3.5 then
        if not (PathfindInProgress() or PathIsRunning()) and not IsPlayerOccupied() then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos(), GetCharacterCondition(CharacterCondition.flying))
        end
        return
    end

    if (GetDistanceToTarget() < 3.5 or GetCharacterCondition(CharacterCondition.gathering42)) and
        (PathfindInProgress() or PathIsRunning())
    then
        yield("/vnav stop")
        return
    end

    if not GetCharacterCondition(CharacterCondition.gathering) then
        SkillCheck()
        yield("/interact")
        return
    end

    -- proc the buffs you need
    if (NextNode.isUmbralNode and not NextNode.isFishingNode) or visibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        LogInfo("[Diadem Gathering] [Node Type] This is a Max Integrity Node, time to start buffing/smacking")
        if BuffYield2 and GetGp() >= 500 and not HasStatusId(219) and GetLevel() >= 40 then
            UseSkill(Yield2)
            return
        elseif BuffGift2 and GetGp() >= 300 and not HasStatusId(759) and GetLevel() >= 50 then
            UseSkill(Gift2) -- Mountaineer's Gift 2 (Min)
            return
        elseif BuffTidings2 and GetGp() >= 200 and not HasStatusId(2667) and GetLevel() >= 81 then
            UseSkill(Tidings2) -- Nald'thal's Tidings (Min)
            return
        elseif BuffGift1 and GetGp() >= 50 and not HasStatusId(2666) and GetLevel() >= 15 then
            UseSkill(Gift1) -- Mountaineer's Gift 1 (Min)
            return
        elseif BuffBYieldHarvest2 and GetGp() >= 100 and not HasStatusId(1286) and GetLevel() >= 68 then
            UseSkill(Bountiful2)
            return
        end
    -- elseif visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
    --     LogInfo("[Diadem Gathering] [Node Type] Normal Node")
    --     DGatheringLoop = true
    end

    if (GetGp() >= (GetMaxGp() - 30)) and (GetLevel() >= 68) and visibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then
        LogInfo("Popping Yield 2 Buff")
        UseSkill(Bountiful2)
        return
    end

    if GetTargetName():sub(1, 7) == "Clouded" then
        yield("/callback Gathering true 0")
    else
        yield("/callback Gathering true "..GatheringSlot-1)
    end
end

function Fish()
    local weather = GetActiveWeatherID()
    if not (weather >= 133 and weather <= 136) then
        if GetCharacterCondition(CharacterCondition.fishing) then
            yield("/ac Quit")
            yield("/wait 1")
        else
            State = CharacterState.ready
            LogInfo("State Change: ready")
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
        LogInfo("State Change: Dismounting")
        return
    end

    if GetDistanceToPoint(NextNode.fishingX, NextNode.fishingY, NextNode.fishingZ) > 5 and not PathfindInProgress() and not PathIsRunning() then
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
            LogInfo("State Change: MoveToNextNode")
        end
        return
    end

    if GetDistanceToPoint(Mender.x, Mender.y, Mender.z) > 100 then
        LeaveDuty()
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
        LogInfo("State Change: Ready")
        return
    end

    if GetClassJobId() ~= 16 and GetClassJobId() ~= 17 then
        yield("/gs change Miner")
        yield("/wait 3")
        return
    end

    if not HasTarget() then
        for i=1, #MobTable[TargetType] do
            yield("/target "..MobTable[TargetType][i][1])
            yield("/wait 0.03")
            if HasTarget() then
                return
            end
        end
        
        State = CharacterState.moveToNextNode
        LogInfo("State Change: MoveToNextNode")
        return
    end

    if GetDistanceToTarget() > 10 then
        -- if not GetCharacterCondition(CharacterCondition.flying) then
        --     State = CharacterState.mounting
        --     LogInfo("State Change: Mount")
        -- else
        --     PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        -- end
        -- return
        if not PathfindInProgress() and not PathIsRunning() then
            PathfindAndMoveTo(GetTargetRawXPos(), GetTargetRawYPos(), GetTargetRawZPos())
        end
        return
    end

    if PathfindInProgress() or PathIsRunning() then
        yield("/vnav stop")
        return
    end

    if GetCharacterCondition(CharacterCondition.mounted) then
        -- State = CharacterState.dismounting
        -- LogInfo("State Change: Dismount")
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
                LogInfo("[FATE] State Change: Ready")
            end
        elseif ShouldAutoBuyDarkMatter then
            if not HasTarget() or GetTargetName() ~= Mender.npcName then
                yield("/target "..Mender.npcName)
                yield("/wait 1")
                if not HasTarget() or GetTargetName() ~= Mender.npcName then
                    LeaveDuty() -- leave and reenter next to mender
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
    diademEntry = EnterDiadem,
    mounting = Mount,
    dismounting = Dismount,
    moveToNextNode = MoveToNextNode,
    gathering = Gather,
    fishing = Fish,
    fireCannon = FireCannon,
    buyFishingBait = BuyFishingBait,
    repair = Repair
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
if (RouteType == "RedRoute" or RouteType == "MinerIslands") and GetClassJobId() ~= 16 then
    yield("/gs change Miner")
elseif (RouteType == "PinkRoute" or RouteType == "BotanistIslands") and GetClassJobId() ~= 17 then
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
    elseif not IsInZone(DiademZoneId) and State ~= CharacterState.diademEntry then
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
