--[[
    
    *******************************************
    *             Diadem Fishing              *
    *******************************************

    Author: UcanPatates  

    **********************
    * Version  |  1.1.5  *
    **********************

    -> 1.1.5  : Added ability to fish for umbral fish and ability to choose whether to fish for grade 2 or grade 3 artisanal fish (for achievements).
                -> Umbral fishing only available while fishing for Sweatfish / Grade 4 artisanal fish.
    -> 1.1.4  : Fixed Mender NPC name for targetting. Tweaked food check handling to bypass missing text node on /item usage.
    -> 1.1.3  : Added a Echo setting.
    -> 1.1.2  : Update to click command for SND.
    -> 1.1.1  : Update for DT changed the /click talk to /click  Talk_Click.
    -> 1.1.0  : Changed the forced preset and some fixes.
    -> 1.0.9  : Now purchases the exact amount of bait and dark matter.
    -> 1.0.8  : Some tweaks to the pathing to fix a jumping when not supposed to issue.
    -> 1.0.7  : 500 Cast and Super amiss check fixes.
    -> 1.0.6  : Added NPC repair option and the ability to set a minimum number of baits to buy and Auto Cordial usage.
    -> 1.0.5  : Buying fix for user error.
    -> 1.0.4  : Now supports bait and Dark Matter buying, automatically selects the bait, and sets the AutoHook preset automatically.
    -> 1.0.3  : Now checks if the nvavmesh is ready.
    -> 1.0.1  : Now You don't have to touch the snd settings.
    -> 1.0.0  : Added food usage safety checks and more.
    -> 0.0.2  : Beta version not finished
    -> 0.0.1  : Fishing script with auto repair.


    ***************
    * Description *
    ***************

    This script will fish for you at diadem (Sweetfish).
    
    here is a wiki:
    https://github.com/PunishXIV/AutoHook/wiki/The-Diadem


    *********************
    *  Required Plugins *
    *********************

    -> SomethingNeedDoing (Expanded Edition) [Make sure to press the lua button when you import this] -> https://puni.sh/api/repository/croizat
    -> AutoHook : https://love.puni.sh/ment.json
    -> vnavmesh : https://puni.sh/api/repository/veyn
    -> Pandora's Box : https://love.puni.sh/ment.json
    -> Simple Tweaks : you need to enable /bait.
    
    **************
    *  SETTINGS  *
    **************
]] 

--Do you want to see whats happening in the echo chat.
EchoToChat = true

--Do you want to buy the correct bait for the FishType selected and DarkMatter if you don't have it ?
BuyBait = true           -- true | false (default is true)
MinimumBait = 200        -- Minimum number of Baits you want.

BuyDarkMatter = true     -- true | false (default is true)
MinimumDarkMatter = 99   -- Minimum number of DarkMatter you want.

--Auto use Cordial this is a pandora setting.
UseCordial = true        -- true | false (default is true)

-- When do you want to repair your own gear? From 0-100.
SelfRepair = true        -- true | false (default is true)
NpcRepair = false        -- true | false (default is false)
StopTheScripIfThereIsNoDarkMatter = false -- true | false (default is false)
RepairAmount = 99        -- Number between 1 to 99 

-- If you would like to use food while in diadem, and what kind of food you would like to use.
UseFood = true           -- true | false (default is true)
StopTheScripIfThereIsNoFood = false -- true | false (default is false)
FoodKind = "Jhinga Curry <HQ>" -- "Jhinga Curry <HQ>" (make sure to have the name of the food IN the "")

FishType = "Grade4"   -- set type of fish for which you want to target | Grade4 , Grade3, Grade2
 -- Default Grade4 for Sweatfish
 -- Grade 4 and Grade 2 need Diadem Hoverworm Bait
 -- Grade 3 need Diadem Crane Fly Bait

-- Preset settings here
ForceAutoHookPreset = true -- true | false (default is true) this setting will configure the preset for you and wont use below setting.
CustomAutoHookPreset = "myfishingpreset" -- "custom preset name" get it from AutoHook.
CustomAutoHookPresetBait = "Diadem Hoverworm" -- bait for custom preset | Diadem Hoverworm , Diadem Balloon Bug , Diadem Red Balloon, or Diadem Crane Fly
HowManyMinutes = 20     -- this setting is to move every x minutes.
-- (default is 20 not recomended to make it more than 30)
-- *** if using CustomAutoHookPreset, Grade4 fishes at Blustery Cloudtop | Grade3 fishes at Windbreaking Cloudtop | Grade2 fishes at Buffeted Cloudtop

UmbralFish = false -- true | false (default is false) this setting will move to another hole for umbral fish during Umbral Flare, Levin, and Tempest weather.  Default hole has Umbral Duststorm fish
-->Grade 4 Artisanal Skybuilders' Marrella uses hoverworm like Sweatfish, not focused during Umbral Duststorms, but will be caught if !!! seen at normal grade 4 spot even if false
  --Need Diadem Balloon Bug for Umbral Flare in inventory | Focuses on catching Grade 2 Artisanal Skybuilders' Cometfish
  --Need Diadem Red Balloon for Umbral Levin in inventory | Focuses on catching Grade 3 Artisanal Skybuilders' Cloudshark
  --Need Diadem Crane Fly for Umbral Tempest in inventory | Focuses on catching Grade 3 Artisanal Skybuilders' Archaeopteryx
  -->These are all direct catches to quickly get the achievement, recommend turning off again after 100 Umbral Fish caught.
  --***This is set to only work if FishType = "Grade4". 
  --***If set to true and required bait not in inventory, it will keep fishing the normal spot and ignore the corresponding umbral weather.


--[[

  ************
  *  Script  *
  *   Start  *
  ************

]]

-- 4th var
-- 0 means First spot to randomly select
-- 1 means Second spot to randomly select
-- 2 means umbral flare/levin/tempest spot to ramdomly select
-- 500 is bailout and clear the 500cast thingy
if FishType == "Grade4" then
    FishingSpot =  -- can add if then here to do grade4, grade3, grade2 fishing
    {
      {520.7,193.7,-518.1,0}, -- First spot
      {521.4,193.3,-522.2,0},
      {526.3,192.6,-527.2,0},
    
      {544.6,192.4,-507.8,1}, -- Second spot
      {536.9,192.2,-503.2,1},
      {570.3,189.4,-502.7,1},
    
      {237.5,293.7,-826.9,2}, -- Umbral spot
      {269.6,292.5,-828.1,2},
      {320.8,292.9,-815.8,2},
    
      {422.9,-191.2,-300.2,500} --bailout
    }
elseif FishType == "Grade3" then
    FishingSpot =
    {
      {239.6,289.8,-781.7,0}, -- First spot
      {186.8,293.4,-763.3,0},
      {221.1,292.7,-826.0,0},

      {397.4,290.2,-709.0,1}, -- Second spot
      {370.6,289.9,-697.0,1},
      {346.2,282.5,-659.9,1},
    
      {422.9,-191.2,-300.2,500} --bailout
    }
elseif FishType == "Grade2" then
    FishingSpot =
    {
      {614.1,222.6,-64.2,0}, -- First spot
      {612.9,223.5,-103.8,0},
      {637.9,227.4,-141.9,0},

      {704.0,222.9,-78.3,1}, -- Second spot
      {687.3,223.3,-60.0,1},
      {671.2,222.7,-42.5,1},
    
      {422.9,-191.2,-300.2,500} --bailout
    }
end

-- Functions
function Echo(Value)
    if EchoToChat then
        yield(Value)
    end
end

function setPropertyIfNotSet(propertyName)
    if GetSNDProperty(propertyName) == false then
        SetSNDProperty(propertyName, "true")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to True")
        Echo("[SetSNDPropertys] " .. propertyName .. " set to True")
    end
end

function unsetPropertyIfSet(propertyName)
    if GetSNDProperty(propertyName) then
        SetSNDProperty(propertyName, "false")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to False")
        Echo("[SetSNDPropertys] " .. propertyName .. " set to False")
    end
end

function BuyPcall(ItemID, NpcName, ShopAddonName, SelectIconString, WhichSlotToBuy, TotalAmount)
    local PurchaseLimit = 99
    local FullBatches = TotalAmount / PurchaseLimit
    local RemainingItems = TotalAmount % PurchaseLimit
    local ItemCount = GetItemCount(ItemID)


    local function PerformPurchase(Slot, Amount)
        local ExpectedItemCount = ItemCount + Amount
        while true do
            yield("/wait 0.1")
            ItemCount = GetItemCount(ItemID)
            if GetTargetName() ~= NpcName then
                yield("/target " .. NpcName)
            elseif IsAddonVisible("SelectIconString") then
                yield("/callback SelectIconString true "..SelectIconString)
            elseif IsAddonVisible("SelectYesno") then
                yield("/callback SelectYesno true 0")
                yield("/wait 0.1")
            elseif ItemCount  >= ExpectedItemCount then
                break --Exit the loop
            elseif IsAddonVisible(ShopAddonName) then
                yield("/callback " .. ShopAddonName .. " true 0 " .. Slot .. " " .. Amount)
                yield("/wait 0.1")
            else
                yield("/interact")
            end
        end
    end

    for i = 1, FullBatches do
        PerformPurchase(WhichSlotToBuy, PurchaseLimit)
        yield("/wait 0.1")
    end

    if RemainingItems > 0 then
        PerformPurchase(WhichSlotToBuy, RemainingItems)
    end

    while IsAddonVisible(ShopAddonName) do
        yield("/callback " .. ShopAddonName .. " true -1")
        yield("/wait 0.1")
    end
end

function NomNomDelish()
    Echo("[FoodCheck] Starting.")
    FoodCheck = 1
    local EatThreshold = HowManyMinutes * 60
    while (GetStatusTimeRemaining(48) <= EatThreshold or not HasStatusId(48)) and UseFood and FoodCheck < 4 do
        Echo("[FoodCheck] Attempting food "..FoodCheck.."/3 times..")
        yield("/item " .. FoodKind)
        yield("/wait 2")
        FoodCheck = FoodCheck + 1
        if FoodCheck > 3 then
            UseFood = false
            if StopTheScripIfThereIsNoFood then
                if GetCharacterCondition(34) then
                    DutyLeave()
                end
                LogInfo("[FoodCheck] StopTheScripIfThereIsNoFood is true stopping the script")
                Echo("[FoodCheck] StopTheScripIfThereIsNoFood is true stopping the script")
                yield("/snd stop")
            end
            LogInfo("[FoodCheck] Set to False, no food remaining")
            Echo("[FoodCheck] Set to False, no food remaining")
            break
        end
    end
    FoodCheck = 1
    LogInfo("[FoodCheck] Completed")
    Echo("[FoodCheck] Completed")
end

function LetsBuySomeStuff()
    if IsInZone(939) then
        local DiademHoverwormCount = GetItemCount(30281)
        local DiademCraneFlyCount = GetItemCount(30280)
        local Grade8DarkMatterCount = GetItemCount(33916)
        local distance = GetDistanceToPoint(-641.2, 285.3, -138.7)
        local BuyBaitMinimum = MinimumBait / 4
        local BuyDarkMatterMinimum = MinimumDarkMatter / 4

        if FishType == "Grade4" or FishType == "Grade2" then
            if DiademHoverwormCount < BuyBaitMinimum and BuyBait then
                if distance >= 4 then
                    if distance <= 50 and GetCharacterCondition(77, false) then
                        WalkTo(-641.2, 285.3, -138.7)
                    else
                        FlyTo(-641.2, 285.3, -138.7)
                    end
                end
            end
        elseif FishType == "Grade3" then
            if DiademCraneFlyCount < BuyBaitMinimum and BuyBait then
                if distance >= 4 then
                    if distance <= 50 and GetCharacterCondition(77, false) then
                        WalkTo(-641.2, 285.3, -138.7)
                    else
                        FlyTo(-641.2, 285.3, -138.7)
                    end
                end
            end
        end
        if Grade8DarkMatterCount < BuyDarkMatterMinimum and BuyDarkMatter then
            if distance >= 4 then
                if distance <= 50 and GetCharacterCondition(77, false) then
                    WalkTo(-641.2, 285.3, -138.7)
                else
                    FlyTo(-641.2, 285.3, -138.7)
                end
            end
        end


        local distance = GetDistanceToPoint(-641.2, 285.3, -138.7)
        if FishType == "Grade4" or FishType == "Grade2" then
            if BuyBait and distance <= 4 and DiademHoverwormCount < BuyBaitMinimum then
                local BuyAmount = MinimumBait - DiademHoverwormCount 
                BuyPcall(30281, "Merchant & Mender", "Shop", 0, 6, BuyAmount)
                LogInfo("[Debug]Bought Diadem Hoverworm.")
                Echo("[Debug]Bought Diadem Hoverworm.")
            elseif not BuyBait and DiademHoverwormCount < BuyBaitMinimum then
                LogInfo("[Debug]BuyBait is False and Bait is running out, continue.")
                Echo("[Debug]BuyBait is False and Bait is running out, continue.")
            end
        elseif FishType == "Grade3" then
            if BuyBait and distance <= 4 and DiademCraneFlyCount < BuyBaitMinimum then
                local BuyAmount = MinimumBait - DiademCraneFlyCount 
                BuyPcall(30280, "Merchant & Mender", "Shop", 0, 5, BuyAmount)
                LogInfo("[Debug]Bought Diadem Crane Fly.")
                Echo("[Debug]Bought Diadem Crane Fly.")
            elseif not BuyBait and DiademCraneFlyCount < BuyBaitMinimum then
                LogInfo("[Debug]BuyBait is False and Bait is running out, continue.")
                Echo("[Debug]BuyBait is False and Bait is running out, continue.")
            end
        end

        yield("/wait 1") -- :D go ahed delete it don't cry to me if its broke tho.

        if BuyDarkMatter and distance <= 4 and Grade8DarkMatterCount < BuyDarkMatterMinimum then
            local BuyAmount = MinimumDarkMatter - Grade8DarkMatterCount 
            BuyPcall(33916, "Merchant & Mender", "Shop", 0, 14, BuyAmount)
            LogInfo("[Debug]Bought Grade8 DarkMatter.")
            Echo("[Debug]Bought Grade8 DarkMatter.")
        elseif not BuyDarkMatter and Grade8DarkMatterCount < BuyDarkMatterMinimum then
            LogInfo("[Debug]BuyDarkMatter is False and DarkMatter is running out, continue.")
            Echo("[Debug]BuyDarkMatter is False and DarkMatter is running out, continue.")
        end

        while IsAddonVisible("Shop") do
            yield("/callback Shop true -1")
            yield("/wait 0.1")
        end
        PlayerTest()
    end
end

function PlayerTest()
    repeat
        yield("/wait 0.1")
    until IsPlayerAvailable()
end

function RandomSpot(Value)
    local availableSpots = {} -- Table to store available spot indices

    for i, spot in ipairs(FishingSpot) do
        if spot[4] == Value then
            table.insert(availableSpots, i)
        end
    end
    if #availableSpots > 0 then
        local randomIndex = math.random(1, #availableSpots)
        local spotIndex = availableSpots[randomIndex]

        local spot = FishingSpot[spotIndex]
        local x, y, z = spot[1], spot[2], spot[3]
        return x, y, z

    else
        LogInfo("[Debug]No available spots")
        return nil, nil, nil
    end
end

function DistanceToAurvael()
    local distance = GetDistanceToPoint(-18.6, -16.0, 141.2)
    if distance and distance > 100 then
        LogInfo("[Debug]Distance to Aurvael is further than 100 units")
        Echo("[Debug]Distance to Aurvael is further than 100 units")
        return nil
    end
    return distance
end

function MountAndFly()
    Echo("[MountAndFly] Starting.")
    while IsInZone(939) and GetCharacterCondition(4, false) and GetCharacterCondition(77, false) do
        PathStop()
        while GetCharacterCondition(4, false) and IsInZone(939) do
            while GetCharacterCondition(27, false) and IsInZone(939) do
                yield("/wait 0.1")
                yield('/gaction "mount roulette"')
            end
            while GetCharacterCondition(27) and IsInZone(939) do
                yield("/wait 0.3")
            end
            yield("/wait 1")
        end
    end
    if GetCharacterCondition(77) == false and IsInZone(939) then
        yield("/gaction jump")
        yield("/wait 0.1")
        yield("/gaction jump")
    end
    LogInfo("[MountAndFly] Completed")
    Echo("[MountAndFly] Completed")
end

function NpcRepairMenu(Name)
    Echo("[RepairNpc] Starting the repair with NPC " .. Name .. ".")
    while true do
        if not NeedsRepair(RepairAmount) then
            break
        elseif GetTargetName() ~= Name then
            yield("/target "..Name)
            yield("/wait 0.1")
        elseif IsAddonVisible("SelectIconString") then
            yield("/callback SelectIconString true 1")
        elseif IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
            yield("/wait 0.1")
        elseif IsAddonVisible("Repair") then
            yield("/callback Repair true 0")
        else
            yield("/interact")
        end
        yield("/wait 0.1")
    end
    while IsAddonVisible("Repair") do
        yield("/callback Repair true -1")
        yield("/wait 0.1")
    end
    LogInfo("[RepairNpc] Got Repaired by "..Name .." .")
    Echo("[RepairNpc] Got Repaired by "..Name .." .")
end

function Repair()
    if NeedsRepair(RepairAmount) and SelfRepair then
        Echo("[Repair] Starting.")
        while not IsAddonVisible("Repair") do
            yield("/generalaction repair")
            yield("/wait 0.5")
        end
        yield("/callback Repair true 0")
        yield("/wait 0.1")
        if GetNodeText("_TextError", 1) == "You do not have the dark matter required to repair that item." and
            IsAddonVisible("_TextError") then
            SelfRepair = false
            LogInfo("[Repair] Set to False not enough dark matter")
            Echo("[Repair] Set to False not enough dark matter")
            if StopTheScripIfThereIsNoDarkMatter then
                LogInfo("[Repair] StopTheScripIfThereIsNoDarkMatter is true stopping the script")
                Echo("[Repair] StopTheScripIfThereIsNoDarkMatter is true stopping the script")
                if GetCharacterCondition(34) then
                    DutyLeave()
                end
                yield("/snd stop")
            end
        end
        if IsAddonVisible("SelectYesno") then
            yield("/callback SelectYesno true 0")
        end
        while GetCharacterCondition(39) do
            yield("/wait 1")
        end
        yield("/wait 1")
        if IsAddonVisible("Repair") then
            yield("/callback Repair true -1")
        end
    end

    if NeedsRepair(RepairAmount) and NpcRepair then
        if IsInZone(886) then
            WalkTo(47, -16, 151)
            if GetDistanceToPoint(47, -16, 151) <= 4 then
                NpcRepairMenu("Eilonwy")
            end
        end
        if IsInZone(939) then
            if GetDistanceToPoint(-641.2, 285.3, -138.7) >= 4 then
                if GetDistanceToPoint(-641.2, 285.3, -138.7) <= 50 and GetCharacterCondition(77, false) then
                    WalkTo(-641.2, 285.3, -138.7)
                else
                    FlyTo(-641.2, 285.3, -138.7)
                end
            end
            if GetDistanceToPoint(-641.2, 285.3, -138.7) <= 4 then
                NpcRepairMenu("Mender")
            end
        end
    end
    PlayerTest()
    LogInfo("[Repair] Completed")
    Echo("[Repair] Completed")
end

function WalkTo(valuex, valuey, valuez)
    Echo("[WalkTo] Starting.")
    MeshCheck()
    PathfindAndMoveTo(valuex, valuey, valuez, false)
    while PathIsRunning() or PathfindInProgress() do
        yield("/wait 0.1")
    end
    LogInfo("[WalkTo] Completed")
    Echo("[WalkTo] Completed")
end

function FlyTo(valuex, valuey, valuez)
    Echo("[FlyTo] Starting.")
    MeshCheck()
    MountAndFly()
    PathfindAndMoveTo(valuex, valuey, valuez, true)
    while PathIsRunning() or PathfindInProgress() do
        yield("/wait 0.1")
        MountAndFly()
    end
    LogInfo("[FlyTo] Completed")
    Echo("[FlyTo] Completed")
end

function Dismount()
    Echo("[Dismount] Trying.")
    local a = 0
    if GetCharacterCondition(4) or GetCharacterCondition(77) and IsInZone(886) == false then
        yield("/ac dismount")
        yield("/wait 0.3")
        while GetCharacterCondition(77) and a < 3 and IsInZone(886) == false do
            yield("/wait 0.5")
            a = a + 1
        end
        if a == 3 then
            yield("/wait 0.1")
            yield("/send SPACE")
            LogInfo("[Debug] Dismount BailoutCommanced")
            Echo("[Debug] Dismount BailoutCommanced!")
        end
    end
    LogInfo("[Dismount] Completed")
    Echo("[Dismount] Completed")
end

function Truncate1Dp(num)
    return truncate and ("%.1f"):format(num) or num
end

function MeshCheck()
    local was_ready = NavIsReady()
    if not NavIsReady() then
        while not NavIsReady() do
            LogInfo("[Debug]Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
            Echo("[Debug]Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
            yield("/wait 1")
            local was_ready = NavIsReady()
            if was_ready then
                LogInfo("[Debug]Navmesh ready!")
                Echo("[Debug]Navmesh ready!")
            end
        end
    else
        LogInfo("[Debug]Navmesh ready!")
        Echo("[Debug]Navmesh ready!")
    end
end

function MoveToDiadem(RandomSelect)
    Echo("[MoveToDiadem] Starting.")
    MeshCheck()
    local X, Y, Z
    if IsInZone(939) then
        X, Y, Z = RandomSpot(RandomSelect)
        local distance = GetDistanceToPoint(X, Y, Z)
        if distance >= 50 then
            if not (GetCharacterCondition(4) and GetCharacterCondition(77)) then
                MountAndFly()
            end
            PathfindAndMoveTo(X, Y, Z, true) -- Fly to spot
            while GetDistanceToPoint(X, Y, Z) > 1 and IsInZone(939) do
                yield("/wait 0.5")
                if not (PathIsRunning() or IsMoving()) then
                    PathfindAndMoveTo(X, Y, Z, true) -- Fly to spot
                end
                if not (GetCharacterCondition(4) and GetCharacterCondition(77)) then
                    MountAndFly()
                end
            end
            Dismount()
        else
            while GetDistanceToPoint(X, Y, Z) > 1 and IsInZone(939) do
                yield("/wait 0.5")
                if not (PathIsRunning() or IsMoving()) then
                    PathfindAndMoveTo(X, Y, Z, false) -- Walk to spot
                end
            end
            Dismount()
        end
        yield("/wait 0.3")
        if RandomSelect == 0 then
            local oceanX, oceanY, oceanZ = X - 1.2, Y, Z - 1.2
            WalkTo(oceanX, oceanY, oceanZ)
        elseif RandomSelect == 1 then
            local oceanX, oceanY, oceanZ = X + 1.2, Y, Z + 1.2
            WalkTo(oceanX, oceanY, oceanZ)
        elseif RandomSelect == 2 then
            local oceanX, oceanY, oceanZ = X, Y, Z - 3.5
            WalkTo(oceanX, oceanY, oceanZ)
        elseif RandomSelect == 500 then
            local oceanX, oceanY, oceanZ = X + 1.2, Y, Z - 1.2
            WalkTo(oceanX, oceanY, oceanZ)
        end
        LogInfo("[MoveToDiadem] Completed")
        Echo("[MoveToDiadem] Completed")
    end
end

function Bailout500Cast()
    Echo("[Bailout500Cast] Starting, you have been fishing a lot :D")
    while GetCharacterCondition(6) do
        yield("/ac Quit")
        yield("/wait 1")
    end
    MoveToDiadem(500)
    PlayerTest()
    yield("/wait 2")
    yield("/ac Cast")
    yield("/wait 3")
    while GetCharacterCondition(6) do
        yield("/ac Quit")
        yield("/wait 1")
    end
    LogInfo("[Bailout500Cast] Completed")
    Echo("[Bailout500Cast] Completed")
end

function Dofishing()
    if not GetCharacterCondition(4) then
        Echo("[Fishing] Starting for ".. HowManyMinutes.. " minutes .")
        local MoveEveryMin = HowManyMinutes * 60
        NomNomDelish()
        if IsInZone(939) then
            SetAutoHookPreset()
            yield("/wait 0.3")
            yield("/ahon")
            fishing_start_time = os.time()
            yield("/ac Cast")
            yield("/wait 0.3")
            if UmbralFish == true and FishType == "Grade4" then
                while fishing_start_time + MoveEveryMin > os.time() and IsInZone(939) and weathercheck() ~= true and GetItemCount(30281) > 0 do
                    if (GetNodeText("_ScreenText", 11, 8) ==
                        "The fish here have grown wise to your presence. You might have better luck in a new location..." or
                        GetNodeText("_ScreenText", 11, 8) ==
                        "The fish sense something amiss. Perhaps it is time to try another location.") and
                        IsNodeVisible("_ScreenText", 1, 40001) then
                        Bailout500Cast()
                        break
                    end
                    if not GetCharacterCondition(6) then
                        yield("/ac Cast")
                    end
                        yield("/wait 2")
                end
            else
                if FishType == "Grade4" or FishType == "Grade2" then
                    while fishing_start_time + MoveEveryMin > os.time() and IsInZone(939) and GetItemCount(30281) > 0 do
                        if (GetNodeText("_ScreenText", 11, 8) ==
                            "The fish here have grown wise to your presence. You might have better luck in a new location..." or
                            GetNodeText("_ScreenText", 11, 8) ==
                            "The fish sense something amiss. Perhaps it is time to try another location.") and
                            IsNodeVisible("_ScreenText", 1, 40001) then
                            Bailout500Cast()
                            break
                        end
                        if not GetCharacterCondition(6) then
                            yield("/ac Cast")
                        end
                        yield("/wait 2")
                    end
                elseif FishType == "Grade3" then
                    while fishing_start_time + MoveEveryMin > os.time() and IsInZone(939) and GetItemCount(30280) > 0 do
                        if (GetNodeText("_ScreenText", 11, 8) ==
                            "The fish here have grown wise to your presence. You might have better luck in a new location..." or
                            GetNodeText("_ScreenText", 11, 8) ==
                            "The fish sense something amiss. Perhaps it is time to try another location.") and
                            IsNodeVisible("_ScreenText", 1, 40001) then
                            Bailout500Cast()
                            break
                        end
                        if not GetCharacterCondition(6) then
                            yield("/ac Cast")
                        end
                        yield("/wait 2")
                    end
                end        
            end
            while GetCharacterCondition(6) do
                yield("/ac Quit")
                yield("/wait 1")
            end
            PlayerTest()
            LogInfo("[Fishing] Completed")
            Echo("[Fishing] Completed")
        end
    end
end

function Doumbralfishing()
    if not GetCharacterCondition(4) then
        Echo("[UmbralFishing] Starting for ".. HowManyMinutes.. " minutes .")
        local MoveEveryMin = HowManyMinutes * 60
        NomNomDelish()
        if IsInZone(939) then
            SetUmbralAutoHookPreset()
            GetUmbralBait()
            yield("/echo You have "..UmbralBait.." "..UmbralBaitName.." available")
            yield("/wait 0.3")
            yield("/ahon")
            fishing_start_time = os.time()
            yield("/ac Cast")
            yield("/wait 0.3")
            while fishing_start_time + MoveEveryMin > os.time() and IsInZone(939) and weathercheck() == true and UmbralBait > 0 do
                if (GetNodeText("_ScreenText", 11, 8) ==
                    "The fish here have grown wise to your presence. You might have better luck in a new location..." or
                    GetNodeText("_ScreenText", 11, 8) ==
                    "The fish sense something amiss. Perhaps it is time to try another location.") and
                    IsNodeVisible("_ScreenText", 1, 40001) then
                    Bailout500Cast()
                    break
                end
                if not GetCharacterCondition(6) then
                    yield("/ac Cast")
                end
                yield("/wait 2")
            end
            while GetCharacterCondition(6) do
                yield("/ac Quit")
                yield("/wait 1")
            end
            PlayerTest()
            LogInfo("[UmbralFishing] Completed")
            Echo("[UmbralFishing] Completed")
        end
    end
end

function WeGoIn()
    while IsInZone(886) do
        Echo("[WeGoIn] Started.")
        local distance = DistanceToAurvael()
        if distance and distance > 4 then
            WalkTo(-18.4, -16.0, 143.2)
        end
        if distance and distance < 4 then
            if IsAddonVisible("ContentsFinderConfirm") then
                yield("/callback ContentsFinderConfirm true 8")
                yield("/wait 1.5")
            elseif GetTargetName() ~= "Aurvael" then
                yield("/target Aurvael")
            elseif GetCharacterCondition(32, false) then
                yield("/interact")
            elseif IsAddonVisible("Talk") then
                yield("/click Talk Click")
            elseif IsAddonVisible("SelectString") then
                yield("/callback SelectString true 0")
            elseif IsAddonVisible("SelectYesno") then
                yield("/callback SelectYesno true 0")
            end
            yield("/wait 0.5")
        end
    end
    PlayerTest()
    LogInfo("[WeGoIn] Completed")
    Echo("[WeGoIn] Completed")
end

function SetAutoHookPreset()
    if ForceAutoHookPreset then
        if FishType == "Grade4" then
            DeleteAllAutoHookAnonymousPresets()
            UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1Xy27bOhD9FUObbtLClh+xs9N10iRAmgaViy6K4oKRaIswTfpSVFK3yL93RiRtUZZtBV20i7uKMpw5c+ZBzvhnEBVaTkmu8+l8EVz8DK4EeeQ04jy40KqgZwEe3jFBd4epO7qFr3A8OQseFJOK6U1w0QNpfvU94UVK050Y9V8M1gcpkwzByo8Qv0qc0fgsuF7PMkXzTHKQ9LpdD/k4dIkxOfcsuifJTLNi5RgMet3BCQrOSnJOE10x7FXVwtNupUoZ4QdS2gtHo0mNycBn4hONHuUT1GdOeO48vGd5drWheYXjsAY5HHqQI1cfsqRxxub6H8LKEFGQO0GsSbIEVACzVdvHraJOLOoD0YyKhFb4jOp2Iz/ZoTNV7AedEm265nNOPwq++cJ0FiWaPdGYk7XXkECpDh3W6ti30LOMcEaW+XvyJBWiewIXa//Ml3+iCeQb9HuYwaY7ARQGnsPRC3i8+q4VsdcMczmT8TNZ3wpdMM2kuCZMuPS8hYa6JytIV3Av4e6BdYPFncz1EYsHiJ82ewneBgfODWZ5vvMYr6HdFeHTQikqdGumNbtX8G30uMe6Eb/UisSCU6igXONNYGIRawpt0quyMzp5pNqSqhqAl+2pNSFCin/jZ0r0HHwCiTuW649zdAhd9NUUHek4d/1uON55vGQkpavODfbWs1QrxL+Hv4TfSLlEG3eJvlBS/m9aD0+BBBJ0TWhFs80agAe9c7yFzjjWSorFUfPygmVU3Eu9f8dq2N1+BfuOLqhIidq8hl2JANf6UhZW3ykaiYsWT2ZsRVXtxn1gYnsEFR6869ZchCOM34DtorcqW7Dy9Txi6cXW3hgCmym29gMzkt8P7HwYYvIM3CtD82xfH5w1xxsWzTVVU1IsMlgUVjg0oKn3rx4OaffKuI7+RP8rmKIpPLW6wLGCW0C9zdt1c+u+bFLc77R23dOuTapa+6VvW862dfudAiEEcqt1YtmGAGtoYwmMzHA8oOwCwBQb6ZbtAYtKNDsj9LntmyO8tjr7BE+Z17QaKZ/C2FesB3F5M7tpMDbODxxuURvOD1T25ZsbPHbT/roVmNkDg8gbQuEEtyM7hK4VDKHOoAMzjuVEEN6Jl5vHgvEUBt+bzm66HWut2xSGMUtgLsOOhX6MQrSShfDUIEXDSX1Z6/t76Rg9FWpOEjuG7AI5nAxPbHlDsPxrfm3s1o4jywYeo+IUE1XmqLp+2NUGP414p9Z0mSu/LewL7pd9jAmsld0rdpRnf7zUDdv1ocpfSqGnBF57botuo/6/I2xHfHv5BT8WQx/vDwAA")
            yield("/wait 0.3")
            yield("/bait Diadem Hoverworm")
        elseif FishType == "Grade3" then
            DeleteAllAutoHookAnonymousPresets()
            UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1XyW7jOBD9FYOXuUgDUbt0czvLBHAWxAn6EMyBEks2EVl0SCrTnsD/PqCWWJIdx+lOAznMTS5WvVr8WFV8QeNS8QmRSk6yOYpf0GlBkhzGeY5iJUowkD6csgK2h7Q9uqAotsPIQDeCccHUGsXYQBfy9EealxToVqz1NzXWJefpQoNVH7b+qnD80EDnq7uFALngOUUxtqwe8mHoCiMKehbWu8FMFuWyjcDFlvtOCK0Vz3NIVccQd9Xs991yQRnJ3yipj108CMTtB9KPc5zwZ0BxRnLZOjhjcnG6BtkJ0RtAel4P0m//HvIIswXL1DfCqgy1QLaCmSLpo0Sx1xTcD3dxu6hRg3pDFIMihU48/tDO79fabk0F+xcmRNWkuZdwXeTr70wtxqlizzDLyaot3j56+uGOpzDoe3IaT3cLkjPyKM/IMxfaWU/Qpu4YffktpPwZBIqxLugbIbg9h27j8Bubn5NlVZRxMc9ByNaJphBFsRNY7jB6uwcVbjYGOv2hBGnur/6X7vjsH7K6KFTJFOPFOWFFW3gTG2haCrgEKckcUIyQga6qINAVLwAZNcJ6BSjWhdmDN+VS/TTejQAJ+yNEJnrjvPZYnW/jma0gVYLkk1IIKNQnZTlA/bRc90a7k/Fe75XWGRcpUI1fEcOyQ8toWDNTfKUvPCvmMwWrqglvE2qYNRafk0cXrgrsvmBPJWhcRCGwaOIQM7CiwHR9GpiEponp+Bhc7INj4QxtDDRlUl1n2odE8UPNWZ1AG2CT3VsxnjBCYTmaCFLA6Cxfa8grLpYk/4vzRw3StpvvQKrf9a3UpxKUzqK9n1UvWUBxxdVuO9l2niuubuGplTc4dX1cHOgm13qcKcGL+W/3aTkdn1OYQ0GJWB90uw/hXsIJLxv9VrGWtKXTJ3dsCWLQ2S5Z8Xqku/Wf1sCF7eu61GDbqjQqr2DV0Dpg2cvteON7CXeCrfqJ1ZJfTyzwbF28Gu6DqfVsP55cY65v/DhTICaknC/UlC31rMb1wbAVVAtcKeplQH90Jlk9ZLxod/E5sMPobavtzO2Nu4WnkgmgM0VUqRcEvc4dfQ1/8Ub9nsuxew+O4/ZxJO5q7RLzWLIdy6ovRp/OzLAToA4lgUm9DEzXilIzolZoJuBTN0wdm9gB2vzdDo3m9fDwKqjnxsML6g0Q7EX+2wPkXBAKI2c0FopJUpB8NHtcJyXLKQj5x+hapkT0hiA+VLQLCoViKcl1pXQEtcJ4ycuip4ZitwqrVyqnv4aH2lMpMpI2Y6HZl71ouGfbg7eJtzHQl3lbbdePn146tLGWTHQZqwp215Bm+dCftXirto/EHcJZHqWYJIlpRdg3Xc8iZoI9YgbYcUPfS1LHStHGGBDKDvUfcJhQbp9GY7nINMSXIdKet8keXlWvoxNeqAkpUsgbSjXT6H++kY/yjUReRh3PN20nC003C6kZZmlmQupnNIPIwRatGlyNO2hRFQl7eAmlQAIvMC0v9E3XtrBJbIpNgkMvtElCk4igzX83Z9K72REAAA==")
            yield("/wait 0.3")
            yield("/bait Diadem Crane Fly")
        elseif FishType == "Grade2" then
            DeleteAllAutoHookAnonymousPresets()
            UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1XyW7jOBD9lYCXuYgD7dvN7SwdwEkHsYM+BHOgxJJNRBYdkkq3J/C/D6gllmTHcbrTQA5zk4pVrxY9VpWe0ahUfEykkuNsjuJndFaQJIdRnqNYiRIMpA8nrIDtIW2PLimK7TAy0I1gXDC1RrFloEt59jPNSwp0K9b6mxrrivN0ocGqB1s/VTh+aKCL1WwhQC54TlFsmWYP+TB0hREFPQvzzWDGi3LZRuBapvtGCK0Vz3NIVcfQ6qrZb7vlgjKSv1JS33KtQSBuP5B+nKOEPwGKM5LL1sE5k4uzNchOiN4A0vN6kH77ecgDTBcsU18IqzLUAtkKpoqkDxLFXlNwP9zF7aJGDeoNUQyKFDrx+EM7v19ruzUV7F8YE1WT5k7CtyJff2dqMUoVe4JpTlZt8fbR0w93PIVB35PTeJotSM7IgzwnT1xoZz1Bm7pj9OW3kPInECi2dEFfCeEtYrlNCF/Y/IIsqzKNinkOQrZuNakoip3AdIf52D2ocLMx0NlPJUhzo/V3m/HpD7K6LFTJFOPFBWFF+ymwZaBJKeAKpCRzQDFCBrqugkDXvABk1AjrFaBYl2oP3oRL9ct4NwIk7I8QYfTKee2xOt/GM11BqgTJx6UQUKgPynKA+mG57o12J+O93iutcy5SoBq/IoZph5bRsGaq+Eq3AFbMpwpWVVveJtQwayQ+Jo8uXBXYXcEeS9C4KKMusRI7wa5jJtiNUoojP8owDQLbpWFKfCdAGwNNmFTfMu1Dovi+5qxOoA2wye61GE8ZobA8+aov4g8ulhrymoslyb9y/qBB2gb0HUj1Xt9TfSpB6SzaG1t1lwUU11ztNphtL7rm6hYeW3mDU9fHtQLd9lqPUyV4Mf/jPk2n43MCcygoEeuDbvch3Ek45WWj3yrWkrZ0+mTGliAGve6KFS9Hun//bQ5c2L6uSw22rUqj8gJWjbEDlr3cjje+kzATbNVPrJb8fmKBZ+vi1XDvTK1n+/7kGnN940eZAjEm5XyhJmypp7dVHwxbQbXSlaJeD/RDZ7bVQ8aLdifWga1G719tZ25v3C08lkwAnSqiSr0y6AXv6Gv4mzfqz1yO3XtwHLePI3FXa5eYx5LtWFZ9Mvp0ZoZJAjcAz8OZbVLsZhnFJLU8HIQBhTQilg0e2vzTDo3mf+L+RVDPjftn1B8gphm9PkAuBKFwYp+MhGKSFCQ/mT6sk5LlFIT8S79kGqw7Bq1DZbukUCiWklzXSsdQK4yWvCx6aih2vWi40Dn91TzUnkqRkbQZDM0O7UXD3dserJXexkCf5n9ru4D88tqhjbVkrMtYVbC7iDTrh36sxVu1fTTuUM7JwiRKIcGR6SXYTQLAUZICJpmTun4ASeaFaGMMKGWH+gMcppTbJ9JILj4Xkfb8r+zhVfXHdMoLNSZFCnlDqWYe/c838l6+Rant+VHmYDMMbOxGLmASQoRpaIEfmuAkXlC1uBp30KQqEvbwLN9yAtPyceL7HnazxMdR5oSYhLZJLdc2wfLQ5j9q5zDb7REAAA==")
            yield("/wait 0.3")
            yield("/bait Diadem Hoverworm")
        end
    else
        yield("/ahpreset " .. CustomAutoHookPreset)
        yield("/wait 0.3")
        yield("/bait " .. CustomAutoHookPresetBait)
    end
end

function SetUmbralAutoHookPreset()
    if GetActiveWeatherID() == 133 then -- Umbral Flare
        DeleteAllAutoHookAnonymousPresets()
        UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1XS2/bOBD+KwYvexEBUaKeN8d5bIA0LeoUPQR7oMSRTYQWXYrKNlv4vxfUI5b8ShNkgQW2N5ocfvPN6OPM+Aea1kbNWGWqWbFA6Q90UbJMwlRKlBpdg4Ps4Y0oYXvI+6NrjlIvThz0SQulhXlCKXHQdXXxPZc1B77dtvabFuuDUvnSgjULz64anDB20NX6bqmhWirJUUpcd4R8GrrBSKLRDfdFMrNlveoZUOLSFyj0t5SUkJvBRTI08152qzQXTB5JaUgo2SFCx0TGPKeZegSUFkxWvYNLUS0vnqAaUAx2IINgBBn2n4c9wHwpCnPGRBOh3aj6jblh+UOF0qBLeBjv4w5Rkw71EzMCyhwGfMLde+E4115/VYt/YMZMK5re6+5tb+dL+d3tuyWTgj1Ul+xRaQsw2ujD8Z3x/mfI1SNolBKbpEOqD2MrloHDPn9nYnHFVk2g03IhQVe9EysLjlI/cuke+xFUvNk46OK70ax7kzbzd2r+N1tfl6YWRqjyiomyzwcmDrqpNXyAqmILQClCDrptSKBbVQJyWoSnNaDUJuYA3o2qzJvxPmmo4DBDhNGR89Zjc77lM19DbjSTs1prKM07RbmD+m6xHmS7F/FB743VpdI5cIvfCMP1otjpVDM3am0fsSgXcwPrprBuA+qUNdXvE8cQriH2pRTfarC4qMi4zz0vw4xmEaZFQXDiJgnmNKEsSzyXBT7aOOhGVOZjYX1UKL1vNWsD6Al20R3jeC4Yh9XkjEmpVDk5qxcW9FbpFZN/KvVgYfoi8hVY87t9l/a0AmPj6F/ox1I+fV1CeavMNDfiEeZye9jZt5mgJLIlqkeeG63Kxbthu/4A+wYWUHKmn07CH0I4V3Umn6MeWXhh8mywJX/UZMThgNWdFutjnqLA859NjvkaGZ3w1tlZlU8LA3rG6sXS3IiV7TmkPdiVfzOI1LptanYxqN4HSrQfBcl+Pz/Rmu0Q0RenXnKf4VstNPC5Yaa2fc9OKbs6/DVF/bI2fkvgTRJ46zcf1LqQxAEtCMGQc1vrsgIzDgQDhYgGUZQHIUWbv/pi102y988bbb27/4FGhc+Lk+B44bvSjMOETuYPT1ktJAdd/TGZVsvCQgyLNjmVrGsOpRE5kzZD1nNrMF2puhyZoZQGye744Y9Hwdh6qnXB8q64HZxSaWDD2h/CzlVpZqzMQXb5aebS0YATbBz0n/kbsO2qb+6l9rLdmdlsN4kedteup9plu701O6TxgR55GPhBHMUYXMoxDZMAM5YTHLMk96Ii40FQoI2zrzf6Sr1dLVVlJpcMtBhH91t0/zvRuV7MMhb7mPOCYBrnMU4in+GAFH4WekkY+3RfdK5rIz4tOm8y1UZUrGRyLL+ZWoH5VwreYQm9XoqntPdbY+y1Gsu5Szw3ITjxswBTiAhmbpFjj8Zu5LluzHjbaFvcjuKXVaaZnFxKpmGCJ68Q1cC1n3ihl/suDnPXxZQUHCckiTALeRDFeVRkRYw2PwEwWw2fGBMAAA==")
        yield("/wait 0.3")
        yield("/bait Diadem Balloon Bug")
    elseif GetActiveWeatherID() == 135 then -- Umbral Levin
        DeleteAllAutoHookAnonymousPresets()
        UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1XyW7jOBD9FYOXuYiASFHrzXGWCeBOB3EafQjmQIklm4gsuikq05mG/31ALbHk2EknyGGAyY0mi69elR6ryr/QtDZqxitTzfIlSn6hs5KnBUyLAiVG1+AgeziXJewORX90KVBCo9hB11oqLc0jSoiDLquzn1lRCxC7bWu/bbG+KJWtLFizoHbV4ASRgy42tysN1UoVAiXEdUfIL0M3GHE4uuG+Sma2qtc9A0Zc9gqF/pYqCsjM4CIZmtHX3SotJC+OpDQgjOwRYWMiY57TVD0ASnJeVL2Dc1mtzh6hGlD09yB9fwQZ9J+H38NiJXNzwmUTod2o+o2F4dl9hRK/S3gQPccdosYd6jU3EsoMBnyC/XvBONe0v6rlPzDjphVN73X/Nt37Ul53+3bFC8nvq3P+oLQFGG304XjOeP8GMvUAGiXEJumQ6oPIimXgsM/fiVxe8HUT6LRcFqCr3omVhUCJF7rsGfsRVLTdOujsp9G8e5M287dq8TffXJamlkaq8oLLss8HJg6a1xq+QFXxJaAEIQddNSTQlSoBOS3C4wZQYhNzAG+uKvNuvGsNFRxmiDA6ct56bM53fBYbyIzmxazWGkrzQVHuoX5YrAfZPov4oPfG6lzpDITFb4Th0jB2OtUsjNrYRyzL5cLApimsu4A6ZU31x8QxhGuIfSvljxosLkojkcUipphllGMWhz6Oc6A49SEmJA1pnvpo66C5rMzX3PqoUHLXatYG0BPsojvG8VRyAevJDYjJCS8KpUoLeqX0mhd/KnVvYfoi8h1487t9l/a0AmPj6F/o17J4/L6C8kqZaWbkAyyK3WFn32aCkdCWqB55YbQqlx+G7XoD7DksoRRcP74IfwjhVNVp8RT1yIIG8ZPBjvxRkxGHA1a3Wm6OeQp96j2ZHPM1MnrBW2dnVT7NDegZr5crM5dr23NIe7Av/2YQqXXb1OxiUL0PlGgv9OPn/fyF1myHiL449ZK7gR+11CAWhpva9j07pezr8PcU9dva+JTAuyTw3m8+qHXcZSEJYxczJkLMAprhKKQBFsIFT4TEc1OOtn/1xa6bZO+eNtp6d/cLjQofjWL/eOG70FzAhE0W949pLQsBuvpjMq1WuYUYFm3yUrIuBZRGZrywGbKeW4PpWtXlyAwlzI/3xw9vPApG1lOtc551xe3glMp8G9bzIexUlWbGywyKLj/NXDoacPytg/4zfwN2XfXdvdRetjszm+0m0cPu2vVUu2y3d2aHND7QoxcJj+Q5xySLU8wyznDEU4pzwYGLMHJZFKCt81xv7I16u1ipykzOOWg5ju5TdP870fmUBgJIjnmUC8w8HuI0pi72U0ozQrifxwdERwKXviY6bzLVRla85MVYfrNC1aJacX3/4eI7rKG3a/El8X2KjL9VZEGQMRa4EY6jPMUsjwBHWc4wJzQP/ZDSALKm07a4HcVv61TzYjKHB1lO8OQtqhp2+dwlHksZ9lwSYibcAHNCYhxSnvMohcjlEdr+C5UmhXgaEwAA")
        yield("/wait 0.3")
        yield("/bait Diadem Red Balloon")
    elseif GetActiveWeatherID() == 136 then -- Umbral Tempest
        DeleteAllAutoHookAnonymousPresets()
        UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACu1XS2/bOBD+KwYvexEBiaKeN9d5bAA3DeoUPQR7oMSRTUQWXYrKxhv4vxfUI5Zsx7GLLLDA9kaTnG++GX2cGb+gcaXlhJW6nGRzFL+gy4IlOYzzHMVaVWAhczgVBWwPeXd0w1FMwshCd0pIJfQaxY6FbsrL5zSvOPDttrm/abA+S5kuDFi9IGZV4/ihha5X9wsF5ULmHMWObQ+Qj0PXGFEwsLDfJTNZVMuOAXVs+g6FzkrmOaS6Z+j0r5H33UrFBcvfSKnvUGeHCB0SGfIcJ/IJUJyxvOwcXIlycbmGskfR24H0vAGk330e9gizhcj0JybqCM1G2W3MNEsfSxR7bcL9cB+3jxq1qHdMCyhS6PHxd+38Ya5JZ6rEPzBhuhFN53XXmux8Kbe1vl+wXLDH8oo9SWUABhtdOK413P8KqXwChWLHJOmQ6v3QiKXnsMvfJzG/Zss60HExz0GVnRMjC45iN7DpHvsBVLjZWOjyWSvWvkmT+Xs5+5utbgpdCS1kcc1E0eUDOxaaVgo+Q1myOaAYIQvd1iTQrSwAWQ3CegUoNok5gDeVpf5lvDsFJRxmiDB647zxWJ9v+cxWkGrF8kmlFBT6g6LcQf2wWA+y3Yv4oPf61pVUKXCDXwvDJqFttaqZabkyj1gU85mGVV1YtwG1yhqrj4mjD1cT+1aIHxUYXER8kngsIhgI9zENMxtHWRJg4A6zA99zfS9EGwtNRam/ZMZHieKHRrMmgI5gG91bHC8E47AcTRQrYHSVrw3krVRLlv8p5aMB6UrId2D17+ZVmtMStImie59finz9fQHFrdTjVIsnmOXbw/Z+kwfqBKZAdcgzrWQx/zBs2+1hT2EOBWdqfRT+EMKFrJL8Ner2xmtJqov+jiHxo1e7bUznWg4Yn258r8TqTLqBR9xXyzMJD2zPp9yam9c2zjSoCavmCz0VS9P7nOZg9xnWA1GlmuZqFr0ucqBVuIEX7fbIo5OJGWa6ItmJ/yv8qIQCPtNMV6b/mmlp90Wcpu2TVXqyGE9Q3WnyeldHJwnmVGX8SxLovjk985v3am7A3JS7iYe9gHmYUpdjZmcUp1kQ+Lab+q5H0Oavrui2E/XD60ZTdx9e0KAAk9Do8K0CfK0YhxEdzR7XSSVyDqr8YzQuF5mB6DcP51iybjgUWqQsNxkynpsL46WsisE1FFMv2h2D3OFIGhpPlcpY2pbZg9My3X9e9TB4IQs9YUUKeZuftgD0Bi1vY6H/zN+RbXf/5Z5ujM3OxGS7TnS/y7e93Syb7e21Qxrv6ZH7IQ/DiGLHI4ApzwhmERh50jQhtue4AUcba19v9Ey9XS9kqUdXDJQYRvdbdP870dlAvTCKfAwAAaYEGE7C1MOhw8LAc4EARPuic3yTseOic0djpUXJCpbvlDuVLhjIlQa1fv5w/R2W0flyPKa/3zpj5+qMuFlkO0GAU5dzTFNIcUQSwC73vMh2SebxqG62DW5L8dsyUSwf3cNyBaUe4dGZ0uoRoAmhIU1CnAVZiGlCUhwxiHAQuGkAfpoAELT5CZ1PyNaqEwAA")
        yield("/wait 0.3")
        yield("/bait Diadem Crane Fly")
    end
end

function weathercheck()
    if UmbralFish == true and FishType == "Grade4" and GetActiveWeatherID() == 133 then
        GetUmbralBait()
        if UmbralBait > 0 then
            return true -- umbral flare detected and have bait to fish
        else
            if CheckUmbralEcho == 0 then
                yield("/echo You have "..UmbralBait.." "..UmbralBaitName.." available, skipping "..UmbralWeatherType.." weather.")
                yield("/echo Buy "..UmbralBaitName.." for "..UmbralWeatherType.." weather.")
                CheckUmbralEcho = 1
            end
            return false -- umbral flare detected but no bait to fish
        end
    elseif UmbralFish == true and FishType == "Grade4" and GetActiveWeatherID() == 135 then
        GetUmbralBait()
        if UmbralBait > 0 then
            return true -- umbral levin detected and have bait to fish
        else
            if CheckUmbralEcho == 0 then
                yield("/echo You have "..UmbralBait.." "..UmbralBaitName.." available, skipping "..UmbralWeatherType.." weather.")
                yield("/echo Buy "..UmbralBaitName.." for "..UmbralWeatherType.." weather.")
                CheckUmbralEcho = 1
            end
            return false -- umbral levin detected but no bait to fish
        end
    elseif UmbralFish == true and FishType == "Grade4" and GetActiveWeatherID() == 136 then
        GetUmbralBait()
        if UmbralBait > 0 then
            return true -- umbral tempest detected and have bait to fish
        else
            if CheckUmbralEcho == 0 then
                yield("/echo You have "..UmbralBait.." "..UmbralBaitName.." available, skipping "..UmbralWeatherType.." weather.")
                yield("/echo Buy "..UmbralBaitName.." for "..UmbralWeatherType.." weather.")
                CheckUmbralEcho = 1
            end
            return false -- umbral tempest detected but no bait to fish
        end
    elseif UmbralFish == true and FishType == "Grade4" and GetActiveWeatherID() ~= 133 and GetActiveWeatherID() ~= 135 and GetActiveWeatherID() ~= 136 then
        CheckUmbralEcho = 0
        return false -- umbral duststorm or normal weather detected
    end
end

function GetUmbralBait() -- all at Windbreaking Cloudtop (X27, Y9)
    if GetActiveWeatherID() == 133 then -- Diadem Balloon Bug
        UmbralBait = GetItemCount(30278)
        UmbralBaitName = "Diadem Baloon Bug"
        UmbralWeatherType = "Umbral Flare"
    elseif GetActiveWeatherID() == 135 then -- Diadem Red Balloon
        UmbralBait = GetItemCount(30279)
        UmbralBaitName = "Diadem Red Baloon"
        UmbralWeatherType = "Umbral Levin"
    elseif GetActiveWeatherID() == 136 then -- Diadem Crane Fly
        UmbralBait = GetItemCount(30280)
        UmbralBaitName = "Diadem Crane Fly"
        UmbralWeatherType = "Umbral Tempest"
    end
end

-- Setting up the some stuff
CurrentJob = GetClassJobId()
DiademHoverwormCount = GetItemCount(30281)
DiademCraneFlyCount = GetItemCount(30280)
CheckUmbralEcho = 0
PandoraSetFeatureState("Auto-Cordial",UseCordial)
if NpcRepair and SelfRepair then
    NpcRepair = false
    yield("You can only select one repair setting. Setting Npc Repair false")
end
if NpcRepair then
    BuyDarkMatter = false
end

-- Set properties if they are not already set
setPropertyIfNotSet("UseItemStructsVersion")
setPropertyIfNotSet("UseSNDTargeting")

-- Unset properties if they are set
unsetPropertyIfSet("StopMacroIfTargetNotFound")
unsetPropertyIfSet("StopMacroIfCantUseItem")
unsetPropertyIfSet("StopMacroIfItemNotFound")

--Start up message

if ForceAutoHookPreset == true then
    if FishType == "Grade4" then
        yield("/e Fishing at Blustery Cloudtop for Grade 4 artisanal fish using script's default AH preset.")
        yield("/wait 0.1")
        if UmbralFish == true then
            yield("/e Moving for umbral fish during umbral weathers if appropriate bait is in inventory.")
            yield("/wait 0.1")
            yield("/e If this is incorrect please stop script and fix settings.")
            yield("/wait 0.1")
        elseif UmbralFish ~= true then
            yield("/e Not moving for umbral fish during umbral weathers.")
            yield("/wait 0.1")
            yield("/e If this is incorrect please stop script and fix settings.")
            yield("/wait 0.1")
        end        
    elseif FishType == "Grade3" or FishType == "Grade2" then
        if FishType == "Grade3" then
            yield("/e Fishing at Windbreaking Cloudtop for Grade 3 artisanal fish using script's default AH preset.")
            yield("/wait 0.1")
        elseif FishType == "Grade2" then
            yield("/e Fishing at Buffeted Cloudtop for Grade 2 artisanal fish using script's default AH preset.")
            yield("/wait 0.1")
        end
        yield("/e Not moving for umbral fish during umbral weathers.")
        yield("/wait 0.1")
        yield("/e If this is incorrect please stop script and fix settings.")
        yield("/wait 0.1")
    else
        yield("/e Please check FishType setting: "..FishType.." not recognized, stopping script.")
        yield("/wait 0.1")
        yield("/snd stop")
    end
elseif ForceAutoHookPreset == false then
    if FishType == "Grade4" then
        yield("/e Fishing at Blustery Cloudtop using custom AH preset named: "..CustomAutoHookPreset.." and using bait: "..CustomAutoHookPresetBait..".")
        yield("/wait 0.1")
        if UmbralFish == true then
            yield("/e Moving for umbral fish during umbral weathers if appropriate bait is in inventory.")
            yield("/wait 0.1")
            yield("/e If this is incorrect please stop script and fix settings.")
            yield("/wait 0.1")
        elseif UmbralFish ~= true then
            yield("/e Not moving for umbral fish during umbral weathers.")
            yield("/wait 0.1")
            yield("/e If this is incorrect please stop script and fix settings.")
            yield("/wait 0.1")
        end        
    elseif FishType == "Grade3" or FishType == "Grade2" then
        if FishType == "Grade3" then
        yield("/e Fishing at Windbreaking Cloudtop using custom AH preset named: "..CustomAutoHookPreset.." and using bait: "..CustomAutoHookPresetBait..".")
            yield("/wait 0.1")
        elseif FishType == "Grade2" then
            yield("/e Fishing at Buffeted Cloudtop using custom AH preset named: "..CustomAutoHookPreset.." and using bait: "..CustomAutoHookPresetBait..".")
            yield("/wait 0.1")
        end
        yield("/e Not moving for umbral fish during umbral weathers.")
        yield("/wait 0.1")
        yield("/e If this is incorrect please stop script and fix settings.")
        yield("/wait 0.1")
    else
        yield("/e Please check FishType setting: "..FishType.." not recognized, stopping script.")
        yield("/wait 0.1")
        yield("/snd stop")
    end
else
    yield("/e Please double check ForceAutoHookPreset setting, stopping script.")
    yield("/snd stop")
end

-- Main loop
while true do
    if GetInventoryFreeSlotCount() == 0 then
        LogInfo(
            "It seems like your inventory has reached Max Capacity slot wise. For the safety of you (and to help you not just stand there for hours on end), we're going to stop the script here and leave the instance")
        yield(
            "/e It seems like your inventory has reached Max Capacity slot wise. For the safety of you (and to help you not just stand there for hours on end), we're going to stop the script here and leave the instance")
        if GetCharacterCondition(34) then
            DutyLeave()
        end
        yield("/snd stop")
    end

    if IsInZone(886) or IsInZone(939) then
        if CurrentJob == 18 then
        else
            yield("/e Switch to Fisher and start the script again.")
            yield("/snd stop")
        end
        if FishType == "Grade4" or FishType == "Grade2" then
            if BuyBait == false and DiademHoverwormCount == 0 then
                yield("/e You don't have Diadem Hoverworm in your inventory, stopping the script.")
                yield("/snd stop")
            end
        elseif FishType == "Grade3" then
            if BuyBait == false and DiademCraneFlyCount == 0 then
                yield("/e You don't have Diadem Crane Fly in your inventory, stopping the script.")
                yield("/snd stop")
            end
        end
        Repair()
        WeGoIn()
        LetsBuySomeStuff()
        if UmbralFish == true and FishType == "Grade4" and weathercheck() == true then
            MoveToDiadem(2)
            Doumbralfishing()
        end
        MoveToDiadem(0)
        Dofishing()
        Repair()
        LetsBuySomeStuff()
        if UmbralFish == true and FishType == "Grade4" and weathercheck() == true then
            MoveToDiadem(2)
            Doumbralfishing()
        end
        MoveToDiadem(1)
        Dofishing()
    else
        yield("/e Maybe go into firmament hee ?")
        yield("/snd stop")
    end
end
