--[[
Fully Unified Task Automation (F.U.T.A.)

What does it do?

configure AR to run a script after AR is done and it have it run THIS script.
This script will, after AR is done, do various things based on a set of rules you will configure in a separate file (FUTAconfig_McVaxius.lua)

It could be ocean fishing, triple triad, inventory cleaning, going for a jog around the housing ward, delivering something to specific person, crafting. or whatever!

Requirements : SND, vnavmesh, dropbox, visland, pandora, simpletweaks
and maybe more - let's see where we go with it
everything from the folder you found this
and https://github.com/Jaksuhn/SomethingNeedDoing/blob/master/Community%20Scripts/AutoRetainer%20Companions/RobustGCturnin/_functions.lua

throw everything into %AppData%\XIVLauncher\pluginConfigs\SomethingNeedDoing\

What is working?
	Fishing
		Geting Fisher Levels and determining who is the lowest level fisher
		Fully cycling ocean fishing to the char with lowest level of fishing job
	Outputting to log file if Red Onion Helm Detected
	Updating Inventories, FC, Chocobo saddlebags for Atools by opening them.
		******************************************************************************************
		*DONT ASK ABOUT THIS IN PUNISH DISC OR YOU WILL BE SENT TO THE TEASPOON DROPPING CUPBOARD -> https://www.youtube.com/watch?v=TsFGJqXnqBE
		*Repricing items in retainers first time 100%, 3% chance after that unless you configure it differently.
		you may need to turn off retainer window bailout in /ays expert   or set it to 30 or 60 seconds.. still tbd on this
		*DONT ASK ABOUT THIS IN PUNISH DISC OR YOU WILL BE SENT TO THE TEASPOON DROPPING CUPBOARD -> https://www.youtube.com/watch?v=TsFGJqXnqBE
		******************************************************************************************
	Doing GC Turnins when configured inventory slots free is below a certain amount
	Visiting personal houses when we reach specified number of retainer cleanings
	Rebuying Ceruleum Fuel
	Trickling in repair kits

nice to have working
	(From Cabbage @ Punish disc) gardening -> https://gist.github.com/cabbscripts/6d265058d5e605b90adb8362c7638976
		it uses YA's list priority to harvest -> reseed -> quit, could add watering in too
		and assumes your plots are stacked on top of the housing entrance 

Known issues and resolution
	changing the table structure right now i can't do dynamically and safely (please help me!) so i am versioning things if i change the table structure so you
	can at least keep your old configs / counters if you need them.    there is probably a nice way to do this without deleting your configs but this is where we are :(
	also - if you dont have a fully busy roster of retainers, ocean fishing via this method isnt reccommended, you should just use the persistent ocean fishing script thats also on this repo somewhere. i won't be updating that one though.
	Automarket is donezo. it was nice while it lasted.  maybe a replacement will appear. i am looking at some script alternative but i don't like it.	for now i set the default value for illegal cleaning to 0 until a solution appears. you can leave existing configurations alone as if it comes back it will just start working again if you update _functions.lua

--]]
------------------------------------------------------------
-------------------Static Variables-------------------------
------------------------------------------------------------
table_version = 2 -- don't change this. I will change it. this way your old configs are stored and someday someone can help me figure out how to migrate shit
------------------------------------------------------------
----------------------GLOBAL VARIABLES----------------------
------------------------------------------------------------
FUTA_config_file = "FUTAconfig_McVaxius_"..table_version..".lua"
force_fishing = 0 -- Set to 1 if you want the default indexed char (read the default settings for FISH) to fish whenever possible
venture_cleaning = 20 -- How many venture coins do we need to have left we do a cleaning - useful for leveling new retainer abusers 21072 is item id
folderPath = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"
loadfiyel = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\_functions.lua"
fullPath = os.getenv("appdata") .. "\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\" .. FUTA_config_file
functionsToLoad = loadfile(loadfiyel)
functionsToLoad()
dont_report_good_stuff = 0 --by default reporting everything, if you turn this on, it will not report on "good" stuff (we made x MRK!) aside from personal home entries
logfile_differentiator = " - Account 1"  --example of extra text to throw into log file say if your pointing a few clients to same log file for convenience
force_equipstuff = 0 --should we try to force recommended equip every chance we get? by default we won't do it
discard_type = 0 --0 = dont discard, 1 = discard, 2 = discard only if "CLEAN"[3] is > 0, or if its ==0 we desynth instead!, 3 = dont discard but desnyth if "CLEAN"[3] == 0 from special white list of items ill put here --* not implemented
log_gcranks = 9 --log the gc ranks of each char if they are below this rank on all 3. that way we can catch the "lower" one from the main one they are in. set it to 0 to disable the check
automarketfix = "AutoBot" -- try to xldisable profile automarket. however if you set this to "no" it wont do it.  the reason for this is eventually automarket just does some weird stuff and wont let you access retainer bells
equip_from_table = 0 --0 is no, 1 is yes
illegalcleaningresetvalue = 3 --this is the pct chance it will try to do a "selling/repricing" after completing AR tasks. it is also the value it sets after a cleaning is done/triggered. 3% might actually be kind of high if you have lots of chars . i might lower it to 1 for myself.
dontforceillegalcleaning = 1 --this is so it doesnt force a 100% chance to illegally clean after a gc cleaning. this is probably best if you have giant empire you want to delay cleanings as much as possible
------------------------------------------
--Config and change back after done!------
------------------------------------------
re_organize_return_locations = 0 -- only set this one time and run the script so it can clean up the return locations, 0 magitek fuel = limsa bell, +fuel = fc entrance, also sets some defaults for fcs with newly acquired subs
------------------------------------------
------------------------------------------
------------------------------------------

--yield("/wintitle Final Fantasy XIV")   --FOR HACKY FISHIN SWITCHER WITH AHK
--yield("/wait 5")
--yield("/waitaddon _ActionBar <maxwait.600><wait.2>")

--EXCLUSION LIST START--
--untested exclusion list. you figure it out. ;)
miqotes_have_fleas = 
{
"Large Buttcheeks@you",
"Black'friday deals@friday",
"Nut'every Day'november@truth"
}
if miqotes_have_fleas[1] ~= "Large Buttcheeks@you" then
	potential_futa_hater = GetCharacterName(true)
	not_on_my_watch_pervert = 0
	yield("/wait 0.5")
	for i=1,#miqotes_have_fleas do
		if potential_futa_hater == miqotes_have_fleas[i] then not_on_my_watch_pervert = 1 end
	end
	yield("/wait 0.5")
	if not_on_my_watch_pervert == 1 then
		yield("/echo Not on my watch pervert!")
		yield("/pcraft stop")
	end
end
--EXCLUSION LIST END--

--update atools w fc and inventory
yield("/echo Fully Unified Task Automation (F.U.T.A.) Initializing .....")
yield("/freecompanycmd") -- for atools
yield("/echo Free Company command executed.")
yield("/inventory") --for atools
yield("/echo Inventory command executed.")
yield("/playtime")  --for altoholic
yield("/echo Playtime command executed.")
yield("/saddlebag") --for atools
yield("/echo Saddlebag command executed.")
yield("/echo Fully Unified Task Automation (F.U.T.A.) atools database updated")
yield("/echo Non Aggregated Recursive Integration (N.A.R.I.) Initializing .....")
----------------------------------

RestoreYesAlready() --bring it back so we can do stuff
--Script+ar breaker stuff force fixed
RestoreYesAlready()
yield("/bmrai off")
yield("/vbmai off")
yield("/rotation Cancel")
--script breaker stuff end
if automarketfix ~= "no" then
	--[[
	yield("/xldisableprofile "..automarketfix)
	while HasPlugin("AutoBot") do
		yield("/echo waiting on am to turn off safely")
		yield("/wait 1")
	end
	yield("/wait 2")
	yield("/xlenableprofile "..automarketfix)
	--]]
	--yield("/am stop ") --this is all we need to stop the bells from being inoperable hahah this is it hahahahahah --deprecated i think
	yield("/automarket stop ") --this is all we need to stop the bells from being inoperable hahah this is it hahahahahah
end
--------------------------
yield("/echo Script breakers disabled")		
FUTA_processors = {} -- Initialize variable

-- 3D Table   {}[i][j][k]
----  -> --Y- -> implemented
----  -> --N- -> not implemented yet - might be replaced with another feature. dont worry about it.
----  -> --?- -> not possible yet/partially implemented - might be replaced with another feature. dont worry about it.
FUTA_defaults = {
    {
        {"Firstname Lastname@Server", 0}, 			--Y--{}[i][1][1..2]--name@server and return type 0 return home to fc entrance, 1 return home to a bell, 2 don't return home, 3 is gridania inn, 4 limsa bell near aetheryte, 5 personal estate entrance, 6 bell near personal home, 7 fc entrance and do nothing else
        {"FISH", 0},								--Y--{}[i][2][1..2]--level, 0 = dont do anything, 100 = dont do anything, 101 = automatically pick this char everytime (default indexed char), minimum = pick this char if no 101 exists (default indexed char)
		{"CLEAN", 0, 0, 0, 50},						--Y--{}[i][3][1..5]--chance to do random cleaning/100 if 100 it will be changed to illegalcleaningresetvalue(default 3) after 1 run, process_gc_rank = 0=no,1=yes. expert_hack = 0=no,1=yes. clean_inventory = 0=no, >0 check inventory slots free and try to clean out inventory., set [5] to -1 if you want to disable gc cleaning for this char
--		{"CLEAN", 100, 0, 0, 50},					--Y--{}[i][3][1..5]--chance to do random cleaning/100 if 100 it will be changed to illegalcleaningresetvalue(default 3) after 1 run, process_gc_rank = 0=no,1=yes. expert_hack = 0=no,1=yes. clean_inventory = 0=no, >0 check inventory slots free and try to clean out inventory., set [5] to -1 if you want to disable gc cleaning for this char
		{"FUEL", 0, 0},								--Y--{}[i][4][1..3]--fuel safety stock trigger, fuel to buy up to i[4][3] amount when hitting i[4][2] amount or lower leave i[4][2] at 0 if you dont want it to process this
		{"TT", 0, 0},								--N--{}[i][5][1..3]--minutes of TT, npc to play 1= roe 2= manservant
		{"CUFF", 0},						    	--Y--{}[i][6][1..2]--auto equip related. if this is anything other than 0, it will try to iterate from /gearset change x  where x is 1 to CUFF. don't overuse this. use it on specific chars like raid alts only. as it will triggger EVERYTIME The gearset updater function runs.  this one only really matters for FUTA_GC anyways as that is the moment when gearsets become important
		{"MRK", 0},									--Y--{}[i][7][1..2]--the artisan list ID to trigger after each QV check on this char, just make an artisan list with magitek repair mats and put the ID there
		{"FCB", "nothing", "nothing"},				--N--{}[i][8][1..3]--refresh FC buffs if they have 1 or less hours remaining on them. (remove and re-assign)
		{"PHV", 0, 100},							--Y--{}[i][9][1..3]--0 = no personal house 1 = has a personal house, personal house visit counter, once it reaches {}[][][2] it will reset to 1 after a visit, each ar completion will +1 it
		{"DUTY", "Teaspoon Dropping Cupboard", -5, 0},--N-{}[i][10][1..4]--name of duty, number of times to run (negative values for one time run - set to 0 after), normal 0 unsynced 1    				https://www.youtube.com/watch?v=TsFGJqXnqBE
		{"MINI", 0, 0, 0},							--N-{}[i][11][1..4]--Daily mini cactpot, [2] year [3] month [4] day, if we are in the next day after reset time. then we go run it again and set the time. again.
		{"VERM", 0, 0, 0}							--N-{}[i][12][1..4]--Verminion, [2] year [3] month [4] day, if we are in the next week after reset time. then we go run it again and set the time. again.
    }
}

equip_teble = {
43471,43472,43473,43474,43475          --Night of devilry
}

-- Read and deserialize the data
serializedData = readSerializedData(fullPath)
deserializedTable = {}
if serializedData then
    deserializedTable = deserializeTable(serializedData)
	-- Assign the deserialized table to FUTA_processors
    FUTA_processors = deserializedTable

    -- Check the deserialized table
    --yield("/echo Deserialized table:")
    --printTable(FUTA_processors)
else
    yield("/echo Error: Serialized data is nil.")
end

--loadfiyel2 = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\FUTAconfig_McVaxius.lua"
--functionsToLoad2 = loadfile(loadfiyel2)
--functionsToLoad2()

function getRandomNumber(min, max)
    return math.random(min, max)
end

zungazunga() -- Get out of anything quickly


hoo_arr_weeeeee = -1 -- Who are we? Default to -1 for figuring out if new char or not

for i = 1, #FUTA_processors do
    if GetCharacterName(true) == FUTA_processors[i][1][1] then
        hoo_arr_weeeeee = i
    end
end

if hoo_arr_weeeeee == -1 then
    -- We have a new char to add to the table!
    FUTA_processors[#FUTA_processors + 1] = {}
    -- Initialize all levels with defaults
    for j = 1, #FUTA_defaults[1] do
        FUTA_processors[#FUTA_processors][j] = {}
        for k = 1, #FUTA_defaults[1][j] do
            FUTA_processors[#FUTA_processors][j][k] = FUTA_defaults[1][j][k]
        end
    end

    -- Assign the character name
    FUTA_processors[#FUTA_processors][1][1] = GetCharacterName(true)
	hoo_arr_weeeeee = #FUTA_processors --we added it, lets cardinality it
end

-- Check if any table data is missing and put in a default value
for i = 1, #FUTA_processors do
    --yield("/echo Type of FUTA_processors["..i.."]:" .. type(FUTA_processors[i]))
    for j = 2, #FUTA_defaults[1] do
        --yield("/echo Type of FUTA_processors["..i.."]["..j.."]:" .. type(FUTA_processors[i][j]))
        for k = 1, #FUTA_defaults[1][j] do
            --yield("/echo Type of FUTA_processors["..i.."]["..j.."]["..k.."]:" .. type(FUTA_processors[i][j][k]))
            if FUTA_processors[i][j][k] == nil then
                FUTA_processors[i][j][k] = FUTA_defaults[1][j][k]
            end
        end
    end
end

yield("/echo N.A.R.I. Table Processor Completed")


--[[
-- Function to recursively print table contents
function printTable(t, indent)
    indent = indent or ""
    if type(t) ~= "table" then
        yield("/echo " .. indent .. tostring(t))
        return
    end
    
    for k, v in pairs(t) do
        local key = tostring(k)
        if type(v) == "table" then
            yield("/echo " .. indent .. key .. " =>")
            printTable(v, indent .. "  ") -- Recursive call with increased indent
        else
            yield("/echo " .. indent .. key .. " => " .. tostring(v))
        end
    end
end

-- Debug: Output the contents of FUTA_processors
if #FUTA_processors == 0 then
    yield("/echo FUTA_processors is empty!")
else
    yield("/echo FUTA_processors contents:")
    for i = 1, #FUTA_processors do
        yield("/echo Entry " .. i .. ":")
        printTable(FUTA_processors[i], "  ")
    end
end
--]]

--one-off-hackeries
if re_organize_return_locations == 1 then
	if GetItemCount(10155) >  0 then
		FUTA_processors[hoo_arr_weeeeee][1][2] = 0  --configure for return to fc house if we have repair kits
	end
	--insert hacky stuff to fix some data for later
	--fuel settings
	if GetItemCount(10373) == 0 and FUTA_processors[hoo_arr_weeeeee][4][2] > -1 then
		FUTA_processors[hoo_arr_weeeeee][4][2] = 0
		FUTA_processors[hoo_arr_weeeeee][4][3] = 0
	end
	if FUTA_processors[hoo_arr_weeeeee][4][2] > -1 and GetItemCount(10373) > 0 then
		FUTA_processors[hoo_arr_weeeeee][4][2] = 666
		FUTA_processors[hoo_arr_weeeeee][4][3] = 6666
	end
end

-- After tablebunga() call
tablebunga(FUTA_config_file, "FUTA_processors", folderPath)
yield("/echo tablebunga() completed successfully")

-- Begin to do stuff
wheeequeheeheheheheheehhhee = 0 -- Secret variable
do_we_discard = 0 --set this for now
yield("/echo Debug: Beginning to do stuff")

--check for red onion helm
check_ro_helm()

--check for GC Ranks
check_GC_RANKS(log_gcranks)

---------------------------------------------------------------------------------
------------------------------FISHING  START-------------------------------------
---------------------------------------------------------------------------------
if FUTA_processors[hoo_arr_weeeeee][2][2] > -1 then  -- -1 is ignore+disable for this feature
	--we dont have a fishing level setup
    yield("/echo Let's see if fishing is even a thing on this char and update the database")
	yield("/wait 0.5")	
	if tonumber(GetLevel(17)) > 0 then
		FUTA_processors[hoo_arr_weeeeee][2][2] = tonumber(GetLevel(17))
		if FUTA_processors[hoo_arr_weeeeee][2][2] == 99999 then --*this doesnt work atm
			xp = GetNodeText("_Exp", 3)
			xpxp = string.match(xp, "%d[%d.,]*"):gsub(",", "")  -- Remove commas
			yield("/echo Cleaned xp string: " .. xpxp)
			local xp_numeric = tonumber(xpxp) or 0  -- Convert to number, default to 0 if nil
			yield("/echo partial levle in 99 is  -> ".. xp_numeric / 25000000)
			FUTA_processors[hoo_arr_weeeeee][2][2] = FUTA_processors[hoo_arr_weeeeee][2][2] + xp_numeric
		end
		tablebunga(FUTA_config_file, "FUTA_processors", folderPath)
		yield("/echo tablebunga() completed successfully w new fishing data")
	end
	if tonumber(GetLevel(17)) == 0 then
		FUTA_processors[hoo_arr_weeeeee][2][2] = -1  --fishing is disabled don't check it again
		tablebunga(FUTA_config_file, "FUTA_processors", folderPath)
		yield("/echo this char is not a fisher")
	end
end

--fishing - always check first since it takes some time sometimes to get it going
--dont do anything else if we are fishing. just return home and resume AR after
if os.date("!*t").hour % 2 == 0 and os.date("!*t").min < 15 then
    if os.date("!*t").min >= 1 then
        wheeequeheeheheheheheehhhee = 1
    end
end
yield("/echo Debug: Time check completed")

-- Determine who is the lowest level fisher of them all.
lowestID = 1
--first get a non 0 value
for i = 1, #FUTA_processors do
    if FUTA_processors[i][2][2] > 0 then
        lowestID = i
    end
end
--now look for a smaller one
for i = 1, #FUTA_processors do
    if FUTA_processors[i][2][2] > 0 and FUTA_processors[i][2][2] < FUTA_processors[lowestID][2][2] then
        lowestID = i
    end
end

yield("/echo Debug: Lowest ID determined -> "..lowestID.." Corresponding to -> "..FUTA_processors[lowestID][1][1].. " With a level of -> "..FUTA_processors[lowestID][2][2])

-- If the lowest guy is max level, we aren't fishing
if FUTA_processors[lowestID][2][2] == 100 and force_fishing == 0 or FUTA_processors[lowestID][2][2] == -1 then
    wheeequeheeheheheheheehhhee = 0
    yield("/echo Lowest char is max level or no chars have fishing so we aren't fishing")
end


--update do_we_discard
dwdid = hoo_arr_weeeeee
if wheeequeheeheheheheheehhhee == 1 then 
	dwdid = lowestID
end
if discard_type == 1 then
	do_we_discard = 1
end
if discard_type > 1 then
	if FUTA_processors[dwdid][3][2] > 0 and discard_type == 2 then
		do_we_discard = 1 
	end
	if FUTA_processors[dwdid][3][2] == 0 then
		do_we_discard = 2 
	end
end

-- It's fishing time
if wheeequeheeheheheheheehhhee == 1 then
    if GetCharacterCondition(31) == false then
        if GetCharacterCondition(32) == false then
            ungabungabunga() -- We really try hard to be safe here
            yield("/echo Debug: Preparing for fishing")
            
            loadfiyel2 = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\FUTA_fishing.lua"
            functionsToLoad = loadfile(loadfiyel2)
            functionsToLoad()
			
            yield("/waitaddon _ActionBar <maxwait.600><wait.2>")
			
			yield("/ays multi d")
			yield("/wait 1")
			yield("/ays reset")
			yield("/wait 5")
			
            fishing()
            yield("/echo Debug: Fishing completed")

            -- Drop a log file entry on the charname + Level
            local file = io.open(folderPath .. "FeeshLevels.txt", "a")
            if file then
                currentTime = os.date("*t")
                formattedTime = string.format("%04d-%02d-%02d %02d:%02d:%02d", currentTime.year, currentTime.month, currentTime.day, currentTime.hour, currentTime.min, currentTime.sec)
                FUTA_processors[lowestID][2][2] = GetLevel()
				xp = GetNodeText("_Exp", 3)
				yield("/echo current xp: "..string.match(xp, "%d[%d.,]*"))
				xpxp = string.match(xp, "%d[%d.,]*")
                file:write(formattedTime.." - "..logfile_differentiator.."["..lowestID.."] - "..FUTA_processors[lowestID][1][1].." - Fisher Lv - "..FUTA_processors[lowestID][2][2].." - XP -> "..xpxp.."\n")
                file:close()
                yield("/echo Text has been written to '" .. folderPath .. "FeeshLevels.txt'")
            else
                yield("/echo Error: Unable to open file for writing")
            end
            tablebunga(FUTA_config_file, "FUTA_processors", folderPath)
            yield("/echo Debug: Log file entry completed")
        end
    end
end
---------------------------------------------------------------------------------
------------------------------FISHING END----------------------------------------
---------------------------------------------------------------------------------
if wheeequeheeheheheheheehhhee == 0 then

	----------------------------
	--CLEAN--
	----------------------------
    -- Start of processing things when there is no fishing   
	if HasPlugin("AutoBot") then  --only clean if we actually have "the" plugin
		if FUTA_processors[hoo_arr_weeeeee][3][2] > 0 then
			cleanrand = getRandomNumber(0, 99)
			yield("/echo rolling dice to see if we do a repricing -> "..cleanrand.." out of chance -> "..FUTA_processors[hoo_arr_weeeeee][3][2])
			if cleanrand < FUTA_processors[hoo_arr_weeeeee][3][2] then
				wheeequeheeheheheheheehhhee = 1  --re using this var because we can and it means the same thing at end of script
				yield("/echo Debug: Inventory cleaning adjustment started")
				--kneecapping AR for now because it interferes with am
				yield("/ays multi d")
				yield("/wait 1")
				yield("/ays reset")
				yield("/wait 1")
				yield("/ays multi d")
				yield("/wait 5")
				clean_inventory()
	--			yield("/echo Debug:Debug:Debug:Debug:Debug:Debug:Debug:")
				zungazunga()
				-- If [3] was 100, we set it back down to 10 because 100 means a one-time guaranteed cleaning
				if FUTA_processors[hoo_arr_weeeeee][3][2] > 99 then
					FUTA_processors[hoo_arr_weeeeee][3][2] = illegalcleaningresetvalue --for easier find replace shenanigans  [2] = 11 -> [2] = 99, for example
					tablebunga(FUTA_config_file, "FUTA_processors", folderPath)
					yield("/echo Debug: Inventory cleaning adjustment completed -> and 100 chance changed to "..illegalcleaningresetvalue)
				end
			end
		end
	end
	 --In case we just ran it and need to avoid double triggering it
	if FUTA_processors[hoo_arr_weeeeee][3][2] == -1 then
		yield("/echo Debug: Inventory cleaning adjustment completed -> -1 changed to 11")
		FUTA_processors[hoo_arr_weeeeee][3][2] = illegalcleaningresetvalue 
	end
	if wheeequeheeheheheheheehhhee == 1 and FUTA_processors[hoo_arr_weeeeee][3][2] > 0 then
		FUTA_processors[hoo_arr_weeeeee][3][2] = -1
		yield("/echo Debug: Inventory cleaning adjustment completed -> chance changed to -1 to avoid double send")
	end

	----------------------------
	--CLEAN2 Electric boogaloo--
	----------------------------
	--check inventory size and do gcturnin shit 
	yield("/echo Do we need to clear inventory?")
	if FUTA_processors[hoo_arr_weeeeee][3][2] < 1000 then
		--first try to npcsell before we go to a GC desk
		if (GetInventoryFreeSlotCount() < FUTA_processors[hoo_arr_weeeeee][3][5] and FUTA_processors[hoo_arr_weeeeee][3][5] > 0 or GetItemCount(21072) < venture_cleaning) and FUTA_processors[hoo_arr_weeeeee][3][5] > 0 then
			yield("/echo Attempting to clean inventory @ an npc and or retainerbell and or desynthing (not yet)")
			delete_my_items_please(do_we_discard)
			--*if there is a bell nearby we should probably go to it. also this should be moved to _functions.lua
			yield("/ays itemsell") --npc AND retainer selling
		end
		if (GetInventoryFreeSlotCount() < FUTA_processors[hoo_arr_weeeeee][3][5] and FUTA_processors[hoo_arr_weeeeee][3][5] > 0 or GetItemCount(21072) < venture_cleaning) and FUTA_processors[hoo_arr_weeeeee][3][5] > 0 then
			if FUTA_processors[hoo_arr_weeeeee][3][2] > 0 and dontforceillegalcleaning == 0 then 
				FUTA_processors[hoo_arr_weeeeee][3][2] = 100 --queue up a "clean" after next set of QV - but only if we are even allowing it on this one
			end
			yield("/echo Yes we need to clean inventory and turnin GC stuff!")
			loadfiyel2 = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\FUTA_GC.lua"
			functionsToLoad = loadfile(loadfiyel2)
			functionsToLoad()
			FUTA_robust_gc()
			if FUTA_processors[hoo_arr_weeeeee][3][2] > 0 then --to keep it from double running after it turns itself on in case there was some weird overflow with submarine items, but only if its not disabled already
				FUTA_processors[hoo_arr_weeeeee][3][2] = FUTA_processors[hoo_arr_weeeeee][3][2] + 1000 
			end
			if GetInventoryFreeSlotCount() < (FUTA_processors[hoo_arr_weeeeee][3][5] + 20) then
				loggabunga("FUTA_", logfile_differentiator.." - Inventory still low after cleaning -> "..FUTA_processors[hoo_arr_weeeeee][1][1])
			end
		end
	end
	if FUTA_processors[hoo_arr_weeeeee][3][2] > 1000 then
		FUTA_processors[hoo_arr_weeeeee][3][2] = FUTA_processors[hoo_arr_weeeeee][3][2] - 1000 --reset it for next actual run
	end
	----------------------------
	-----Buy Ceruleum Fuel------
	----------------------------
	if FUTA_processors[hoo_arr_weeeeee][4][2] > 0 then
		if GetItemCount(10155) < FUTA_processors[hoo_arr_weeeeee][4][2] then
			ungabungabunga() -- get out of any screens we are in
			enter_workshop()
			try_to_buy_fuel(FUTA_processors[hoo_arr_weeeeee][4][3])
		end
	end

	----------------------------
	----Trickle Repair Kits-----
	----------------------------
	if FUTA_processors[hoo_arr_weeeeee][7][2] > 0 then
		if GetInventoryFreeSlotCount() < 20 then
			loggabunga("FUTA_", logfile_differentiator.." - MRK -> Not enough space to safely synth -> "..FUTA_processors[hoo_arr_weeeeee][1][1])
		end
		if GetItemCount(10386) < 20 then
			loggabunga("FUTA_", logfile_differentiator.." - MRK -> Not enough G6DM -> "..FUTA_processors[hoo_arr_weeeeee][1][1])
		end
		if GetItemCount(10335) < 20 then
			loggabunga("FUTA_", logfile_differentiator.." - MRK -> Not enough DMC -> "..FUTA_processors[hoo_arr_weeeeee][1][1])
		end
		--do same for all 6 crystal types, if we under 500 of any of them throw up a warning!
		if GetInventoryFreeSlotCount() > 19 and GetItemCount(10386) and GetItemCount(10335) then
			mrkMade = GetItemCount(10373)
			yield("/artisan lists "..FUTA_processors[hoo_arr_weeeeee][7][2].." start")
			--begin waiting for crafting to finish
			threetimes = 0
			while GetCharacterCondition(5) == true or threetimes < 3 do
				yield("/echo Waiting on artisan to finish what its doing....")
				zungazunga()
				yield("/wait 5")
				if GetCharacterCondition(5) == true then
					threetimes = 0 --reset it if we are still changing jobs in between
				end
				if GetCharacterCondition(5) == false then 
					threetimes = threetimes + 1 
				end
			end
			zungazunga()
			yield("/wait 5")
			zungazunga()
			yield("/wait 5")
			mrkMade = GetItemCount(10373) - mrkMade
			if dont_report_good_stuff == 0 then
				loggabunga("FUTA_", logfile_differentiator.." - MRK -> "..FUTA_processors[hoo_arr_weeeeee][1][1].." -> MRK made -> "..mrkMade)
			end
		end
	end
	
	----------------------------
	--PHV Personal House Visit--
	----------------------------
	--This should be done last--
	----------------------------
	if FUTA_processors[hoo_arr_weeeeee][9][2] > 0 then
		yield("/echo Personal House Visit counter Incremented by 1")
		FUTA_processors[hoo_arr_weeeeee][9][2] = 1 + FUTA_processors[hoo_arr_weeeeee][9][2]
		if FUTA_processors[hoo_arr_weeeeee][9][2] > FUTA_processors[hoo_arr_weeeeee][9][3] then
			FUTA_processors[hoo_arr_weeeeee][9][2] = 1
			yield("/li home")
			CharacterSafeWait()
			return_fc_entrance() --does the same thing just enters target
			open_house_door() --opens the door to house
			CharacterSafeWait()
			loggabunga("FUTA_", logfile_differentiator.." - Home Visit Executed by -> "..FUTA_processors[hoo_arr_weeeeee][1][1])
			zungazunga()
			FUTA_return() --return to configured location
		end
	end
end

--insert hacky stuff to fix some data for later
--fuel settings
--[[
if GetItemCount(10373) == 0 and FUTA_processors[hoo_arr_weeeeee][4][2] > -1 then
	FUTA_processors[hoo_arr_weeeeee][4][2] = 0
	FUTA_processors[hoo_arr_weeeeee][4][3] = 0
end
if FUTA_processors[hoo_arr_weeeeee][4][2] > -1 and GetItemCount(10373) > 0 then
	FUTA_processors[hoo_arr_weeeeee][4][2] = 666
	FUTA_processors[hoo_arr_weeeeee][4][3] = 6666
end
-]]

-- Stop beginning to do stuff
yield("/echo Debug: Finished all processing")
tablebunga(FUTA_config_file, "FUTA_processors", folderPath)
zungazunga()
yield("/echo onto the next one ..... ")

if equip_from_table == 1 then
	yield("/echo but wait let's double check our outfit")
	for i=1,#equip_teble do
		if GetItemCount(equip_teble[i])>0 then
			yield("/equipitem "..equip_teble[i])
			yield("/wait 3.5")
		end
			yield("/wait 0.1")
	end
end
yield("/vnav stop") --run case we running into wall at house
if wheeequeheeheheheheheehhhee == 1 then
	yield("/ays multi e") --if we had to toggle AR
end
--yield("/pcraft stop") --uncomment this if you want it to clear snd errors after script run
PauseYesAlready() --we dont need this unless we do then plugin/etc will turn it on - this is so that questionable x cbt doesn't break for seasonals