--[[
    
    *******************************************
    *             Diadem Fishing              *
    *******************************************

    Author: UcanPatates  

    **********************
    * Version  |  1.0.9  *
    **********************

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
    -> Simple Tweaks  
    
    **************
    *  SETTINGS  *
    **************
]] 

--Do you want to buy Diadem Hoverworm and DarkMatter if you don't have it ?
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

-- Preset settings here
ForceAutoHookPreset = true -- true | false (default is true) this setting will configure the preset for you and wont use below setting.
CustomAutoHookPreset = "myfishingpreset" -- "custom preset name" get it from AutoHook.
HowManyMinutes = 20     -- this setting is to move every x minutes.
-- (default is 20 not recomended to make it more than 30)


--[[

  ************
  *  Script  *
  *   Start  *
  ************

]]

-- 4th var
-- 0 means First spot to randomly select
-- 1 means Second spot to randomly select
-- 500 is bailout and clear the 500cast thingy
FishingSpot =
{
  {520.7,193.7,-518.1,0}, -- First spot
  {521.4,193.3,-522.2,0},
  {526.3,192.6,-527.2,0},

  {544.6,192.4,-507.8, 1}, -- Second spot
  {536.9,192.2,-503.2, 1},
  {570.3,189.4,-502.7, 1},

  {422.9,-191.2,-300.2, 500} --bailout
}

-- Functions
function setPropertyIfNotSet(propertyName)
    if GetSNDProperty(propertyName) == false then
        SetSNDProperty(propertyName, "true")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to True")
    end
end

function unsetPropertyIfSet(propertyName)
    if GetSNDProperty(propertyName) then
        SetSNDProperty(propertyName, "false")
        LogInfo("[SetSNDPropertys] " .. propertyName .. " set to False")
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
                yield("/pcall SelectIconString true "..SelectIconString)
            elseif IsAddonVisible("SelectYesno") then
                yield("/pcall SelectYesno true 0")
                yield("/wait 0.1")
            elseif ItemCount  >= ExpectedItemCount then
                break --Exit the loop
            elseif IsAddonVisible(ShopAddonName) then
                yield("/pcall " .. ShopAddonName .. " true 0 " .. Slot .. " " .. Amount)
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
        yield("/pcall " .. ShopAddonName .. " true -1")
        yield("/wait 0.1")
    end
end

function NomNomDelish()
    local EatThreshold = HowManyMinutes * 60
    while (GetStatusTimeRemaining(48) <= EatThreshold or HasStatusId(48) == false) and UseFood do
        yield("/item " .. FoodKind)
        yield("/wait 2")
        if GetNodeText("_TextError", 1) == "You do not have that item." and IsAddonVisible("_TextError") then
            UseFood = false
            if StopTheScripIfThereIsNoFood then
                if GetCharacterCondition(34) then
                    DutyLeave()
                end
                LogInfo("[FoodCheck] StopTheScripIfThereIsNoFood is true stopping the script")
                yield("/snd stop")
            end
            LogInfo("[FoodCheck] Set to False No Food Remaining")
            break
        end
    end
    LogInfo("[FoodCheck] Completed")
end

function LetsBuySomeStuff()
    if IsInZone(939) then
        local DiademHoverwormCount = GetItemCount(30281)
        local Grade8DarkMatterCount = GetItemCount(33916)
        local distance = GetDistanceToPoint(-641.2, 285.3, -138.7)
        local BuyBaitMinimum = MinimumBait / 4
        local BuyDarkMatterMinimum = MinimumDarkMatter / 4

        if DiademHoverwormCount < BuyBaitMinimum and BuyBait then
            if distance >= 4 then
                if distance <= 50 and GetCharacterCondition(77, false) then
                    WalkTo(-641.2, 285.3, -138.7)
                else
                    FlyTo(-641.2, 285.3, -138.7)
                end
            end
        end
        if Grade8DarkMatterCount < BuyDarkMatterMinimum and BuyDarkMatterMinimum then
            if distance >= 4 then
                if distance <= 50 and GetCharacterCondition(77, false) then
                    WalkTo(-641.2, 285.3, -138.7)
                else
                    FlyTo(-641.2, 285.3, -138.7)
                end
            end
        end


        local distance = GetDistanceToPoint(-641.2, 285.3, -138.7)
        if BuyBait and distance <= 4 and DiademHoverwormCount < BuyBaitMinimum then
            local BuyAmount = MinimumBait - DiademHoverwormCount 
            BuyPcall(30281, "Mender", "Shop", 0, 6, BuyAmount)
            LogInfo("[Debug]Bought Diadem Hoverworm.")
        elseif not BuyBait and DiademHoverwormCount < BuyBaitMinimum then
            LogInfo("[Debug]BuyBait is False and Bait is running out, continue.")
        end

        yield("/wait 1") -- :D go ahed delete it don't cry to me if its broke tho.

        if BuyDarkMatter and distance <= 4 and Grade8DarkMatterCount < BuyDarkMatterMinimum then
            local BuyAmount = MinimumDarkMatter - Grade8DarkMatterCount 
            BuyPcall(33916, "Mender", "Shop", 0, 14, BuyAmount)
            LogInfo("[Debug]Bought Grade8 DarkMatter.")
        elseif not BuyDarkMatter and Grade8DarkMatterCount < BuyDarkMatterMinimum then
            LogInfo("[Debug]BuyDarkMatter is False and DarkMatter is running out, continue.")
        end

        while IsAddonVisible("Shop") do
            yield("/pcall Shop true -1")
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
        return nil
    end
    return distance
end

function MountAndFly()
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
end

function NpcRepairMenu(Name)
    while true do
        if not NeedsRepair(RepairAmount) then
            break
        elseif GetTargetName() ~= Name then
            yield("/target "..Name)
            yield("/wait 0.1")
        elseif IsAddonVisible("SelectIconString") then
            yield("/pcall SelectIconString true 1")
        elseif IsAddonVisible("SelectYesno") then
            yield("/pcall SelectYesno true 0")
            yield("/wait 0.1")
        elseif IsAddonVisible("Repair") then
            yield("/pcall Repair true 0")
        else
            yield("/interact")
        end
        yield("/wait 0.1")
    end
    while IsAddonVisible("Repair") do
        yield("/pcall Repair true -1")
        yield("/wait 0.1")
    end
    LogInfo("[RepairNpc]Got Repaired by "..Name .." .")
end

function Repair()
    if NeedsRepair(RepairAmount) and SelfRepair then
        while not IsAddonVisible("Repair") do
            yield("/generalaction repair")
            yield("/wait 0.5")
        end
        yield("/pcall Repair true 0")
        yield("/wait 0.1")
        if GetNodeText("_TextError", 1) == "You do not have the dark matter required to repair that item." and
            IsAddonVisible("_TextError") then
            SelfRepair = false
            LogInfo("[Repair] Set to False not enough dark matter")
            if StopTheScripIfThereIsNoDarkMatter then
                if GetCharacterCondition(34) then
                    DutyLeave()
                end
                yield("/snd stop")
            end
        end
        if IsAddonVisible("SelectYesno") then
            yield("/pcall SelectYesno true 0")
        end
        while GetCharacterCondition(39) do
            yield("/wait 1")
        end
        yield("/wait 1")
        if IsAddonVisible("Repair") then
            yield("/pcall Repair true -1")
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
end

function WalkTo(valuex, valuey, valuez)
    MeshCheck()
    PathfindAndMoveTo(valuex, valuey, valuez, false)
    while PathIsRunning() or PathfindInProgress() do
        yield("/wait 0.1")
    end
    LogInfo("[WalkTo] Completed")
end

function FlyTo(valuex, valuey, valuez)
    MeshCheck()
    MountAndFly()
    PathfindAndMoveTo(valuex, valuey, valuez, true)
    while PathIsRunning() or PathfindInProgress() do
        yield("/wait 0.1")
        MountAndFly()
    end
    LogInfo("[FlyTo] Completed")
end

function Dismount()
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
        end
    end
    LogInfo("[Dismount] Completed")
end

function Truncate1Dp(num)
    return truncate and ("%.1f"):format(num) or num
end

function MeshCheck()
    local was_ready = NavIsReady()
    if not NavIsReady() then
        while not NavIsReady() do
            LogInfo("[Debug]Building navmesh, currently at " .. Truncate1Dp(NavBuildProgress() * 100) .. "%")
            yield("/wait 1")
            local was_ready = NavIsReady()
            if was_ready then
                LogInfo("[Debug]Navmesh ready!")
            end
        end
    else
        LogInfo("[Debug]Navmesh ready!")
    end
end

function MoveToDiadem(RandomSelect)
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
        elseif RandomSelect == 500 then
            local oceanX, oceanY, oceanZ = X + 1.2, Y, Z - 1.2
            WalkTo(oceanX, oceanY, oceanZ)
        end
        LogInfo("[MoveToDiadem] Completed")
    end
end

function Bailout500Cast()
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
end

function Dofishing()
    if not GetCharacterCondition(4) then
        local MoveEveryMin = HowManyMinutes * 60
        NomNomDelish()
        if IsInZone(939) then
            SetAutoHookPreset()
            if ForceAutoHookPreset then
                yield("/wait 0.3")
                yield("/bait Diadem Hoverworm")
            end
            yield("/wait 0.3")
            yield("/ahon")
            fishing_start_time = os.time()
            yield("/ac Cast")
            yield("/wait 0.3")
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
            while GetCharacterCondition(6) do
                yield("/ac Quit")
                yield("/wait 1")
            end
            PlayerTest()
            LogInfo("[Fishing] Completed")
        end
    end
end


function WeGoIn()
    while IsInZone(886) do
        local distance = DistanceToAurvael()
        if distance and distance > 4 then
            WalkTo(-18.4, -16.0, 143.2)
        end
        if distance and distance < 4 then
            if IsAddonVisible("ContentsFinderConfirm") then
                yield("/pcall ContentsFinderConfirm true 8")
                yield("/wait 1.5")
            elseif GetTargetName() ~= "Aurvael" then
                yield("/target Aurvael")
            elseif GetCharacterCondition(32, false) then
                yield("/interact")
            elseif IsAddonVisible("Talk") then
                yield("/click talk")
            elseif IsAddonVisible("SelectString") then
                yield("/pcall SelectString true 0")
            elseif IsAddonVisible("SelectYesno") then
                yield("/pcall SelectYesno true 0")
            end
            yield("/wait 0.5")
        end
    end
    PlayerTest()
    LogInfo("[WeGoIn] Completed")
end

function SetAutoHookPreset()
    if ForceAutoHookPreset then
        DeleteAllAutoHookAnonymousPresets()
        UseAutoHookAnonymousPreset("AH4_H4sIAAAAAAAACuVXS3PTMBD+KxlfuAQmcR5NejNpaZkppYPDcGA4qI4Sa6JYQZZbQif/nV1LcizHrlM4wAynuqvdb799SLt58oJMiRlJVTpbrrzzJ+8yIfecBpx750pmtOvh4Q1L6OFwYY/ew5c/mXa9O8mEZGrnnfdBml7+iHi2oIuDGPX3GuuDEFGMYPmHj185znjS9a6281jSNBYcJP1ez0F+HjrHmJ45Fr1WMrM421gGw35v2ELBWgnOaaRKhv2ymt/uVsgFI7whpX1/PJ5WmAxdJi7R4F48QH2WhKfWwzuWxpc7mpY4jiqQo5EDObb1IWsaxmyp3hKWh4iC1ApCRaI1oAKYqdoxbhl1alDviGI0iWiJz7hqN3aT7VtTyX7SGVG6az6n9GPCd1+YioNIsQcacrJ1GhIoVaH9Sh0HBnoeE87IOn1HHoREdEdgYx10XfknGkG+Qb+PGay7E0Bh6Dgc78Hj5Q8liblmmMu5CB/J9n2iMqaYSK4IS2x6XkND3ZINpMu7FXD3wLrG4kak6hmLO4if1nvxXnsN5xozPz94DLfQ7pLwWSYlTdTJTCt2L+Bb6/GIdS1+rhUkK06hgmKLN4Elq1BRaJN+mZ3WSQN5KqmyAXgpTo1J+EiJWoI78H/DUvVxib6ggb7qeiMT62nQ8ycHZxeMLOimc41t9SjkBqFv4S/h10Ks0cbeny+U5P/rrsNT8I/cbP+haM42VFb68gNLiiPIw/ANtK4xn++2QGLYP8PLah2FSookb1WjVeDlz0y3mUF+PWOa3Ap1fEMrLnuDkssbuqLJgshda4BVBHgULkRm9K2iltiE/XZe/DGmRYO1JqXR0ontdGMIbC7Z1g1MS/48sLORj8nTcC8MzbF9eXDGHO9nsFRUzki2imHN2ODIwTFbvEf2Anyi3zMm6QIeZZXhAMJ9oXorXtTQ7T1Yp3jcVad1ymktUdY6LvOppTu1RqcWA9WRR6XD8vYCCE0R061lmk+DsiWL6dTSglmDRYn5wQh9Fj3yDK9C55hgm3lFq5ZyG8axYjWIi+v5dY2xdt5wWKDWnDdV8ZudSWb//loI9FiCGeXMJ3+KO5OZT1cS5lNn2IHJx1KSEN4J17v7jPEFjMNXncPga24j3IxgRLMIpjVsXuhHKwQbkSWOGqRoNK2ucAN3W52gp0wuSWTGi1krR9NRy+43Ast/5jfIYRl5ZgXBY1ScYaLyHJWXErPw4KcWW7V9t/TrwrzCboknmKxKiZ3CBmn818tas183VflCJGpG4BXnpsAm6v+x+rpi7vK7/7b/BS5IxOjxDwAA")
    else
        yield("/ahpreset " .. CustomAutoHookPreset)
    end
end

-- Setting up the some stuff
CurrentJob = GetClassJobId()
DiademHoverwormCount = GetItemCount(30281)
PandoraSetFeatureState("Auto-Cordial",UseCordial)
if not SelfRepair then
    BuyDarkMatter = false
end
if NpcRepair and SelfRepair then
    NpcRepair = false
    yield("You can only select one repair setting. Setting Npc Repair false")
end

-- Set properties if they are not already set
setPropertyIfNotSet("UseItemStructsVersion")
setPropertyIfNotSet("UseSNDTargeting")

-- Unset properties if they are set
unsetPropertyIfSet("StopMacroIfTargetNotFound")
unsetPropertyIfSet("StopMacroIfCantUseItem")
unsetPropertyIfSet("StopMacroIfItemNotFound")

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
        if BuyBait == false and DiademHoverwormCount == 0 then
            yield("/e You don't have Diadem Hoverworm in your inventory stopping the script.")
            yield("/snd stop")
        end
        Repair()
        WeGoIn()
        LetsBuySomeStuff()
        MoveToDiadem(0)
        Dofishing()
        Repair()
        LetsBuySomeStuff()
        MoveToDiadem(1)
        Dofishing()
    else
        yield("/e Maybe go into firmament hee ?")
        yield("/snd stop")
    end
end
