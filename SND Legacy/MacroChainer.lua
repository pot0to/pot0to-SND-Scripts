--[[

********************************************************************************
*                                Macro Chainer                                 *
*                                Version 0.0.1                                 *
********************************************************************************

Used to chain together a bunch of SND macros, one after the other. I mostly use
it to chain together all my desired dailies, but you can use it for whatever.
]]

MacrosToRun =
{
    "Mini Cactpot",
    "Allied Societies Quests",
    "Map Gatherer"
}

yield("/wait 5")
for _, macro in ipairs(MacrosToRun) do
    yield("/snd run "..macro)
    repeat
        yield("/wait 1")
    until not IsMacroRunningOrQueued(macro)
end