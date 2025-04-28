--[[
  Description: this is so if your doing it with multiple chars you can setup the sync. start the mooching scripts before the farming script
  Author: McVaxius
  Link: https://discord.com/channels/1162031769403543643/1162799234874093661/1169362690502840350
]]

--how many 50 pt per 4 minute failures do you want
--you  need 96 to get all 4800 pt for non furniture non dye stuff
--mgf_sucks = 96
mgf_sucks = 10

--counter for mgf fails do the math yourself
mgf_counter = 0
--how many runs left
mgf_left = mgf_sucks - mgf_counter

--state change checking so we can actually count the number of times we failed
in_saucer = 1

while (mgf_counter < mgf_sucks) do
--    yield("/send KEY_3")
--    yield("<wait.0.35>")
--    yield("/interact <wait.1>")
    yield("/callback FGSEnterDialog true 0")
    yield("/callback FGSEnterDialog true -2")
    yield("/wait 1.0")
    yield("/callback ContentsFinderConfirm true 8")
    yield("/callback ContentsFinderConfirm true -2")
    yield("/callback FGSSpectatorMenu true 3")
    yield("/callback FGSExitDialog true 0")
    --1197 gold saucer blunderville reg area
    --1165 fail guys area
    if  (GetZoneID()==1165 and in_saucer == 1) then
        in_saucer = 0
    end
    if  (IsInZone(1165)==false and in_saucer == 0) then
        in_saucer = 1
        mgf_counter = mgf_counter + 1
        mgf_left = mgf_sucks - mgf_counter
        yield("/echo Runs left:"..mgf_left)
    end
end

    yield("/wait 10.0")
    yield("/echo we finished mooching")
    yield("/shutdown")
    --make sure pyes is setup do a fake shut down to get the auto text for it