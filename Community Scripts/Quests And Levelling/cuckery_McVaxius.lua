--hacky script to force ice cosmic to continue after a fail so we can level up to 100 without any shenanigans
--made for personal use but you can use it if you want
--set ice to stop at level 100

wheeee = 1

while wheeee == 1 do
	if tonumber(GetLevel(GetClassJobId())) > 99 then
		yield("/pcraft stop")
		yield("/echo we are done this job!")
	end
	if GetCharacterCondition(5) == false then
		yield("/ice start")
		yield("/echo starting ice cosmic again because we aren't crafting for some reason")
	end
	yield("/wait 30")
end