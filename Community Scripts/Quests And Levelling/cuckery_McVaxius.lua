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

yield("/ice start")


wheeee = 1
fishcounter = 0

--func stolen from https://gist.github.com/SubaruYashiro/5195c26d3e2668d31ce92def404a2ae1
function submitReport()
  if not IsAddonVisible("WKSMissionInfomation") then
    yield("/callback WKSHud true 11")
    yield("/wait 0.2")
  end

  if IsAddonVisible("WKSRecipeNotebook") then
    yield("/callback WKSMissionInfomation true 14 1")
  end
  
  while IsPlayerOccupied() do
    yield("/wait 0.5")
  end

  --yield("/gs change " ..class)
  yield("/wait 1")
  yield("/callback WKSMissionInfomation true 11 1")
end

while wheeee == 1 do
	--yield("/echo This job -> "..tonumber(GetClassJobId()).." - is at Level ->"..tonumber(GetLevel(GetClassJobId())))
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
	if GetClassJobId() == 18 and GetCharacterCondition(6) == false then --start fishing we we fishers and not fishing
		fishcounter = fishcounter + 1
		yield("/ac cast")
		yield("/wait 1")
		if fishcounter > 3 then
			fishcounter = 0
			submitReport()
			--try to hit report and finish mission
		end
	end
	if tonumber(GetLevel(GetClassJobId())) > 100 then --reduce to 99 if you are actually leveling jobs.
		yield("/ice stop")
		yield("/echo we are done this job! -> "..tonumber(GetClassJobId()).." - Level ->"..tonumber(GetLevel(GetClassJobId())))
		yield("/pcraft stop")
	end
	if GetCharacterCondition(5) == false and GetClassJobId() ~= 18 then --only useful for non fishers as they will get stuck occasionally
		yield("/ice start")
		yield("/echo starting ice cosmic again because we aren't crafting for some reason")
	end
	yield("/wait 1")
	if GetClassJobId() ~= 18 then -- if we not a fisher then wait full 30 seconds
		yield("/wait 29")
	end
end