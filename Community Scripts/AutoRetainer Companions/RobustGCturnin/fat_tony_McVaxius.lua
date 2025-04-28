--[[
Fat Tony script

This is a pair script for the bagman script. basically it will load x chars go to location to wait for deliveries. when it receives a 1 gil trade, it knows its time to switch to next char.
Otherwise it won't do anything really different than bagman.
]]
--[[

requires plugins
Autoretainer
Lifestream
Teleporter
Pandora -> TURN OFF AUTO NUMERICS
automaton -> TURN OFF AUTO NUMERICS
Dropbox -> autoconfirm
Visland
Vnavmesh
Simpletweaks -> enable targeting fix
YesAlready -> /Enter .*/
]]
--TURN OFF RSR!
yield("/rotation Cancel")
--TURN OFF RSR!

tonys_turf = "Maduin" --what server will our tonies run to
tonys_spot = "Pavolis Meats" --where we tping to aka aetheryte name
tony_zoneID = 132 --this is the zone id for where the aetheryte is, if its anything other than 0, it will be evaluated to see if your already in teh zone for cases of multi transfer from or to same
tonys_house = 0 --0 fc 1 personal 2 apartment. don't judge. tony doesnt trust your bagman to come to the big house
tony_type = 0 --0 = specific aetheryte name, 1 first estate in list outside, 2 first estate in list inside

--if all of these are not 42069420, then we will try to go there at the very end of the process otherwise we will go directly to fat tony himself
tony_x = 42069420
tony_y = 42069420
tony_z = 42069420

--[[
tony firstname, lastname, meeting locationtype, returnhome 1 = yes 0 = no, 0 = fc entrance 1 = nearby bell 2 = limsa bell, 3 = fc entrance no move after
]]

local franchise_owners = {
{"Firstname Lastname@Server", 1, 2},  --return to limsa
{"Firstname Lastname@Server", 0, 0},  --dont return home because next line a diff bagman is giving me stuff !
{"Firstname Lastname@Server", 1, 0},  --return to fc entrance
{"Firstname Lastname@Server", 1, 0},  --return to fc entrance
{"Firstname Lastname@Server", 1, 0}  --return to fc entrance
}

loadfiyel = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions.lua"
functionsToLoad = loadfile(loadfiyel)
functionsToLoad()
DidWeLoadcorrectly()

--the boss wants that monthly gil payment, have your bagman ready with the gil. 
--If he has to come pick it up himself its gonna get messy

yield("/ays multi d")
fat_tony = "Firstname Lastname" --ignore this dont set it

local function distance(x1, y1, z1, x2, y2, z2)
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

local function approach_tony()
	local specific_tony = 0
	if tony_x ~= 42069420 and tony_y ~= 42069420 and tony_z ~= 42069420 then
		specific_tony = 1
	end
	if specific_tony == 0 then
		PathfindAndMoveTo(GetObjectRawXPos(fat_tony),GetObjectRawYPos(fat_tony),GetObjectRawZPos(fat_tony), false)
	end
	if specific_tony == 1 then
		PathfindAndMoveTo(tony_x,tony_y,tony_z, false)
	end
end

local function approach_entrance()
	PathfindAndMoveTo(GetObjectRawXPos("Entrance"),GetObjectRawYPos("Entrance"),GetObjectRawZPos("Entrance"), false)
end

geel = 0
local function shake_hands()
	gilxit = 0
	bababobo = 0
	while gilxit == 0 do
		bababobo = bababobo + 1
		yield("/wait 1")
		if bababobo > 15 then
			yield("/echo where is this bagman, im gonna teach them a lesson....")
			bababobo = 0
		end
		if GetGil() > geel then
			if (GetGil() - geel) == 1 then
				gilxit = 1 --we are done, get out next tony time
				yield("/echo allright time to deliver this to the boss")
			end
		end
		geel = GetGil()
	end
end

for i=1,#franchise_owners do
	--update tony's name
	fat_tony = franchise_owners[i][1]
	
	yield("/echo Loading tony to recieve protection payments Fat Tony -> "..fat_tony..".  Tony -> "..franchise_owners[i][1])
	yield("/echo Processing Tony "..i.."/"..#franchise_owners)

	--only switch chars if the bagman is changing. in some cases we are delivering to same tony or different tonies. we dont care about the numbers
	--if GetCharacterName(true) ~= franchise_owners[i][1] then
	while GetCharacterName(true) ~= franchise_owners[i][1] do
		yield("/ays relog " ..franchise_owners[i][1])
		yield("/wait 2")
		CharacterSafeWait()
	end	

    yield("/echo Processing Tony "..i.."/"..#franchise_owners)

	--allright time for a road trip. tony needs that bag
	road_trip = 1 --we took a road trip
	--now we must head to the place we are meeting this filthy animal 
	--first we have to find his neighbourhood, this uber driver better not complain
	--are we on the right server already?
	yield("/li "..tonys_turf)
	yield("/wait 2")
	yield("/callback SelectYesno true 0")
	yield("/wait 2")
	CharacterSafeWait()
	yield("/echo Processing Tony "..i.."/"..#franchise_owners)
	
	--now we have to walk or teleport?!!?!? to fat tony, where is he waiting this time?
	if tony_type == 0 then
		yield("/echo "..fat_tony.." is meeting us in the alleyways.. watch your back")
			while tony_zoneID ~= GetZoneID() do --we are teleporting to Tony's spot
				yield("/tp "..tonys_spot)
				yield("/wait 2")
				yield("/callback SelectYesno true 0")
				ZoneTransition()
			end
	end
	if tony_type > 0 then
		yield("/echo "..fat_tony.." is meeting us at the estate, we will approach with respect")
		yield("/estatelist "..fat_tony)
		yield("/wait 0.5")
		--very interesting discovery
		--1= personal, 0 = fc, 2 = apartment
		yield("/callback TeleportHousingFriend true "..tonys_house)
		ZoneTransition()
	end
	geel = GetGil() --get the initial geel value
	
	--ok this filthy animal is nearby. let's approach this guy, weapons sheathed, we are just doing business
	if tony_type == 0 then
		approach_tony()
		visland_stop_moving()
	end
	if tony_type == 1 then
		approach_entrance()
		yield("/wait 5")
		approach_entrance()
		visland_stop_moving()
		if tony_type == 2 then
			yield("/interact")
			yield("/callback SelectYesno true 0")
			yield("/wait 5")
		end
		approach_tony()
		visland_stop_moving()
	end
	shake_hands() -- its a business doing pleasure with you tony as always
	zungazunga() --close any trailing dialogs in case a trade was errantly opened.
	if road_trip == 1 then --we need to get home
		--time to go home.. maybe?
		if franchise_owners[i][2] == 0 then
			yield("/echo wait why can't i leave "..fat_tony.."?")
		end
		if franchise_owners[i][2] == 1 then
			yield("/li")
			yield("/echo See ya "..fat_tony..", a pleasure.")
			yield("/wait 5")
			CharacterSafeWait()
			--[[
			--added 5 second wait here because sometimes they get stuck.
			yield("/wait 5")
			yield("/tp Estate Hall")
			yield("/wait 1")
			--yield("/waitaddon Nowloading <maxwait.15>")
			yield("/wait 15")
			yield("/waitaddon NamePlate <maxwait.600>")
			yield("/wait 5")
			--]]
			--normal small house shenanigans
			if franchise_owners[i][3] == 0 then
				return_to_fc()			
				CharacterSafeWait()
				yield("/wait 5")
				return_fc_entrance()
			end
			if franchise_owners[i][3] == 3 then --return to fc without returning to entrance
				return_to_fc()			
				CharacterSafeWait()
			end
			--retainer bell nearby shenanigans
			if franchise_owners[i][3] == 1 then
				return_to_fc()			
				CharacterSafeWait()
				yield("/target \"Summoning Bell\"")
				yield("/wait 2")
				PathfindAndMoveTo(GetObjectRawXPos("Summoning Bell"), GetObjectRawYPos("Summoning Bell"), GetObjectRawZPos("Summoning Bell"), false)
				visland_stop_moving() --added so we don't accidentally end before we get to the bell
			end
			--limsa bell
			if franchise_owners[i][3] == 2 then
				return_to_limsa_bell()
			end
		end
	end
end

--what you thought your job was done you ugly mug? get back to work you gotta pay up that gil again next month!
--boss please i just collected the stuff be nice
yield("/ays multi e")
