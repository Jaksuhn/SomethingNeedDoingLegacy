--hacky script to force ice cosmic to continue after a fail

wheeee = 1

while wheeee == 1 do
	if GetCharacterCondition(5) == false then
		yield("/ice start")
		yield("/echo starting ice cosmic again because we aren't crafting for some reason")
	end
	yield("/wait 30")
end