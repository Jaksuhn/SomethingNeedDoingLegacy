 --[[
  Description: nothing to see here . garbage script
  Author: McVaxius
]]

--dont use this script its hot garbage and autoduty exists. im only updating it for personal use so just a reminder
--dont use this script its hot garbage and autoduty exists. im only updating it for personal use so just a reminder
--dont use this script its hot garbage and autoduty exists. im only updating it for personal use so just a reminder
--dont use this script its hot garbage and autoduty exists. im only updating it for personal use so just a reminder
--dont use this script its hot garbage and autoduty exists. im only updating it for personal use so just a reminder


--if you see --*
--this is a todo for some logic ill add sooner or later

--todo
--convert all variable sanity (type) checks into a generic function to reduce code clutter
--add in some check if we are doing trust/squad/DS and then follow an npc in party when in combat so we resolve stack markers

--we configure everything in a ini file.
--this way we can just copy paste the scripts and not need to edit the script per char

-- Function to load variables from a file
function loadVariablesFromFile(filename)
    local file = io.open(filename, "r")

    if file then
        for line in file:lines() do
            -- Remove single-line comments (lines starting with --) before processing
            line = line:gsub("%s*%-%-.*", "")
            
            -- Extract variable name and value
            local variable, value = line:match("(%S+)%s*=%s*(.+)")
            if variable and value then
                -- Convert the value to the appropriate type (number or string)
                value = tonumber(value) or value
                _G[variable] = value  -- Set the global variable with the extracted name and value
            end
        end

        io.close(file)
    else
        print("Error: Unable to open file " .. filename)
    end
end


-- Specify the path to your text file
-- forward slashes are actually backslashes.
--to use this find the arbitraryduty_McVaxius.ini file and rename it to arbitraryduty_Yourcharfirstlast.ini   notice no spaces.
--so if your character is named Pomelo Pup'per then you would call the .ini file   arbitraryduty_PomeloPupper.ini
--also be sure to update the folder name as per your preference
--just remember it will strip spaces and apostrophes
tempchar = GetCharacterName()
--tempchar = tempchar:match("%s*(.-)%s*") --remove spaces at start and end only
tempchar = tempchar:gsub("%s", "")  --remove all spaces
tempchar = tempchar:gsub("'", "")   --remove all apostrophes
local filename = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\arbitraryduty_"..tempchar..".ini"

-- Call the function to load variables from the file
loadVariablesFromFile(filename)

-- Now you can use the variables in your Lua script
--yield("/cl")

yield("/echo ATTEMPTING TO LOAD INI FILE if you dont see -> SUCCESSFULLY LOADED ALL VARS")
yield("/echo at the end of the next block of text.")
yield("/echo then you need to review the template to see if your missing something")

yield("/echo Character:"..GetCharacterName())
yield("/echo Filename+path:"..filename)
yield("/echo char_snake:"..char_snake)
yield("/echo enemy_snake:"..enemy_snake)
yield("/echo repeat_trial:"..repeat_trial)
yield("/echo repeat_type:"..repeat_type)
yield("/echo partymemberENUM:"..partymemberENUM)
yield("/echo dont_lockon:"..dont_lockon)
yield("/echo lockon_wait:"..lockon_wait)
yield("/echo snake_deest:"..snake_deest)
yield("/echo enemy_deest:"..enemy_deest)
yield("/echo meh_deest:"..meh_deest)
yield("/echo enemeh_deest:"..enemeh_deest)
yield("/echo limituse:"..limituse)
yield("/echo limitpct:"..limitpct)
yield("/echo limitlevel:"..limitlevel)
yield("/echo movetype:"..movetype)
yield("/echo LOOT_CHESTS?????:"..lootchests)
yield("/echo getout:"..getout)

yield("/echo SUCCESSFULLY LOADED ALL VARS")

--cleanup the variablesa  bit.  maybe well lowercase them later toohehe.
char_snake = char_snake:match("^%s*(.-)%s*$"):gsub('"', '')
enemy_snake = enemy_snake:match("^%s*(.-)%s*$"):gsub('"', '')

--see the .ini file for explanation on settings
--more comments at the end

--counter init
local repeated_trial = 0

--our current area
local we_are_in = 666
local we_were_in = 666

--placeholder for target location
local currentLocX = 1
local currentLocY = 1
local currentLocZ = 1

--our current location
local mecurrentLocX = GetPlayerRawXPos()
local mecurrentLocY = GetPlayerRawYPos()
local mecurrentLocZ = GetPlayerRawZPos()

--our current area
local we_are_in = 666
local we_were_in = 666
local chesttargeted = false

--declaring distance var
local dist_between_points = 500

local neverstop = true
local i = 0

--duty specific vars
local dutycheck = 0
local dutycheckupdate = 1

--arbitrary duty solver
local dutyloaded = 0
local dutyFile = "buttcheeks"
local doodie = {} --initialize table for waypoints
local whereismydoodie = 1 --position in doodie table
local customized_targeting = 0 -- this is for custom code for specific duties
local waitTarget = 0 --so we aren't spamming target search nonstop and breaking the WP system
local customized_behaviour = 0
local WPsearchcounter = 0 -- init counter
local WPsearchX = 1
local WPsearchY = 1
local WPsearchZ = 1
local cycleTime = 1 --how many seconds to wait between cycles. might move this to the .ini file later
local deathCounter = 0

if lootchests == 0 then
	yield("/fulf pass")
end
if lootchests > 0 then
	yield("/fulf need")
end

local function distance(x1, y1, z1, x2, y2, z2)
    -- Following block to error trap some issues when changing areas
    local success, x1_num = callback(tonumber, x1)
    if not success then yield("/echo Failed to convert x1: " .. tostring(x1) .. " to number") end

    local success, y1_num = callback(tonumber, y1)
    if not success then yield("/echo Failed to convert y1: " .. tostring(y1) .. " to number") end

    local success, z1_num = callback(tonumber, z1)
    if not success then yield("/echo Failed to convert z1: " .. tostring(z1) .. " to number") end

    local success, x2_num = callback(tonumber, x2)
    if not success then yield("/echo Failed to convert x2: " .. tostring(x2) .. " to number") end

    local success, y2_num = callback(tonumber, y2)
    if not success then yield("/echo Failed to convert y2: " .. tostring(y2) .. " to number") end

    local success, z2_num = callback(tonumber, z2)
    if not success then yield("/echo Failed to convert z2: " .. tostring(z2) .. " to number") end

	--[[yield("/echo x1_num: " .. tostring(x1_num))
	yield("/echo y1_num: " .. tostring(y1_num))
	yield("/echo z1_num: " .. tostring(z1_num))
	yield("/echo x2_num: " .. tostring(x2_num))
	yield("/echo y2_num: " .. tostring(y2_num))
	yield("/echo z2_num: " .. tostring(z2_num))]]

    local funmath = 42069420
    if type(y1_num) == "number" and type(x1_num) == "number" and type(z1_num) == "number" then
        if type(y2_num) == "number" and type(x2_num) == "number" and type(z2_num) == "number" then
            -- Calculate distance only if all inputs are numbers
            funmath = math.sqrt((x2_num - x1_num)^2 + (y2_num - y1_num)^2 + (z2_num - z1_num)^2)
        end
    end

    return funmath
end


local function interpolate(x1, y1, z1, x2, y2, z2, t)
    -- t is the parameter representing the percentage of the distance from (x1, y1, z1) to (x2, y2, z2)
    -- t should be a value between 0 and 1, where 0 represents (x1, y1, z1) and 1 represents (x2, y2, z2)
    local distance = math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
    local newX = x1 + (x2 - x1) * t
    local newY = y1 + (y2 - y1) * t
    local newZ = z1 + (z2 - z1) * t
    return newX, newY, newZ
end

-- Function to determine cardinal direction
local function getCardinalDirection(rotation)
    if (rotation >= -45 and rotation <= 45) or (rotation < -135 and rotation >= -180) or (rotation > 135 and rotation <= 180) then
        return "North"
    elseif rotation > 45 and rotation <= 135 then
        return "East"
    elseif rotation > -135 and rotation <= -45 then
        return "South"
    else
        return "West"
    end
end

-- random number function
local function getRandomNumber(min, max)
  return math.random(min,max)
end

function targetchests()
	if lootchests > 0 then
		PandoraSetFeatureConfigState("Auto-interact with Objects in Instances", "ExcludeExit", true) 
		chesttargeted = false
		if GetTargetName() == "Treasure Coffer" then chesttargeted = true end
		if string.len(GetTargetName()) == 0 or GetTargetName() == "Exit" or GetTargetName() == "Shortcut" or chesttargeted == true then
			yield("/target Chest")
			yield("/target \"Treasure Coffer\"")
			yield("/wait 0.5")	
			if chesttargeted == true then
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
				--yield("/autofollow")
				yield("/echo Chest ! -> "..GetTargetName())
	--			yield("/lockon")
	--			yield("/automove")
				yield("/rotation Cancel")
			end
		end
	end
	if lootchests == 0 then 
		PandoraSetFeatureConfigState("Auto-interact with Objects in Instances", "ExcludeExit", false) 
	end
end

--Wrapper to get nearest objectKind
--Returns name of closest objectKind
--Uses SND's targeting system
--Looks for enemies by default if looking for battlenpc
function TargetNearestObjectKind(objectKind, radius, subKind)
    local smallest_distance = 10000000000000.0
    local closest_target
    local radius = radius or 0
    local subKind = subKind or 5
    local nearby_objects = GetNearbyObjectNames(radius^2, objectKind)
    
    if nearby_objects.Count > 0 then
        for i = 0, nearby_objects.Count - 1 do
            yield("/target "..nearby_objects[i])
            if not GetTargetName() or nearby_objects[i] ~= GetTargetName()
                or (objectKind == 2 and subKind ~= GetTargetSubKind()) then
            elseif GetDistanceToTarget() < smallest_distance then
                smallest_distance = GetDistanceToTarget()
                closest_target = GetTargetName()
            end
        end
        ClearTarget()
        if closest_target then yield("/target "..closest_target) end
    end
    return closest_target
end

local function limitbreak()
	if limituse == 1 then --are we a limit break user? we will only trigger via script if we are a dps. however that value is pulled from the ini
		local which_one = 666 --pointless variable init
		which_one = GetClassJobId()
		if type(which_one) ~= "number" then  --error trap variable type because we dont like SND pausing
			which_one = 9000 --invalid job placeholder
		end
		local GetLimoot = 0 --init lb value. its 10k per 1 bar
		GetLimoot = GetLimitBreakCurrentValue()
		if type(GetLimoot) ~= "number" then  --error trap variable type because we dont like SND pausing
			GetLimoot = 0 --well its 0 if its 0
		end
		local local_teext = "\"Limit Break\""
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
end

local function setdeest()
	if currentLocX and currentLocY and currentLocZ and mecurrentLocX and mecurrentLocY and mecurrentLocZ then
		dist_between_points = distance(currentLocX, currentLocY, currentLocZ, mecurrentLocX, mecurrentLocY, mecurrentLocZ)
		-- dist_between_points will contain the distance between the two points
		--yield("/echo Distance between char_snake and point 1: " .. dist_between_points)
	else
		yield("/echo Failed to retrieve coordinates for one or both points.")
		dist_between_points = 500 -- default value haha
	end
end

--duty functions
local function load_duty_data()
	--tablestructure: visland OR vnavmesh (0, 1), x,y,z, wait at waypoint (seconds for /wait x) before /stop visland/vnavmesh, distance to be over to end waypoint if it was an area transition. default 0
	local file_path = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"..dutyFile
	local doodies = {}  -- Initialize an empty table
	if dutyFile ~= "buttcheeks" then
		yield("/echo Attempting to load -> "..file_path)
	    local file = io.open(file_path, "r")  -- Open the file in read mode
		if file then
			for line in file:lines() do  -- Iterate over each line in the file
				if line ~= "" then  -- Skip empty lines
					local row = {}  -- Initialize an empty table for each row
					for value in line:gmatch("[^,]+") do  -- Split the line by comma
						table.insert(row, value)  -- Insert each value into the row table
						--yield("/echo value "..value)
					end
					table.insert(doodies, row)  -- Insert the row into the main table
				end
			end
			file:close()  -- Close the file
			dutyloaded = 1
			return doodies  -- Return the loaded table
		else
			yield("/echo Error: Unable to open table file '" .. file_path .. "'")
			return nil
		end
	end
end

local function getmovetype(wheee)
	local funtimes = "vnavmesh"
	--yield("/echo DEBUG get move type for muuvtype -> "..wheee)
	if tonumber(wheee) == 0 then
		funtimes = "visland"
		yield("/echo DEBUG get move type for muuvtype -> SHOULD BE VISLAND")
	end
	return funtimes
end

local function dutyFileExists(dutyFile)
    local file = io.open(os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\"..dutyFile, "r")
    if file then
        io.close(file)
        return true
    else
        return false
    end
end

local function porta_decumana()
		if type(GetZoneID()) == "number" and GetZoneID() == 1048 then
			customized_targeting = 1
			yield("/target Ultima")
			if distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),GetTargetRawXPos(),GetTargetRawYPos(),GetTargetRawZPos()) > 2 then
					yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos()) --move to the target
			end
			--check the area number before doing ANYTHING this breaks other areas.
			--porta decumana ultima weapon orbs in phase 2 near start of phase
			--very hacky kludge until movement isn't slidy
			--nested ifs because we don't want to get locked into this
--[[
--COMMENTED OUT THIS ENTIRE SECTION SINCE WE HAVE PROPER VBM MODULE NOW		
		mecurrentLocX = GetPlayerRawXPos()
			mecurrentLocY = GetPlayerRawYPos()
			mecurrentLocZ = GetPlayerRawZPos()
			phase2 = distance(-692.46704, -185.53157, 468.43414, mecurrentLocX, mecurrentLocY, mecurrentLocZ)
			if dutycheck == 0 then
				--check our distance to target and get over there.
				if distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),GetTargetRawXPos(),GetTargetRawYPos(),GetTargetRawZPos()) > 2 then
					yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos()) --move to the target
				end
			end
			if dutycheck == 0 and dutycheckupdate == 1 and phase2 < 40 then
				--we in phase 2 boyo
				dutycheck = 1
			end
--			mecurrentLocX = GetPlayerRawXPos()
--			mecurrentLocY = GetPlayerRawYPos()
--			mecurrentLocZ = GetPlayerRawZPos()
			if dutycheckupdate == 1 and dutycheckupdate == 1 and type(GetDistanceToObject("Magitek Bit")) == "number" and GetDistanceToObject("Magitek Bit") < 50 then
				dutycheck = 0 --turn off this check
				dutycheckupdate = 0
			end
			if dutycheck == 1 and phase2 < 40 and GetDistanceToObject("The Ultima Weapon") < 40 then
				if partymemberENUM == 1 then
					--yield("/"..movetype.." moveto -692.46704 -185.53157 468.43414")
					yield("/"..movetype.." moveto -698.85711669922 -185.53157043457 485.63247680664")
				end
				if partymemberENUM == 2 then
					--yield("/"..movetype.." moveto -715.5604 -185.53159 468.4341")
					yield("/"..movetype.." moveto -708.22570800781 -185.53158569336 485.37371826172")
				end
				if partymemberENUM == 3 then
					--yield("/"..movetype.." moveto -715.5605 -185.53157 491.5273")
					yield("/"..movetype.." moveto -705.68145751953 -185.67491149902 478.03894042969")
				end
				if partymemberENUM == 4 then
					--yield("/"..movetype.." moveto -692.46704 -185.53159 491.52734")
					yield("/"..movetype.." moveto -698.59442138672 -185.53158569336 474.63607788086")
				end
				--yield("/wait 5") -- is this too long? we'll see!  maybe this is bad
			end
		--[[
		--on hold for now until movement isnt slide-time-4000
				if type(GetDistanceToObject("Aetheroplasm")) == "number" then
		--			if GetObjectRawXPos("Aetheroplasm") > 0 then
					if GetDistanceToObject("Aetheroplasm") < 20 then
						--yield("/wait 1")
						yield("/echo Porta Decumana ball dodger distance to random ball: "..GetDistanceToObject("Aetheroplasm"))
						yield("/visland stop")
						yield("/vnavmesh stop")
						--yield("/vbm cfg AI Enabled false")
						while type(GetDistanceToObject("Aetheroplasm")) == "number" and GetDistanceToObject("Aetheroplasm") < 20 do
							if partymemberENUM == 1 then
								yield("/visland moveto -692.46704 -185.53157 468.43414")
							end
							if partymemberENUM == 2 then
								yield("/visland moveto -715.5604 -185.53159 468.4341")
							end
							if partymemberENUM == 3 then
								yield("/visland moveto -715.5605 -185.53157 491.5273")
							end
							if partymemberENUM == 4 then
								yield("/visland moveto -692.46704 -185.53159 491.52734")
							end
							yield("/wait 5")			
						end
						yield("/visland stop")
						yield("/vnavmesh stop")
						--yield("/vbm cfg AI Enabled true")
					end
				end	
			]]
			-- ]] fake comment ending
	end
end

local function searchNearestWP()
	--WP file is loaded, we arent in combat and we are in a duty
	local searchPCT = 5
	if dutyloaded == 1 and GetCharacterCondition(26) == false and GetCharacterCondition(34) == true then
		--everything is normal reset the counter
		if ((math.abs(((WPsearchX - GetPlayerRawXPos())/WPsearchX)) * 100) > searchPCT or (math.abs(((WPsearchY - GetPlayerRawXPos())/WPsearchY)) * 100) > searchPCT or (math.abs(((WPsearchZ - GetPlayerRawXPos())/WPsearchZ)) * 100) > searchPCT) and WPsearchcounter > 0 then
			WPsearchcounter = 0
			WPsearchX = GetPlayerRawXPos()
			WPsearchY = GetPlayerRawYPos()
			WPsearchZ = GetPlayerRawZPos()
		end
		--we've entered into combat
		if GetCharacterCondition(26) == true and GetCharacterCondition(34) == true then
			WPsearchcounter = 0
			WPsearchX = GetPlayerRawXPos()
			WPsearchY = GetPlayerRawYPos()
			WPsearchZ = GetPlayerRawZPos()
		end
		if (math.abs(((WPsearchX - GetPlayerRawXPos())/WPsearchX)) * 100) < searchPCT and (math.abs(((WPsearchY - GetPlayerRawXPos())/WPsearchY)) * 100) < searchPCT and (math.abs(((WPsearchZ - GetPlayerRawXPos())/WPsearchZ)) * 100) < searchPCT then
			WPsearchcounter = WPsearchcounter + 1
			yield("/echo We are potentially stuck WPsearchcounter -> "..WPsearchcounter)
		end
		if WPsearchcounter > 10 then
			yield("This waypoint is defective/incorrect -> "..whereismydoodie)
			local tempsearchdist = 9000
			local tempstoredist = 0
			for i=2, #doodies do
				tempstoredist = distance(GetPlayerRawXPos(),GetObjectRawYPos(),GetObjectRawZPos(),doodies[i][2],doodies[i][3],doodies[i][4])
				if  tempstoredist < tempsearchdist then
					tempsearchdist = tempstoredist
					whereismydoodie = i
				end
			end
			yield("Found a closer waypoint -> "..whereismydoodie)
			WPsearchcounter = 0
		end
	end
end

local function arbitrary_duty()
	--just make it use the zoneID no more need to edit this script for it to work
	dutyFile = "whee.duty"
	if type(GetZoneID()) == "number" then
		dutyFile = GetZoneID()..".duty"
	end
	if dutyFile ~= "whee.duty" then
	--if we die:
		--wait 30 seconds then accept respawn (new counter var.. just in case we get a rez
		--maybe throw this as ini file configuration later
	if GetCharacterCondition(34) == true and IsPlayerDead()==false then
		deathCounter = 0
	end
	if GetCharacterCondition(34) == true and IsPlayerDead() then
		deathCounter = deathCounter + 1
	end
	if IsPlayerDead() and deathCounter > 30 and (dutyloaded == 1 or GetCharacterCondition(26) == false) then
		yield("/callback _Notification false 0 0 \"ed\" ")  --brings up the window if its closed for some reason
		yield("/callback SelectYesno true 0")
	end
	
	searchNearestWP() --just in case we stuck somewhere for 10 seconds + duty is loaded we will search for nearestWP
	
	if GetCharacterCondition(34) == true and dutyFileExists(dutyFile) then
		--if we haven't loaded a duty file. load it
		if dutyloaded == 0 and dutyFile ~= "buttcheeks" then --we take a doodie from a .duty file
			yield("/wait 5")
			doodie = load_duty_data()
			yield("/echo Waypoints loaded for this area -> "..#doodie)
		end
		local muuvtype = "wheeeeeeeeeeeeeeeeeeeee"
		--DEBUG xyz stuff
		--yield("/echo distance("..GetPlayerRawXPos()..","..GetPlayerRawYPos()..","..GetPlayerRawZPos()..","..doodie[whereismydoodie][2]..","..doodie[whereismydoodie][3]..","..doodie[whereismydoodie][4])
		local tempdist = 0
		--if whereismydoodie < (#doodie+1) then
		if whereismydoodie < (#doodie+1) then --maybe +1 is dangerous
			tempdist = distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),doodie[whereismydoodie][2],doodie[whereismydoodie][3],doodie[whereismydoodie][4])
			--if we are in combat stop navmesh/visland
			if GetCharacterCondition(26) == true and type(GetTargetName()) == "string" and string.len(GetTargetName()) > 1 then
				--yield("/visland stop")
				--yield("/vnavmesh stop")
				--yield("/automove off")
				--yield("/echo stopping nav cuz in combat")
				--conditionally stop nav for navmesh only........ then path to target if we are over 3 yalms away, this is a waypoint farming system after all.
				if PathIsRunning() then
					if distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),GetTargetRawXPos(),GetTargetRawYPos(),GetTargetRawZPos()) > 1 then
						yield("/echo Stopping Nav -> distance to target > 1")
						PathStop()
						yield("/wait 0.1")
						yield("/echo Sending player to target using navmesh")
						--yield("/"..muuvtype.." moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos()) --move to the target
						yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos()) --move to the target
						while PathIsRunning() and (tonumber(doodie[whereismydoodie][6])) == 0 do --wait for it to get there --update all movement in this script with this kind of logic... it will fix alot of bs i think.
							yield("/wait 0.1")
						end
					end
				end
				--check if we are farther than 3 yalms from group member 2 and try to move closer and that we aren't doing some kind of unsynced stuff (epic echo i guess. however that doesnt work so we will check for 0 hp (0))
				if distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),GetPlayerRawXPos(tostring(2)),GetPlayerRawYPos(tostring(2)),GetPlayerRawZPos(tostring(2))) > 3 and GetPartyMemberHP(0) ~= 0 then
					--yield("/"..muuvtype.." moveto "..GetPlayerRawXPos(tostring(2)).." "..GetPlayerRawYPos(tostring(2)).." "..GetPlayerRawZPos(tostring(2))) --move to the target
					yield("/vnavmesh moveto "..GetPlayerRawXPos(tostring(2)).." "..GetPlayerRawYPos(tostring(2)).." "..GetPlayerRawZPos(tostring(2))) --move to the target
					yield("/echo Gathering party up a bit during combat")
				end
			end
			if GetCharacterCondition(26) == false or string.len(GetTargetName()) == 0 then --we want waypoints to work even if someone else aggros stuff as we may not have a target yet. this might solve prae/meri shenanigans
				muuvtype = getmovetype(doodie[whereismydoodie][1]) --grab the movetype from the waypoint
				if target ~= doodie[whereismydoodie][7] then --dont get away from they keys and such
					yield("/"..muuvtype.." moveto "..doodie[whereismydoodie][2].." "..doodie[whereismydoodie][3].." "..doodie[whereismydoodie][4]) --move to the x y z in the waypoint
					yield("/echo No Combat - Regular NAV , WP -> "..whereismydoodie.." navtype -> "..muuvtype.." nav code -> "..doodie[whereismydoodie][1].."  current dist to objective -> "..tempdist)
					--yield("/echo No Combat - Regular NAV , DEBUG -> /"..muuvtype.." moveto "..doodie[whereismydoodie][2].." "..doodie[whereismydoodie][3].." "..doodie[whereismydoodie][4].."<-- line end")
				end
				if string.len(doodie[whereismydoodie][7]) > 1 then
					yield("/target "..doodie[whereismydoodie][7])
					yield("/wait 1")
				end
				if string.len(doodie[whereismydoodie][7]) > 1 and target == doodie[whereismydoodie][7] then
					yield("/"..muuvtype.." moveto "..GetObjectRawXPos(doodie[whereismydoodie][7]).." "..GetObjectRawYPos(doodie[whereismydoodie][7]).." "..GetObjectRawXPos(doodie[whereismydoodie][7])) --move to the x y z in the waypoint
					yield("/echo No Combat - Special Object NAV , WP -> "..whereismydoodie.." navtype -> "..muuvtype.." nav code -> "..doodie[whereismydoodie][1].."  current dist to objective -> "..tempdist)
				end
				yield("/automove off")	
			end
			--if we are <? yalms from waypoint, wait x seconds then stop visland/vnavmesh
			local skipcheck = 0 --this is important if we hit a chest node and we are skipping nodes we will skip the waypoint without processing the next one immediately
			if doodie[whereismydoodie][7] == 1 and lootchests == 0 then --if we are skipping chests then we skip the waypoint
				whereismydoodie = whereismydoodie + 1
				skipcheck = 1
			end
            
            --Use TargetNearestObjectKind() to look for treasure chests
            if lootchests == 2 and dutyloaded == 1 and GetCharacterCondition(26) == false then
				targetchests()
--[[
                TargetNearestObjectKind(6)
                if GetTargetName() then
                    while TargetNearestObjectKind(6) == GetTargetName() do
                        yield("/e Looking for chests...")
                        yield("/"..muuvtype.." moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos()) --move to the x y z in the waypoint
                        yield("/wait "..doodie[whereismydoodie][5])
                    end
                end
]]
            end
			--42069420 is the value that indicates distance() failed for some reason
			if (tempdist < 2 or (tonumber(doodie[whereismydoodie][6]) > 0 and tempdist > tonumber(doodie[whereismydoodie][6])) and skipcheck == 0) and tempdist ~= 42069420 then
				yield("/echo Onto the next waypoint! Current WP completed --> "..whereismydoodie)
				--check for npcs rq if its brayflox.
				if GetZoneID() == 1041 then
					yield("/targetnpc")
					yield("/wait 0.5")
					yield("/interact")
				end
				yield("/wait "..doodie[whereismydoodie][5])
				whereismydoodie = whereismydoodie + 1
				yield("/automove off")
				yield("/visland stop")
				yield("/vnavmesh stop")
			end	
		end
	end
	
	if GetCharacterCondition(26) == true then --fix sliding bug
		if getRandomNumber(1,5) == 1 then
			--move to the spot we are at to fix teh sliding bug
			yield("/vnavmesh moveto "..GetPlayerRawXPos().." "..GetPlayerRawYPos().." "..GetPlayerRawZPos())
			yield("/vnavmesh moveto "..GetPlayerRawXPos().." "..GetPlayerRawYPos().." "..GetPlayerRawZPos())
			yield("/vnavmesh moveto "..GetPlayerRawXPos().." "..GetPlayerRawYPos().." "..GetPlayerRawZPos())
		end
	end
	
	if type(we_are_in) == "number" and we_are_in == 1048 then --Porta Decumana
	--yield("/echo Decumana Check!")
		porta_decumana() --supposedly we don't need this anymore. lets find out -- actually we do need it
	end
	if type(GetZoneID()) == "number" and GetZoneID() == 445 then --Alexander 4 Normal
	--rotation manual because we dont want to change targets
		yield("/rotation Manual")
		if string.len(GetTargetName()) == 0 then
			yield("/target \"Right Foreleg\"")
			yield("/target \"Left Foreleg\"")
			yield("/target \"The Manipulator\"")
			yield("/target \"Panzer Doll\"")
		end
		if GetCharacterCondition(26) == true then --try to close distance to target while in combat
			if distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),GetTargetRawXPos(),GetTargetRawYPos(),GetTargetRawZPos()) > 2 then
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos()) --move to the target
			end			
		end
	end
	if type(GetZoneID()) == "number" and GetZoneID() == 584 then --Alexander 9 Savage
		--we need to start the fight with an auto attack so RS will do its thing
		yield("/target Refurb")
		yield("/wait 2")
		yield("/vbm cfg AI Enabled false")
		yield("/lockon")
	end
	if type(GetZoneID()) == "number" and GetZoneID() == 854 then --Eden 2 Savage
		--[[
		https://gamerescape.com/2019/07/17/ffxiv-shadowbringers-guide-edens-gate-descent/
		Dark fire III mechanics probably all we need
		The real challenge in this fight is coordinating the extended timers on spells from the “Spell-in-Waiting” ability the boss uses. 
		One easy trick to keep in mind, as a player with the “Dark Fire” AoE on you, is that if you have more then 5 seconds left on your extended 
		Fire count-down, you’re safe to stack, and should. At 5 seconds, when the icon above your head starts its count-down animation, scatter.
		]]
		--if we see basic dark fire >5 seconds get to center!
		--Dark Fire III
		--customized_targeting = 1
		yield("/vbm cfg AI Enabled false")
		--yield("/echo Turning AI Self Follow Off")
		yield("/wait 0.5")
		--yield("/vbmai off")
		customized_behaviour = 1
		local statoos = GetStatusTimeRemaining(1810) or 999
		if statoos == 999 then
			statoos = GetStatusTimeRemaining(2455) or 999
		end
		movetype = "visland"

		--[[--also unholy darkness tank stack go to middle
		if statoos < 999 and statoos > 5 or GetTargetActionID() == 15955 or GetTargetActionID() == 15956 then
			yield("/"..movetype.." 99.897399902344 0.0 102.01305389404")
			yield("/echo Dark Fire start or stack marker -> going to middle")
			yield("/echo Dark Fire start or stack marker -> going to middle")
			yield("/echo Dark Fire start or stack marker -> going to middle")
			yield("/wait 0.3")
		end
		--this will spread near end of dark fire 3 and when the slicey time happens at start and i think repeated later if dps is low
		if statoos < 7 or GetTargetActionID() == 1810 or GetTargetActionID() == 2455 then]]
		if getRandomNumber(1,10) == 1 then
			--if we see dark fire <6 seconds. get to clock positions!
			yield("/echo Dark Fire or spread slice -> going to Clock Spots")
			yield("/echo Dark Fire or spread slice -> going to Clock Spots")
			yield("/echo Dark Fire or spread slice -> going to Clock Spots")
			--yield("/visland stop")
			--yield("/vnavmesh stop")
			if partymemberENUM == 1 then
				yield("/"..movetype.." moveto 100.0659942627 0.0 105.06355285645")
			end
			if partymemberENUM == 2 then
				yield("/"..movetype.." moveto 94.064888000488 0.0 100.0080871582")
			end
			if partymemberENUM == 3 then
				yield("/"..movetype.." moveto 99.64151763916 0.0 92.986808776855")
			end
			if partymemberENUM == 4 then
				yield("/"..movetype.." moveto 104.58055877686 0.0 100.89888763428")
			end
			if partymemberENUM == 5 then
				yield("/"..movetype.." moveto 96.30509185791 0.0 96.319915771484")
			end
			if partymemberENUM == 6 then
				yield("/"..movetype.." moveto 95.438690185547 0.0 104.02600097656")
			end
			if partymemberENUM == 7 then
				yield("/"..movetype.." moveto 104.17021942139 0.0 104.16522216797")
			end
			if partymemberENUM == 8 then
				yield("/"..movetype.." moveto 103.32738494873 0.0 95.443405151367")
			end
			yield("/wait 0.3")
		end
		--figure out which side hand of erebos is on and get to that side so we don't get KB off platform
		--empty hate IDs: 15941,15942,15961,15962,22748
		--if GetObjectActionID("The Hand of Erebos") == 15941 or GetObjectActionID("The Hand of Erebos") == 15942 or GetObjectActionID("The Hand of Erebos") == 15961 or GetObjectActionID("The Hand of Erebos") == 15962 or GetObjectActionID("The Hand of Erebos") == 22748 then
		while IsObjectCasting("The Hand of Erebos") == true and type(IsObjectCasting("The Hand of Erebos")) == "boolean" do
			--yield("/visland stop")
			--yield("/vnavmesh stop")
			-- Get the rotation value
			local rrr = GetObjectRotation("The Hand of Erebos")
			-- Get the cardinal direction
			local cardinalDirection = "asdfasdfasdf"
			cardinalDirection = getCardinalDirection(rrr)
			yield("/echo cardinalDirection -> "..cardinalDirection.. " rotation -> "..rrr)
			--100.34774780273,0.0,118.00609588623
			--87.239952087402,0.0,101.13842010498
			--98.70711517334,0.0,83.799194335938
			--112.9762878418,0.0,103.01834106445
			if cardinalDirection == "West" then
				yield("/"..movetype.." moveto 100.34774780273 0.0 118.00609588623")
				yield("/echo moving weest")
			end
			if cardinalDirection == "North" then
				yield("/"..movetype.." moveto 87.239952087402 0.0 101.13842010498")
				yield("/echo moving neeerth")
			end
			if cardinalDirection == "East" then
				yield("/"..movetype.." 98.70711517334 0.0 83.799194335938")
				yield("/echo moving eaasst")
			end
			if cardinalDirection == "South" then
				yield("/"..movetype.." moveto 112.9762878418 0.0 103.01834106445")
				yield("/echo moving sooorth")
			end
			--figure out which side and just go over there maintaining same y,z or is it x,y
			--fuck it we pop kb immunity
			yield("/echo Empty Hate - MOVE TO THE HAND or use surecast/armslength")
			yield("/echo Empty Hate - MOVE TO THE HAND or use surecast/armslength")
			yield("/echo Empty Hate - MOVE TO THE HAND or use surecast/armslength")
			--[[
			yield("/echo Empty Hate - MOVE TO THE HAND - following party member 2 (the tank should be played manually)")
			yield("/echo Empty Hate - MOVE TO THE HAND - following party member 2 (the tank should be played manually)")
			yield("/echo Empty Hate - MOVE TO THE HAND - following party member 2 (the tank should be played manually)")
			yield("/visland stop")
			yield("/vnavmesh stop")]]
			yield("/ac \"Surecast\"")
			yield("/ac \"Arm's Length\"")
			yield("/ac \"Surecast\"")
			yield("/ac \"Arm's Length\"")
			yield("/ac \"Surecast\"")
			yield("/ac \"Arm's Length\"")
			yield("/ac \"Surecast\"")
			yield("/ac \"Arm's Length\"")
			yield("/wait 0.1")
		--end
		--if type(GetDistanceToObject("The Hand of Erebos")) == "number" and GetDistanceToObject("The Hand of Erebos") < 120 then
		--	local newX, newY, newZ = interpolate(GetPlayerRawXPos(), GetPlayerRawYPos(), GetPlayerRawZPos(), GetObjectRawXPos("The Hand of Erebos"), GetObjectRawYPos("The Hand of Erebos"), GetObjectRawZPos("The Hand of Erebos"), 0.95)
		--	yield("/"..movetype.." moveto "..GetPlayerRawXPos(tostring(2)).." "..GetPlayerRawYPos(tostring(2)).." "..GetPlayerRawZPos(tostring(2)).." ") 
		--	yield("/echo Empty Hate - MOVING NEAR THE HAND OF EREBOS - follow the player in 2nd slot of party list")
			--yield("/"..movetype.." "..newX.." "..newY.." "..newZ.." ")
			--yield("/echo -> "..movetype.." moveto "..newX.." "..newY.." "..newZ.."  The hand of Erebos is at -> "..GetObjectRawXPos("The Hand of Erebos").." "..GetObjectRawYPos("The Hand of Erebos").." "..GetObjectRawZPos("The Hand of Erebos"))
			--yield("/wait 5")
		end
	end
	if type(GetZoneID()) == "number" and GetZoneID() == 856 then --Eden 4 Savage
		--[[
		https://gamerescape.com/2019/07/18/ffxiv-shadowbringers-guide-edens-gate-sepulture/
		]]
	end
	--duty specific stuff
	if type(GetZoneID()) == "number" and GetZoneID() == 1036 then --Sastasha
		customized_targeting = 1
		if whereismydoodie < 7 then
			yield("/target aurelia")
			yield("/target Chopper")
		end
		if whereismydoodie < 3 then
			if getRandomNumber(1,10) == 1 then
				yield("/gaction jump")
			end
			if getRandomNumber(1,10) == 2 then
				yield("/send e")
			end
			if string.len(GetTargetName()) == 0 then
				yield("/target Giant Clam")
			end
		end
	end
	if type(GetZoneID()) == "number" and GetZoneID() == 1044 and GetCharacterCondition(4) then --Praetorium
		if string.len(GetTargetName()) == 0 then
			TargetClosestEnemy()
		end
		--[[
		local praedist = 500
		local praetargets = {
		"Magitek Colossus",
		"Cohort Eques",
		"Magitek Reaper",
		"Magitek Death Claw",
		"Magitek Vanguard H-1"
		}
		for i = 1, #praetargets do
			if string.len(GetTargetName()) == 0 and GetCharacterCondition(26) == true then --if something is whacking us but we dont have it targeted...!?!?!
				yield("/echo We are being attacked - attempting to catch a "..praetargets[i])
				praedist = distance(GetPlayerRawXPos(),GetPlayerRawYPos(),GetPlayerRawZPos(),GetObjectRawXPos(".praetargets[i].."),GetObjectRawYPos(".praetargets[i].."),GetObjectRawZPos(".praetargets[i].."))
				if praedist < 10 then
					yield("/target "..praetargets[i])
				end
			end
		end]] -- if TargetClosestEnemy works we don't need this commented out block anymore
		--will spam Photon Stream and auto lockon. eventually clear the garbage
		local magiwhee = 1128
			if getRandomNumber(1,2) == 1 then
				magiwhee = 1129
			end
		--this shit doesn't actualy work so well just use lasers for now ;\
		--if partymemberENUM == 2 or partymemberENUM == 4 or partymemberENUM == 6 or partymemberENUM == 8 then
		--	magiwhee = 1128 --big buum
		--	magiwhee = 1129 --lasers
		--end
		yield("/lockon on") --need this for various stuff hehe.
		yield("/gaction jump") --just in case
--			yield("/automove")
		yield("/send q")
		yield("/wait 0.3")
--			yield("/automove stop")
--		ExecuteAction(magiwhee)
		yield("/send KEY_2")
		yield("/wait 0.5")
--			yield("/automove")
		yield("/send w")
		yield("/wait 0.3")
--		ExecuteAction(magiwhee)
		yield("/send KEY_2")
		yield("/wait 0.5")
--		ExecuteAction(magiwhee)
		yield("/send KEY_2")
		yield("/wait 0.5")
--			yield("/automove stop")
		yield("/send e")
		yield("/wait 0.3")
--		ExecuteAction(magiwhee)
		yield("/send KEY_2")
		yield("/wait 0.5")
--		ExecuteAction(magiwhee)
		yield("/send KEY_2")
		yield("/wait 0.5")
	end
end
end

yield("/echo starting.....")
yield("/echo Turning AI On")
yield("/wait 0.5")
yield("/vbm cfg AI Enabled true")
yield("/echo Turning AI Self Follow On")
yield("/wait 0.5")
yield("/vbmai on")
yield("/bmrai on")

while repeated_trial < (repeat_trial + 1) do
	--yield("/echo get limoooot"..GetLimitBreakCurrentValue().."get limootmax"..GetLimitBreakBarCount() * GetLimitBreakBarValue()) --debug for hpp. its bugged atm 2024 02 12 and seems to return 0
    if GetCharacterCondition(34)==true and GetCharacterCondition(26)==false and customized_targeting == 0 and string.len(GetTargetName())==0 then 
		yield("/targetenemy") --this will trigger RS to do stuff. this is also kind of spammy in the text box. how do i fix this so its not spammy?
		--TargetClosestEnemy() --this is really bad it targets through walls and floors
	end
    if GetCharacterCondition(34)==true and GetCharacterCondition(26)==true and string.len(GetTargetName()) > 0 then 
		if type(GetTargetHPP()) == "number" and GetTargetHPP() > 95 then
			yield("/ac provoke")
		end
		--try to use a tank gap closer
			yield("/ac Intervene")
			yield("/ac Onslaught")
			yield("/ac Plunge")
			yield("/ac Primal Rend")
			yield("/ac Rough Divide")
	end

	--[[
 --this is fully broken atm as it just kind of hangs everything and keeps trying to target stuff
    if GetCharacterCondition(34)==true and GetCharacterCondition(26)==false and customized_targeting == 0 and string.len(GetTargetName())==0 then 
		waitTarget = waitTarget + 1
		if waitTarget > 10 then
			TargetNearestObjectKind(2) --Find nearest battlenpc 
			waitTarget = 0
		end
	end
	]]
	--some other spams.
	--the command "targetnenemy" is unavailable at this time
	--unable to execute command while occupied
	--unable to execute command while mounted
	if enemy_snake ~= "nothing" and string.len(GetTargetName())==0 and type(GetObjectRawXPos(enemy_snake)) == "number" then --check if we are forcing a target or not
		yield("/target "..enemy_snake) --this will trigger RS to do stuff.
		currentLocX = GetTargetRawXPos()
		currentLocY = GetTargetRawYPos()
		currentLocZ = GetTargetRawZPos()
	end
	if char_snake ~= "no follow" and char_snake ~= "party leader" then --follow mode loc
		currentLocX = GetPlayerRawXPos(tostring(char_snake))
		currentLocY = GetPlayerRawYPos(tostring(char_snake))
		currentLocZ = GetPlayerRawZPos(tostring(char_snake))
	end
	--yield("Target x y z "..currentLocX.." "..currentLocY.." "..currentLocZ)
	mecurrentLocX = GetPlayerRawXPos()
	mecurrentLocY = GetPlayerRawYPos()
	mecurrentLocZ = GetPlayerRawZPos()
	
	limitbreak() --by the power of hydaelyn i smite thee
	
	if GetCharacterCondition(34)==false and char_snake == "party leader" then --if we are not in a duty --try to restart duty
		yield("/rotation Cancel")
		yield("/visland stop")
		yield("/vnavmesh stop")
		yield("/wait 2")
		yield("/echo We seem to be outside of the duty.. let us enter!")
		--reset this so we can sneak in a config change before ending script
		PandoraSetFeatureConfigState("Auto-interact with Objects in Instances", "ExcludeExit", false) 
		--yield("/wait 15")	
		yield("/wait 5")
		if repeat_type == 0 then --4 Real players (or scripts haha) using duty finder
			yield("/finder")
			yield("/echo attempting to trigger duty finder")
			yield("/callback ContentsFinder true 12 0")
		end
		if repeat_type == 1 then --just you using duty support
			--("/callback DawnStory true 20") open the window.. how?
			--we use simpletweaks
			yield("/maincommand Duty Support")
			yield("/wait 2")
			--yield("/echo attempting to trigger duty support")
			--yield("/callback DawnStory true 11 0") --change tab to first tab
			--yield("/callback DawnStory true 12 35")--select port decumana
			--yield("/wait 2")
			yield("/callback DawnStory true 14") --START THE DUTY
		end
		if repeat_type == 2 then --just you using GC Squad guy
			yield("/target Sergeant")
			yield("/wait 1")
			yield("/interact")
			yield("/callback SelectString true 1 <wait.1>")
			--*TBD once i get char up to test strings with
		end
	
		yield("/echo Total Trials triggered for "..char_snake..": "..repeated_trial)
		yield("/wait 10")
	end
	
	--if we are not in combat AND we are in a duty then we will look for an exit or shortcut. also test if we loaded a wp file and didnt finish or if we didnt
	if GetCharacterCondition(26)==false and GetCharacterCondition(34)==true then
		--we dont need to manually exit. automaton can do that now
		--we will manually exit anyways becuase we need to walk by treasure chests in some duties and trials
		--also we will take the exit near the last waypoint and not the one near the entrance.........
		if chesttargeted == false then
			yield("/wait 5")
		end
		targetchests()
		if chesttargeted == false then
			--if type(GetDistanceToObject("Exit")) == "number" and GetDistanceToObject("Exit") < 100 and GetDistanceToObject("Exit") > 0 and getout == 1 and (dutyloaded == 0 or (dutyloaded == 1 and whereismydoodie == #doodie)) then
			if getout == 1 and string.len(GetTargetName()) == 0 then
				yield("/target Exit")
				yield("/target Shortcut")
			end
			--if type(GetDistanceToObject("Shortcut")) == "number" and GetDistanceToObject("Shortcut") < 80 and GetDistanceToObject("Shortcut") > 0 then
			if getout == 1 and string.len(GetTargetName()) == 0 then
			end
		end

		yield("/wait 0.1")
		if GetTargetName()=="Exit" or GetTargetName()=="Shortcut" then --get out ! assuming pandora setup for auto interaction
			local minicounter = 0
			--repair snippet stolen from https://github.com/Jaksuhn/SomethingNeedDoing/blob/master/Community%20Scripts/Gathering/DiademReentry_Caeoltoiri.lua
			--check if we even have g8dm, otherwise dont waste time
			if GetItemCount(33916) > 0 then
				if NeedsRepair(99) then
					yield("/wait 10")
					while not IsAddonVisible("Repair") do
					  yield("/generalaction repair")
					  yield("/wait 1")
					  minicounter = minicounter + 1
					  if minicounter > 20 then
						minicounter = 0
						break
					  end
					end
					yield("/callback Repair true 0")
					yield("/wait 0.1")
					if IsAddonVisible("SelectYesno") then
					  yield("/callback SelectYesno true 0")
					  yield("/wait 1")
					end
					while GetCharacterCondition(39) do yield("/wait 1")
					yield("/wait 1")
					yield("/callback Repair true -1")
					  minicounter = minicounter + 1
					  if minicounter > 20 then
						minicounter = 0
						break
					  end
					end
				end
			end
			if whereismydoodie > #doodie then
				yield("/visland stop")
				yield("/wait 0.1")
				yield("/vnavmesh stop")
				yield("/wait 0.1")
			end
			--double check target type here. shortcuts are a a-ok goto always.
			if GetTargetName()=="Shortcut" then
				--yield("/lockon on")
				--yield("/automove on")
				yield("/vnavmesh moveto "..GetObjectRawXPos("Shortcut").." "..GetObjectRawYPos("Shortcut").." "..GetObjectRawZPos("Shortcut"))
				yield("/wait 10")
				searchNearestWP() --update the waypoint . we just used a shorcut!
			end
			if GetTargetName()=="Exit" then
				local zempdist = 0
				if dutyloaded == 1 then
					zempdist = distance(GetObjectRawXPos("Exit"),GetObjectRawYPos("Exit"),GetObjectRawZPos("Exit"),doodie[#doodie][2],doodie[#doodie][3],doodie[#doodie][4])
				end
				if dutyloaded == 0 or (dutyloaded == 1 and whereismydoodie >= #doodie) then --if we didnt load a waypoint file we don't care about which exit it is
					--yield("/lockon on")
					--yield("/automove on")
					--replaced above with navmesh to exit
					yield("/vnavmesh moveto "..GetObjectRawXPos("Exit").." "..GetObjectRawYPos("Exit").." "..GetObjectRawZPos("Exit"))
					booxit = 0
					while booxit < 10 do
						yield("/wait 1")
						yield("/interact")
						booxit = booxit + 1
					end
				end
			end
		end
	end
	--test dist to the intended party leader
	if GetCharacterCondition(34)==true then --if we are in a duty
		--call the waypoint system if we are wanting to from the .ini file
		arbitrary_duty() --this is the big boy
		
		--regular movement to target
		if customized_behaviour == 0 and char_snake ~= "no follow" and char_snake ~= "party leader" and enemy_snake == "nothing" then --close gaps to party leader only if we are on follow mode
			setdeest()
			if dist_between_points > snake_deest and dist_between_points < meh_deest then
					--yield("/visland moveto "..currentLocX.." "..currentLocY.." "..currentLocZ) --sneak around when navmesh being weird
					yield("/"..movetype.." moveto "..currentLocX.." "..currentLocY.." "..currentLocZ)
					--yield("/echo vnavmesh moveto "..math.ceil(currentLocX).." "..math.ceil(currentLocY).." "..math.ceil(currentLocZ))
					--DEBUG echo
					--yield("/echo player follow distance between points: "..dist_between_points.." enemy deest"..enemy_deest.." char deest :"..snake_deest)
			end
		end
		if customized_behaviour == 0 and enemy_snake ~= "nothing" and dutycheck == 0 then --close gaps to enemy only if we are on follow mode
			setdeest()
			if dist_between_points > enemy_deest and dist_between_points < enemeh_deest then
					--yield("/visland moveto "..currentLocX.." "..currentLocY.." "..currentLocZ)
					yield("/"..movetype.." moveto "..currentLocX.." "..currentLocY.." "..currentLocZ)
					--yield("/echo vnavmesh moveto "..math.ceil(currentLocX).." "..math.ceil(currentLocY).." "..math.ceil(currentLocZ))
			end
		end
		--yield("/echo distance between points: "..dist_between_points.." snake_deest"..snake_deest.." meh_deest :"..meh_deest)
	end
	--test dist to the intended party leader
	i = 0
	if GetCharacterCondition(28)==true then --if we are bound by qte
		if GetCharacterCondition(29)==true then --if we are bound by qte
			while i < 150 do
				i = i + 1
				--yield("/send SPACE")
				yield("/gaction jump")
				yield("/gaction jump")
				yield("/wait 0.1")
				if GetCharacterCondition(28)==false then --if we are not bound by qte get out of the space bar spamming so we can resume following or whatever
					i = 150
				end
			end
		end
	end
	--check if we chagned areas or just wait as normal
	we_are_in = GetZoneID() --where are we?
	if type(we_are_in) ~= "number" then
		we_are_in = we_were_in --its an invalid type so lets just default it and wait 10 seconds
		yield("/echo invalid type for area waiting 10 seconds")
		yield("/wait 10")
	end
	if we_are_in ~= we_were_in then
		yield("/rotation auto") --we need to turn this on here so rotations work
		yield("/"..movetype.." stop")
		yield("/wait 1")
		yield("/"..movetype.." stop")
		yield("/wait 1")
		--if GetCharacterCondition(34) == true and char_snake ~= "no follow" then --only trigger rebuild in a duty and when following a party leader
		if GetCharacterCondition(34) == true then --only trigger rebuild in a duty and when following a party leader
			if char_snake == "party leader" then
			    yield("/vbmai on")
				yield("/bmrai on")
				repeated_trial = repeated_trial + 1
			end
		end
		yield("/echo trial has begun!")
		--reset duty specific stuff. can make smarter checks later but for now just set the duty related stuff to 0 so it doesn't get "in the way" of stuff if you aren't doing that specific duty.
		dutycheck = 0 --by default we aren't going to stop things because we are in a duty
		dutycheckupdate = 1 --sometimes we don't want to update dutycheck because we reached phase 2 in a fight.
		we_were_in = we_are_in --record this as we are in this area now
	end
	if GetCharacterCondition(34) == true and GetCharacterCondition(26) == false and GetTargetName()~="Exit" then --if we aren't in combat and in a duty
		--yield("/equipguud") --this is super annoying and not needed
		yield("/vbmai on")
		yield("/bmrai on")
		yield("/rotation auto")
		--only party leader will do cd 5 because otherwise its spammy
		if char_snake == "party leader" then
			if GetCharacterCondition(26) == false and GetCharacterCondition(34) == true and string.len(GetTargetName()) > 0 then
				targetchests() --just in case we finished the duty
				if chesttargeted == false then
					yield("/cd 5")
				end
			end
		end
		yield("/send KEY_1")  --* huge fucking problem if its bound to anything but some kind of attack. maybe this hsould be default attack on?
		yield("/action Auto-attack")
		--yield("/wait 10")
		dutycheck = 0 --by default we aren't going to stop things because we are in a duty
		dutycheckupdate = 1 --sometimes we don't want to update dutycheck because we reached phase 2 in a fight.
	end
	--if we arent in a duty - force disable / reset some duty stuff
	if GetCharacterCondition(34) == false then
		dutyloaded = 0
		dutytoload = "buttcheeks"
		whereismydoodie = 1
		customized_targeting = 0
		customized_behaviour = 0
		yield("/rotation Cancel")
	end
	yield("/wait "..cycleTime) --the entire fuster cluck is looping at this rate
end