--[[
Changelog
v2.1
social distancing tested properly
emotes tested properly
added wiggle to social distancing
improved the defaults on everything a little bit more
included some autorot presets - i didn't make one for FATE . i think the FRENRIDER one is sufficient for that purpose
re-orged folders
IDEAS: Some configs specifically for THUNT (Treasure Hunt Maps) and maybe FORAY ?!?!?

v2.0
added DD and FATE sections and logic related to them
added social distancing in forays and outdoor areas
cleaned up potential crash bugs and added lots of additional cleanups
added idle shitter emotes

v1.0
it works™

--script to kind of autofollow specific person in party when not in a duty by riding their vehicule
--meant to use when your ahh botting treasure maps or fates with alts, but playing main char manually :~D


*repos sorted by length of string.
https://plugins.carvel.li
https://love.puni.sh/ment.json
https://puni.sh/api/repository/veyn
https://puni.sh/api/repository/croizat
https://puni.sh/api/repository/taurenkey
https://raw.githubusercontent.com/SubZero0/Dalamud.SkipCutscene/dist/repo.json
https://raw.githubusercontent.com/FFXIV-CombatReborn/CombatRebornRepo/main/pluginmaster.json

*recommendation:
delete all the comments before the vars once you get it working properly

*requirements:
croizats SND - disable SND targeting in config
simpletweaks with targeting fix enabled
vnavmesh
visland
_functions.lua into your SND folder in %AppData%\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions
you can find it here https://raw.githubusercontent.com/Jaksuhn/SomethingNeedDoing/master/Community%20Scripts/AutoRetainer%20Companions/RobustGCturnin/_functions.lua

*optional:
bring some gysahl greens
bring some food and configure it properly
discardhelper
cutscene skipper (MSQ roullette cutscenes)
lazyloot plugin (if your doing anything other than fates)
VBM/BMR (bmr has slash commands for following and more modules)
RSR

***Few annoying problems that still exist and some thoughts
*how do we change instances #s maybe custom chat commands? lifestream /li # works. now to add nodetext scanning for group. also have to use target and lockon until lim fixes /li x without los
	this is insanely buggy and perhaps crashy.. nodetext scanning too fast will break things

*lazyloot is a toggle not on or off so you have to turn it on yourself

*we can't get synced level (yet) I managed to isolate the part with nodetext but its using weird special characters i dont know how to convert to real numbers
text = GetNodeText("_Exp", 3)
number = string.match(text, "%u%u%u%s*(.-)%s*EXP")
yield("/echo "..number)

reason is i wanted to smartly auto equip xp gear based on your current synced level.... :(

I will do it a bit later once i uhh. make a lookup table for this trash here:
0123456789

]]

--*****************************************************************
--************************* START INIZER **************************
--*****************************************************************
-- Purpose: to have default .ini values and version control on configs
-- Personal ini file
-- if you want to use my ini file serializer just copy form start of inizer to end of inizer and look at how i implemented settings and go nuts :~D
tempchar = GetCharacterName()
tempchar = tempchar:gsub("%s", "")  -- Remove all spaces
tempchar = tempchar:gsub("'", "")   -- Remove all apostrophes
filename_prefix = "frenrider_" -- Script name
filename = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"..filename_prefix..tempchar..".ini"
open_on_next_load = 0          -- Set this to 1 if you want the next time the script loads, to open the explorer folder with all of the .ini files

-- Ensure the version is always written to the file
-- VERSION VAR --
-- VERSION VAR --
-- VERSION VAR --
-- VERSION VAR --
vershun = 1                    -- Version number used to decide if you want to delete/remake the ini files on next load. useful if your changing party leaders for groups of chars or new version of script with fundamental changes
loadfiyel = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions.lua"
functionsToLoad = loadfile(loadfiyel)
functionsToLoad()
ini_check("version", vershun)
-- VERSION VAR --
-- VERSION VAR --
-- VERSION VAR --
-- VERSION VAR --

--*****************************************************************
--************************** END INIZER ***************************
	--*****************************************************************

---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------CONFIGURATION SECTION---------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
----------------------------
---FREN / PARTY / CHOCOBO---
----------------------------
fren = ini_check("fren", "Fren Name")  						-- can be partial as long as its unique
fly_you_fools = ini_check("fly_you_fools", false)			-- (fly and follow instead of mount and wait) usecase: you dont have multi seater of sufficient size, or you want to have multiple multiseaters with diff peopel riding diff ones.  sometimes frendalf doesnt want you to ride him and will ask you to ride yourself right up into outer space
fool_flier = ini_check("fool_flier", "Beast with 3 backs")	-- if you have fly you fools as true, which beast shall you summon? the precise name with correct capitalization such as "Company Chocobo" "Behemoth" etc
fulftype = ini_check("fulftype", "unchanged")				-- If you have lazyloot installed AND enabled (has to be done manually as it only has a toggle atm) can setup how loot is handled. Leave on "unchanged" if you don't want it to set your loot settings. Other settings include need, greed, pass
force_gyasahl = ini_check("force_gyasahl", false) 	   		-- force gysahl green usage . maybe cause problems in towns with follow
companionstrat = ini_check("companionstrat", "Free Stance") -- chocobo strat to use . Valid options are: "Follow", "Free Stance", "Defender Stance", "Healer Stance", "Attacker Stance"
timefriction = ini_check("timefriction", 1)					-- how long to wait between "tics" of the main loop? 1 second default. smaller values will have potential crashy / fps impacts.
idle_shitter =  ini_check("idle_shitter", "/tomescroll")	-- what shall we do if we are idle, valid options are "list" "nothing" or any slash command, if you choose nothing, then after x tics of being idle it will do nothing, otherwise it will pick from a list randomly or run the specific emote you chose.  if your weird and evil you can throw in a snd script here too with /pcraft run asdfasdf
idle_shitter_tic =  ini_check("idle_shitter_tic", 10)		-- how many tics till idle shitter?
----------------------------
---CLING / DIST---
----------------------------
cling = ini_check("cling", 2.6) 							-- Distance to trigger a cling to fren when > bistance
clingtype = ini_check("clingtype", 0)						-- Clingtype, 0 = navmesh [Default], 1 = visland, 2 = bossmod follow leader, 3 = CBT autofollow, 4 = vanilla game follow
clingtypeduty = ini_check("clingtypeduty", 2)				-- do we need a diff clingtype in duties? use same numbering as above 
socialdistancing = ini_check("socialdistancing", 5)			-- if this value is > 0 then it won't get any closer than this even if cling is lower.  The reason is to keep them from looking too much like bots.  it will consider this value only in outdoor areas, and foray areas.
socialdistancing_indoors = ini_check("socialdistancing_indoors", 0)	-- if this value is 1 then it will social distance indoors too! i set it to 1 as default. you can change it to 0 for defaults or if you need tigther following in dungeons/duties. its generally ok in dungeons except when it isn't haha. i changed the default to 0 because i got stuck in cuckerhell
socialdistance_x_wiggle = ini_check("socialdistance_x_wiggle", 1) -- wiggle +/- this many yalms on the x axis during social distancing
socialdistance_z_wiggle = ini_check("socialdistance_z_wiggle", 1) -- wiggle +/- this many yalms on the z axis during social distancing
maxbistance = ini_check("maxbistance", 50) 					-- Max distance from fren that we will actually chase them, so that we dont get zone hopping situations ;p
ddistance = ini_check("ddistance", 100) 					-- DEEP DUNGEON RELATED - if your in a deep dungeon should we even follow? add this to "cling" if we are in a DD, 100 is default
follow_in_combat = ini_check("follow_in_combat", 42)		-- 0 = dont follow the leader while in combat, 1 = follow the leader while in combat, 42 = let a table decide based on job/role
fdistance = ini_check("fdistance", 0) 						-- F.A.T.E. related - if your in a fate, add some more padding to "cling" default is 20 for now until some testing is done
formation = ini_check("formation", false)					-- Follow in formation? If false, then it will "cling", valid values are true or false - see note at bottom to see how formations work (cardinal and intercardinals)
hcling_reset = ini_check("hcling_reset", 10) 				-- how many "tics" before hcling is 0 and the user is basically forced to navmesh over to fren - this also handles some special logic such as DD/FATE force cling
----------------------------
---COMBAT / AI---
----------------------------
autorotationtype = ini_check("autorotationtype", "FRENRIDER")	-- If we are using BossMod rotation, what preset name shall we use? use "none" to manually configure it yourself.  keep in mind you have to make the rotation and name it in the first place.  "xan" is what i call mine
autorotationtypeDD = ini_check("autorotationtypeDD", "DD")		-- If we are using BossMod rotation, what preset name shall we use for DD
autorotationtypeFATE = ini_check("autorotationtypeFATE", "FATE")-- If we are using BossMod rotation, what preset name shall we use for FATE
rotationtype = ini_check("rotationtype", "Auto")				-- What RSR type shall we use?  Auto or Manual are common ones to pick. if you choose "none" it won't change existing setting.
bossmodAI = ini_check("bossmodAI", "on")						-- do we want bossmodAI to be "on" or "off"
positional_in_combat = ini_check("positional_in_combat", 42)	-- 0 = front, 1 = back, 2 = any, use 42 if you want a table to decide.
maxAIdistance = ini_check("maxAIdistance", 424242) 				-- distance to targets in combat w BMR, if you dont want to pick, use 424242, otherwise melee 2.6 and caster 10
limitpct = ini_check("limitpct", -1)							-- What percentage of life on target should we use LB at. It will automatically use LB3 if that's the cap or it will use LB2 if that's the cap, -1 disables it
rotationplogon = ini_check("rotationplogon", "RSR")				-- Which plogon for rotations? valid options are BMR, VBM, RSR --does wrath have slash commands now? can we add it?
----------------------------
---EXP / FOOD / REPAIR
----------------------------
xpitem = ini_check("xpitem", 0)								-- xp item - attemp to equip whenever possible azyma_earring = 41081 btw, if this value is 0 it won't do anything
repair = ini_check("repair", 0)								-- 0 = no, 1 = self repair always, 2 = repair if we are in an inn using the inn npc, dont use option 2 unless you are leaving your char in the inn perpetually
tornclothes = ini_check("tornclothes", 0)					-- if we are repairing what pct to repair at
feedme = ini_check("feedme", 4650)							-- eatfood, in this case itemID 4650 which is "Boiled Egg", use simpletweaks to show item IDs it won't try to eat if you have 0 of said food item
feedmeitem = ini_check("feedmeitem", "Boiled Egg")			-- eatfood, in this case the item name. for now this is how we'll do it. it isn't pretty but it will work.. for now..
----------------------------
----------------------------
----------------------------
--formations note
						--[[
						Like this -> . so that 1 is the main tank and the party will always kind of make this formation during combat
						8	1	5
						3		2
						7	4	6
						]]


--feedmeitem = ini_check("feedmeitem", "Baked Eggplant<hq>")-- eatfood, in this case the item name add a <hq> at the end if you want it to be hq. for now this is how we'll do it. it isn't pretty but it will work.. for now..
--[[
this next setting is a dud for now until i figure out how to do it
seems like we will need to use puppetmaster.... 
repo
https://github.com/Aspher0/PuppetMaster_Fork
pluginmaster
https://raw.githubusercontent.com/Aspher0/PuppetMaster_Fork/main/PuppetMaster.json

you can go to "Default settings"

Default Trigger (use regex)  (in this case "weeehehe")
(?i)\b(?:weeehehe)\s+(?:\((.*?)\)|(\w+))
Replacement
/li $1$2

--]]
--binstance = ini_check("binstance", "let us travel to instance")
				--[[ group instance change prefix, it will take " x" where x is the instance number as an argument, so you can setup qolbar keys with lines like this presumable
after changing instances, followers will /cl their chat windows
exmample qolbar for telling group to go instance 2
/mount
/p let us travel to isntance 2
/li 2
]]
-- mker = "cross" -- In case you want the other shapes. Valid shapes are triangle square circle attack1-8 bind1-3 ignore1-2

---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
-----------CONFIGURATION END-----------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
---------------------------------------
if open_on_next_load == 1 then
	local folderPath = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
	os.execute('explorer "' .. folderPath .. '"')
end
----------------
--INIT SECTION--
----------------
yield("/echo Starting fren rider")
--yield("/target \""..fren.."\"")
yield("/wait 0.5")
--yield("/xldisableplugin AutoDuty")  --this will cause grief if it is enabled sometimes

yield("/vbmai "..bossmodAI)
yield("/bmrai "..bossmodAI)
yield("/bmrai maxdistancetarget "..maxAIdistance)

--xBM Handling
if rotationplogon == "VBM" then
	if HasPlugin("BossModReborn") then
		yield("/xldisableplugin BossModReborn")
		repeat
			yield("/wait 1")
		until not HasPlugin("BossModReborn")
		yield("/xlenableplugin BossMod")
		repeat	
			yield("/wait 1")
		until HasPlugin("BossMod")
		yield("/vbmai "..bossmodAI)
		yield("/vbm ar set "..autorotationtype)
		yield("/echo WE SWITCHED TO VBM FROM BMR - please review DTR bar etc.")
	end
end

if rotationplogon == "BMR" then
	if HasPlugin("BossMod") then
		yield("/xldisableplugin BossMod")
		repeat
			yield("/wait 1")
		until not HasPlugin("BossMod")
		yield("/xlenableplugin BossModReborn")
		repeat
			yield("/wait 1")
		until HasPlugin("BossModReborn")
		yield("/bmrai "..bossmodAI)
		yield("/bmr ar set "..autorotationtype)
		yield("/echo WE SWITCHED TO BMR FROM VBM - please review DTR bar etc.")
	end
end

--rotation handling
function rhandling()
	if rotationplogon == "BMR" or rotationplogon == "VBM" then
		yield("/rotation cancel")  --turn off RSR
		if autorotationtype ~= "none" then
			yield("/vbm ar set "..autorotationtype)
			yield("/bmr ar set "..autorotationtype)
		end
	end
	if rotationplogon == "RSR" then
		yield("/bmr ar toggle") --turn off Boss Mod
		if rotationtype ~= "none" then
			yield("/rotation "..rotationtype)
		end
	end
end
rhandling()

if fulftype ~= "unchanged" then
--turns out its just a toggle we can't turn it on or off purposefully
--	yield("/wait 0.5")
--	yield("/fulf on")
--	yield("/echo turning FULF ON!")
	yield("/echo Configuring FULF!")
	yield("/wait 1")
	yield("/fulf "..fulftype)
end

if follow_in_combat == 1 then
	yield("/bmrai followcombat on")
end
if follow_in_combat == 0 then
	yield("/bmrai followcombat on")
end
----------------
----INIT END----
----------------

----------------
----MISC VAR----
----------------
are_we_DD = 0 --no we aren't in a deep dungeon
hcling = cling --harmonized cling for situations where we want to modify the cling value temporarily such as deep dungeon or fates
hcling_counter = 0 --counter for hcling_reset
weirdvar = 1
shartycardinality = 2 -- leader
partycardinality = 2 -- me
fartycardinality = 2 --leader ui cardinality
autotosscount = 0 --i forget its something . i think discard counter
did_we_toggle = 0 --so we aren't setting this setting multiple times. breaking its ability to function or causing ourselves a crash maybe
are_we_social_distancing = 0 --var controlled by a function to see if we need to socially distance on a vnavmesh follow.
idle_shitter_counter = 0 --counter for the idle shitters

pandora_interact_toggler_count = 0 -- for checking on pandora interact settings.
pandora_interact_toggler_count = 0 -- for checking on pandora interact settings.

--idle shitter list --i don't really care about this list if someone wants to improve it lmk . maybe we could have diff lists and make them an option too? --*
idle_shitter_list = {
"/vpose",
"/laugh",
"/cry",
"/dance",
"/tomescroll", --requires companion app to be setup and linked to acc. reee
"/study",
"/panic",
"/wave",
"/goodbye",
"/yawn",
"/blowkiss",
"/bread",
"/examineself",
"/mandervilledance",
"/bdance",
"/tdance",
"/stepdance",
"/mmambo",
"/lookout",
"/pushups",
"/winded",
"/groundsit",
"/lean",
"/photograph"
}

--zones of interact --rule - only put zones that require everyone in party to interact. if its party leader only. dont do it.
zoi = {
1044,--praetorium
1043,--meridianum
171,--dzemael
1037,--totorak
1041,--brayflox
1063,--keeper of the lake
1040,--hawk tua manner
1036,--cuckstasha
434,--busk bigil
1063,--snowcuck
1113,--xelphatol --problem. fix later  dont wanna interact with lifts
1245--halatali
}

duties_with_distancing = {
{886,"Firmament"},
{939,"Diadem"},

{732,"Anemos"},
{763,"Pagos"},
{795,"Pyros"},
{827,"Hydatos"},

{759,"Doman Enclave"},
{915,"Gangos"},
{920,"Hydatos"},
{975,"Zadnor"},

{123123,"Cosmo1"},
{123123,"Cosmo2"},
{123123,"Cosmo3"},
{123123,"Cosmo4"},

{123123,"Shits Triangle1"},
{123123,"Shits Triangle2"}
}

job_configs = {
--jobID,dist,followincombat 0 or 1,positional,name
{19,2.6,1,0,"Paladin"},
{21,2.6,1,0,"Warrior"},
{32,2.6,1,0,"Dark Knight"},
{37,2.6,1,0,"Gunbreaker"},

{20,2.6,1,1,"Monk"},
{22,2.6,1,1,"Dragoon"},
{30,2.6,1,1,"Ninja"},
{34,2.6,1.1,"Samurai"},
{39,2.6,1,1,"Reaper"},
{31,2.6,1,1,"Viper"},

{38,10,1,2,"Dancer"},
{23,10,1,2,"Bard"},
{31,10,1,2,"Machinist"},

{25,10,1,2,"Black Mage"},
{27,10,1,2,"Summoner"},
{35,2.6,1,2,"Red Mage"},
{42,10,1,2,"Pictomancer"},
{36,10,1,2,"Blue Mage"},

{24,10,1,2,"White Mage"},
{28,10,1,2,"Scholar"},
{33,10,1,2,"Astrologian"},
{40,10,1,2,"Sage"}
}
----------------
----MISC END----
----------------

--The Distance Function. the meat and potatos of this script
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

function can_i_lb()
    local dpsJobs = {
        [2]  = true, [4]  = true, [5]  = true, [7]  = true, [20] = true, [22] = true, [24] = true,
        [25] = true, [26] = true, [27] = true, [29] = true, [30] = true, [31] = true,
        [34] = true, [35] = true, [38] = true, [39] = true, [41] = true
    }
    local joeb = GetClassJobId()
    return dpsJobs[joeb] or false
end
-------------
--JOB INIT---
-------------
goatEnjoyer = GetClassJobId() --call this again if we gonna call one of the curated funcs

function returnJobbu()
	for i=1,#job_configs do
		if goatEnjoyer == job_configs[i][1] then
			return i
		end
	end
end

function returnCuratedDist()
	return job_configs[returnJobbu()][2]
end

function returnCuratedFollow()
	return job_configs[returnJobbu()][3]
end

function returnCuratedPosition()
	whichP = job_configs[returnJobbu()][4]
	if positional_in_combat < 42 then whichP = positional_in_combat end
	beturn = "any"
	if whichP == 0 then beturn =  "front" end
	if whichP == 1 then beturn =  "rear" end
	if whichP == 2 then beturn =  "any" end
	return beturn
end

yield("/bmrai positional "..returnCuratedPosition())
yield("/echo Turning Positional "..returnCuratedPosition().." on")

function returnCuratedJob() --not used yet.
	return job_configs[returnJobbu()][5]
end

if follow_in_combat == 42 then
	if returnCuratedFollow() == 0 then
		yield("/bmrai followcombat off")
		yield("/echo Turning Follow in combat Off")
	end
	if returnCuratedFollow() == 1 then
		yield("/bmrai followcombat on")
		yield("/echo Turning Follow in combat On")
	end
end

if maxAIdistance == 424242 then
	maxAIdistance = returnCuratedDist()
	yield("/echo Setting Base (non DD/F.A.T.E.) Cling to during combat -> "..maxAIdistance)
end
-------------
--JOB END---
-------------

-- Function to calculate tether point on the buffer circle (social distancing)
function calculateBufferXY(meX, meZ, theyX, theyZ)
    local dx, dz = meX - theyX, meZ - theyZ
    local dist = math.sqrt(dx * dx + dz * dz)

    if dist == 0 then
        -- Avoid division by zero; just return original position
        return meX, meZ
    end

    -- Normalize the direction vector and scale by socialdistancing radius
    local scale = socialdistancing / dist
    local calcedX = theyX + dx * scale
    local calcedZ = theyZ + dz * scale
	
	--yield("/echo getRandomNumber -> "..getRandomNumber(0,socialdistance_x_wiggle))
	--yield("/echo socialdistance_x_wiggle: " .. tostring(socialdistance_x_wiggle))
	--yield("/echo socialdistance_z_wiggle: " .. tostring(socialdistance_z_wiggle))

	if socialdistance_x_wiggle > 0 then
		calcedX = calcedX + getRandomNumber(-1 * socialdistance_x_wiggle,socialdistance_x_wiggle)
	end
	if socialdistance_z_wiggle > 0 then
		calcedZ = calcedZ + getRandomNumber(-1 * socialdistance_z_wiggle,socialdistance_z_wiggle)
	end

    return calcedX, calcedZ
end


-- Function to calculate the offset based on follower index and leader's facing direction
function calculateOffset(followerIndex, leaderRotation)
    -- Calculate offsetX and offsetY based on follower index and leader's facing direction
    -- Example: Adjust offsetX and offsetY based on formation layout and leader's facing direction
    local offsetX, offsetY = 0, 0
    -- Adjust offsetX and offsetY based on formation layout and leader's facing direction
    if followerIndex == 1 then
        -- Example: Adjust offsetX and offsetY for follower 1
        offsetX, offsetY = -1 * hcling * 2, hcling * 2
    elseif followerIndex == 2 then
        -- Example: Adjust offsetX and offsetY for follower 2
        offsetX, offsetY = 0, hcling * 2
    elseif followerIndex == 3 then
        -- Example: Adjust offsetX and offsetY for follower 3
        offsetX, offsetY = hcling * 2, hcling * 2
    elseif followerIndex == 4 then
        -- Example: Adjust offsetX and offsetY for follower 4
        offsetX, offsetY = -1 * hcling * 2, 0
    -- Handle other follower indexes similarly
    end
    
    -- Rotate the offset based on the leader's facing direction
    local rotatedOffsetX = offsetX * math.cos(leaderRotation) - offsetY * math.sin(leaderRotation)
    local rotatedOffsetY = offsetX * math.sin(leaderRotation) + offsetY * math.cos(leaderRotation)
    
    return rotatedOffsetX, rotatedOffsetY
end

function moveToFormationPosition(followerIndex, leaderX, leaderY, leaderZ, leaderRotation)
    -- Calculate the formation position based on follower index and leader's facing direction
    local offsetX, offsetY = calculateOffset(followerIndex, leaderRotation)
    
    -- Move the follower to the formation position relative to the leader
    local targetX = leaderX + offsetX
    local targetY = leaderY + offsetY
    
    -- Example: Move follower to the calculated position
    PathfindAndMoveTo(targetX, targetY, leaderZ, false)
end

function are_we_distancing()
	returnval = 0
	zown = GetZoneID()
	--are_we_social_distancing = 0
	for i=1,#duties_with_distancing do
		if zown == duties_with_distancing[i][1] then
			if socialdistancing > 0 then 
				--yield("/echo We are in a social distancing area (foray) -> "..duties_with_distancing[i][2].."("..duties_with_distancing[i][1]..")")
				returnval = 1
				--are_we_social_distancing = 1
			end
		end
	end
	if socialdistancing_indoors == 1 then
		returnval = 1 --force it if we need to force it.
		--yield("/echo we are Social distancing EVERYWHERE!")
	end
	if GetCharacterCondition(34) == false and returnval == 0 then
		returnval = 1
		yield("/echo We aren't in a duty so we are social distancing")
	end --obviously if we aren't in a duty we are going to be social distancing by default
	return returnval
end

function checkAREA()
	are_we_DD = 0 --always reset this just in case
	hcling = cling
	if are_we_social_distancing == 1 then
		hcling = cling + ( socialdistance_x_wiggle + socialdistance_z_wiggle ) / 2   --we need more wiggle room outside.
	end
	--are_we_social_distancing = 0
	hcling_counter = hcling_counter + 1

	idle_shitter_counter = idle_shitter_counter + 1
	--yield("/echo idle shitter counter -> "..idle_shitter_counter)
	if GetCharacterCondition(26) == true then
		idle_shitter_counter = 0
	end

	--check if we are in a deep dungeon
	if IsAddonVisible("DeepDungeonMap") then
--		if IsAddonReady("DeepDungeonMap") then
		if HasPlugin("BossMod") then
			yield("/vbm setpresetname "..autorotationtypeDD) 
			yield("/vbmai off")
		end
		if HasPlugin("BossModReborn") then yield("/bmrai setpresetname "..autorotationtypeDD) end
		are_we_DD = 1
		hcling = cling + ddistance
		--yield("/echo we in DD -> hcling is 0> "..hcling)
		--deep dungeon requires VBM. BMR **WILL** crash your client without any logs or crash dump
		--[[ --supposedly fixed now
		if HasPlugin("BossModReborn") then
			yield("/xldisableplugin BossModReborn")
			repeat
				yield("/wait 1")
			until not HasPlugin("BossModReborn")
			yield("/xlenableplugin BossMod")
			repeat
				yield("/wait 1")
			until HasPlugin("BossMod")
			yield("/vbmai "..bossmodAI)
			yield("/vbm setpresetname "..autorotationtype)
			yield("/echo WE SWITCHED TO VBM FROM BMR - please review DTR bar etc.")
		end
		--]]
--		end
	end
	--check if we are in a F.A.T.E.
	if IsInFate() == true then
		hcling = cling + fdistance
	end
--	yield("/echo idle_shitter_counter -> "..idle_shitter_counter)
	if idle_shitter_counter > idle_shitter_tic then  --its time to do something idle shitters!
		idle_shitter_counter = 0
--			yield("/echo we attempted to -> shitter to 0 counter")
		if idle_shitter ~= "list" and idle_shitter ~= "nothing" then
			yield(idle_shitter)
--			yield("/echo we attempted to -> "..idle_shitter)
		end
		if idle_shitter == "list" then
			floop = idle_shitter_list[getRandomNumber(1,#idle_shitter_list)]
			yield(floop.." motion")
--			yield("/echo we attempted to -> list "..floop)
		end
		if idle_shitter == "nothing" then
--			yield("/echo we attempted to -> nothing")
			--yield("/echo I'm not an idle shitter")
		end
	end

	if hcling_counter > hcling_reset then
		hcling = cling
		hcling_counter = 0
	end

	are_we_social_distancing = are_we_distancing()
	if are_we_social_distancing == 1 then
		if socialdistancing > cling then
			hcling = socialdistancing
		end
	end

	if IsPartyMemberMounted(shartycardinality) == true and fly_you_fools == false then
		are_we_social_distancing = 0 --turn off social distancing if the party leader is mounted.
	end
end

function clingmove(nemm)
	checkAREA()
	did_we_try_to_move = 0
	if GetTargetName() == "Vault Door" then --we in a treasure map dungeon and need to click the door without following the fren
		--yield("/interact") --no this is dangerous
		PandoraSetFeatureState("Auto-interact with Objects in Instances",true)
		yield("/wait 5")
		return --don't do the other stuff until we have opened the door
	end
	if GetObjectRawXPos(nemm) == 0 and GetObjectRawYPos(nemm) == 0 and GetObjectRawZPos(nemm) == 0 then
		yield("/echo Cannot find >"..nemm.."< or they are somehow at 0,0,0 - we are not moving")
		return
	end
	--jump if we are mounted and below the leader by 10 yalms
	if (GetObjectRawYPos(nemm) - GetPlayerRawYPos()) > 9 and GetCharacterCondition(4) == true then
		yield("/gaction jump")
	end
	zclingtype = clingtype
	if GetCharacterCondition(34) == true then
		zclingtype = clingtypeduty --get diff clingtype in duties
	end
	allowmovement = 0  --dont allow movement by default
	if (follow_in_combat == 1 and GetCharacterCondition(26) == true) or GetCharacterCondition(26) == false then
		allowmovement = 1
	end
	if allowmovement == 0 and GetCharacterCondition(26) == true then
		yield("/vnav stop")
	end
	if allowmovement == 1 then
		--sub-area-transition-hack-while-in-duty
		if are_we_DD == 0 then
			if bistance > 20 and GetCharacterCondition(34) == true then --maybe we went through subarea transition in a duty?
				yield("/echo "..nemm.." is kind of far - lets just forge ahead a bit just in case")
				yield("/hold W <wait.3.0>")
				yield("/release W")
				did_we_try_to_move = 1
			end
		end
		--navmesh
		if zclingtype == 0 then
			--DEBUG
			--yield("/echo x->"..GetObjectRawXPos(nemm).."y->"..GetObjectRawYPos(nemm).."z->"..GetObjectRawZPos(nemm))--if its 0,0,0 we are not gonna do shiiiit.
			--PathfindAndMoveTo(GetObjectRawXPos(nemm),GetObjectRawYPos(nemm),GetObjectRawZPos(nemm), false)
			if bistance > hcling then
				if are_we_social_distancing == 1 and are_we_in_i_zone == 0 then --if we need to spread AND we arent in a zone of interact
					--*we will do some stuff here
					fartX,fartZ = calculateBufferXY (GetPlayerRawXPos(),GetPlayerRawZPos(),GetObjectRawXPos(nemm),GetObjectRawZPos(nemm))
					if GetCharacterCondition(77) == false then yield("/vnav moveto "..fartX.." "..GetObjectRawYPos(nemm).." "..fartZ) end
					if GetCharacterCondition(77) == true then yield("/vnav flyto "..fartX.." "..GetObjectRawYPos(nemm).." "..fartZ) end
				end
				if are_we_social_distancing == 0 or are_we_in_i_zone == 1 then --if we don't need to spread OR we are in a zone of interact
					if GetCharacterCondition(77) == false then yield("/vnav moveto "..GetObjectRawXPos(nemm).." "..GetObjectRawYPos(nemm).." "..GetObjectRawZPos(nemm)) end
					if GetCharacterCondition(77) == true then yield("/vnav flyto "..GetObjectRawXPos(nemm).." "..GetObjectRawYPos(nemm).." "..GetObjectRawZPos(nemm)) end
				end
				did_we_try_to_move = 1
			end
		end
		--visland
		if zclingtype == 1 then
			if GetCharacterCondition(77) == false then yield("/visland moveto "..GetObjectRawXPos(nemm).." "..GetObjectRawYPos(nemm).." "..GetObjectRawZPos(nemm)) end
			if GetCharacterCondition(77) == true then yield("/visland flyto "..GetObjectRawXPos(nemm).." "..GetObjectRawYPos(nemm).." "..GetObjectRawZPos(nemm)) end
			did_we_try_to_move = 1
		end
		--not bmr
		if zclingtype > 2 or zclingtype < 2 then
				yield("/bmrai follow "..GetCharacterName())
				yield("/bmrai followoutofcombat on")
				yield("/bmrai maxdistancetarget 2.6")
		end
		--bmr
		if zclingtype == 2 then
			bistance = distance(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos(nemm),GetObjectRawYPos(nemm),GetObjectRawZPos(nemm))
			if bistance < maxbistance then
				yield("/bmrai followtarget on") --* verify this is correct later when we can load dalamud
				yield("/bmrai followoutofcombat on")
				yield("/bmrai follow "..nemm) 	  --* verify this is correct later when we can load dalamud
				did_we_try_to_move = 1
			end
			if bistance > maxbistance then --follow ourselves if fren too far away or it will do weird shit
				yield("/bmrai followtarget on") --* verify this is correct later when we can load dalamud
				yield("/bmrai followoutofcombat on")
				yield("/bmrai follow "..GetCharacterName()) 	  --* verify this is correct later when we can load dalamud
				yield("/echo too far! stop following!")
				did_we_try_to_move = 1
			end
		end
		if zclingtype == 3 then
			yield("/autofollow "..nemm)
			did_we_try_to_move = 1
		end
		if zclingtype == 4 then
			--we only doing this silly method out of combat
			if GetCharacterCondition(26) == false then
				--yield("/target "..nemm)
				yield("/target \""..nemm.."\"")
				yield("/follow")
				did_we_try_to_move = 1
			end
			--if we in combat and target is nemm we will clear it becuase that may bork autotarget from RSR
			if GetCharacterCondition(26) == true then
				if nemm == GetTargetName() then
					ClearTarget()
				end
			end
		end
	end
	if did_we_try_to_move == 1 then --check some things just in case
		if GetCharacterCondition(11) == true then --groundsit
			yield("/gaction jump")
		end
	end
end

we_are_in = GetZoneID()
we_were_in = GetZoneID()
for i=0,7 do
	if GetPartyMemberName(i) == fren then
		shartycardinality = i
	end
	if GetPartyMemberName(i) == GetCharacterName() then
		partycardinality = i
	end
end
partycardinality = partycardinality + 1
--turns out the above is worthless and not what i wanted for pillion. but we keep it anyways in case we need the data for something.

countfartula = 2
function counting_fartula()
countfartula = 2 --redeclare dont worry its fine. we need this so we can do it later in the code for recalibration
	while countfartula < 9 do
		yield("/target <"..countfartula..">")
		yield("/wait 0.5")
		yield("/echo is it "..GetTargetName().."?")
		if GetTargetName() == fren then
			fartycardinality = countfartula
			countfartula = 9
			--yield("Aha... count fartula is -> "..fartycardinality)
		end
		countfartula = countfartula + 1
	end
end
counting_fartula() --we can call it before mounting because the order changes sometimes after a duty ends or after changing areas (AFTER a duty ends?) idk it was hard to recreate but this solves it.

function checkzoi()
--pandora memory leak too real
	if pandora_interact_toggler_count > 10 then
		pandora_interact_toggler_count = 0
		are_we_in_i_zone = 0
		GZI = GetZoneID()
		if GZI == 1037 then--tam-tara special behaviour since the bossmodule isn't complete and im lazy - it works
			yield("/target Inconspicuous Imp")
			double_check_navGO(GetObjectRawXPos("Inconspicuous Imp"),GetObjectRawYPos("Inconspicuous Imp"),GetObjectRawZPos("Inconspicuous Imp"))
		end
		--prae, meri, dze, halatali	
		for zzz=1,#zoi do
			if zoi[zzz] == GZI then
				are_we_in_i_zone = 1
			end
			yield("/wait 0.5")
		end
		if are_we_in_i_zone == 1 then
			hcling = cling -- no social distancing if we need to interact with stuff in the zone
		end
		if are_we_in_i_zone == 1 and did_we_toggle == 0 then
			PandoraSetFeatureState("Auto-interact with Objects in Instances",true)
			did_we_toggle = 1
			yield("/echo Turning on Pandora Auto Interact -- it will be turned off when we leave this area")
			--yield("/echo PandoraSetFeatureState(Auto-interact with Objects in Instances,true)")
		end
		if are_we_in_i_zone == 0 then
			PandoraSetFeatureState("Auto-interact with Objects in Instances",false)
			did_we_toggle = 0
			--yield("/echo PandoraSetFeatureState(Auto-interact with Objects in Instances,false)")
		end
	end
end

--yield("Friend is party slot -> "..partycardinality.." but actually is ff14 slot -> "..fartycardinality)
yield("/echo Friend is party slot -> "..fartycardinality .. " Order of join -> "..partycardinality.." Fren Join order -> "..shartycardinality)
ClearTarget()

--bmr follow off. default state. slot1 is the runner of this script
--yield("/bmrai follow slot1")
yield("/bmrai follow slot1")
yield("/echo Beginning fren rider main loop")

xp_item_equip = 0 --counter
re_engage = 0 --counter
renav_check = 0

while weirdvar == 1 do
	--catch if character is ready before doing anything
	if IsPlayerAvailable() then
		if type(GetCharacterCondition(34)) == "boolean" and type(GetCharacterCondition(26)) == "boolean" and type(GetCharacterCondition(4)) == "boolean" then
			bistance = distance(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos(fren),GetObjectRawYPos(fren),GetObjectRawZPos(fren))
			if bistance > maxbistance then --follow ourselves if fren too far away or it will do weird shit
				clingmove(GetCharacterName())
			end

			--if we in combat and target is <3 yalms dont nav anywhere.
			if GetCharacterCondition(26) == true and type(GetTargetName()) == "string" and string.len(GetTargetName()) > 1 then
				if distance(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos(GetTargetName()),GetObjectRawYPos(GetTargetName()),GetObjectRawZPos(GetTargetName())) < 3 then
					yield("/vnav stop")
				end
			end

			--renav condition while in a duty. if we stuck for more than 10 seconds in place. renav damnit
			if GetCharacterCondition(4) == true and bistance > hcling and GetCharacterCondition(34) == true then 
				renav_check = renav_check + 1
				if renav_check > 10 then
					renav_check = 0
					yield("/echo Gently checking nav")
					double_check_navGO(GetObjectRawXPos(GetCharacterName()), GetObjectRawYPos(GetCharacterName()), GetObjectRawZPos(GetCharacterName()))
				end
			end

			--dismount regardless of in duty or not
			if IsPartyMemberMounted(shartycardinality) == false and fly_you_fools == true and GetCharacterCondition(4) == true then
				--continually try to dismount
				--bmr follow off.
				yield("/bmrai follow slot1")
				if GetZoneID() ~= 1044 then
					yield("/ac dismount")
				end
				yield("/wait 0.5")
				rhandling()
			end

			xp_item_equip = xp_item_equip + 1		
			if xp_item_equip > ((1/timefriction)) * 5 and xpitem > 0 and GetItemCountInContainer(xpitem,1000) ~= 1 then -- every 5 seconds try to equip xp item(s) if they aren't already equipped
					yield("/equipitem "..xpitem)
					xp_item_equip = 0
			end
			
			re_engage = re_engage + 1
			if re_engage > 2 then --every 3 seconds we will do rhandling() just to make sure we are attacking stuff if we aren't mounted.
				if GetCharacterCondition(4) == false then
					rhandling()
				end
				re_engage = 0
			end
			
			--Food check!
			statoos = GetStatusTimeRemaining(48)
			---yield("/echo "..statoos)
			if GetCharacterCondition(26) == false then -- dont eat while fighting it will upset your stomach
				if type(GetItemCount(feedme)) == "number" then
					if GetItemCount(feedme) > 0 and statoos < 300 then --refresh food if we are below 5 minutes left
						yield("/item "..feedmeitem)
						yield("/echo Attempting to eat "..feedmeitem)
					end
				end
			end

			if GetCharacterCondition(34) == true then --in duty we might do some special things. mostly just follow the leader and let the ai do its thing.
				--bmr follow on
				--yield("/bmrai follow slot"..fartycardinality.."")
				--yield("/bmrai follow "..fren)
				--we will use clingmove not bmrai follow as it breaks pathing from that point onwards
				clingmove(fren)
				--allright im getting sick of pratorium. its time to do something.
				if type(GetZoneID()) == "number" and GetZoneID() == 1044 and GetCharacterCondition(4) then --Praetorium
					--if string.len(GetTargetName()) == 0 then
					TargetClosestEnemy()
					--end
					yield("/send KEY_2")
					flandom = getRandomNumber(1,3)
					if flandom == 1 then yield("/send E") end
					yield("/wait 0.5")
				end
				pandora_interact_toggler_count = pandora_interact_toggler_count + 1
				checkzoi()
			end

			if GetCharacterCondition(34) == false then  --not in duty  
				--SAFETY CHECKS DONE, can do whatever you want now with characterconditions etc			
				--movement with formation - initially we test while in any situation not just combat
				--check distance to fren, if its more than cling, then
	
				pandora_interact_toggler_count = pandora_interact_toggler_count + 1
				checkzoi()

				if formation == true and bistance < maxbistance then
					-- Inside combat and formation enabled
					local leaderX, leaderY, leaderZ = GetObjectRawXPos(fren), GetObjectRawYPos(fren), GetObjectRawZPos(fren)
					local leaderRotation = GetObjectRotation(fren)
					moveToFormationPosition(partycardinality, leaderX, leaderY, leaderZ, leaderRotation)
					yield("/wait 0.5")
				end
				--movement without formation
				if GetCharacterCondition(26) == true and formation == false then --in combat
					if formation == false then
						if bistance > hcling and bistance < maxbistance then
							clingmove(fren) --movement func
						end
						yield("/wait 0.5")
					end	
				end
				
				--we are limitbreaking all over ourselves
				if can_i_lb() == true and limitpct > -1 then
					GetLimoot = 0 --init lb value. its 10k per 1 bar
					GetLimoot = GetLimitBreakCurrentValue()
					if type(GetLimoot) ~= "number" then  --error trap variable type because we dont like SND pausing
						GetLimoot = 0 --well its 0 if its 0
					end
					local_teext = "\"Limit Break\""
					--check the target life %
					if type(GetTargetHPP()) == "number" and GetTargetHPP() < limitpct then
						--seems like max lb is 1013040 when ultimate weapon buffs you to lb3 but you only have 30k on your bar O_o
						--anyways it will trigger if lb3 is ready or when lb2 is max and it hits lb2
						if (GetLimoot == (GetLimitBreakBarCount() * GetLimitBreakBarValue())) or GetLimoot > 29999 then
							yield("/rotation Cancel")		
							yield("/echo Attempting "..local_teext)
							yield("/ac "..local_teext)
						end
						if GetLimoot < GetLimitBreakBarCount() * GetLimitBreakBarValue() then
							yield("/rotation auto")		
						end
						--yield("/echo limitpct "..limitpct.." HPP"..GetTargetHPP().." HP"..GetTargetHP().." get limoot"..GetLimitBreakBarCount() * GetLimitBreakBarValue()) --debug line
					end
				end

				autotosscount = autotosscount  + 1
				if autotoss == true and autotosscount > 100 then
				   yield("/discardall")
				   autotosscount = 0
				end
				--check if we changed areas and stop movement and clear target
				we_are_in = GetZoneID()
				if we_are_in ~= we_were_in then
					yield("/wait 0.5")
					yield("/visland stop")
					yield("/vnavmesh stop")
					yield("/wait 0.5")
					yield("/visland stop")
					yield("/vnavmesh stop")
					ClearTarget()
					we_were_in = we_are_in
				end
							
				--the code block that got this all started haha
				--follow and mount fren
				if GetCharacterCondition(26) == false then --not in combat
					--process repair stuff
					if repair > 0 then
						if repair == 1 then
							if NeedsRepair(tornclothes) and GetItemCount(1) > 4999 and GetCharacterCondition(34) == false and GetCharacterCondition(56) == false then --only do this outside of a duty yo
								yield("/ad repair")
								goatcounter = 0
								for goatcounter=1,30 do
									yield("/wait 0.5")
									yield("/callback _Notification true 0 17")
									yield("/callback ContentsFinderConfirm true 9")
								end
								yield("/ad stop")
							end
						end
						if repair == 2 then
							--JUST OUTSIDE THE INN REPAIR
							if NeedsRepair(tornclothes) and GetItemCount(1) > 4999 and GetCharacterCondition(34) == false and GetCharacterCondition(56) == false then --only do this outside of a duty yo
								yield("/ad repair")
								goatcounter = 0
								for goatcounter=1,30 do
									yield("/wait 0.5")
									yield("/callback _Notification true 0 17")
									yield("/callback ContentsFinderConfirm true 9")
								end
								yield("/ad stop")
							end
							--reenter the inn room
							--if (GetZoneID() ~= 177 and GetZoneID() ~= 178) and GetCharacterCondition(34) == false and NeedsRepair(50) == false then
							if (GetZoneID() ~= 177 and GetZoneID() ~= 178 and GetZoneID() ~= 179) and GetCharacterCondition(34) == false and IsPlayerAvailable() then
								yield("/send ESCAPE")
								yield("/ad stop") --seems to be needed or we get stuck in repair genjutsu
								yield("/target Antoinaut") --gridania
								yield("/target Mytesyn")   --limsa
								yield("/target Otopa")     --uldah
								yield("/wait 1")
								if type(GetCharacterCondition(34)) == "boolean" and  GetCharacterCondition(34) == false and IsPlayerAvailable() then
									yield("/lockon on")
									yield("/automove")
								end
								yield("/wait 2.5")
								if type(GetCharacterCondition(34)) == "boolean" and  GetCharacterCondition(34) == false and IsPlayerAvailable() then
									yield("/callback _Notification true 0 17")
									yield("/callback ContentsFinderConfirm true 9")
									--yield("/interact")
									PandoraSetFeatureState("Auto-interact with Objects in Instances",true)
								end
								yield("/wait 1")
								if type(GetCharacterCondition(34)) == "boolean" and  GetCharacterCondition(34) == false and IsPlayerAvailable() then
									yield("/callback _Notification true 0 17")
									yield("/callback ContentsFinderConfirm true 9")
									yield("/callback SelectIconString true 0")
									yield("/callback _Notification true 0 17")
									yield("/callback ContentsFinderConfirm true 9")
									yield("/callback SelectString true 0")
									yield("/wait 1")
								end
								--yield("/wait 8")
								--RestoreYesAlready()
							end
						end					
					end
					if GetCharacterCondition(4) == true and fly_you_fools == true then
						--follow the fren
						if GetCharacterCondition(4) == true and bistance > hcling and PathIsRunning() == false and PathfindInProgress() == false then
							--yield("/echo attempting to fly to fren")
							clingmove(fren)

							yield("/target <"..fartycardinality..">")
							
						end
					end
					if GetCharacterCondition(4) == false and GetCharacterCondition(10) == false then --not mounted and not mounted2 (riding friend)
						--chocobo stuff. first check if we can fly. if not don't try to chocobo
						--actually check if we are in a sanctuary first, if true we aren't gonna try to check or do anything.
						if InSanctuary() == false then
							if HasFlightUnlocked() == true or force_gyasahl == true then
								--check if chocobro is up or (soon) not!
								if GetBuddyTimeRemaining() < 900 and GetItemCount(4868) > 0 then
									yield("/visland stop")
									yield("/vnavmesh stop")
									yield("/item Gysahl Greens")
									yield("/wait 3")
									yield("/cac \""..companionstrat.."\"")
								end
							end
						end
						--yield("/target <cross>")
						if formation == false then
							--check distance to fren, if its more than cling, then
							bistance = distance(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos(fren),GetObjectRawYPos(fren),GetObjectRawZPos(fren))
							if bistance > hcling and bistance < maxbistance then
							--yield("/target \""..fren.."\"")
								--PathfindAndMoveTo(GetObjectRawXPos(fren),GetObjectRawYPos(fren),GetObjectRawZPos(fren), false)
								clingmove(fren) --movement func
								--yield("/echo DEBUG line 467ish")
							end
							yield("/wait 0.5")
						end	

						--yield("/echo fly fools .."..tostring(fly_you_fools))
						if fly_you_fools == true then
							if GetCharacterCondition(4) == true then
								yield("/rotation cancel") --keep rotations off
							end
							if GetCharacterCondition(4) == false and GetCharacterCondition(10) == false and IsPartyMemberMounted(shartycardinality) == true then
								--mountup your own mount
								--cancel movement
								yield("/mount \""..fool_flier.."\"")
								--yield("/wait 5") -- we can mount and move now
								ClearTarget()
								yield("/rotation Cancel")
								--try to fly 
								--yield("/gaction jump")
								--yield("/lockon on")
							end
						end
						if IsPartyMemberMounted(shartycardinality) == true and fly_you_fools == false then
							--for i=1,7 do
								--yield("/ridepillion <"..partycardinality.."> "..i)
								counting_fartula()
								yield("/ridepillion <"..fartycardinality.."> 2")
								yield("/rotation Cancel")
							--end
							yield("/echo Attempting to Mount Friend")
							yield("/wait 0.5")
						end
					end
				end
			end
		end
	end
	yield("/wait "..timefriction)
end