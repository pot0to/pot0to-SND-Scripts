--[[

********************************************************************************
*                              Umbral Gathering                                *
********************************************************************************

Does DiademV2 gathering until umbral weather happens, then gathers umbral node
and goes fishing until umbral weather disappears.

********************************************************************************
*                               Version 1.0.4                                  *
********************************************************************************

Created by: pot0to (https://ko-fi.com/pot0to)
        
    ->  1.0.4   Fixed DoFish, added DodgeTree()
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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/jNhD+K4YuvViAHpQo5eb1Jm4Abxqss+ih6GFMUTZhWfRS1HbdRf57h3rEki3H28DopTlZHg6/GY6G38zohzUptZxCoYtpurJufli3OSwzPsky60arko8tszgXOT8sJu3SPT55UTy2HpWQSui9deOitLj9zrIy4clBbPSfa6xPUrK1AasePPNU4YTR2JrtntaKF2uZocR1nB7y69AVRkx7O5yLzkzX5bb1gLgOueBCu0tmGWe6s9HtqnmXzUqVCMhagNAlPQDSqN2JYn2750XHUHDkYRD0PAzbIMOGL9Yi1R9AVH4aQdEKFhrYBlERrAn9KW4XNW5QH0ELnjPe8Sc83hf2I+a1W5X4m09B16++tXq82zuKt9/sflpDJmBT3ME3qQxAT9Aexx/35Z85k9846rsmSK1N0rPQBuyDWM1gW51skq8yrooW1au3+tQhJ+72oKJnxLr9rhU0V8mE+kku/oLdfa5LoYXMZyDyNgA2vvN5qfgnXhSwQtOWNbYeKiesB4kXblwj7HcoMZEYwJvLQr8Z7xEPwoc9tGzrzHptsVo/+LPY4XVQkE1LpXiur3TKI9SrnXXQ25MTD1qvtOoEWWi5MxdU5KuF5ruK+g6+N0k0UddxuQtX+fAlF19LbnAtWMZAgMS2S2hgkyiO7AiYa7NkiT++y90ktRBvLgr9W2psYFb/UaenOUDroO94kXPex48CEr4dTRXkfHSX7Q3kg1RbyH6VcmNAWnr4nUP138jxBC9FI4WswKpR/28WzeHactKI6ggQlxraaTEXWsl8dQVUx++gzvmK5wmo/aG4/STCR1mi8tFJaw0vjF8UTtw+Ven5MKD1pMTunCUaeP6LyjlbPaVXrDV6Jq8nqeZqCuVqjaV/ayoIJu9QwlfNASZMVaLMQ4eLB5oFnwbxaY19pVyawt4yT5tmn/nXUiieoCldmipmOoczufdzuXQ5N95T4E0p8NZ33mE3mrqJl4apHS2pa5PEBRs8lto+jwn1IQqThFnPf7b01nSXQ/SGnSo5T28zhfQ2IqPFZr8sRZYg2/4ymq2R9Ud3wJXo87PpBN/J7538rp7572z3v2a71Ic4jQi3GfKeTULkvWVEY5s5vh94hEbUgw7b1fyGZNcnutiMc5eIDntJUUAOWZ/ypkpsC5mPUFtoUPKE9s6G6z7BNlkw7JgxRsaZWmGylWXeURtoC0gQH49Wfn+ujYzhUqWA1TsznVkzgAZxcGGEDHDnwCeHoS8Z//kXiMO48OYhwWw2kqkJchXf7tjQDAvmsRYf1IaSu5OIietQj7nUZoxTLLtBaMe+R+2EOLGTsmWEw0KViDVu4+KX7RInJpwOQPGRPfr3qdbxwA1jiJbLwGYQJzYBileBcmZjZlCHYfmnHK/CP0jxjuTBEgAA"
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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YTW/jOAz9K4Eve4kAf8iO3VsmbTMF2m4x6WAPiz3QtpwIcayMLM9Md9D/PpRtNXbiNEUR7GV7aRWKfKRo+pHyL2taKTGDUpWzbGld/LKuCohzNs1z60LJio0tvXnLC7bbTM3WDa7cMBpbD5ILydWTdeGgtLz6meRVytKdWOs/N1h3QiQrDVYvXL2qcYJwbM23jyvJypXIUeLYdg/5degaI5r0LOyTwcxW1cZEQB2bngjBWIk8Z4nqGDpdNfe0WyFTDrkBCBzaA6Ct2jUvV1dPrOw48vci9P1ehIFJMqzZYsUz9Ql4HacWlEawUJCsERXB2tQf4nZRoxb1ARRnRcI68QT7dkE/Y64xlfxfNgPVPHrjdd/a3cu311o/riDnsC6v4buQGqAnMMfxxn35F5aI7wz1HZ0k45P2PJiEfeLLOWzqk02LZc5kaVDdxtSb2PQg3B5U+IxYVz+VhPZV0ql+FIsfsL0pVMUVF8UceGESQPCZ31aS3bGyhCW6tqyxdV8HYd0LfOHGDcLTFiU6EwN4t6JU78Z7wIOw4QgtYh3ZbzzW+7t4Flt8HSTks0pKVqgznXIP9WxnHYz24MSD3mutpkAWSmz1C8qL5UKxbU19u9jbIprK84Tchatj+FrwbxXTuBa4GbX9eEKieOIQmlIgkCU2Sd3YBSeNgCWhhXi3vFR/ZtoHVvXfTXnqA5gAPdsNX4nxkkPKNqPP+pX6IeRGQ97jf8g/C7HWIIYe/mJQ/9ZyPMFL08ggL7FrNL/bTX04005aUZMB6kw07RjMhZKiWJ4B1fY6qLdsyYoU5NOuub0R4VJUqLx30kbDDaIXhYOwD1V6MQxoPUq+PeZp4rvei8oxXz2lV7y1erqup5licgbVcoWtf6M7CBbGUMHXwwEWTN2i9KLDxQPDgjfxo8Me+0q71I3dMI8psy/sW8UlS9GVqnQX05PDkdp7Wy2dro2PEnhXCbz3mXfYLc2ol6SJQ5jvJ4T6dkIil4X4x6epH/mub0fW8z+G3trpcojecFKlx+ltLpHeRnS0WD/FFc9TZNs/RvMVsv7oGpjkfX7Wk+AH+X2Q39kr/4Pt/tdsN2ExcxxnQgLIfEKT0COxzzwCzGM0iCFOo7DDdg2/Idn1iS6y30B0OEvyEgrI+5R3Bzju5jkc0N3RNN2kOB7zBCdlzI0OolGYbkRVdNQGxgHqR/tXKq9/nw2140pmgF071xNZe/FE4j9xdfTRcuBTw9AXjP/8y8PumvDuy4E21pKZTnKd3+51ob0k6GUj3qkNFXWnAJ0sojSiMcFFSGjAGAk9NyZhHHlh4GSBZ2d1ATa4bYhfNzHelEaXFX5HUngnGJHR28usW/4u9dMEYmJ7NCXUc7DZU0hIEnmOl0GQOolrPf8GALN6nbUSAAA="
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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/jNhD+K4YuvZiASL1zc7yJG8BJgziLHooeKImyCcuil6LSdRf57x1KYizZcrzZTXtpbsRw5puHht+Q+mZNKiWmtFTlNFtaF9+sq4LGOZvkuXWhZMXGlt6c84LtN1OzdQMrEkZj615yIbnaWRcYpOXV1ySvUpbuxVr/ucG6FSJZabB6QfSqxvHDsTXbPq4kK1ciBwm27R7y69A1RhT0LOyzwUxX1cZE4GLbPROCsRJ5zhLVMcRdNXLerZApp7kB8LHbA3BbtWterq52rOw48g4i9LxehL4pMl2zxYpn6pLyOk4tKI1goWiyBlQAa0t/jNtFjVrUe6o4KxLWicc/tPP7FSPGVPK/2ZSq5tMbr4fW5KDeTmv9uKI5p+vymj4JqQF6ApOOM+7LH1ginhjoY10k49PteTAFu+TLGd3UmU2KZc5kaVBJY+oEtnsUbg8qfAasq69K0vYo6VI/isVfdHtTqIorLooZ5YUpAIJvPq8ku2VlSZfg2rLG1l0dhHUn4MCNG4TdFiS6EgN4c1GqH8a7h0TYcIQWsk7sNx7r/X08iy0cB0nzaSUlK9Q7ZXmA+m65DkZ7lPGg91qraZCFElt9QHmxXCi2ralvH3vbRBP5PiF34eoYPhf8S8U0ruVnmJDIzpCd2DFyvcxGseOkyGdekqUsIKHjWIA356X6LdM+oKv/aNpTJ2ACxCSww9MxPrB0dEnzXIhCo90JuaH5r0Kstb1hht8ZXe8Hhd6FFHQCZmS0oiZLFweaWozxQklR1Cen1XoZNxnNSzD+XlTb6aDO2ZIVKZW7t8RVI3wSFSiblHoaxI9eFI7CPlbpxTCg9Sj59pSnwCPOi8opXz2lV7y1erp3J5lickqr5QrG+0ZPCWjQoaauLwDQFPUY0osO3zbM6EXHg/OVGaintaET00AP7EvFJUsBW1V6NOnrwGFXval5zjfDxzf/T795h7JwkPgwlDHyEw8j16UUxbbjosRJ/DSmtof92Hr+03BWe2Uc4CwHrp/uac6aSZqykTtarHdxxfMUKPSX0WwFVD66pkzyPunis7T2k7z0wXYfbPfBdv87tss8QmMnJci3kxC5WYhR5BOMgsyxWRCkFMdeh+0afgOy+1eJ7mSBblK47fIELr5QFe2+UZhsRFX01IDRvOjwSeT036Oh9lTJjMKAzjUvtg9HL/LOPP08sBz4VTD0B+In/xwMQb7pR8L+1v/Dd31trCVTXeS6vt3bf3vn18tGvFcbaudO66WEJDBqbYT9kELrRS6KcGAjgkmSuSwIYd7WrdfgtiF+3sTw8BnN2RMvRmhkmgteH7ykBez02uyWLWnBKkn7zxKbYBYzQpDjug5y0zBDMQ0DlGaJHyU48lM/s57/AcS5Lo2BEgAA"
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
            autohookPreset = "AH4_H4sIAAAAAAAACu1YS2/bOBD+K4Yue7EAPahXbq6buAHcbFC72MOiB4qkbMKy6FJUW2+R/96hJMaSLcdNm93L5mILw5lvHhp+Q+q7NamUmOJSldNsZV19t64LnOZskufWlZIVG1t6cc4LdlikZukWnrw4GVv3kgvJ1d66ckFaXn8jeUUZPYi1/kOD9V4IstZg9YOnn2qcMB5bs91yLVm5FjlIXMfpIT8NXWMkUc/CuRjMdF1tTQTIddCFEIyVyHNGVMfQ7ap5l90KSTnODUDooh4AatVueLm+3rOy4yg4ijAIehGGpsh4wxZrnqk3mNdxakFpBAuFyQZQAawt/SluFzVpUe+x4qwgrBNPeGwX9ivmGVPJ/2FTrJpXb7weW3tH9fZb6+Ua5xxvyhv8RUgN0BOYdPxxX/6BEfGFgb6ri2R8op4HU7A3fDXD2zqzSbHKmSwNqteY+pGDTsLtQcUPgHX9TUncbiVd6qVYfMW720JVXHFRzDAvTAFseOfzSrL3rCzxClxb1ti6q4Ow7gRsuHGDsN+BRFdiAG8uSvXLePeQCBuO0LKtM+uNx3r9EM9iB9tB4nxaSckK9UJZHqG+WK6D0Z5kPOi91moaZKHETm9QXqwWiu1q6jvE3jbRRL5MyF24OoaPBf9cMY1reYlHfBwnNkVuYiMPfmJCXDtxqUsCErDMZxbgzXmp/sy0D+jqv5v21AmYAH3Hi5+I8S3HlG1H7/SW+irkVkPewT/O3wmx0SCGHv5ieHOYFnoV8tBZmLnRippUkRtpfjHGCyVFUW+fVutx5mQ4L8H4Z1Edv4M6ZytWUCz3z4mrRngrKlA2KfU0vDB5VDgJ+1SlF8OA1lLy3TlPUeD5jyrnfPWUnvDW6ukGnmSKySmuVmuY8Vs9KqADhjq7PgVAZ9SzSD90SLehxyA5nZ5PDEI9sg2nmAb6wD5XXDIK2KrS80mfCY676lnNc7kZXt/5f/rOO7zlpNRxQjcDtkpcG6UeUBbJsJ3iIPXdMAl8EloPnwxxtefGIeKCMyg6T1wzCcQ1QqPFZp9WPKfAo3+MZmvg89ENZpL3mde9SGu/yUuvbPfKdq9s9/+YcN1TGnPgdkOxHVGKbBQz104ponZIEIqIE1K4mXTYruE3ILt/lejOFuiWwpGXEzj9QlW0+0ZhshVV0VMDRguS43uR37+UxtpTJTMMAzrXvNjeHoMkuHD/C8By4HvB0GeI3/x8MAT5rK8Jh6P/Lx/4tbGWTHWR6/p2rwDtwV8/NuKD2lA7d1vP9zyaZdQOUuTDoI1jO65/koTSNEoyF6d16zW4bYgftyncfkZLtt0x6CB7ZNoLLiG8xAWs9RtN8iyDm1TPtU/S1I9cZFMcMRuGn2fHCGc2pXESk4gEAXashx8CWrwshhIAAA=="
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
    if GetCharacterCondition(CharacterCondition.flying) then
        State = CharacterState.moveToNextNode
        LogInfo("[FATE] State Change: MoveToNextNode")
    elseif GetCharacterCondition(CharacterCondition.mounted) then
        yield("/gaction jump")
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
