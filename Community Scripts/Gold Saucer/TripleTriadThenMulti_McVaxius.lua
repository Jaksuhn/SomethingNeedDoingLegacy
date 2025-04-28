--[[
  Description: Run to the fortemps guy
  requires vnavmesh and saucy
]]

function visland_stop_moving()
 yield("/equipguud")
 yield("/wait 3")
 muuv = 1
 muuvX = GetPlayerRawXPos()
 muuvY = GetPlayerRawYPos()
 muuvZ = GetPlayerRawZPos()
 while muuv == 1 do
	yield("/wait 1")
	if muuvX == GetPlayerRawXPos() and muuvY == GetPlayerRawYPos() and muuvZ == GetPlayerRawZPos() then
		muuv = 0
	end
	muuvX = GetPlayerRawXPos()
	muuvY = GetPlayerRawYPos()
	muuvZ = GetPlayerRawZPos()
 end
 yield("/echo movement stopped - time for GC turn ins or whatever")
 yield("/visland stop")
 yield("/wait 3")
end

function open_aetheryte()
 yield("/waitaddon NamePlate <wait.1>")
 yield("/wait 10")
 yield("/target Aetheryte <wait.1>")
 yield("/lockon")
 yield("/automove")
 yield("/send E")
 yield("/wait 0.5")
 yield("/send E")
 yield("/wait 0.5")
 yield("/send E")
 yield("/wait 0.5")
 yield("/send E")
 yield("/wait 0.5")
 yield("/send E")
 yield("/wait 0.5")
 yield("/interact")
 yield("/wait 1")
 yield("/callback SelectString true 0")
end

--teleport to Ishgard when name plate is ready
yield("/tp Foundation <wait.8>")

--fire up saucy
yield("/saucy")
--don't forget to manually set how many matches you want and enable it!
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")
yield("/echo Set the number of matches and Enable TT after!!!")

--callback teleport to the last vigil
open_aetheryte()
yield("/callback TelepotTown false 11 8u")
yield("/callback TelepotTown false 11 8u")

yield("/visland execonce tthouse")
visland_stop_moving()

--target manor entrance guy
 yield("/target House Fortemps Guard <wait.1>")
 yield("/lockon")
 yield("/automove")
--proceed when not moving
 visland_stop_moving()
 yield("/interact")
 yield("/wait 5")

--target the manservant
--House Fortemps Manservant
 yield("/target House Fortemps Manservant <wait.1>")
 yield("/lockon")
 yield("/automove")
--proceed when not moving
 visland_stop_moving()
 yield("/interact")
 yield("/wait 5")

--wait a few seconds then start checking status of player condition until its no longer playing TT
yield("/wait 5")

--its condition 13 = playing minigame that we care about
--?? check cond 13 when not cond 13 then we can move on after a short wait
--??
while GetCharacterCondition(13)==true do
	yield("/wait 1")
end

--teleport home
yield("/tp Estate Hall")
yield("/wait 15")
yield("/waitaddon NamePlate <maxwait.600><wait.5>")
--visland to entrance of own estate. make a 0.5 radius tight visland for this....
yield("/visland execonce gigahouse")

--proceed when not moving
visland_stop_moving()

yield("/wait 5")
yield("/ays multi")
yield("/pcraft stop")