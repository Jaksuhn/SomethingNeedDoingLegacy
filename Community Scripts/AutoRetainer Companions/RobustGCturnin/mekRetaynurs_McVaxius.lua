--[[
mek retaynurs

-------What does it do?-------------
assuming you have all the plogons and did the yesalready configs.
it will magically buy 2 lv1 fishing rods, make 2 retainers with a name API for the names. do the retainer venture unlock quest and then run back to the vocate to finish and be ready for you to 1 click and add weapons.
---------------------

config. 
you need navmesh, pandora, teleporter, lifestream, somethingeeddoing, textadvance, yesalready, simpletweaks, rotation solver reborn
and yesalready. setup yesalready to auto accept any purchases from npcs ;o
also assumes limsa start and quests.
please have aleport teleport unlocked you lazy bum

tested pretty hard :~D it is 6 minutes run time from start to finish


CONFEEGOOORASHUNS
CONFEEGOOORASHUNS
CONFEEGOOORASHUNS
CONFEEGOOORASHUNS
CONFEEGOOORASHUNS
CONFEEGOOORASHUNS
for now requires you to be in limsa and have a combat job preferrably over 45
--simpletweaks config -> targeting fix
--snd -> turn off snd targeting

--Yesalready configs
-- -> will be lots once i get around to it

--[[
Yes Already configs
order is important for the lists in particular.
purpose of this yes alredy is so that you can click the retainer in list and boom it goes to inventory and you just right click eqiup to retainer on the rod. very fast

>>>>>>>LISTS<<<<<<<**********
Assign retainer class.
View retainer attributes and gear. (No main arm equipped)
Fisher.
Hire a retainer.
Polite.


>>>>>>>YESNO<<<<<<<**********
====CLICK YES=====
Hire this retainer?
/Hire the services of.*/
Finalize your retainer's appearance?
Hire a retainer?
/will become a fisher. Are you certain you wish to proceed?.*/
Purchase 1 weathered fishing rod for 74 gil?
====CLICK NO=====
Load previously saved appearance data?
/Save appearance data.*/
]]


function visland_stop_moving()
 yield("/equipguud")
 yield("/equiprecommended")
 yield("/character")
 yield("/callback Character true 15")
 yield("/wait 0.5")
 yield("/callback SelectYesno true 0")
 yield("/character")
 yield("/callback Character true 15")
 yield("/callback SelectYesno true 0")
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
 yield("/echo movement stopped safely - script proceeding to next bit")
 yield("/visland stop")
 yield("/vnavmesh stop")
 yield("/wait 3")
end

-- Function to replace accented letters with their regular versions
function remove_accents(s)
    local accent_map = {
        ['á']='a', ['à']='a', ['â']='a', ['ä']='a', ['ã']='a', ['å']='a',
        ['é']='e', ['è']='e', ['ê']='e', ['ë']='e',
        ['í']='i', ['ì']='i', ['î']='i', ['ï']='i',
        ['ó']='o', ['ò']='o', ['ô']='o', ['ö']='o', ['õ']='o',
        ['ú']='u', ['ù']='u', ['û']='u', ['ü']='u',
        ['ç']='c', ['ñ']='n',
        ['Á']='A', ['À']='A', ['Â']='A', ['Ä']='A', ['Ã']='A', ['Å']='A',
        ['É']='E', ['È']='E', ['Ê']='E', ['Ë']='E',
        ['Í']='I', ['Ì']='I', ['Î']='I', ['Ï']='I',
        ['Ó']='O', ['Ò']='O', ['Ô']='O', ['Ö']='O', ['Õ']='O',
        ['Ú']='U', ['Ù']='U', ['Û']='U', ['Ü']='U',
        ['Ç']='C', ['Ñ']='N'
    }
    return (s:gsub("[áàâäãåéèêëíìîïóòôöõúùûüçñÁÀÂÄÃÅÉÈÊËÍÌÎÏÓÒÔÖÕÚÙÛÜÇÑ]", function(c)
        return accent_map[c]
    end))
end

-- Function to convert the string to the desired format
-- Function to truncate the string to 19 characters
function truncate_to_19(s)
	s = remove_accents(s)
    if #s > 19 then
        return s:sub(1, 19)
    else
        return s
    end
end


--buy 2 rods
yield("/vnavmesh moveto -246.67446899414 16.199998855591 41.268531799316")
visland_stop_moving()
yield("/target Syneyhil")
yield("/wait 2")
yield("/interact")
yield("/wait 2")
yield("/callback SelectIconString true 1 <wait.2>")
yield("/callback SelectString true 0 <wait.2>")
yield("/callback Shop true 0 4 1 <wait.1.0>")  --the 1 on the end is quantity i thnk we can do 2, but i dont wanna mess with that
yield("/callback Shop true 0 4 1 <wait.1.0>")
yield("/callback Shop true -1 <wait.1.0>")
visland_stop_moving()

--get to vocate and mek 2 retainers.
	yield("/vnavmesh moveto -146.021484375 18.212013244629 17.593742370605")
	visland_stop_moving()
function mekkitnaow()
	yield("/target Frydwyb")
	yield("/wait 2")
	yield("/interact")
	yield("/wait 10") -- give it some time to reach the retainer screen.
	--yield("/callback _CharaMakeProgress true 0 1 0 Elezen 2")
	yield("/callback _CharaMakeProgress true -13 -1")
	yield("/callback _CharaMakeProgress true 0 0 0 Hyur 1")
	yield("/callback _CharaMakeProgress true -16 1")
	--this is where it fails. it does not click the checkbox to continue. we stop for now ;p
	yield("/callback _CharaMakeFeature false 100") -- confirm to next step
end

function nemmitnaow()
	--generate a name using a free API because we are creatively bankrupt and caught in youtube genjutsu
	-- Function to extract first and last names from JSON string
	function extractNames(jsonString)
		local first_name = jsonString:match('"first"%s*:%s*"([^"]+)"')
		local last_name = jsonString:match('"last"%s*:%s*"([^"]+)"')
		return first_name, last_name
	end

	nemmy = "Woahtherebucko"

	-- Function to execute a Lua script fetched from a URL using curl
	function executeScriptFromURL(url)
		-- Command to fetch the data using curl
		local command = string.format('curl -s "%s"', url)

		-- Open a pipe to read the output of the command
		local pipe = io.popen(command)

		-- Read the output of the command (the data)
		local data = pipe:read("*a")
		pipe:close()

		-- Extract first and last names
		local first_name, last_name = extractNames(data)

		-- Output the names
		if first_name and last_name then
			yield("/echo `First Name: " .. first_name .. ", Last Name: " .. last_name .. "`")
			nemmy = first_name.."'"..string.lower(last_name)
			nemmy = truncate_to_19(nemmy)
			yield("/echo attempting to use --> "..nemmy)
		else
			yield("/echo `Failed to extract names.`")
		end
	end

	-- API URL
	apiUrl = "https://randomuser.me/api/"

	-- Execute the script to fetch and print the JSON response from the API URL
	executeScriptFromURL(apiUrl)

	yield("/wait 10") -- give it some time to leave the retainer screen.
	yield("/callback InputString true 0 "..nemmy.." ") -- Hire this retainer?
end

mekkitnaow() --retainer 1
yield("/wait 5")
while IsAddonVisible("InputString") do
	nemmitnaow()
	yield("/wait 10") -- give it some time to leave the naming screen
end
yield("/wait 5")
mekkitnaow() --retainer 2
yield("/wait 5")
while IsAddonVisible("InputString") do
	nemmitnaow()
	yield("/wait 10") -- give it some time to leave the naming screen
end


--now we need to reach the troubled adventurer and hookup the retainer ventures quest
yield("/vnavmesh moveto -107.00193786621 18.000331878662 -0.36875337362289")
visland_stop_moving()
yield("/target Troubled Adventurer")
yield("/wait 2")
yield("/interact")
yield("/wait 10") -- give it some time to clean itself of filthy dialogue and such

yield("/tp Aleport")
yield("/wait 15") -- give it some time to TP
visland_stop_moving()

--fire up chocobo 
if GetBuddyTimeRemaining() < 900 and GetItemCount(4868) > 0 then
	yield("/visland stop")
	yield("/vnavmesh stop")
	yield("/item Gysahl Greens")
	yield("/wait 3")
end

yield("/vnavmesh moveto 248.72131347656 -11.946593284607 98.499946594238")
visland_stop_moving()
yield("/rotation auto")
yield("/target Murderous Mantis")
yield("/wait 2")
goatshart = 1
floatblart = 0
while goatshart == 1 do
	if GetCharacterCondition(26) == false then
		floatblart = floatblart + 1
		if floatblart > 3 then
			goatshart = 0
		end
		if GetCharacterCondition(26) == true then
			floatblart = 0
		end
	end
	yield("/target dusk bat")
	yield("/target hedgemole")
	yield("/target Murderous Mantis")
	yield("/wait 1") -- give it some time to process combat
end
yield("/rotation cancel")

--ok threat is gone
visland_stop_moving()
yield("/target Novice Retainer")
yield("/wait 2")
yield("/interact")
visland_stop_moving()
yield("/target Novice Retainer")
yield("/wait 2")
yield("/interact")
yield("/wait 10")
visland_stop_moving()

yield("/tp Limsa")
yield("/wait 15") -- give it some time to TP
visland_stop_moving()
--get back to the vocate and sortout the retainers
yield("/vnavmesh moveto -146.021484375 18.212013244629 17.593742370605")
visland_stop_moving()
yield("/target Frydwyb")
yield("/wait 2")
yield("/interact")
yield("/wait 10") -- give it some time to reach the retainer screen.

--[[
--for reference: ->
--SLURPE's original script:

local retainerName = "-nine"
local retainerNumber = 2
local retainerNameText = ""
function setup(retainerNumber,saveFileName,saveNumber,personality)

retainerNameText = saveFileName .. retainerName
yield("/e "..retainerNameText)

yield("/target Frydwyb")
yield("/wait 1")
yield("/interact")
yield("/wait 1")

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectString") 

yield("/callback SelectString true 0") -- Hire a retainer

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectYesno") 

yield("/callback SelectYesno true 0") -- Hire a retainer Yes/No

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectYesno") 

yield("/callback SelectYesno true 0") -- Load char


repeat
  yield("/wait 0.1")
until IsAddonVisible("CharaMakeDataImport") 
yield("/callback CharaMakeDataImport true 102 "..saveNumber.." false") -- select first file 0 first 1 second


repeat
  yield("/wait 0.1")
until IsAddonVisible("_CharaMakeFeature") 

yield("/callback _CharaMakeFeature false 100") -- confirm to next step

repeat
  yield("/wait 0.1")
until IsAddonVisible("CharaMakeDataExport") 

yield("/callback CharaMakeDataExport true 101 "..saveNumber.." ".. saveFileName) -- save to first file

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectOk") 

yield("/callback SelectOk true 0") -- ok

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectYesno") 

yield("/callback SelectYesno true 0") -- Finalize your retainer's appearance?

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectString") 

yield("/callback SelectString true "..personality) -- select first one polite, Rough, Serious, Carefree, Independent, Lively, Nothing

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectYesno") 

yield("/callback SelectYesno true 0") -- Hire this retainer?

repeat
  yield("/wait 0.1")
until IsAddonVisible("InputString") 

yield("/callback InputString true 0 "..retainerNameText.." ") -- Hire this retainer?
yield("/e "..retainerNameText)

repeat
  yield("/wait 0.1")
until IsAddonVisible("SelectYesno") 

yield("/callback SelectYesno true 0")

end

function retainerOne()

local saveFileName = "nameOfFirstRetainer"
local saveNumber = 0  -- 0 (first file) 1 (second file) 2 (third file) 3 (fourth file)
local personality = 0   -- 0 polite, 1 Rough, 2 Serious, 3 Carefree, 4 Independent, 5 Lively, 6 Nothing

setup(retainerNumber,saveFileName,saveNumber,personality)
end

function retainerTwo()

local saveFileName = "nameOfSecondRetainer"
local saveNumber = 1  -- 0 (first file) 1 (second file) 2 (third file) 3 (fourth file)
local personality = 1   -- 0 polite, 1 Rough, 2 Serious, 3 Carefree, 4 Independent, 5 Lively, 6 Nothing

setup(retainerNumber,saveFileName,saveNumber,personality)

end


if retainerNumber == 1 then
  retainerOne()
elseif retainerNumber == 2 then
  retainerTwo()
end
  ]]