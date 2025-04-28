--[[
***********************************************************************************************************************************************
***this should be in the (Automaton) enhance duty/start end as /pcraft run start_gooning, obviously make the script in SND for this to work.***
***********************************************************************************************************************************************

in SND make a script called start_gooning
past this into it
click the lua button
set this to run when entering a duty in automaton enhanced duty start/end
type this or copy paste it into there:

/pcraft run always_gooning

this script is just a generic autoduty helper since it makes characters act like cucks sometimes . targeting stuff but not pathing over or helping with combat.

--]]

yield("/wait 1")

--loop wait for is char ready 
while IsPlayerAvailable() == false do
	yield("/echo waiting on player")
	yield("/wait 1")
end

yield("/ad stop")

yield("/wait 1")
yield("/hold W <wait.1.0>")
yield("/release W")

--yield("/echo ad start")
yield("/ad start")
yield("/vbm ai cfg on")
yield("/bmrai on")
--yield("/rotation auto")
--yield("/echo let's start gooning!")


--why is this so complicated? well because sometimes we get bad values and we need to sanitize that so snd does not STB (shit the bed)
function distance(x1, y1, z1, x2, y2, z2)
	if type(x1) ~= "number" then x1 = 0 end
	if type(y1) ~= "number" then y1 = 0 end
	if type(z1) ~= "number" then z1 = 0 end
	if type(x2) ~= "number" then x2 = 0 end
	if type(y2) ~= "number" then y2	= 0 end
	if type(z2) ~= "number" then z2 = 0 end
	zoobz = math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
	if type(zoobz) ~= "number" then
		zoobz = 0
	end
    --return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    return zoobz
end

im_a_cuck = 1

while im_a_cuck == 1 do
	yield("/wait 0.5")
	if GetCharacterCondition(34) == false then
		im_a_cuck = 0
	end
	if GetCharacterCondition(26) == true then
		if distance(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos(GetTargetName()),GetObjectRawYPos(GetTargetName()),GetObjectRawZPos(GetTargetName())) > 20 then
			yield("/vnav moveto "..GetObjectRawXPos(GetTargetName()).." "..GetObjectRawYPos(GetTargetName()).." "..GetObjectRawZPos(GetTargetName()))
			yield("/echo Attempting Autoduty Calibration --> "..GetTargetName())
		end
		if distance(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos(GetTargetName()),GetObjectRawYPos(GetTargetName()),GetObjectRawZPos(GetTargetName())) < 5 then
			yield("/vnav stop")
		end
	end
end