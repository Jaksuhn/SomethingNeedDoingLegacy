--[[
    Name: GatheringHelper
    Description: General gathering node recorder and movement script for MIN/BTN
    Author: LeafFriend, plottingCreeper (food and repair)
    Version: 0.1.5 GITHUB
    Needed Plugins: vnavmesh, Pandora
    Needed Plugin Settings: Pandora Quick Gather enabled

    <Usage>
    1. Change settings as wanted
    2. Run script in lua
    3. Find gathering nodes when starting or when prompted
    4. Script will register found nodes and go back to them after visiting all of them once

    <Changelog>
    0.1.5   - Added workaround for not Closing the Distance when diving
            - Implemented Medicine and Manual usage similar to Food usage
            - Fixed addon checking for spearfishing
            - Added MaterializeDialog check to remove YesAlready reliance
            - Rewrote addon condition checking to use timeouts and addon visibility instead of IsPlayerAvailable()
            - Edited reporting for class checking when Triangulate/Fanthom/Prospect is active and not on their respective class to include instructions to carry on
            - Replaced /pcall with /callback
    0.1.4.1 - Implemented Prospect/Triangulate/Fathom status checks
            - Implemented node name whitelist
            - Implemented Island Sanctuary compatibility
    0.1.4   - Corrected search function, implemented with generalised TargetNearestObjectKind()
            - Added functionality to ping, includes known undetected nodes when pinging to nodes_went
            - Implement rate-limiting Id_Print()
            - Updated IPC 31/03/2024
            - Implement distance-based mounting before moving to next node
            - Added verbose and truncate settings
            - Implement Diadem aetheromatic auger usage
            - Implement randomised wait time
            - Implement spiritbond checking/materia extraction
            - Fixed movement issues when diving
            - Implement aetherial reduction
            - Change timeouts to properly check time passed
            - Implement automated enabling of SND settings and reversion
    0.1.3.4 - Implemented enhanced search function with GetNearbyObjectNames()
            - Properly accounted for diving in NodeMoveFly()
    0.1.3.3 - Added Ephemeral nodes to table of node names
    0.1.3.2 - Handle condition when diving for vnavmesh movement
    0.1.3.1 - Properly implement zone change script termination implementation
    0.1.3   - Implemented class checker to wipe found_nodes if class is changed and prompt if not DoL
            - Implemented food check before homing into found gathering node
            - Implemented gear condition checking
            - Implemented dislodging if char stuck in position moving
            - Implemented script termination if zone change is detected
    0.1.2   - Optimised node traversal
            - Re-enabled truncation for readbility
            - Removed lockon
            - Implemented dislodging if not moving
            - Implemented calling of collectable script if gathering collectables
            - Implemented script termination if inventory free slot threshold reached
    0.1.1   - Implemented NodeMoveFly to determine whether to use /vnavmesh moveto or /vnavmesh flyto
    0.1     - Initial Version

    <TODO>
    - More Optimisation, eventually...
    -- Use plottingCreeper's MoveNear()
    - Implement node checker to wipe found_nodes if gathered item is not gatherable from current node
    - Implement better dislodgement logic
--]]

--Settings
---General Consumables Settings
consume_threshold = 10                                  --Maximum number of seconds to check if food is consumed

---Food Settings
food_to_eat = "Yakow Moussaka <hq>"                     --Name of the food you want to eat, in quotes (ie. "[Name of food]"), or
                                                        --Table of names of the foods you want to eat (ie. {"[Name of food 1]", "[Name of food 2]"}), or
                                                        --Set false otherwise.
                                                        --Include <hq> if high quality. (i.e. "[Name of food] <hq>") DOES NOT CHECK ITEM COUNT YET
                                                        --If a food buff is not up, script will parse through table until there is a named food to eat


--Medicine Settings
medicine_to_use = "Superior Spiritbond Potion <hq>"     --Name of the medicine you want to use, in quotes (ie. "[Name of medicine]"), or
                                                        --Table of names of the medicine you want to use (ie. {"[Name of medicine 1]", "[Name of medicine 2]"}), or
                                                        --Set false otherwise.
                                                        --Include <hq> if high quality. (i.e. "[Name of medicine] <hq>") DOES NOT CHECK ITEM COUNT YET
                                                        --If a medicine buff is not up, script will parse through table until there is a named medicine to use

--Manual Settings
manual_to_read = "Squadron Spiritbonding Manual"        --Name of the manual you want to read, in quotes (ie. "[Name of manual]"), or
                                                        --Table of names of the manual you want to read (ie. {"[Name of manual 1]", "[Name of manual 2]"}), or
                                                        --Set false otherwise.
                                                        --DOES NOT CHECK ITEM COUNT YET
                                                        --Script will parse through all manuals in the table and read said manual if the corresponding buff is not up
                                                        --ONLY SUPPORTS MANUALS THAT GIVES A EQUALLY NAMED STATUS OR GATHERER'S GRACE

---Repair/Materia Settings
do_repair   = "self"                                    --false, "npc" or "self". Add a number to set threshhold; "npc 10" to only repair if under 10%
do_extract  = true                                      --Set true or false to extract materia
do_reduce   = true                                      --Set true or false to perform aetherial reduction

---Gathering logic Settings
num_inventory_free_slot_threshold = 1                   --Max number of free slots to be left before stopping script
interval_rate = 0.1                                     --Seconds to wait for each action
msgDelay = 3                                            --Seconds to wait to reprint the same message
ping_radius = 100                                       --Radius of the gathering node search

do_fly = true                                           --If true, will mount if distance to next node is greater than max_distance_to_walk [Might not work in Island Sanctuary]
min_distance_to_dismount = 10                           --Minimum distance before dismounting while travelling to gathering node
max_distance_to_walk = 30                               --Maximum distance to node, to walk to instead of to fly to
max_distance_to_interact = 3                            --Maximum distance to gathering point to attempt to interact with

timeout_threshold = 3                                   --Maximum number of seconds script will attempt to wait before timing out and continuing the script
moving_timeout_threshold = 20                           --Maximum number of seconds script will wait during movement sections before assuming it is stuck and attempt to dislodge itself

time_to_wait_after_gather = 1                           --Seconds to wait after finishing gathering and before looking for the next gathering node
time_to_wait_after_dislodge = 1                         --Seconds to wait after attempting to dislodge
max_random_wait_addon = 3                               --Max number of seconds to add onto waits

whitelist = {}                                          --List of gathering node names to only search and gather from
add_first_node_to_empty_whitelist = false               --If true, will add the first node's name to initially empty whitelist to avoid gathering from other node types

--Diadem specific Settings
diadem_whitelist = {}                                   --List of gathering node names to only search and gather from in Diadem
diadem_moving_timeout_threshold = 30                    --Maximum number of seconds script will wait before assuming it is stuck in Diadem and attempt to dislodge itself
diadem_range_to_target = 10                             --Maximum range to target use auger in Diadem
diadem_auger_crystals = true                            --If true, will auger Corrupted Sprites

--Island Sanctuary specific Settings
sanctuary_whitelist = {"Island Apple Tree"}             --List of gathering node names to only search and gather from in Island Sanctuary
sanctuary_moving_timeout_threshold = 30                 --Maximum number of seconds script will wait before assuming it is stuck in Diadem and attempt to dislodge itself

---Collectables Settings
collectables_script_name = "AutoCollectables_SingleRun" --Name of collectables script in SND to run when collectable UI is detected

---Debug/Display settings
verbose = false                                         --if true, prints additional statements
truncate = false                                        --if true, truncates node coordinates displayed to 1dp

--diadem_gather_script_name = "DiademNodeGather"          --Name of gathering script in SND to run when in Diadem


--Helper functions
function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

function SetLength(set)
    local count = 0
    for _,_ in pairs(set) do
        count = count + 1
    end
    return count
end

function AddToSet(set, key)
    set[key] = true
end

function RemoveFromSet(set, key)
    set[key] = nil
end

function SetContains(set, key)
    return set[key] ~= nil
end

function PrintSet(set, label)
    local next = next
    if next(set) ~= nil then
        Id_Print("["..label.."] Set:", verbose, true)
        for k,_ in pairs(found_nodes) do
            Id_Print("["..label.."] "..tostring(k), verbose, true)
        end
    end
end

function Queue(list)
    local queue = {}
    return {first = 0, last = -1}
end

function IsQueue(struct)
    return struct.first ~= nil and struct.last ~= nil
end

function QueueIsEmpty(queue)
    return queue.first > queue.last
end

function QueueLength(queue)
    local count = 0
    for _,_ in pairs(queue) do
        count = count + 1
    end
    return count - 2
end

function QueuePush(queue, value)
    local last = queue.last + 1
    queue.last = last
    queue[last] = value
end

function QueuePop(queue)
    local first = queue.first
    if first > queue.last then error("queue is empty") end
    local value = queue[first]
    queue[first] = nil        -- to allow garbage collection
    queue.first = first + 1
    return value
end

function QueueContains(queue, value)
    local first = queue.first
    if first > queue.last then return false end
    for _,v in pairs(queue) do
        if v == value then return true end
    end
    return false
end

function PrintQueue(queue, label)
    local next = next
    if next(queue) ~= nil then
        Id_Print("["..label.."] Queue:", verbose, true)
        for k,v in pairs(queue) do
            Id_Print("["..label.."] k: "..tostring(k)..", v: "..tostring(v), verbose, true)
        end
    end
end

function Split (inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

--Global Variable Initialisation
found_nodes = Set{}
nodes_went = Queue{}
current_target = ""
last_node_gathered = ""
last_job_id = 0
stop_main = false
start_pos = ""

--Wrappers & Functions

--Prints given string into chat with script identifier
function Id_Print(string, print, debug)
    local time = -msgDelay
    if print == nil then print = true end
    if debug == nil then debug = false end
    print_history = print_history or Set{}
    script_start = script_start or os.clock()

    if debug then
        LogDebug("[GatheringHelper] [DEBUG] "..string)
        return
    end


    for k,_ in pairs(print_history) do
        entry = Split(k, "_")
        if entry and time < tonumber(entry[1]) and entry[2] == string then
            time = tonumber(entry[1])
        end
    end

    if print and os.clock() - script_start >= time + msgDelay then
        yield("/echo [GatheringHelper] "..string)
        AddToSet(print_history, (os.clock() - script_start).."_"..string)
    end
end

--Returns given number truncated to 1 decimal place
function Truncate1Dp(num)
    return truncate and ("%.1f"):format(num) or num
end

--Wrapper for class checking, node names to gather from and return current job_id
function ClassCheck()
    if GetZoneID() == 1055 then return end
    local job_id = GetClassJobId()
    local empty_found_nodes = false

    local repeat_check = false
    repeat
        job_id = GetClassJobId()
        repeat_check = false

        if job_id == 16 then     --MIN
            for _,status in pairs({"Prospect"}) do
                if not HasStatus(status) then
                    Id_Print('"'..status..'" is NOT active! Enable "'..status..'" to continue')
                    empty_found_nodes = true
                    repeat_check = true
                end
            end
            for _,status in pairs({"Triangulate", "Fathom"}) do
                if HasStatus(status) then
                    Id_Print('"'..status..'" is active! Disable "'..status..'" to continue...')
                    empty_found_nodes = true
                    repeat_check = true
                end
            end
        elseif job_id == 17 then --BTN
            for _,status in pairs({"Triangulate"}) do
                if not HasStatus(status) then
                    Id_Print('"'..status..'" is NOT active! Enable "'..status..'" to continue')
                    empty_found_nodes = true
                    repeat_check = true
                end
            end
            for _,status in pairs({"Prospect", "Fathom"}) do
                if HasStatus(status) then
                    Id_Print('"'..status..'" is active! Disable "'..status..'" to continue...')
                    empty_found_nodes = true
                    repeat_check = true
                end
            end
        elseif job_id == 18 then --FSH
            for _,status in pairs({"Fathom"}) do
                if not HasStatus(status) then
                    Id_Print('"'..status..'" is NOT active! Enable "'..status..'" to continue')
                    empty_found_nodes = true
                    repeat_check = true
                end
            end
            for _,status in pairs({"Prospect", "Triangulate"}) do
                if HasStatus(status) then
                    Id_Print('"'..status..'" is active! Disable "'..status..'" to continue...')
                    empty_found_nodes = true
                    repeat_check = true
                end
            end
        else                     --Not a gatherer
            repeat_check = true
            empty_found_nodes = true
            Id_Print("Not a Disciple of Land!")
            Id_Print("Change class to continue script.")
        end

        yield("/wait "..interval_rate)
    until not repeat_check

    if empty_found_nodes then
        found_nodes = Set{}
        Id_Print("Forgotten all found nodes...")
        whitelist_set = Set(ZoneBasedWhitelist())
        Id_Print("Remembering initial whitelist...")
    end
    return job_id
end

--Wrapper for eating food, and if want to consume, consume if not fooded
function EatFood()
    if type(food_to_eat) ~= "string" and type(food_to_eat) ~= "table" then return end
    if GetZoneID() == 1055 then return end

    if not HasStatus("Well Fed") then
        local timeout_start = os.clock()
        local user_settings = {GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"), GetSNDProperty("StopMacroIfCantUseItem")}
        SetSNDProperty("UseItemStructsVersion", "true")
        SetSNDProperty("StopMacroIfItemNotFound", "false")
        SetSNDProperty("StopMacroIfCantUseItem", "false")
        repeat
            if type(food_to_eat) == "string" then
                Id_Print("Attempt to eat " .. food_to_eat)
                yield("/item " .. food_to_eat)
            elseif type(food_to_eat) == "table" then
                for _, food in ipairs(food_to_eat) do
                    Id_Print("Attempting to eat " .. food, verbose)
                    yield("/item " .. food)
                    yield("/wait " .. math.max(interval_rate, 1))
                    if HasStatus("Well Fed") then break end
                end
            end

            yield("/wait " .. math.max(interval_rate, 1))
        until HasStatus("Well Fed") or os.clock() - timeout_start > consume_threshold
        SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
        SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
        SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
    end
end

--Wrapper for using medicine, and if want to consume, consume if not medicated
function UseMedicine()
    if type(medicine_to_use) ~= "string" and type(medicine_to_use) ~= "table" then return end
    if GetZoneID() == 1055 then return end

    if not HasStatus("Medicated") then
        local timeout_start = os.clock()
        local user_settings = {GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"), GetSNDProperty("StopMacroIfCantUseItem")}
        SetSNDProperty("UseItemStructsVersion", "true")
        SetSNDProperty("StopMacroIfItemNotFound", "false")
        SetSNDProperty("StopMacroIfCantUseItem", "false")
        repeat
            if type(medicine_to_use) == "string" then
                Id_Print("Attempt to use " .. medicine_to_use)
                yield("/item " .. medicine_to_use)
            elseif type(medicine_to_use) == "table" then
                for _, medicine in ipairs(medicine_to_use) do
                    Id_Print("Attempting to use " .. medicine, verbose)
                    yield("/item " .. medicine)
                    yield("/wait " .. math.max(interval_rate, 1))
                    if HasStatus("Medicated") then break end
                end
            end

            yield("/wait " .. math.max(interval_rate, 1))
        until HasStatus("Medicated") or os.clock() - timeout_start > consume_threshold
        SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
        SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
        SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
    end
end

--Wrapper for reading manuals, and if want to consume, consume if not read
function ReadManual()
    if type(manual_to_read) ~= "string" and type(manual_to_read) ~= "table" then return end
    if GetZoneID() == 1055 then return end

    local function HandleManual(manual_title)
        if string.find(string.lower(manual_title), "rationing") ~= nil then return end --Do not process Rationing Manuals

        if not (HasStatus(manual_title) or (HasStatus("Gatherer's Grace") and SetContains(Set{"Company-issue Survival Manual", "Company-issue Survival Manual II", "Commercial Survival Manual", "Revised Survival Manual"}, manual_title))) then
            local timeout_start = os.clock()
            local user_settings = {GetSNDProperty("UseItemStructsVersion"), GetSNDProperty("StopMacroIfItemNotFound"), GetSNDProperty("StopMacroIfCantUseItem")}
            SetSNDProperty("UseItemStructsVersion", "true")
            SetSNDProperty("StopMacroIfItemNotFound", "false")
            SetSNDProperty("StopMacroIfCantUseItem", "false")
            repeat
                Id_Print("Attempt to read " .. manual_title)
                Dismount()
                yield("/item " .. manual_title)
                repeat
                    yield("/wait " .. math.max(interval_rate, 1))
                until not IsPlayerCasting()
            until HasStatus(manual_title) or (HasStatus("Gatherer's Grace") and SetContains(Set{"Company-issue Survival Manual", "Company-issue Survival Manual II", "Commercial Survival Manual", "Revised Survival Manual"}, manual_title)) or os.clock() - timeout_start > consume_threshold
            SetSNDProperty("UseItemStructsVersion", tostring(user_settings[1]))
            SetSNDProperty("StopMacroIfItemNotFound", tostring(user_settings[2]))
            SetSNDProperty("StopMacroIfCantUseItem", tostring(user_settings[3]))
        end
    end

    if type(manual_to_read) == "string" then
        HandleManual(manual_to_read)
    elseif type(manual_to_read) == "table" then
        for _, manual in ipairs(manual_to_read) do HandleManual(manual) end
    end

end

--Wrapper to handle stopping vnavmesh movement
function StopMoveFly()
    PathStop()
    while PathIsRunning() do
        yield("/wait "..interval_rate)
    end
end

--Wrapper to handle vnavmesh Movement
function NodeMoveFly(node, force_moveto)
    local force_moveto = force_moveto or false
    local x = tonumber(ParseNodeDataString(node)[2]) or 0
    local y = tonumber(ParseNodeDataString(node)[3]) or 0
    local z = tonumber(ParseNodeDataString(node)[4]) or 0
    last_move_type = last_move_type or "NA"

    CheckNavmeshReady()
    start_pos = Truncate1Dp(GetPlayerRawXPos())..","..Truncate1Dp(GetPlayerRawYPos())..","..Truncate1Dp(GetPlayerRawZPos())
    if not force_moveto and ((GetCharacterCondition(4) and GetCharacterCondition(77)) or GetCharacterCondition(81)) then
        last_move_type = "fly"
        PathfindAndMoveTo(x, y, z, true)
    else
        last_move_type = "walk"
        PathfindAndMoveTo(x, y, z)
    end
    while PathfindInProgress() do
        Id_Print("[VERBOSE] Pathfinding from "..start_pos.." to "..PrintNode(node).." in progress...", verbose)
        yield("/wait "..interval_rate)
    end
    Id_Print("[VERBOSE] Pathfinding complete.", verbose)
end

--Wrapper to dismount
function Dismount()
    if GetCharacterCondition(77) then
        local random_j = 0
        ::DISMOUNT_START::
        CheckNavmeshReady()

        local land_x
        local land_y
        local land_z
        local i = 0
        while not land_x or not land_y or not land_z do
            land_x = QueryMeshPointOnFloorX(GetPlayerRawXPos() + math.random(0, random_j), GetPlayerRawYPos() + math.random(0, random_j), GetPlayerRawZPos() + math.random(0, random_j), false, i)
            land_y = QueryMeshPointOnFloorY(GetPlayerRawXPos() + math.random(0, random_j), GetPlayerRawYPos() + math.random(0, random_j), GetPlayerRawZPos() + math.random(0, random_j), false, i)
            land_z = QueryMeshPointOnFloorZ(GetPlayerRawXPos() + math.random(0, random_j), GetPlayerRawYPos() + math.random(0, random_j), GetPlayerRawZPos() + math.random(0, random_j), false, i)
            i = i  + 1
        end
        NodeMoveFly("land,"..land_x..","..land_y..","..land_z)


        local timeout_start = os.clock()
        repeat
            yield("/wait "..interval_rate)
            if os.clock() - timeout_start > timeout_threshold then
                Id_Print("Failed to navigate to dismountable terrain.")
                Id_Print("Trying another place to dismount...")
                random_j = random_j + 1
                goto DISMOUNT_START
            end
        until not PathIsRunning()

        yield('/gaction "Mount Roulette"')

        timeout_start = os.clock()
        repeat
            yield("/wait "..interval_rate)
            if os.clock() - timeout_start > timeout_threshold then
                Id_Print("Failed to dismount.")
                Id_Print("Trying another place to dismount...")
                random_j = random_j + 1
                goto DISMOUNT_START
            end
        until not GetCharacterCondition(77)
    end
    if GetCharacterCondition(4) then
        yield('/gaction "Mount Roulette"')
        repeat
            yield("/wait "..interval_rate)
        until not GetCharacterCondition(4)
    end
end

--Wrapper to mount and fly
function MountFly()
    if not HasFlightUnlocked() or not do_fly then return end
    StopMoveFly()
    while not GetCharacterCondition(4) do
        yield('/gaction "Mount Roulette"')
        repeat
            yield("/wait "..interval_rate)
        until not IsPlayerCasting() and not GetCharacterCondition(57)
    end
    if not GetCharacterCondition(81) and GetCharacterCondition(4) and not GetCharacterCondition(77) then
        repeat
            yield('/gaction "Jump"')
            yield("/wait "..interval_rate)
        until GetCharacterCondition(77) and not GetCharacterCondition(48)
    end
end

--Wrapper for repair/materia/aetherial reduction check, return true if repaired and extracted materia
function RepairExtractReduceCheck()
    if GetZoneID() == 1055 then return true end
    local repair_threshold
    function IsNeedRepair()
        if type(do_repair) ~= "string" then
            return false
        else
            repair_threshold = tonumber(string.gsub(do_repair, "%D", "")) or 99
            if NeedsRepair(tonumber(repair_threshold)) then
                if string.find(string.lower(do_repair), "self") then
                    return "self"
                else
                    return "npc"
                end
            else
                return false
            end
        end
    end

    local repair_token = IsNeedRepair()
    if repair_token then
        if repair_token == "self" then
            StopMoveFly()
            if GetCharacterCondition(4) then
                Id_Print("Attempting to dismount...")
                Dismount()
            end
            Id_Print("Attempting to self repair...")
            while not IsAddonVisible("Repair") and not IsAddonReady("Repair") do
                yield('/gaction "Repair"')
                local timeout_start = os.clock()
                repeat
                    yield("/wait "..interval_rate)
                until IsAddonVisible("Repair") and IsAddonReady("Repair") or os.clock() - timeout_start >= timeout_threshold
            end
            yield("/callback Repair true 0")
            repeat
                yield("/wait "..interval_rate)
            until IsAddonVisible("SelectYesno") and IsAddonReady("SelectYesno")
            yield("/callback SelectYesno true 0")
            repeat
                yield("/wait "..interval_rate)
            until not IsAddonVisible("SelectYesno")
            while GetCharacterCondition(39) do yield("/wait "..interval_rate) end
            while IsAddonVisible("Repair") do
                yield('/gaction "Repair"')
                local timeout_start = os.clock()
                repeat
                    yield("/wait "..interval_rate)
                until not IsAddonVisible("Repair") or os.clock() - timeout_start >= timeout_threshold
            end
            if NeedsRepair(repair_threshold) then
                Id_Print("Self Repair failed!")
                Id_Print("Please place the appropriate Dark Matter in your inventory,")
                Id_Print("Or find a NPC mender.")
                return false
            else
                Id_Print("Repairs complete!")
            end
        elseif repair_token == "npc" then
            Id_Print("Equipment below "..repair_threshold.."%!")
            Id_Print("Please go find a NPC mender.")
            return false
        end
    end

    if do_extract and CanExtractMateria() and GetInventoryFreeSlotCount() > num_inventory_free_slot_threshold then
        StopMoveFly()
        if GetCharacterCondition(4) then
            Id_Print("Attempting to dismount...")
            Dismount()
        end
        Id_Print("Attempting to extract materia...")
        while not IsAddonVisible("Materialize") and not IsAddonReady("Materialize") do
                yield('/gaction "Materia Extraction"')
                local timeout_start = os.clock()
                repeat
                    yield("/wait "..interval_rate)
                until IsAddonVisible("Materialize") and IsAddonReady("Materialize") or os.clock() - timeout_start >= timeout_threshold
        end
        while CanExtractMateria() and GetInventoryFreeSlotCount() > num_inventory_free_slot_threshold do
            yield("/callback Materialize true 2 0")
            yield("/wait "..interval_rate)
            if IsAddonVisible("MaterializeDialog") and IsAddonReady("MaterializeDialog") then yield("/callback MaterializeDialog true 0") end
            repeat
                yield("/wait "..interval_rate)
            until not GetCharacterCondition(39)
        end
        while IsAddonVisible("Materialize") do
            yield('/gaction "Materia Extraction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait "..interval_rate)
            until not IsAddonVisible("Materialize") or os.clock() - timeout_start >= timeout_threshold
        end
        if CanExtractMateria() then
            Id_Print("Failed to fully extract all materia!")
            Id_Print("Please check your if you have spare inventory slots,")
            Id_Print("Or manually extract any materia.")
            return false
        else
            Id_Print("Materia extraction complete!")
        end
    end

    function HasReducibles()
        while not IsAddonVisible("PurifyItemSelector") and not IsAddonReady("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait "..interval_rate)
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - timeout_start > timeout_threshold
        end
        yield("/wait "..interval_rate)
        local visible = IsNodeVisible("PurifyItemSelector", 1, 7) and not IsNodeVisible("PurifyItemSelector", 1, 6)
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait "..interval_rate)
            until not IsAddonVisible("PurifyItemSelector") or os.clock() - timeout_start >= timeout_threshold
        end
        return not visible
    end

    if do_reduce and HasReducibles() and GetInventoryFreeSlotCount() > num_inventory_free_slot_threshold then
        StopMoveFly()
        if GetCharacterCondition(4) then
            Id_Print("Attempting to dismount...")
            Dismount()
        end
        Id_Print("Attempting to perform aetherial reduction...")
        repeat
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait "..interval_rate)
            until IsNodeVisible("PurifyItemSelector", 1, 6) or IsNodeVisible("PurifyItemSelector", 1, 7) or os.clock() - timeout_start > timeout_threshold
        until IsAddonVisible("PurifyItemSelector") and IsAddonReady("PurifyItemSelector")
        yield("/wait "..interval_rate)
        while not IsNodeVisible("PurifyItemSelector", 1, 7) and IsNodeVisible("PurifyItemSelector", 1, 6) and GetInventoryFreeSlotCount() > num_inventory_free_slot_threshold do
            yield("/callback PurifyItemSelector true 12 0")
            repeat
                yield("/wait "..interval_rate)
            until not GetCharacterCondition(39)
        end
        while IsAddonVisible("PurifyItemSelector") do
            yield('/gaction "Aetherial Reduction"')
            local timeout_start = os.clock()
            repeat
                yield("/wait "..interval_rate)
            until not IsAddonVisible("PurifyItemSelector") or os.clock() - timeout_start >= timeout_threshold
        end
        Id_Print("Aetherial reduction complete!")
    end

    return true
end

--Returns false if zone has changed since start of script
function CheckIfSameZoneSinceScriptStart()
    return current_zone == GetZoneID()
end

--Returns name and co-ordinates of target node in a string with format "<name>,<x-coord>,<y-coord>,<z-coord>"
function GetTargetData()
    local name = GetTargetName()
    local x = GetTargetRawXPos()
    local y = GetTargetRawYPos()
    local z = GetTargetRawZPos()
    return name..","..x..","..y..","..z
end

--Parse given string containing node name and co-ords and returns a table containing them
function ParseNodeDataString(string)
    return Split(string, ",")
end

--Return printable node
function PrintNode(node)
    local printable_node = node or ""
    if truncate then
        local data = ParseNodeDataString(node)
        local x = Truncate1Dp(data[2])
        local y = Truncate1Dp(data[3])
        local z = Truncate1Dp(data[4])
        printable_node = data[1]..","..x..","..y..","..z
    end
    return printable_node
end

--Returns displacement between given node as a string and current character position
function GetDistanceToNode(node)
    local given_node = ParseNodeDataString(node)
    return GetDistanceToPoint(tonumber(given_node[2]), tonumber(given_node[3]), tonumber(given_node[4]))
end

--Return the closest gathering node found thus far given by found_nodes, and not went to given by nodes_went
function FindNearestFoundNodeNotGathered()
    local least_distance_to_nodes_not_went = math.huge
    local node_with_least_distance_not_went = nil

    for node,_ in pairs(found_nodes) do
        if node ~= last_node_gathered and not QueueContains(nodes_went, node) then
            local distance_to_node = GetDistanceToNode(node)
            if distance_to_node < least_distance_to_nodes_not_went then
                node_with_least_distance_not_went = node
                least_distance_to_nodes_not_went = math.min(least_distance_to_nodes_not_went, distance_to_node)
            end
        end
    end
    return node_with_least_distance_not_went
end

--Return the appropriate moving_timeout_threshold after checking the current zone
function ZoneBasedMovingTimeoutThreshold()
    local zone_id = GetZoneID()
    if zone_id == 939 then return diadem_moving_timeout_threshold
    elseif zone_id == 1055 then return sanctuary_moving_timeout_threshold
    else return moving_timeout_threshold end
end

--Return the appropriate whitelist after checking the current zone
function ZoneBasedWhitelist()
    local zone_id = GetZoneID()
    if zone_id == 939 then return diadem_whitelist
    elseif zone_id == 1055 then return sanctuary_whitelist
    else return whitelist end
end

--Return the appropriate gatherable objectKind after checking the current zone
function ZoneBasedObjectKind()
    local zone_id = GetZoneID()
    if zone_id == 1055 then return 14
    else return 6 end
end

--Wrapper to check navmesh readiness
function CheckNavmeshReady()
    was_ready = NavIsReady()
    while not NavIsReady() do
        Id_Print("Building navmesh, currently at "..Truncate1Dp(NavBuildProgress()*100).."%")
        yield("/wait "..(interval_rate * 10))
    end
    if not was_ready then Id_Print("Navmesh is ready!") end
end

--Wrapper to acquire target given target name and enabling required SND settings
function TargetWithSND(target_name)
    local user_settings = {GetSNDProperty("UseSNDTargeting"), GetSNDProperty("StopMacroIfTargetNotFound")}
    SetSNDProperty("UseSNDTargeting", "true")
    SetSNDProperty("StopMacroIfTargetNotFound", "false")
    yield("/target " .. target_name)
    SetSNDProperty("UseSNDTargeting", tostring(user_settings[1]))
    SetSNDProperty("StopMacroIfTargetNotFound", tostring(user_settings[2]))
end

--Wrapper to get nearest objectKind
--Uses SND's targeting system
function TargetNearestObjectKind(objectKind, radius, subKind)
    local smallest_distance = math.huge
    local closest_target
    local radius = radius or 0
    local subKind = subKind or 5
    local nearby_objects = GetNearbyObjectNames(radius^2, objectKind)
	local names = {}

    if nearby_objects and type(nearby_objects) == "userdata" and nearby_objects.Count > 0 then
        for i = 0, nearby_objects.Count - 1 do
			if names[nearby_objects[i]] == nil then names[nearby_objects[i]] = 0
			else names[nearby_objects[i]] = names[nearby_objects[i]] + 1 end

            local target = nearby_objects[i] .. " <list." .. names[nearby_objects[i]] .. ">"
            TargetWithSND(target)
            if not GetTargetName() or nearby_objects[i] ~= GetTargetName()
                or (SetLength(whitelist_set) > 0 and not SetContains(whitelist_set, GetTargetName()))
                or (objectKind == 2 and subKind ~= GetTargetSubKind())
                or (objectKind == 2 and subKind == GetTargetSubKind() and GetTargetHPP() <= 0) then
            elseif GetDistanceToTarget() < smallest_distance then
                smallest_distance = GetDistanceToTarget()
                closest_target = target
            end
        end
        ClearTarget()
        if closest_target then TargetWithSND(closest_target) end
    end
    return closest_target
end

--Wrapper to handle data as needed
function HandleDataAsNeeded()
    local do_pop = false
    for k,_ in pairs(found_nodes) do
        if k == last_node_gathered and QueueContains(nodes_went, k) then do_pop = true end
    end
    if do_pop then
        QueuePop(nodes_went)
    end
end

--Wrapper to add node to given set or queue, returns true if added
function AddNodeDataToSetOrQueue(node, set_or_queue, name_of_set_or_queue)
    if set_or_queue == nil or node == nil or ParseNodeDataString(node)[4] == nil then return end
    local name_of_set_or_queue = name_of_set_or_queue or "NAMENOTGIVEN"

    if IsQueue(set_or_queue) then --Given struct is Queue
        if not QueueContains(set_or_queue, node) then
            QueuePush(set_or_queue, node)
            return true
        end
    else                          --Given struct is Set (or not Queue)
        if not SetContains(set_or_queue, node) then
            AddToSet(set_or_queue, node)
            return true
        end
    end
    return false
end

--Wrapper to cache path to found node
function PathfindToFoundNode(node)
    local x = tonumber(ParseNodeDataString(node)[2]) or 0
    local y = tonumber(ParseNodeDataString(node)[3]) or 0
    local z = tonumber(ParseNodeDataString(node)[4]) or 0
--[[
    NavPathfind(x, y, z, true)
    NavPathfind(x, y, z)

    while PathfindInProgress() do
        Id_Print("Pathfinding in progress...")
        StopMoveFly()
        yield("/automove off")
        yield("/wait "..interval_rate)
    end
]]
end

--Wrapper to handle fly status when within or without given respective thresholds
function CheckDistanceToWalkFly(node)
    --Workaround for pathfinding during diving not moving to node
    if GetCharacterCondition(81) and GetDistanceToNode(node) < max_distance_to_interact and GetCharacterCondition(4) then
        StopMoveFly()
        Dismount()
    elseif GetDistanceToNode(node) < min_distance_to_dismount and GetCharacterCondition(4) then
        StopMoveFly()
        Dismount()
    --elseif GetDistanceToNode(node) > max_distance_to_walk and ((not GetCharacterCondition(81) and not GetCharacterCondition(77)) or (GetCharacterCondition(81) and not GetCharacterCondition(4)))then
    --Workaround for pathfinding during diving not moving to node
    elseif (GetCharacterCondition(81) and not GetCharacterCondition(4)) or GetDistanceToNode(node) > max_distance_to_walk and ((not GetCharacterCondition(81) and not GetCharacterCondition(77)) or (GetCharacterCondition(81) and not GetCharacterCondition(4)))then
        MountFly()
    end
end

--Wrapper handling when player stopped moving
function ActionsIfDetectedNotMoving(target)
    Id_Print("Detected timeout...")
    Id_Print("Attempting to dislodge...")

--[[
    Id_Print("[NAVMESHDEBUG] ZoneID: "..GetZoneID(), verbose, true)
    Id_Print("[NAVMESHDEBUG] Move Type: "..last_move_type, verbose, true)
    Id_Print("[NAVMESHDEBUG] Starting Coord: "..start_pos, verbose, true)
    Id_Print("[NAVMESHDEBUG] Current Coord: "..(GetPlayerRawXPos()..","..GetPlayerRawYPos()..","..GetPlayerRawZPos()), verbose, true)
    Id_Print("[NAVMESHDEBUG] End Coord: "..(ParseNodeDataString(target)[2]..","..ParseNodeDataString(target)[3]..","..ParseNodeDataString(target)[4]), verbose, true)
--]]

    --Implement random coord base on current player position
    PathMoveTo(tonumber(GetPlayerRawXPos()+math.random(-5, 5)),
        tonumber(GetPlayerRawYPos()+math.random(-5, 5)),
        tonumber(GetPlayerRawZPos()+math.random(-5, 5)))
    yield("/wait "..(time_to_wait_after_dislodge + math.random(0, max_random_wait_addon * 1000) / 1000))
    Id_Print("Waiting for "..Truncate1Dp(time_to_wait_after_dislodge + math.random(0, max_random_wait_addon * 1000) / 1000).."s before moving on...")
end

--Wrapper to handle auger usage
function CheckDiademAuger()
    if GetZoneID() ~= 939 or not (GetClassJobId() == 16 or GetClassJobId() == 17) then return end
    if GetDiademAetherGaugeBarCount() >= 1 and TargetNearestObjectKind(2, ping_radius) then
        local target = GetTargetData()
        if ParseNodeDataString(target)[4] == nil then return end

        local targets = Set{}
        if GetClassJobId() == 16 then
            targets = Set{"Diadem Beast", "Diadem Golem", "Diadem Ice Bomb", "Diadem Ice Golem", "Diadem Zoblyn"}
        elseif GetClassJobId() == 17 then
            targets = Set{"Diadem Bloated Bulb", "Diadem Icetrap", "Diadem Melia", "Diadem Werewood", "Proto-noctilucale"}
        end
        if diadem_auger_crystals then AddToSet(targets, "Corrupted Sprite") end

        if not SetContains(targets, ParseNodeDataString(target)[1]) then
            ClearTarget()
            return
        end
        Id_Print("Using Aetheromatic Auger on "..ParseNodeDataString(target)[1])
---[[
        CheckDistanceToWalkFly(target)
        NodeMoveFly(target)
        repeat
            yield("/wait "..interval_rate)
        until GetDistanceToTarget() < diadem_range_to_target
        StopMoveFly()
        Dismount()
        yield('/gaction "Duty Action I"')
        repeat
            yield("/wait "..interval_rate)
        until not IsPlayerCasting() and not TargetNearestObjectKind(2, diadem_range_to_target)
        Id_Print("Target augered.")
--]]
    end
end

--Wrapper to record Diadem nodes
function RecordDiademNode(node)
    if GetZoneID() ~= 939 or not (GetClassJobId() == 16 or GetClassJobId() == 17) then return end
    -- Autogenerate WP file
    local file_path = os.getenv("appdata").."\\XIVLauncher\\pluginConfigs\\SomethingNeedDoing\\GatheringHelper-"..GetClassJobId().."-"..GetZoneID()..".waypoint"

    -- Open file for appending (or create it if it doesn't exist)
    local file = io.open(file_path, "a")

    if file then
        -- Write text to the file
        file:write(node.."\n")
        -- Close the file handle
        file:close()
        Id_Print("Node added to -> "..file_path)
    else
        Id_Print("Error: Unable to open file for writing")
    end
end

function DebugData()
    Id_Print("[DEBUGDATA] --------------------", verbose, true)
    --Prints out found nodes
    PrintSet(found_nodes, "DEBUGDATA")
    Id_Print("[DEBUGDATA] len(found_nodes): "..SetLength(found_nodes), verbose, true)
    --Prints out nodes went
    PrintQueue(nodes_went, "DEBUGDATA")
    Id_Print("[DEBUGDATA] len(nodes_went): "..QueueLength(nodes_went), verbose, true)
    Id_Print("[DEBUGDATA] last_node_gathered: "..last_node_gathered, verbose, true)
    Id_Print("[DEBUGDATA] --------------------", verbose, true)
end

--Script logic
function main()
    DebugData()

    --Pre-gather Checks
    ---Check if need repairs at start
    ---Check if there's inventory space left
    ---Check if zone has changed
    ::BEFORE_GATHER::
    if (not GetCharacterCondition(6) and not RepairExtractReduceCheck())
        or GetInventoryFreeSlotCount() <= num_inventory_free_slot_threshold
        or not CheckIfSameZoneSinceScriptStart() then
            if GetInventoryFreeSlotCount() <= num_inventory_free_slot_threshold then
                Id_Print("Inventory free slot threshold reached.")
            end
            if not CheckIfSameZoneSinceScriptStart() then
                Id_Print("Zone change detected.")
            end

        stop_main = true
        return
    end

    --Find nearest gathering node
    ::MOVE_NEXT_NODE::
    local node_last_loop
    local timeout_start = os.clock()
    repeat
        last_job_id = ClassCheck()
        if not CheckIfSameZoneSinceScriptStart() then goto BEFORE_GATHER end
        CheckDiademAuger()

        Id_Print("Pinging for nearby Gathering Nodes...")
        if not TargetNearestObjectKind(ZoneBasedObjectKind(), ping_radius) then
            --Add undeteced found_nodes within ping_radius to nodes_went
            local next = next
            if next(found_nodes) ~= nil then
                for k,_ in pairs(found_nodes) do
                    if GetDistanceToNode(k) < ping_radius and k ~= last_node_gathered then
                        AddNodeDataToSetOrQueue(k, nodes_went, "nodes_went")
                        HandleDataAsNeeded()
                    end
                end
            end
            next_node_move_to = FindNearestFoundNodeNotGathered()
        else
            break
        end

        if next_node_move_to == nil then
            Id_Print("Traversed all found nodes!")
            Id_Print("Go find another!")
            StopMoveFly()
            MountFly()
            yield("/wait "..interval_rate)
        else
            CheckDistanceToWalkFly(next_node_move_to)
            if node_last_loop ~= next_node_move_to or not PathIsRunning() then
                NodeMoveFly(next_node_move_to)
                node_last_loop = next_node_move_to
            end
            Id_Print("Moving to "..PrintNode(next_node_move_to))

            if os.clock() - timeout_start > ZoneBasedMovingTimeoutThreshold() then
                ActionsIfDetectedNotMoving(next_node_move_to)
                timeout_start = os.clock()
            end
        end

        yield("/wait "..interval_rate)
    until (GetCharacterCondition(6) or GetCharacterCondition(32))

    Id_Print("Gathering Node found!")
    StopMoveFly()
    yield("/automove off")
    if not GetCharacterCondition(6) then
        EatFood()
        UseMedicine()
        ReadManual()
    end

    repeat
        yield("/wait "..interval_rate)
        TargetNearestObjectKind(ZoneBasedObjectKind(), ping_radius)
        current_target = GetTargetData()
    until ParseNodeDataString(current_target)[4]
    if not SetContains(found_nodes, current_target) then Id_Print("[VERBOSE] New Gathering Node: "..PrintNode(current_target), verbose) end
    AddNodeDataToSetOrQueue(current_target, found_nodes, "found_nodes")
    if SetLength(whitelist_set) <= 0 and add_first_node_to_empty_whitelist then
        Id_Print("Adding "..ParseNodeDataString(current_target)[1].." to whitelist")
        AddToSet(whitelist_set, ParseNodeDataString(current_target)[1])
    end
    PathfindToFoundNode(current_target)

    --Movement logic, also dismounts if mounted when close enough
    ::HOME_IN_NEXT_NODE::
    timeout_start = os.clock()
    repeat
        last_job_id = ClassCheck()
        if not CheckIfSameZoneSinceScriptStart() then goto BEFORE_GATHER end
        CheckDistanceToWalkFly(current_target)
        if not IsMoving() and not PathIsRunning() then
            NodeMoveFly(current_target)
            Id_Print("Moving to Target...")
        end

        if os.clock() - timeout_start > ZoneBasedMovingTimeoutThreshold() then
            ActionsIfDetectedNotMoving(current_target)
            timeout_start = os.clock()
        end

        yield("/wait "..interval_rate)
        TargetWithSND(ParseNodeDataString(current_target)[1])
    until (GetTargetName() ~= nil and GetDistanceToTarget() <= max_distance_to_interact) or (GetCharacterCondition(6) or GetCharacterCondition(32))
    --until (GetCharacterCondition(6) or GetCharacterCondition(32))
    StopMoveFly()

    ::START_GATHER::
    Id_Print("Starting to gather from current gathering node...")
    AddNodeDataToSetOrQueue(current_target, nodes_went, "nodes_went")
    --RecordDiademNode(current_target)
    last_node_gathered = current_target
    timeout_start = os.clock()
    if GetZoneID() == 1055 then
        while not GetCharacterCondition(32) and os.clock() - timeout_start <= timeout_threshold do
            yield("/interact")
            yield("/wait "..interval_rate)
        end
        timeout_start = os.clock()
        while GetCharacterCondition(32) and os.clock() - timeout_start <= timeout_threshold do
            yield("/wait "..interval_rate)
        end
    else
        while not (IsAddonVisible("Gathering") or IsAddonVisible("SpearFishing")) and os.clock() - timeout_start <= timeout_threshold do
            yield("/interact")
            yield("/wait "..interval_rate)
        end
        timeout_start = os.clock()
        while not (IsAddonVisible("Gathering") or IsAddonVisible("SpearFishing")) and os.clock() - timeout_start <= timeout_threshold do
            yield("/interact")
            yield("/wait "..interval_rate)
        end
    end
    if os.clock() - timeout_start > timeout_threshold then
        Id_Print("Timeout detected while attempting to gather...")
        Id_Print("Reacquiring a gathering point...")
        goto BEFORE_GATHER
    end

    --Wait for gathering to finish
    ::FINISH_GATHER::
    repeat
--[[
        --if is in Diadem and have a gathering script, run gathering script
        if diadem_gather_script_name ~= "" and GetZoneID() == 939 then yield("/runmacro "..diadem_gather_script_name) end
--]]

        --if is collectable, run collectables script
        if collectables_script_name ~= "" and IsAddonVisible("GatheringMasterpiece") then yield("/runmacro "..collectables_script_name) end

        yield("/wait "..interval_rate)
    until not (GetCharacterCondition(6) or GetCharacterCondition(32)) and IsPlayerAvailable()
    Id_Print("Finished gathering from current gathering node!")
    Id_Print("Waiting for "..(time_to_wait_after_gather + math.random(0, max_random_wait_addon * 1000) / 1000).."s before moving on...")
    yield("/wait "..Truncate1Dp(time_to_wait_after_gather + math.random(0, max_random_wait_addon * 1000) / 1000))

    ::CHECK_DATA::
    HandleDataAsNeeded()
end

--Run script
Id_Print("----------Starting GatheringHelper----------")
current_zone = GetZoneID()
whitelist_set = Set(ZoneBasedWhitelist())
while not stop_main do
    main()
end
Id_Print("----------Stopping GatheringHelper----------")