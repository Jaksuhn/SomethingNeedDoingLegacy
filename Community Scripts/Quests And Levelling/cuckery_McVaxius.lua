--[[
hacky script to force ice cosmic to continue after a fail so we can level up to 100 without any shenanigans
made for personal use but you can use it if you want
set ice to stop at level 100

Some notes to self (YES ITS MISPELLED BUT THIS IS WHAT IT IS)
WKSMissionInfomation
node 24
Appears with this kind of text:
 10:22/15:00


local fartime = GetNodeText("WKSMissionInfomation", 24)
local timetofart = fartime:match("(%d%d:%d%d)")

yield("/echo timestamp -> "..timetofart)
yield("/echo timestamp -> "..GetNodeText("WKSMissionInfomation", 24))
--]]


wheeee = 1

while wheeee == 1 do
	yield("/echo This job -> "..tonumber(GetClassJobId()).." - is at Level ->"..tonumber(GetLevel(GetClassJobId())))
	if GetItemCount(45690) > 29999 then --45690  is cosmo credits
		yield("/ice stop")
		yield("/echo we have 30k cosmo credits. go spend it")
		yield("/pcraft stop")
	end
	if GetItemCount(45691) > 9999 then --45691  is lunar credits
		yield("/ice stop")
		yield("/echo we have 10k lunar credits. go gamble it")
		yield("/pcraft stop")
	end
	if tonumber(GetLevel(GetClassJobId())) > 100 then --reduce to 99 if you are actually leveling jobs.
		yield("/ice stop")
		yield("/echo we are done this job! -> "..tonumber(GetClassJobId()).." - Level ->"..tonumber(GetLevel(GetClassJobId())))
		yield("/pcraft stop")
	end
	if GetCharacterCondition(5) == false then
		yield("/ice start")
		yield("/echo starting ice cosmic again because we aren't crafting for some reason")
	end
	yield("/wait 30")
end