--[[
Generally Ordered Optimized Navigation.lua  (thanks for the idea fifi)
or "Something need Gooning"
thanks to @Akasha and @Ritsuko for some of the ideas/code

purpose: help autoduty with farming duties.
design: it will run 99 prae, and then run decumana until reset time (1 am PDT) and reset the counter and go back to farming prae.

Plugins/configs (ill update as people realize i forgot instructions)
Automaton (Now called CBT)
Some form of bossmod
Rotation Solver Reborn
Vnavmesh
Simpletweaks

Configurations (NOT OPTIONAL.  THEY ARE ABSOLUTELY MANDATORY)
Pandora -> actually have this disabled it causes problems.
Simpletweaks -> targeting fix
SND -> disable snd targeting + disable addon errors (everything under /target and /waitaddon)
AD -> Turn off "Leave Duty" and or change to leave only when duty is complete and not path complete

Yesalready configs (maybe only the first one is needed since the rest are done via callbacks w ya off) also make sure yesalready is on :p ad turns it off sometimes (???)
	"YesNo"
		Return to the starting point for the Praetorium?   ※You may be unable to re-enter ongoing battles.
		/Repair all displayed items for.*/
		/Exit.*/
	"Lists"
		/Retire to an inn room.*/

Enhanced Duty start/end
	duty start -> /pcraft run start_gooning
	duty end -> /ad stop
	leave duty -> 10 seconds
Use whatever path you want. but i reccommend the included path file for all party members. W2W Ritsuko etc.

recommended party:
war dps dps sch
for sch in RSR turn off adloquim, succor and physick

reccommend setup:
WAR SCH SMN/MCH MNK
or 
WAR SCH MCH MCH
or
BLU BLU BLU BLU or some combination of BST/BLU

(yeah right hahaha.)

random thoughts
I figured out how to get ad to do unsync+level sync
you first setup unsync+level sync . since it will never unhceck level sync. then tick unsync for regular duty prae
and then let goon do its thing
minor qol just to see the times in a nice chat window
--]]
yield("/echo please get ready for G.O.O.N ing time")
--yield("/bmrai ui") --open this in case we need to set the preset. at least until we can slash command it.

jigglecounter = 0
x1 = GetPlayerRawXPos()
y1 = GetPlayerRawYPos()
z1 = GetPlayerRawZPos()

stopcuckingme = 0    --counter for checking whento pop duty

--if its a cross world party everyone will make a queue attempt
function isLeader()
    return (GetCharacterName() == GetPartyMemberName(GetPartyLeadIndex()))
end

imthecaptainnow = 0  --set this to 1 if its the party leader

if isLeader() then 
	imthecaptainnow = 1 
	yield("/echo I am the party leader i guess")
end

-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
--------EDITABLE SETTINGS!---------------------------------------------------------------------------------------
duty_counter = 0	 --set it to 0 if its the first run of the "day"
					 --change this if you want to restart a "run" at a higher counter level becuase you were alreaday running it.
					 --just set it to whatever the last "current duty count" was from echos
					 --i.e. if you saw "This is duty # -> 17"  from the echo window , then set it to 17 before you resume your run for the day		 

feedme = 4745		 --itemID for food to eat. use simple tweaks ShowID to find it (turn it on and hover over item, it will be the number on the left in the square [] brackets)
feedmeitem = "Orange Juice"  --add the <hq> if its HQ
--feedmeitem = "Baked Eggplant<hq>"  --remove the <hq> if its not HQ

tornclothes = 25 --pct to try to repair at
finickyclothes = 0 --0 = dont auto equip, 1 = autoequip, useful if you have bis that isnt max level, default set to NOT equip so peopel can manage their BIS

--bm_preset = "AutoDuty" --if you set it to "none" it wont use bmr. this is for the preset to use.
bm_preset = "none" --if you set it to "none" it wont use bmr and instead it will use RSR. this is for the preset to use.

--debug/dont-touch-settings-unless-you-know-whats-up
itworksonmymachine = 0 --0 means use ad start (pre-select "regular" mode first in ad), 1 means use the callback and snd function method(s) for queueing into porta/prae.   it no longer works on my machine and i suspect it won't on others too haha
hardened_sock = 1200 		 --bailout from duty in 1200 seconds (20 minutes)
echo_level = 3 		 --3 only show important stuff, 2 show the progress messages, 1 show more, 0 show all
debug_counter = 0 --if this is >0 then subtract from the total duties . useful for checking for crashes just enter in the duty_counter value+1 of the last crash, so if you crashed at duty counter 5, enter in a 6 for this value
maxjiggle = 15 --how much default time (# of loops of the script) before we jiggle the char in prae
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------

--dont touch these ones
entered_duty = 0
equip_counter = 0
inprae = 0
maxzone = 0

function force_rotation()
	if bm_preset == "none" then
		yield("/bmrai setpresetname Deactivate") --turn off bm rotation
		yield("/rotation Auto")
	end

	if bm_preset ~= "none" then
		yield("/bmrai setpresetname "..bm_preset)
		yield("/bmrai followtarget on")
		yield("/bmrai follow Slot1")
		yield("/rotation Cancel") --turn off RSR in case it is on
	end
	
	yield("/bmrai on")
end

force_rotation()
--decide if we are going to bailout - logic stolen from Ritsuko <3
function leaveDuty()
    yield("/ad stop")
    while IsInZone(1044) do
        if IsAddonVisible("SelectYesno") then
            --yield("/click SelectYesno Yes")
			yield("/callback SelectYesno true 0")
        else
            yield("/leaveduty")
        end
        yield("/wait 2")
    end
    return
end

while 1 == 1 do
	yield("/wait 1.5") --the big wait. run the entire fucking script every ? seconds
	
--safe check ifs
if IsPlayerAvailable() then
if type(GetCharacterCondition(34)) == "boolean" and type(GetCharacterCondition(26)) == "boolean" and type(GetCharacterCondition(4)) == "boolean" then
--
	--decide if we are going to bailout - logic stolen from Ritsuko <3
	zoneleft = GetContentTimeLeft()
	if type(zoneleft) == "number" and zoneleft > 100 then
		if zoneleft > maxzone then
			maxzone = zoneleft
			--force_rotation() --refresh the rotationtype when we do this
		end
		inprae = maxzone - zoneleft
		if inprae > hardened_sock and GetCharacterCondition(26) == false then
			yield("/echo We bailed from duty -> "..duty_counter)
			NavRebuild()
			while not NavIsReady() do
				yield("/wait 1")
			end
			leaveDuty()
		end
	end

	if GetCharacterCondition(34) == false then yield("/callback SelectYesno true 0") end	--is there some bullshit and yesalready was disabled outside of the duty? 
	maxzone = 0--reset the timer for inside prae

	--Food check!
	statoos = GetStatusTimeRemaining(48)
	---yield("/echo "..statoos)
	if type(GetItemCount(feedme)) == "number" then
		if GetItemCount(feedme) > 0 and statoos < 90 and GetCharacterCondition(34) == false then --refresh food if we are below 15 minutes left
			yield("/item "..feedmeitem)
			yield("/echo Attempting to eat "..feedmeitem)
			yield("/wait 0.5")
		end
	end

	--Do we need repairs? only check outside of duty.
	--check every 0.3 seconds 8 times so total looop is 2.4 seconds
	goat = 0
	while goat < 9 and GetCharacterCondition(34) == false do
		goat = goat + 1
		yield("/wait 0.3")
		if GetCharacterCondition(34) == false then
			--SELF REPAIR
			local minicounter = 0
			--check if we even have g8dm, otherwise dont waste time, 10386 is g6dm if you wanna change it, 17837 is g7, 33916 is g8
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
				yield("/interact")
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
	--end safe check one
	end
	end
	--
	--safe check ifs part 2
	if IsPlayerAvailable() then
	if type(GetCharacterCondition(34)) == "boolean" and type(GetCharacterCondition(26)) == "boolean" and type(GetCharacterCondition(4)) == "boolean" then
	--

	--yield("/echo x diff"..math.abs(x1 - GetPlayerRawXPos()))
	--check if we are stuck somewhere.
	--first ensure we are in the duty and not in combat

	if GetZoneID() == 1044 and GetCharacterCondition(26) == false and IsPlayerAvailable() then --Praetorium
		maxjiggle = 6
		flurb = "????"
		for flurby = 1,30 do
			if IsPlayerAvailable() then
				if GetNodeText("_ToDoList", flurby, 3) == "Arrive at the command chamber: 0/1" then flurb = "Arrive at the command chamber: 0/1" end
				if GetNodeText("_ToDoList", flurby, 3) == "Clear the command chamber: 0/1" then flurb = "Clear the command chamber: 0/1" end
				if GetNodeText("_ToDoList", flurby, 3) == "Arrive at the Laboratorium Primum: 0/1" then flurb = "Arrive at the Laboratorium Primum: 0/1" end
				if GetNodeText("_ToDoList", flurby, 3) == "Clear the Laboratorium Primum: 0/1" then flurb = "Clear the Laboratorium Primum: 0/1" end
				if GetNodeText("_ToDoList", flurby, 3) == "Arrive on the Echelon: 0/1" then flurb = "Arrive on the Echelon: 0/1" end
				if GetNodeText("_ToDoList", flurby, 3) == "Defeat Gaius van Baelsar: 0/1" then flurb = "Defeat Gaius van Baelsar: 0/1" end
			end
			yield("/wait 0.3")
		end
		if flurb == "Clear the Laboratorium Primum: 0/1"  and GetCharacterCondition(26) == false and IsPlayerAvailable() then
			flurb = GetNodeText("_ToDoList", 25, 3)
--this doesnt work the way i intended so removing it for now.
			--[[yield("/target Shortcut")
			yield("/wait 0.5")
			yield("/target Nero")
			yield("/wait 0.5")
			if type(GetTargetName()) == "string" and GetTargetName() == "Shortcut" then
				yield("/ad stop")
				yield("/interact")
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
				yield("/wait 10")
				yield("/interact")
				yield("/bmrai on")
				yield("/rotation auto")
			end
			if type(GetTargetName()) == "string" and GetCharacterCondition(26) == false then
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
			end
			--]]
		end
		if flurb == "Arrive on the Echelon: 0/1"  and GetCharacterCondition(26) == false  and IsPlayerAvailable() then
			maxjiggle = 20
		end
	--safe check ifs part 3
	if IsPlayerAvailable() then
	if type(GetCharacterCondition(34)) == "boolean" and type(GetCharacterCondition(26)) == "boolean" and type(GetCharacterCondition(4)) == "boolean" then
	--
		if flurb == "Defeat Gaius van Baelsar: 0/1" and GetCharacterCondition(26) == false and GetCharacterCondition(34) == true and IsPlayerAvailable() then
			maxjiggle = 20
			yield("/target Magitek")
			yield("/wait 0.5")
			yield("/target Shortcut")
			yield("/wait 0.5")
			yield("/interact")
			yield("/hold W <wait.2.0>")
			yield("/release W")
			yield("/wait 0.5")
			yield("/interact")
			yield("/wait 0.5")
			if type(GetTargetName()) == "string" and GetTargetName() == "Shortcut" and GetCharacterCondition(26) == false and IsPlayerAvailable() then
				yield("/ad stop")
				yield("/interact")
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
				yield("/wait 10")
				yield("/interact")
				yield("/bmrai on")
				yield("/rotation auto")
			end
			if type(GetTargetName()) == "string" and GetCharacterCondition(26) == false and IsPlayerAvailable() then
				yield("/interact")
				yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
			end
			if type(GetTargetName()) ~= "string" and GetCharacterCondition(26) == false and IsPlayerAvailable() then
				yield("/wait 1.5")
				yield("/target Gaius")
				yield("/wait 1.5")
			end
		end
		--
		end
		end
		--
		if echo_level < 3 then yield("/echo Prae Duty Progress -> "..flurb) end
	end

	--1044 is prae we only need this there atm
	if GetZoneID() == 1044 then --Praetorium
	--if GetZoneID() == 1044 and not HasTarget() then
	--	TargetClosestEnemy(30)
	--end
			
	if GetCharacterCondition(34) == true and GetCharacterCondition(26) == false then
		if math.abs(x1 - GetPlayerRawXPos()) < 3 and math.abs(y1 - GetPlayerRawYPos()) < 3 and math.abs(z1 - GetPlayerRawZPos()) < 3 then
			if echo_level < 4 then yield("/echo we havent moved very much something is up ") end
			jigglecounter = jigglecounter + 1
		end
		if jigglecounter > maxjiggle and GetZoneID() == 1044 then --we stuck for 30+ seconds somewhere in praetorium
			if echo_level < 4 then yield("/echo attempting to restart AD and hope for the best") end
			jigglecounter = 0
			yield("/ad stop")
			yield("/wait 2")
			yield("/return")
			yield("/wait 1")
			yield("/callback SelectYesno true 0")
			yield("/wait 12")
			yield("/ad start")
			yield("/wait 2")
		end
	end
			
--[[
		local mytarget = GetTargetName()
		if type(mytarget) == "string" and mytarget ~= "Phantom Gaius" then
			local ndist = GetDistanceToObject(null)
			local gdist = GetDistanceToObject("Phantom Gaius")
			local deltadist = ndist - gdist
			if (deltadist > 1 or deltadist < -1) and gdist < 100 then
				if echo_level < 1 then yield("/echo targeting nearby enemy!") end
				TargetClosestEnemy()
				--yield("/vnav stop")
			end
		end
		--]]
	end
	--if GetCharacterCondition(34) == false then --fix autoqueue just shitting out
		--yield("/send U")
	--end
	
	if GetCharacterCondition(34) == true and GetCharacterCondition(26) == false then
		equip_counter = equip_counter + 1
		if equip_counter > 50 and finickyclothes == 1 then 
			yield("/equiprecommended")
			yield("/wait 0.5")
			equip_counter = 0
		end
		--TargetClosestEnemy()
		--yield("/ac \"Fester\"") --i dont think we need this.
	end
	if GetCharacterCondition(4) == true then --target stuff while on magitek if we don't thave a target. trying to fix this bullashit
		--if type(GetTargetName()) ~= "string" then
			TargetClosestEnemy()
			yield("/send KEY_2")
			yield("/wait 0.5")
		---end
	end

	if GetCharacterCondition(4) == false and GetCharacterCondition(26) == true then
		if type(GetTargetName()) ~= "string" then
			TargetClosestEnemy()
			--yield("/vnav stop")
			--yield("/ad pause")
			yield("/wait 0.5")
			--[[jigglecounter = 0 -- we reset the jiggle counter while we are in combat. combat is good means we are doing something productive
			if echo_level < 1 then yield("/echo stopping vnav for combat") end
			if echo_level < 1 then yield("/echo pausing AD for combat") end
			yield("/vnavmesh moveto "..GetTargetRawXPos().." "..GetTargetRawYPos().." "..GetTargetRawZPos())
			yield("/wait 5")
			yield("/vnav stop")
			yield("/wait 0.5")
			yield("/ad resume")
			if echo_level < 1 then yield("/echo resuming AD") end--]]
		end
	end
	
	if GetCharacterCondition(34) == true then
		x1 = GetPlayerRawXPos()
		y1 = GetPlayerRawYPos()
		z1 = GetPlayerRawZPos()
	end

	stopcuckingme = stopcuckingme + 1
	--autoqueue at the end because its least important thing
	if type(GetZoneID()) == "number" then
		zonecheck = GetZoneID()
		if not (zonecheck == 1044 or zonecheck == 1048) then
			entered_duty = 0
		end
		if (zonecheck == 1044 or zonecheck == 1048) and entered_duty == 0 then
			entered_duty = 1
			if (duty_counter < 20 and zonecheck ~= 1048) or zonecheck == 1044 or (zonecheck == 1048 and duty_counter > 98) then --don't count yesterday's last decumana in the counter!
				duty_counter = duty_counter + 1
			end
			if debug_counter == 0 then
				if echo_level < 4 then yield("/echo This is duty # -> "..duty_counter) end
			end
			if debug_counter > 0 then
				if echo_level < 4 then yield("/echo This is duty # -> "..duty_counter.." Runs since last crash -> "..(duty_counter-debug_counter)) end
			end
			
		end
	end
	if os.date("!*t").hour > 6 and os.date("!*t").hour < 8 and duty_counter > 20 then --theres no way we can do 20 prae in 1 hour so this should cover rollover from the previous day
		duty_counter = 0
		if echo_level < 4 then yield("/echo We are starting over the duty counter, we passed daily reset time!") end
	end
	if IsPlayerAvailable() then
		if stopcuckingme > 2 and GetCharacterCondition(34) == false and imthecaptainnow == 1 and (GetZoneID() == 177 or GetZoneID() == 178 or GetZoneID() == 179) and not NeedsRepair(tornclothes) then
			whoops = 0
			boops = 0
			did_we_clear_it = 0
			if itworksonmymachine == 1 or duty_counter == 99 or duty_counter == 0 then --we only have to clear the DF if we are clearing the DF, we should probably do it before switching to decu or back to prae
				yield("/finder")
				yield("/wait 0.5")
				while not IsAddonVisible("ContentsFinder") and whoops == 0 do
					yield("/waitaddon ContentsFinder")
					yield("/wait 0.5")
					boops = boops + 1
					if boops > 10 then whoops = 1 end
				end -- safety check before callback
				if IsAddonVisible("ContentsFinder") then did_we_clear_it = 1 end
				yield("/wait 1")
				yield("/callback ContentsFinder true 12 1")
				yield("/send ESCAPE")
			end
			--[[
			--first we must unselect the duty that is selected. juuust in case
			if GetNodeText("ContentsFinder", 14) == "The Praetorium" then
				yield("/callback ContentsFinder true 3 15")
			end
			if GetNodeText("ContentsFinder", 14) == "Porta Decumana" then
				yield("/callback ContentsFinder true 3 4")
			end
			--]]
			if echo_level < 2 then yield("/echo attempting to trigger duty finder") end
			--yield("/callback ContentsFinder true 12 1")
			if did_we_clear_it == 1 or itworksonmymachine == 0 then  --we need to make sure we cleared CF before we try to queue for something.
			whoops = 0
			boops = 0
				if duty_counter < 99 then
					--OpenRegularDuty(1044) --Praetorium	
					if echo_level < 3 then yield("/echo Trying to start Praetorium") end
					if itworksonmymachine == 0 then
						yield("/ad stop")
						yield("/wait 0.5")
						yield("/ad queue The Praetorium")
					end
					if itworksonmymachine == 1 then
						while not IsAddonVisible("ContentsFinder") and whoops == 0 do
							OpenRegularDuty(16) --Praetorium	
							yield("/waitaddon ContentsFinder")
							yield("/wait 0.5")
							boops = boops + 1
							if boops > 10 then whoops = 1 end
						end -- safety check before callback
						yield("/wait 3")
						yield("/callback ContentsFinder true 3 15")
					end
				end
				if duty_counter > 98 then
					if echo_level < 3 then yield("/echo Trying to start Porta") end
					if itworksonmymachine == 0 then
						yield("/ad stop")
						yield("/wait 0.5")
						yield("/ad queue Porta Decumana")
					end
					if itworksonmymachine == 1 then
						while not IsAddonVisible("ContentsFinder") and whoops == 0 do
							OpenRegularDuty(830) --Decumana
							yield("/waitaddon ContentsFinder")
							yield("/wait 0.5")
							boops = boops + 1
							if boops > 10 then whoops = 1 end
						end -- safety check before callback
						yield("/wait 3")
						--OpenRegularDuty(1048) --Decumana
						yield("/callback ContentsFinder true 3 4")
					end
				end
				yield("/callback ContentsFinder true 12 0")
				stopcuckingme = 0
			end
		end
	end

--safe check ends
end
end
---
end