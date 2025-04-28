--[[
"move forwards a bit" after teleporting back to fc estate
until lim fixes this problem with AR teleporting home to weird situation ;o
loop wait for is char ready 

setup automaton -> enhanced login -> run while AR is active. 
/pcraft run moveforwardabit
or whatever you called it.

also TURN OF SIMPLE teleport in autoretainer. it is not needed and will cause problems with this script
--]]

function fartknocker()
	while IsPlayerAvailable() == false do
		yield("/echo waiting on player")
		yield("/wait 1")
	end
end

--don't run this on chars with blu level > 0. they might be actual play chars and it would be annoying to move randomly on login
yield("/echo BLU level -> "..tonumber(GetLevel(25)).." above 0 means we won't do anything")
yield("/echo Stopping am just in case bell interaction got borked from the last char due to bailout etc")
yield("/am stop")

isblu = tonumber(GetLevel(25))

--we can add cosmic,s9,buttcheeks,etc as they get added to the game
housing_zones = 
{
136, 	--mist
282, 	--mist private cottage
283, 	--mist private house
284, 	--mist private mansion
340, 	--lavender beds
342, 	--lavender beds private cottage
343, 	--lavender beds private house
344, 	--lavender beds private mansion
341, 	--goblet
345, 	--goblet private cottage
346, 	--goblet private house
347, 	--goblet private mansion
641, 	--shirogane
649, 	--shirogane private cottage
650, 	--shirogane private house
651, 	--shirogane private mansion
979, 	--empyreum
980, 	--empyreum private cottage
981, 	--empyreum private house
982 	--empyreum private mansion
}

badzoyn = 1 --this needs to be global

function bz()
	zoyn = GetZoneID()
	badzoyn = 1
	for i=1,#housing_zones do
		if housing_zones[i] == zoyn then
			--badzoyn = 0   --dont tp if we in a housing zone.
			badzoyn = 1230   --just disable this stuff for now
		end
	end
end

if isblu == 0 then
	if badzoyn == 0 then --we are already in a housing zone. let's enter the nearby entrance
		yield("/echo Jumping towards entrance a bit")
	
--		yield("/ays m d") --turn ar off for now
--		yield("/ays reset") --reset ar shenanigans for now
		yield("/target entrance")
		yield("/wait 0.5")
	end		
	bz()
	if badzoyn == 0 then --we are already in a housing zone. let's enter the nearby entrance

		yield("/hold Q")
		yield("/target entrance")
		yield("/interact")
		yield("/callback SelectYesno true 0")
		yield("/lockon on")
		yield("/automove on")
		yield("/release Q")
		yield("/hold E")
		yield("/wait 0.5")
	end		
	bz()
	if badzoyn == 0 then --we are already in a housing zone. let's enter the nearby entrance
		yield("/gaction jump")

		yield("/release E")
		yield("/hold W <wait.0.5>")
		yield("/gaction jump")
		yield("/release W")
		yield("/interact")
		yield("/callback SelectYesno true 0")
		yield("/hold Q")
		yield("/wait 0.5")
	end		
	bz()
	if badzoyn == 0 then --we are already in a housing zone. let's enter the nearby entrance

		yield("/release Q")
		yield("/target entrance")
		yield("/interact")
		yield("/lockon on")
		yield("/automove on")
		yield("/callback SelectYesno true 0")
		yield("/wait 0.5")
	end		
	bz()
	if badzoyn == 0 then --we are already in a housing zone. let's enter the nearby entrance
		yield("/callback SelectYesno true 0")
		yield("/gaction jump")
--		yield("/ays m e") --turn ar back on
	end


	if badzoyn == 1 then
		yield("/waitaddon NamePlate <maxwait.600><wait.5>")
		yield("/ays m d") --turn ar off for now
		yield("/ays reset") --reset ar shenanigans for now
		yield("/wait 1")
		yield("/waitaddon NamePlate <maxwait.600><wait.5>")

		--teleport home
		yield("/li fc")
		yield("/wait 15")
		fartknocker()
		yield("/waitaddon NamePlate <maxwait.600><wait.5>")
		yield("/wait 1")
		yield("/hold W <wait.0.5>")
		yield("/release W")

		yield("/ays m e") --turn ar back on
	end
	
	
	yield("/wait 1")
	yield("/callback SelectYesno true 0")
end