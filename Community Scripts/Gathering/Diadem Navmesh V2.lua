--[[

    *******************
    * Diadem Farming  *
    *******************

    ************************
    * Version | 0.0.1.22  *
    ************************
   
    Version Notes:
    0.0.1.22 ->    -Added more routes.
                       -> One additional 8 node loop for miner, two additional 16 node loops for miner.(4 miner routes now, RedRoute is default route)
                       -> One additional 8 node loop for botanist, two additional 16 node loops for botanist.(4 botanist routes now)
                   -Added GP reserve setting to allow Bountiful Yield II spam to not affect +5 node Buffs set as true by default,
                   -Modified script to enable ability to set class to route chosen if on wrong class when script started
                       -> Need to enable and have Botanist and Miner gearsets
                   -Added mob_table to detour to island murderfields for a specific mob you want to focus if it is not found while gathering ; fixed name of Diadem Biast to Diadem Beast
                       -> When aether bar sets designated value in settings it will detour to the mob island spot and unload all bars
                       -> Will still kill mob if encountered while gathering
                   -Added Revisit Proc check, so buffs reapply if revisit procs on umbral node or +5 gathering nodes
                   -Added option to gather umbral nodes (all), it will swap to the appropriate class and only go once enough GP is available for buffs selected
                       -> Need to have Botanist and Miner gearsets
                       -> umbral nodes you don't want should be able to be commented out with a -- before the table entry to skip that node or nodes
                       -> will only gather umbral node once per weather then return to farming unless PrioritizeUmbrals set to true.
                   -Added buff options for umbral node gathering, as well as options to conserve GP if gathering umbrals and umbral weather detected
                   -Class check will now occur based on assigned route if node isn't found before exiting duty to reset.
    0.0.1.21 ->    Update for snd version click changes.
    0.0.1.20 ->    Update for DT changed the /click talk to /click  Talk_Click.
    0.0.1.19.2 ->  More Pandora settings added to count for user error if you have Auto-interact with Gathering Nodes and Auto-Mount after Gathering they are disabled now.
    0.0.1.19.1 ->  Now you don't need to configure plugin options i got you ;D
    0.0.1.19 ->    Anti stutter now configurable for gathering loops.
    0.0.1.18.4 ->  Added a option to not use aether cannon , New option anti stutter added Tweaked some of the killing logic.
    0.0.1.18.3 ->  Fixed the 4.node of PinkRoute Hopefully fixed the rare accurance of not getting in diadem again
    0.0.1.18.2 ->  Litle fix for jumping before nodes and fixed the automation
    0.0.1.18 ->    Some automation Bug fixes, safeties added in places (missing a node in a loop will reset the instance)
    0.0.1.17 ->    Now it will go to other nodes and continue if the target you were trying to kill got stolen(yea i know we already fixed it once)
    0.0.1.16 ->    Fixed the rare getting stuck after killing mobs issue. (this time it is a real fix)
    0.0.1.15 ->    . . . This hasn't been miner edition for awhile. NAME CHANGED
    0.0.1.14 ->    (Man I thought I would of been done with this) Made a "CapGP" setting. If you want it to spend GP before you get to cap, change this to false. (this will use YieldII)
    0.0.1.13 ->    Targeting system has been overhauled on the mob kill side, now it SHOULD only target the mobs you want to target. (this also means you can edit the table and remove which mobs you ONLY want to target.)
    0.0.1.12 ->    Switched over the debug to output to XlLog under "Info" this cleans up chat a lot, but also has it in a neat place for us to track where things might of broke
    0.0.1.11 ->    Partially fixed the getting stuck after killing mobs fixed the dismount problem that made you fall down infinitely
    0.0.1.10 ->    New node targeting fixes spawn island aether current fix 
    0.0.1.8  ->    Tweaked the Node targeting should work better and look more human now.
    0.0.1.7  ->    Fixed the nvamesh getting stuck at ground while running path. Added target selection options Twekaed with eather use if you unselect the target or somehow it dies script will contuniue to gather.
    0.0.1.6  ->    Pink Route for btn is live! After some minor code tweaking and standardizing tables. 
    0.0.1.5  ->    Fixed Job checking not working properly
    0.0.1.4  ->    Fixed Gift1 not popping up when it should 
    0.0.1.2  ->    Fixed the waiting if there is no enemy in target distance now script will contuniue path till there is one and Aether use looks more human now
    0.0.1.0  ->    Man... didn't tink I'd hit this with how big this was getting and the bugs I/We created in turn xD 
                  This is the complete version of this script for now. I'm afraid if i change up the codebase anymore, then it's going to break. XD So going to push this as a released version, then focus on re-factoring the code in a different script (with blackjack and hookers)
                  Main things is:
                    -> Red Route is up and running 
                    -> Aethercannon is online and functional (and doesn't crash)
                    -> Ability to select which node your going to hit in the settings (don't be a dumb dumb and set it to where it'll try and gather something outside your gathering range, it won't')
                    -> Ability to ACTUALLY use the proper GP skills on the +10 integ node as well so you can maxamize on getting your items
                    -> Vnavmesh also fixed the pathing issue in v31, so that's also to a point where I feel comfortable releasing this with the "AllIslands" route. 
                  Thank you @UcanPatates with the help on this. I look foward to us making this the best diadem script we can in lua, then maybe translate that into a plugin in itself. 

    ***************
    * Description *
    ***************

    (What was suppose to be a leveling script xD) 
    A SND Lua script that allows you to loop through and maximize the amount of points that you can get in a timespan. 
    This includes (but limited to)
        -> Aethercannon Usage 
        -> Fully Automated Gathering 
        -> Using skills on the proper node 
        -> More dynamic pathing (to hopefully prevent everyone looking as botty)

    PLEASE. CHANGE. SETTINGS. As necessary

    *********************
    *  Required Plugins *
    *********************

    -> visland -> https://puni.sh/api/repository/veyn
    -> SomethingNeedDoing (Expanded Edition) [Make sure to press the lua button when you import this] -> https://puni.sh/api/repository/croizat
    -> Pandora's Box -> https://love.puni.sh/ment.json
    -> vnavmesh : https://puni.sh/api/repository/veyn


    ***********
    * Credits *
    ***********

    Author(s): Leontopodium Nivale | UcanPatates 
    Class: Miner | BTN

    **************
    *  SETTINGS  *
    **************
]]

UseFood = true
FoodKind = "Sideritis Cookie <HQ>"
RemainingFoodTimer = 5 -- This is in minutes
-- If you would like to use food while in diadem, and what kind of food you would like to use. 
-- With the suggested TeamCraft melds, Sideritis Cookies (HQ) are the best ones you can be using to get the most bang for your buck
-- Can also set it to where it will refood at a certain duration left
-- Options
    -- UseFood : true | false (default is true)
    -- FoodKind : "Sideritis Cookie" (make sure to have the name of the food IN the "")
    -- RemainingFoodTimer : Default is 5, time is in minutes

FoodTimeout = 5 
-- How many attempts would you like it to try and food before giving up?
-- The higher this is, the longer it's going to take. Don't set it below 5 for safety. 

RouteType = "RedRoute"
-- Select which route you would like to do.
    -- Options are:
        -- "RedRoute"     -> min perception route, 8 node loop, (Stalagmite > Prismstone > Cloudstone)
        -- "MinerDoubleRoute"     -> min perception and gather routes, 16 node loop, (Stalagmite > Prismstone/Springwater)
        -- "SilexRoute"     -> min perception route, 8 node loop, (Silex > Springwater > Cloudstone)
        -- "SilexDoubleRoute"     -> min perception and gather routes, 16 node loop, (Silex > Prismstone/Springwater)
        -- "PinkRoute"    -> Btn perception route, 8 node loop
        -- "BotanyDoubleRoute"    -> Btn perception and gather routes, 16 node loop (Cocoon > Logs > Raspberry)
        -- "BarbRoute"    -> Btn perception route, 8 node loop (Barbgrass > Logs)
        -- "BarbDoubleRoute"    -> Btn perception and gather routes, 16 node loop (Barbgrass > Cocoon > Logs)

GatheringSlot = 4
-- This will let you tell the script WHICH item you want to gather. (So if I was gathering the 4th item from the top, I would input 4)
-- This will NOT work with Pandora's Gathering, as a fair warning in itself. 
-- Options : 1 | 2 | 3 | 4 | 7 | 8 (1st slot... 2nd slot... ect)

TargetOption = 1
-- This will let you tell the script which target to use Aethercannon.
-- Options : 0 | 1 | 2 | 3 | 4 (Option: 0 is don't use cannon, Option: 1 is any target, Option: 2 only sprites, Option: 3 is don't include sprites, Option: 4 murder island detours)
-- If using option 4 go to the TargetOption == 4 mob_table and remove the "--" for the specific mob you want to focus
   --Option is for when the mobs you want aren't where you are gathering or aren't common in the area.  The mob will still be killed when encountered gathering

AetherBar = 5
-- This only matters if TargetOption = 4
-- Set this to the amount of bars you want the Aether Gauge to fill to before diverting to islands (recommend 5, but at least 2)

GatherUmbrals = false
AutoSwap = false
    -- GatherUmbrals : true | false (default is false)
    -- AutoSwap : true | false (default is false)
       -- Makesure Miner gearset name is "Miner" and Botanist gearset name is "Botanist" if using either of these
       -- **AutoSwap can be true while GatherUmbrals false, but if GatherUmbrals true both should be set to true.

PrioritizeUmbrals = false
    -- PrioritizeUmbrals : true | false (default is false)
       -- This will leave the duty once the umbral node is gathered to allow the gathering of another node if the umbral weather is still active.
       -- ** Beware Umbral weather isn't synched across instances; i.e. umbral weather can be up in one instance and down in another.
       -- **** This also means that conservation of GP will be active the entire umbral weather (no buffs popping for +5 nodes)

UmbralGatheringSlot = 1
-- This will let you tell the script WHICH item you want to gather in umbral nodes. (So if I was gathering the 1st item from the top, I would input 1)
-- This will NOT work with Pandora's Gathering, as a fair warning in itself. 
-- Options : 1 | 2 | 3 | 4 | 7 | 8 (1st slot... 2nd slot... ect)

CapGP = false 
-- Bountiful Yield 2 (Min) | Bountiful Harvest 2 (Btn) [+x (based on gathering) to that hit on the node (only once)]
-- If you want this to let your gp cap between rounds, then true 
-- If you would like it to use a skill on a node before getting to the final one, so you don't waste GP, set to false

GPReserve = 100
-- Set minimum amount of GP for no Yield II Buff use (Set to your max GP for no bountiful Spam, Set to 100 GP minimum to prevent bountiful spam when no GP if above all false)
-- +5 node buffs are also factored without this.  I.e. if you set it to 100, if GP falls below total GP needed for +5 nodes, bountiful won't be used

--Buffs for +5 hit nodes
BuffYield2 = true -- 500 GP | Kings Yield 2 (Min) | Bountiful Yield 2 (Btn) [+2 to all hits]
BuffGift2 = true -- 100 GP | Mountaineer's Gift 2 (Min) | Pioneer's Gift 2 (Btn) [+30% to perception hit]
BuffGift1 = true -- 50 GP | Mountaineer's Gift 1 (Min) | Pioneer's Gift 1 (Btn) [+10% to perception hit]
BuffTidings2 = true -- 200 GP | Nald'thal's Tidings (Min) | Nophica's Tidings (Btn) [+1 extra if perception bonus is hit]
-- Here you can select which buffs get activated whenever you get to the mega node (aka the node w/ +5 Integrity) 
-- These are all toggleable with true | false 
-- They will go off in the order they are currently typed out, so keep that in mind for GP Usage if that's something you want to consider

--Buffs for umbral nodes
UmbralBuffYield2 = true -- 500 GP | Kings Yield 2 (Min) | Bountiful Yield 2 (Btn) [+2 to all hits]
UmbralBuffGift2 = true -- 100 GP | Mountaineer's Gift 2 (Min) | Pioneer's Gift 2 (Btn) [+30% to perception hit]
UmbralBuffGift1 = true -- 50 GP | Mountaineer's Gift 1 (Min) | Pioneer's Gift 1 (Btn) [+10% to perception hit]
UmbralBuffTidings2 = true -- 200 GP | Nald'thal's Tidings (Min) | Nophica's Tidings (Btn) [+1 extra if perception bonus is hit]
-- Here you can select which buffs get activated whenever you get to the mega node (aka the node w/ +5 Integrity) 
-- These are all toggleable with true | false 
-- They will go off in the order they are currently typed out, so keep that in mind for GP Usage if that's something you want to consider

Repair_Amount = 99
Self_Repair = true --if its true script will try to self reapair
Npc_Repair = false --if its true script will try to go to mender npc and repair
--When do you want to repair your own gear? From 0-100 (it's in percentage, but enter a whole value

PlayerWaitTime = true 
-- this is if you want to make it... LESS sus on you just jumping from node to node instantly/firing a cannon off at an enemy and then instantly flying off
-- default is true, just for safety. If you want to turn this off, do so at your own risk. 

AntiStutterOpen = false
AntiStutter = 2
-- default is 2 gathering loops this will execute the script again if you are having stutter issues 
-- WARNING your macro name should be DiademV2

debug = false
-- This is for debugging 

--[[

***************************
* Setting up values here  *
***************************

]]

--script Started echo for debug
if debug then
    yield("/e ------------STARTED------------")
end
:: Waypoints ::
-- Waypoint (V2) Tables 
local X = 0
local Y = 0
local Z = 0
-- for 4th var 
    -- Stay on mount after fly = 0 
    -- Dismount when point is reached = 1
-- for 5th Var 
    -- mineral target [red] = 0
    -- rocky target [blue]  = 1
    -- mature tree          = 2 
    -- lush vegetation      = 3
    -- Clouded Mineral Deposit      = 4
    -- Clouded Lush Vegetation Patch      = 5    
    -- Clouded Rocky Outcrop      = 6
    -- Clouded Mature Tree      = 7
    -- Non-gathering waypoint      = 99
-- for 6th var
    -- FlyTarget  = 0
    -- MoveTarget = 1
--for 7th var
    -- FirstNode = 1
    -- otherNodes = 0

-- for 8th var
    -- Umbral Flare  = 133
    -- Umbral Duststorms  = 134
    -- Umbral Levin  = 135
    -- Umbral Tempest  = 136

if RouteType == "MinerIslands" then 
    gather_table =
        {
            {-570.90,45.80,-242.08,1,0},
            {-512.28,35.19,-256.92,1,0},
            {-448.87,32.54,-256.16,1,0},
            {-403.11,11.01,-300.24,1,1}, -- Fly Issue #1
            {-363.65,-1.19,-353.93,1,1}, -- Fly Issue #2 
            {-337.34,-0.38,-418.02,1,0},
            {-290.76,0.72,-430.48,1,0},
            {-240.05,-1.41,-483.75,1,0},
            {-166.13,-0.08,-548.23,1,0},
            {-128.41,-17.00,-624.14,1,0},
            {-66.68,-14.72,-638.76,1,1},
            {10.22,-17.85,-613.05,1,1},
            {25.99,-15.64,-613.42,1,0},
            {68.06,-30.67,-582.67,1,0},
            {130.55,-47.39,-523.51,1,0}, -- End of Island #1
            {215.01,303.25,-730.10,1,1}, -- Waypoint #1 on 2nd Island (Issue)
            {279.23,295.35,-656.26,1,0},
            {331.00,293.96,-707.63,1,1}, -- End of Island #2 
            {458.50,203.43,-646.38,1,1},
            {488.12,204.48,-633.06,1,0},
            {558.27,198.54,-562.51,1,0},
            {540.63,195.18,-526.46,1,0}, -- End of Island #3 
            {632.28,253.53,-423.41,1,1}, -- Sole Node on Island #4
            {714.05,225.84,-309.27,1,1},
            {678.74,225.05,-268.64,1,1},
            {601.80,226.65,-229.10,1,1},
            {651.10,228.77,-164.80,1,0},
            {655.21,227.67,-115.23,1,0},
            {648.83,226.19,-74.00,1,0}, -- End of Island #5
            {472.23,-20.99,207.56,1,1},
            {541.18,-8.41,278.78,1,1},
            {616.091,-31.53,315.97,1,0},
            {579.87,-26.10,349.43,1,1},
            {563.04,-25.15,360.33,1},
            {560.68,-18.44,411.57,1,0}, --
            {508.90,-29.67,458.51,1,0},
            {405.96,1.82,454.30,1,0},
            {260.22,91.10,530.69,1,1},
            {192.97,95.66,606.13,1,1},
            {90.06,94.07,605.29,1,0},
            {39.54,106.38,627.32,1,0},
            {-46.11,116.03,673.04,1,0},
            {-101.43,119.30,631.55,1,0}, -- End of Island #6?
            {-328.20,329.41,562.93,1,1},
            {-446.48,327.07,542.64,1,1},
            {-526.76,332.83,506.12,1,1},
            {-577.23,331.88,519.38,1,0},
            {-558.09,334.52,448.38,1,0}, -- End of Island #7 
            {-729.13,272.73,-62.52,1,0}, -- Final Node in the Loop
        }
elseif RouteType == "RedRoute" then 
    gather_table = 
        {
            {-161.2715,-3.5233,-378.8041,0,1,1,0}, -- Start of the route
            {-169.3415,-7.1092,-518.7053,0,0,1,0}, -- Around the tree (Rock + Bones?)
            {-78.5548,-18.1347,-594.6666,1,0,1,0}, -- Log + Rock (Problematic)
            {-54.6772,-45.7177,-521.7173,0,0,1,0}, -- Down the hill 
            {-22.5868,-26.5050,-534.9953,0,1,1,0}, -- up the hill (rock + tree)
            {59.4516,-41.6749,-520.2413,0,1,1,0}, -- Spaces out nodes on rock (hate this one)
            {102.3,-47.3,-500.1,0,0,0,0}, -- Over the gap
            {-209.1468,-3.9325,-357.9749,1,0,1,1}, -- Bonus node
        }
elseif RouteType == "MinerDoubleRoute" then 
    gather_table = 
        {
            {-161.2715,-3.5233,-378.8041,0,1,1,0}, -- Start of the route
            {-169.3415,-7.1092,-518.7053,0,0,1,0}, -- Around the tree (Rock + Bones?)
            {-156.303,-12.391,-566.551,1,0,1,0}, -- On Rock face
            {-128.851,-16.832,-632.891,0,0,1,0}, -- Left of tree, next to gap
            {-61.893,-17.282,-640.261,0,1,1,0}, -- Outcrop on wall
            {-78.5548,-18.1347,-594.6666,1,0,1,0}, -- Log + Rock (Problematic)
            {-54.6772,-45.7177,-521.7173,0,0,1,0}, -- Down the hill 
            {-22.5868,-26.5050,-534.9953,0,1,1,0}, -- up the hill (rock + tree)
            {16.421,-23.169,-603.001,1,1,1,0}, -- Hill near wall
            {48.087,-21.077,-624.743,0,0,1,0}, -- left of depression in cliff
            {67.004,-37.367,-572.858,0,0,1,0}, -- Big rock with bush
            {59.4516,-41.6749,-520.2413,0,1,1,0}, -- Spaces out nodes on rock (hate this one)
            {102.3,-47.3,-500.1,0,0,0,0}, -- Over the gap
            {133.582,-48.980,-519.590,0,0,1,0}, -- Big rock by wall and warp
            {-244.303,-3.982,-498.729,1,0,1,0}, -- Bonus node #1
            {-209.1468,-3.9325,-357.9749,1,0,1,1}, -- Bonus node #2
        }
elseif RouteType == "SilexRoute" then 
    gather_table = 
        {
            {737.700,209.889,-239.746,0,0,1,0}, -- Start of the route
            {734.151,220.053,-180.518,0,0,1,0}, -- Over gap (on ground)
            {720.931,224.078,-149.701,0,1,1,0}, -- Log + Rock (problematic)
            {722.045,228.042,-118.285,0,1,1,0}, -- Large rock with flower (two nodes split) 
            {670.115,224.088,-99.152,0,0,1,0}, -- Rock against pillar
            {660.058,222.394,-35.145,0,99,1,0}, -- through warp (saves ~5s)
            {451.043,-23.159,205.634,0,0,1,0}, -- Pointy Rock (either side of point)
            {441.844,-16.969,263.587,0,0,1,0}, -- Flat rock by tree
            {499.126,-3.428,280.660,0,1,0,1}, -- Bonus node
            {463.777,-25.897,188.124,0,99,1,0}, -- through warp (saves ~7s)
        }
elseif RouteType == "SilexDoubleRoute" then 
    gather_table = 
        {
            {737.700,209.889,-239.746,0,0,1,0}, -- Start of the route
            {691.698,221.998,-255.301,0,1,1,0}, -- Rock at down tree
            {598.584,223.718,-223.767,0,1,1,0}, -- Rock inbetween tree
            {657.823,223.511,-155.214,0,0,1,0}, -- between gulley
            {730.325,220.463,-174.150,0,0,1,0}, -- Ground nodes
            {720.931,224.078,-149.701,0,1,1,0}, -- Log + Rock (problematic)
            {722.045,228.042,-118.285,0,1,1,0}, -- Large rock with flower (two nodes split) 
            {670.115,224.088,-99.152,0,0,1,0}, -- Rock against pillar
            {656.182,224.028,-92.003,0,0,1,0}, -- Second Rock against pillar
            {647.278,223.591,-52.843,1,0,1,0}, -- Rock before warp
            {660.058,222.394,-35.145,0,99,1,0}, -- through warp (saves ~5s)
            {476.505,-23.925,204.943,0,1,1,0}, -- Node next to wierd flower
            {451.043,-23.159,205.634,0,0,1,0}, -- Pointy Rock (either side of point)
            {441.844,-16.969,263.587,0,0,1,0}, -- Flat rock by tree
            {499.126,-3.428,280.660,0,1,0,0}, -- Bonus node #1
            {535.754,-8.970,284.862,0,1,0,0}, -- Node before drop
            {463.777,-25.897,188.124,0,99,1,0}, -- through warp (saves ~7s)
            {706.364,223.169,-299.969,0,1,1,1}, -- Bonus node #2
        }
elseif RouteType == "PinkRoute" then 
    gather_table = 
        {
            {-248.6381,-1.5664,-468.8910,0,3,1,0},
            {-338.3759,-0.4761,-415.3227,0,3,1,0},
            {-366.2651,-1.8514,-350.1429,0,3,1,0},
            {-431.2,27.5,-256.7,0,2,1,0}, --tree node
            {-473.4957,31.5405,-244.1215,0,2,1,0},
            {-536.5187,33.2307,-253.3514,0,3,1,0},
            {-571.2896,35.2772,-236.6808,0,3,1,0},
            {-215.1211,-1.3262,-494.8219,0,3,1,1},
        }
elseif RouteType == "BotanyDoubleRoute" then
    gather_table = 
        {
            {-255.847,-3.600,-475.559,0,3,1,0}, -- First Node
            {-195.929,-1.191,-305.467,0,2,1,0}, -- Tree near edge of island
            {-258.553,-2.417,-349.265,0,2,1,0}, -- Tree with secondary leaning trunk (either side)
            {-317.801,-4.988,-327.259,0,2,1,0}, -- Roots either side of rock
            {-348.516,-1.919,-405.314,0,3,1,0}, -- Bushes next to rock face
            {-371.600,-1.930,-345.787,1,3,1,0}, -- Bush next to floating flower
            {-373.373,16.505,-289.629,1,3,1,0}, -- Bushes near small trees
            {-435.409,27.582,-253.528,1,2,1,0}, -- tree left of small rock
            {-419.270,25.456,-212.166,0,3,0,0}, -- path next to purple flower (either side)
            {-455.710,25.718,-195.216,0,2,0,0}, -- Tree roots coming out of rocks (can be up or down)
            {-489.685,25.231,-245.835,0,2,1,0}, -- small tree next to large tree
            {-546.380,32.026,-258.192,1,3,1,0}, -- bush next to tree with overhang
            {-576.495,36.423,-230.603,1,3,1,0}, -- bush next to stump
            {-554.351,28.988,-209.373,1,2,1,0}, -- tree with yellow flower at base
            {-148.715,-5.031,-389.603,1,2,1,0}, -- Big node #1
            {-207.338,-2.753,-503.473,1,3,1,1}, -- Big node #2
        }
elseif RouteType == "BarbRoute" then
    gather_table = 
        {
            {101.137,86.008,572.592,0,2,1,0}, -- First Node - Trees by giant log (either side of gap); rough node
            {105.534,88.484,533.941,1,3,1,0}, -- Bush and purple flowers by big tree
            {196.636,88.830,563.380,1,3,1,0}, -- Bush by big arching root (only seen 1 location)
            {265.308,85.877,554.858,0,3,1,0}, -- Bushes at base of big tree with small tree
            {273.151,85.579,468.941,0,99,0,0}, -- Warp #1
            {359.701,-3.157,450.645,0,2,0,0}, -- Big tree with yellow flowers, roots at either flower
            {426.103,-3.134,431.815,1,2,1,0}, -- Roots of tree
            {482.775,-30.979,463.134,0,3,0,0}, -- Bush by stump or across from stump 
            {441.140,0.709,480.786,0,99,0,0}, -- Relay point to warp #2 - without it wants to go underside to warp sometimes gets stuck
            {341.865,-4.972,470.596,0,99,0,0}, -- Warp #2
            {25.002,112.288,597.284,1,3,1,0}, -- Big node
        }
elseif RouteType == "BarbDoubleRoute" then
    gather_table = 
        {
            {40.040,104.188,624.396,0,3,1,0}, -- First Node
            {101.137,86.008,572.592,0,2,1,0}, -- Trees by giant log (either side of gap); rough node
            {105.534,88.484,533.941,1,3,1,0}, -- Bush and purple flowers by big tree
            {129.249,86.681,599.191,0,3,1,0}, -- Venus fly trap only?
            {153.079,89.878,592.753,0,2,0,0}, -- Giant tree either side of small shoots
            {196.636,88.830,563.380,1,3,1,0}, -- Bush by big arching root (only seen 1 location)
            {215.978,86.681,511.174,1,2,1,0}, -- Tree next to small rock at base
            {265.308,85.877,554.858,0,3,1,0}, -- Bushes at base of big tree with small tree
            {273.151,85.579,468.941,0,99,0,0}, -- Warp #1
            {359.701,-3.157,450.645,0,2,0,0}, -- Big tree with yellow flowers, roots at either flower
            {344.049,-1.527,445.070,0,3,0,0}, -- Bushes at stump
            {336.810,-3.372,388.417,1,3,1,0}, -- Bush at base of large boulder
            {426.103,-3.134,431.815,1,2,1,0}, -- Roots of tree
            {482.775,-30.979,463.134,0,3,0,0}, -- Bush by stump or across from stump 
            {415.078,-5.099,345.443,1,3,1,0}, -- Bush at base of tree 
            {341.865,-4.972,470.596,0,99,0,0}, -- Warp #2
            {25.002,112.288,597.284,1,3,1,0}, -- Big node #1
            {-46.286,115.928,664.905,0,3,0,1}, -- Big node #2 
        }
end

if TargetOption == 1 then 
    mob_table = 
        {
            {"Proto-noctilucale"},
            {"Diadem Bloated Bulb"},
            {"Diadem Melia"},
            {"Diadem Icetrap"},
            {"Diadem Werewood"},
            {"Diadem Biast"},
            {"Diadem Ice Bomb"},
            {"Diadem Zoblyn"},
            {"Diadem Ice Golem"},
            {"Diadem Golem"},
            {"Corrupted Sprite"},
        }
elseif TargetOption == 2 then 
    mob_table = 
        {
            {"Corrupted Sprite"},
        }
elseif TargetOption == 3 then 
    mob_table = 
        {
            {"Proto-noctilucale"},
            {"Diadem Bloated Bulb"},
            {"Diadem Melia"},
            {"Diadem Icetrap"},
            {"Diadem Werewood"},
            {"Diadem Beast"},
            {"Diadem Ice Bomb"},
            {"Diadem Zoblyn"},
            {"Diadem Ice Golem"},
            {"Diadem Golem"},
        }
elseif TargetOption == 4 then -- remove the "--" for the specific mobs you want to focus , option is for when the mobs you want aren't where you are gathering
    mob_table = 
        {
--            {"Proto-noctilucale",350.086,-274.437,187.060}, -- Caiman
--            {"Diadem Bloated Bulb",366.101,-151.133,-262.446}, -- Cocoon
--            {"Diadem Melia",353.527,-181.629,-240.424}, -- Log
--            {"Diadem Icetrap",318.736,-239.523,141.960}, -- Barbgrass
--            {"Diadem Werewood",294.920,-249.042,247.089}, -- Raspberry
--            {"Diadem Beast",189.637,-247.710,338.474}, -- Springwater
--            {"Diadem Ice Bomb",224.096,-222.376,326.174}, -- Silex
--            {"Diadem Zoblyn",340.069,-250.842,319.633}, -- Prismstone
--            {"Diadem Ice Golem",277.357,-274.839,154.479}, -- Ice Stalagmite
--            {"Diadem Golem",245.323,-134.857,-278.155}, -- Cloudstone
        }
end 

umbral_table =
    {
        {-407.974,319.187,-592.998,0,4,1,0,133},
        {392.970,293.182,563.977,0,5,1,0,134},
        {616.989,251.945,-394.351,0,6,1,0,135},
        {-583.880,330.287,426.789,0,7,1,0,136},
    }

spawnisland_table = 
   {
       {-605.7039,312.0701,-159.7864,0,99,0},
   }

-- Skill Check 
if GetClassJobId() == 16 then -- Miner Skills 
    Yield2 = "\"King's Yield II\""
    Gift2 = "\"Mountaineer's Gift II\""
    Gift1 = "\"Mountaineer's Gift I\""
    Tidings2 = "\"Nald'thal's Tidings\""
    Bountiful2 = "\"Bountiful Yield II\""
elseif GetClassJobId() == 17 then -- Botanist Skills 
    Yield2 = "\"Blessed Harvest II\""
    Gift2 = "\"Pioneer's Gift II\""
    Gift1 = "\"Pioneer's Gift I\""
    Tidings2 = "\"Nophica's Tidings\""
    Bountiful2 = "\"Bountiful Harvest II\""
end        

--GP Value Reserve Setting Depending on above buff settings (function below adds 80 GP to prevent too little GP if +5 node is close to previous node)
if BuffYield2 == true then -- set gp
    BuffYield2_GP = 500
elseif BuffYield2 == false then
    BuffYield2_GP = 0
end

if BuffGift2 == true then -- set gp
    BuffGift2_GP = 100
elseif BuffGift2 == false then
    BuffGift2_GP = 0
end

if BuffGift1 == true then -- set gp
    BuffGift1_GP = 50
elseif BuffGift1 == false then
    BuffGift1_GP = 0
end

if BuffTidings2 == true then -- set gp
    BuffTidings2_GP = 200
elseif BuffTidings2 == false then
    BuffTidings2_GP = 0
end

if UmbralBuffYield2 == true then -- set gp
    UmbralBuffYield2_GP = 500
elseif UmbralBuffYield2 == false then
    UmbralBuffYield2_GP = 0
end

if UmbralBuffGift2 == true then -- set gp
    UmbralBuffGift2_GP = 100
elseif UmbralBuffGift2 == false then
    UmbralBuffGift2_GP = 0
end

if UmbralBuffGift1 == true then -- set gp
    UmbralBuffGift1_GP = 50
elseif UmbralBuffGift1 == false then
    UmbralBuffGift1_GP = 0
end

if UmbralBuffTidings2 == true then -- set gp
    UmbralBuffTidings2_GP = 200
elseif UmbralBuffTidings2 == false then
    UmbralBuffTidings2_GP = 0
end

UmbralGathered = 0

YieldGP = BuffYield2_GP + BuffGift2_GP + BuffGift1_GP + BuffTidings2_GP + 80  -- Makes it so that bountiful II will not pop if GP is less than 80 above skills needed
UmbralYieldGP = UmbralBuffYield2_GP + UmbralBuffGift2_GP + UmbralBuffGift1_GP + UmbralBuffTidings2_GP - 50  -- sets GP needed to go to umbral node at full buffs minus 50 GP

if RouteType == "SilexDoubleRoute" then     --these calculations are based off of a 910+ GP pool
     YieldGP = 2 * (BuffYield2_GP + BuffGift2_GP + BuffGift1_GP + BuffTidings2_GP - 70)
elseif RouteType == "MinerDoubleRoute" or RouteType == "BotanyDoubleRoute" then
     YieldGP = 2 * (BuffYield2_GP + BuffGift2_GP + BuffGift1_GP + BuffTidings2_GP - 40)
elseif RouteType == "BarbDoubleRoute" then
     YieldGP = 2 * (BuffYield2_GP + BuffGift2_GP + BuffGift1_GP + BuffTidings2_GP - 30)
     UmbralYieldGP = UmbralBuffYield2_GP + UmbralBuffGift2_GP + UmbralBuffGift1_GP + UmbralBuffTidings2_GP - 40  -- route very close to dirtleaf, shorter flight time
end


--Functions

function setSNDPropertyIfNotSet(propertyName)
if GetSNDProperty(propertyName) == false then
    SetSNDProperty(propertyName, "true")
    LogInfo("[SetSNDPropertys] " .. propertyName .. " set to True")
end
end


function unsetSNDPropertyIfSet(propertyName )
if GetSNDProperty(propertyName) then
    SetSNDProperty(propertyName, "false")
    LogInfo("[SetSNDPropertys] " .. propertyName .. " set to False")
end
end

-- Set properties if they are not already set
setSNDPropertyIfNotSet("UseItemStructsVersion")
setSNDPropertyIfNotSet("UseSNDTargeting")

--for Pandora
PandoraSetFeatureState("Auto-interact with Gathering Nodes",false)
PandoraSetFeatureState("Auto-Mount after Gathering",false)
PandoraSetFeatureState("Pandora Quick Gather",false)

-- Unset properties if they are set
unsetSNDPropertyIfSet("StopMacroIfTargetNotFound")
unsetSNDPropertyIfSet("StopMacroIfCantUseItem")
unsetSNDPropertyIfSet("StopMacroIfItemNotFound")

function UmbralGatheringTarget(i)
    LoopClear()
    GatherNodeTargetLoop=0
    while GetCharacterCondition(45,false) and GetCharacterCondition(6, false) do
        while GetTargetName() == "" and GatherNodeTargetLoop < 20 and IsInZone(886) == false do
            if umbral_table[i][5] == 4 then 
                yield("/target Clouded Mineral Deposit")                
            elseif umbral_table[i][5] == 5 then 
                yield("/target Clouded Lush Vegetation Patch")
            elseif umbral_table[i][5] == 6 then 
                yield("/target Clouded Rocky Outcrop")
            elseif umbral_table[i][5] == 7 then 
                yield("/target Clouded Mature Tree")
            end
            yield("/wait 0.1")
            GatherNodeTargetLoop = GatherNodeTargetLoop + 1
            if GatherNodeTargetLoop == 5 then
                yield("/e Checking class, node not found.")
                UmbralSwap()
            end
        end
        if GatherNodeTargetLoop >= 20 then
            yield("/e Node not found restarting the gathering loop.")
            LeaveDuty()
            while IsInZone(886) == false do
                yield("/wait 2")
            end
        end
        yield("/wait 0.1")
        if GetDistanceToTarget() > 6 then 
            if umbral_table[i][6] == 0 then 
                yield("/vnavmesh flytarget")
            elseif umbral_table[i][6] == 1 then 
                yield("/vnavmesh movetarget")
            end
            while GetDistanceToTarget() > 3.5 and IsInZone(886) == false do 
                if umbral_table[i][6] == 0 and GetCharacterCondition(4) == false and GetCharacterCondition(77) == false then 
                    MountFly()
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) and GetCharacterCondition(77) then
                        yield("/vnavmesh flytarget")
                    end
                end  
                yield("/wait 0.1")
            end
            PathStop()
            if GetDistanceToTarget() < 3.5 and GetCharacterCondition(4) then
                Dismount()
            end
        end
        while GetCharacterCondition(6, false)and IsInZone(886) == false do 
            yield("/wait 0.1")
            yield("/interact")
            while GetTargetName() == "" and GatherNodeTargetLoop < 20 and IsInZone(886) == false do
                if umbral_table[i][5] == 4 then 
                    yield("/target Clouded Mineral Deposit")                
                elseif umbral_table[i][5] == 5 then 
                    yield("/target Clouded Lush Vegetation Patch")
                elseif umbral_table[i][5] == 6 then 
                    yield("/target Clouded Rocky Outcrop")
                elseif umbral_table[i][5] == 7 then 
                    yield("/target Clouded Mature Tree")
                end
                yield("/wait 0.1")
                GatherNodeTargetLoop = GatherNodeTargetLoop + 1
                if GatherNodeTargetLoop == 5 then
                    yield("/e Checking class, node not found.")
                    UmbralSwap()
                end
            end
            if GatherNodeTargetLoop >= 20 then
                yield("/e Node not found restarting the gathering loop.")
                LeaveDuty()
                while IsInZone(886) == false do
                    yield("/wait 2")
                end
            end
            if GetNodeText("_TextError",1) == "Too far away." then 
                yield("/vnavmesh movetarget")
                while GetDistanceToTarget() > 3.5 and IsInZone(886) == false do 
                    yield("/wait 0.1")
                end
                PathStop()
            end
        end            
    end
    PathStop()
    DGatheringUmbral()
    yield("/wait 0.1")
    LogInfo("UmbralGatheringTarget -> Completed")
end

function GatheringTarget(i)
    LoopClear()
    GatherNodeTargetLoop=0
    while GetCharacterCondition(45,false) and GetCharacterCondition(6, false) do
        while GetTargetName() == "" and GatherNodeTargetLoop < 20 and IsInZone(886) == false do
            if gather_table[i][5] == 0 then 
                yield("/target Mineral Deposit")
            elseif gather_table[i][5] == 1 then 
                yield("/target Rocky Outcrop")
            elseif gather_table[i][5] == 2 then 
                yield("/target Mature Tree")
            elseif gather_table[i][5] == 3 then 
                yield("/target Lush Vegetation Patch")
            end
            yield("/wait 0.1")
            GatherNodeTargetLoop = GatherNodeTargetLoop + 1
            if GatherNodeTargetLoop == 5 and AutoSwap == true then
                yield("/e Checking class, node not found.")
                JobCheck(i)
            end
        end
        if GatherNodeTargetLoop >= 20 then
            yield("/e Node not found restarting the gathering loop.")
            LeaveDuty()
            while IsInZone(886) == false do
                yield("/wait 2")
            end
        end
        yield("/wait 0.1")
        if GetDistanceToTarget() > 6 then 
            if gather_table[i][6] == 0 then 
                yield("/vnavmesh flytarget")
            elseif gather_table[i][6] == 1 then 
                yield("/vnavmesh movetarget")
            end
            while GetDistanceToTarget() > 3.5 and IsInZone(886) == false do 
                if gather_table[i][6] == 0 and GetCharacterCondition(4) == false and GetCharacterCondition(77) == false then 
                    MountFly()
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) and GetCharacterCondition(77) then
                        yield("/vnavmesh flytarget")
                    end
                end  
                yield("/wait 0.1")
            end
            PathStop()
            if GetDistanceToTarget() < 3.5 and GetCharacterCondition(4) then
                Dismount()
            end
        end
        while GetCharacterCondition(6, false)and IsInZone(886) == false do 
            yield("/wait 0.1")
            yield("/interact")
            while GetTargetName() == "" and GatherNodeTargetLoop < 20 and IsInZone(886) == false do
                if gather_table[i][5] == 0 then 
                    yield("/target Mineral Deposit")
                elseif gather_table[i][5] == 1 then 
                    yield("/target Rocky Outcrop")
                elseif gather_table[i][5] == 2 then 
                    yield("/target Mature Tree")
                elseif gather_table[i][5] == 3 then 
                    yield("/target Lush Vegetation Patch")
                end
                yield("/wait 0.1")
                GatherNodeTargetLoop = GatherNodeTargetLoop + 1
                if GatherNodeTargetLoop == 5 and AutoSwap == true then
                    yield("/e Checking class, node not found.")
                    JobCheck(i)
                end
            end
            if GatherNodeTargetLoop >= 20 then
                yield("/e Node not found restarting the gathering loop.")
                LeaveDuty()
                while IsInZone(886) == false do
                    yield("/wait 2")
                end
            end
            if GetNodeText("_TextError",1) == "Too far away." then 
                yield("/vnavmesh movetarget")
                while GetDistanceToTarget() > 3.5 and IsInZone(886) == false do 
                    yield("/wait 0.1")
                end
                PathStop()
            end
        end            
    end
    PathStop()
    DGathering()
    yield("/wait 0.1")
    LogInfo("GatheringTarget -> Completed")
end

function CanadianMounty()
    while GetCharacterCondition(4, false) and IsInZone(939) do 
        while GetCharacterCondition(27, false) and IsInZone(939) do
            yield("/wait 0.1")
            yield('/gaction "mount roulette"')
            
        end
        while GetCharacterCondition(27) and IsInZone(939) do 
            yield("/wait 0.1")
        end 
        yield("/wait 1")
        PlayerWait()
        LogInfo("CanadianMounty -> Completed")
    end
end

function Target()
    if GetTargetName() ~= "" then
        return true 
    else
        return false
    end
end

function KillTarget()
    if IsInZone(939) then
        if GetDistanceToTarget() == 0.0 and GetCharacterCondition(6, false) and GetCharacterCondition(45, false) and GetDiademAetherGaugeBarCount() >= 1 and TargetOption ~= 0 then 
            if KillLoop >= 1 then
                if (PathIsRunning() or PathfindInProgress()) then
                    yield("/wait 2")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end
                LoopClear()
            end
            for i=1, #mob_table do
                yield("/target "..mob_table[i][1])
                yield("/wait 0.03")
                if Target() == false then
                    yield("/wait 0.05")
                end
                if Target() == true then 
                    break 
                end
            end   
            
            yield("/wait 0.1")
            if Target() then 
                KillLoop = KillLoop + 1
                if GetDistanceToTarget() > 10 then
                    PathStop()
                    MountFly()
                    yield("/wait 0.1")
                    yield("/vnavmesh flytarget")
                    while GetDistanceToTarget() > 10 and GetTargetName() ~= "" and IsInZone(886) == false do
                        yield("/wait 0.1")
                        if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                            MountFly()
                        end                            
                    end
                end
                PathStop() 
                yield("/wait 0.1")
                while GetTargetHP() > 1.0 and GetTargetName() ~= "" and IsInZone(886) == false do
                    if PathIsRunning() then
                        PathStop()
                    end 
                    Dismount()
                    if GetNodeText("_TextError",1) == "Target not in line of sight." and IsAddonVisible("_TextError") then
                        ClearTarget()
                        yield("/wait 1")
                    end
                    if GetDistanceToTarget() > 15 then
                        ClearTarget()
                        yield("/wait 0.1")
                    end
                    if GetCharacterCondition(27) then -- casting
                        yield("/wait 0.5")
                        LoopClear()
                    else
                        yield("/gaction \"Duty Action I\"")
                        yield("/wait 0.5")
                    end
                end
                LogInfo("KillTarget -> Completed")
            end
        end
    end
end

function MountFly()
    if GetCharacterCondition(4, false) and IsInZone(939) then 
        while GetCharacterCondition(4, false) and IsInZone(939) do 
            CanadianMounty()
        end
    end
    while GetCharacterCondition(77) == false and IsInZone(939) do 
        PathStop()
        CanadianMounty()
        yield("/gaction jump")
        yield("/wait 0.1")
        yield("/gaction jump")
    end
    LogInfo("MountFly -> Completed")
end

function WalkTo(x, y, z)
    PathfindAndMoveTo(x, y, z, false)
    while (PathIsRunning() or PathfindInProgress()) do
        yield("/wait 0.5")
    end
    LogInfo("WalkTo -> Completed")
end

function VNavMoveTime(i)
    -- Setting the camera setting for Navmesh (morso for the standard players that way they don't get nauseas)
    if PathGetAlignCamera() == false then 
        PathSetAlignCamera(true) 
    end 
    if gather_table[i][4] == 0 then 
        while GetDistanceToPoint(X, Y, Z) >= 6 and IsInZone(939) do
            if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                MountFly()
            end
            if PathIsRunning() == false or IsMoving() == false then 
                PathfindAndMoveTo(X, Y, Z, true)
                yield("/wait 0.1")
                while PathfindInProgress() and IsInZone(886) == false do
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end 
            end
            yield("/wait 0.1")
            KillTarget()
        end
    elseif gather_table[i][4] == 1 then 
        while GetDistanceToPoint(X, Y, Z) >= 3 and IsInZone(939) do
            if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                MountFly()
            end
            if PathIsRunning() == false or IsMoving() == false then 
                PathfindAndMoveTo(X, Y, Z, true)
                yield("/wait 0.1")
                while PathfindInProgress() and IsInZone(886) == false do
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end 
            end
            yield("/wait 0.1")
            KillTarget()
        end
    end
    LogInfo("VNavMoveTime(i) -> Completed")
end

function VNavMoveTimeUmbralDivert(i)
    -- Setting the camera setting for Navmesh (morso for the standard players that way they don't get nauseas)
    if PathGetAlignCamera() == false then 
        PathSetAlignCamera(true) 
    end 
    if umbral_table[i][4] == 0 then 
        while GetDistanceToPoint(X, Y, Z) >= 6 and IsInZone(939) do
            if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                MountFly()
            end
            if PathIsRunning() == false or IsMoving() == false then 
                PathfindAndMoveTo(X, Y, Z, true)
                yield("/wait 0.1")
                while PathfindInProgress() and IsInZone(886) == false do
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end 
            end
            yield("/wait 0.1")
            KillTarget()
        end
    elseif umbral_table[i][4] == 1 then 
        while GetDistanceToPoint(X, Y, Z) >= 3 and IsInZone(939) do
            if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                MountFly()
            end
            if PathIsRunning() == false or IsMoving() == false then 
                PathfindAndMoveTo(X, Y, Z, true)
                yield("/wait 0.1")
                while PathfindInProgress() and IsInZone(886) == false do
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end 
            end
            yield("/wait 0.1")
            KillTarget()
        end
    end
    LogInfo("VNavMoveTimeUmbralDivert(i) -> Completed")
end

function VNavMoveTimeDivert(i)
    -- Setting the camera setting for Navmesh (morso for the standard players that way they don't get nauseas)
    if PathGetAlignCamera() == false then 
        PathSetAlignCamera(true) 
    end 
    if gather_table[i][4] == 0 then 
        while GetDistanceToPoint(X, Y, Z) >= 6 and IsInZone(939) do
            if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                MountFly()
            end
            if PathIsRunning() == false or IsMoving() == false then 
                PathfindAndMoveTo(X, Y, Z, true)
                yield("/wait 0.1")
                while PathfindInProgress() and IsInZone(886) == false do
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end 
            end
            yield("/wait 0.1")
            KillTarget()
        end
    elseif gather_table[i][4] == 1 then 
        while GetDistanceToPoint(X, Y, Z) >= 3 and IsInZone(939) do
            if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                MountFly()
            end
            if PathIsRunning() == false or IsMoving() == false then 
                PathfindAndMoveTo(X, Y, Z, true)
                yield("/wait 0.1")
                while PathfindInProgress() and IsInZone(886) == false do
                    yield("/wait 0.1")
                    if GetCharacterCondition(4) == false or GetCharacterCondition(77) == false then 
                        MountFly()
                    end
                end 
            end
            yield("/wait 0.1")
            KillTarget()
        end
    end
    LogInfo("VNavMoveTimeDivert(i) -> Completed")
end

function VislandMoveTime() 
    yield("/visland moveto "..X.." "..Y.." "..Z)
    while GetDistanceToPoint(X, Y, Z) > 1 do 
        yield("/wait 0.1")
    end 
    yield("/visland stop")
    LogInfo("VislandMoveTime -> Completed")
end

function PlayerWait()
    if PlayerWaitTime then 
        math.randomseed( os.time() )
        RandomTimeWait = math.random(10, 20) / 10
        yield("/wait "..RandomTimeWait)
        LogInfo("PlayerWait -> Completed")
    end
end  

function StatusCheck()
    yield("/wait 0.3")
    if GetCharacterCondition(42) then  
        repeat 
            yield("/wait 0.1")
        until GetCharacterCondition(42, false)
    end
    LogInfo("StatusCheck -> Completed")
end     

function DGatheringUmbral()
    LoopClear() 
    UiElementSelector()
    while GetCharacterCondition(6) and IsInZone(886) == false do 
        if VisibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false then 
            while VisibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false do 
                LogInfo("[Diadem Gathering] [Node Type] This is a Max Integrity Node, time to start buffing/smacking")
                PlayerWait()
                yield("/wait 0.1")
                while UmbralBuffYield2 and GetGp() >= 500 and HasStatusId(219) == false and GetLevel() >= 40 and IsInZone(886) == false do -- 
                    if debug then yield("/e [Debug] Should be applying Kings Yield 2") end
                    UseSkill(Yield2)
                    StatusCheck()
                end
                while UmbralBuffGift2 and GetGp() >= 300 and HasStatusId(759) == false and GetLevel() >= 50 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Mountaineer's Gift 2'") end
                    UseSkill(Gift2) -- Mountaineer's Gift 2 (Min)
                    StatusCheck()
                end
                while UmbralBuffTidings2 and GetGp() >= 200 and HasStatusId(2667) == false and GetLevel() >= 81 and IsInZone(886) == false do 
                    if debug then yield("/e [Debug] Should be applying Tidings") end
                    UseSkill(Tidings2) -- Nald'thal's Tidings (Min)
                    StatusCheck()
                end 
                while UmbralBuffGift1 and GetGp() >= 50 and HasStatusId(2666) == false and GetLevel() >= 15 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Mountaineer's Gift 1'") end
                    UseSkill(Gift1) -- Mountaineer's Gift 1 (Min)
                    StatusCheck()
                end
                while UmbralBuffBYieldHarvest2 and GetGp() >= 100 and HasStatusId(1286) == false and GetLevel() >= 68 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Bountiful Yield 2") end
                    UseSkill(Bountiful2)
                    StatusCheck()
                end 
                DGatheringLoop = true
            end
        end 
        yield("/pcall Gathering true "..NodeSelectionUmbral)
        yield("/wait 0.1")
        while GetCharacterCondition(42) and IsInZone(886) == false do
            yield("/wait 0.2")
        end
        if PathIsRunning() == true then 
            PathStop()
        end
        if GetGp() == GetMaxGp() then -- catches Revisit Procs
            DGatheringLoop = false
            yield("/wait 0.1")
        end
    end 
    LogInfo("DGatheringUmbral -> Completed")
end

function DGathering()
    LoopClear() 
    UiElementSelector()
    while GetCharacterCondition(6) and IsInZone(886) == false do 
        if VisibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and ConserveGP == false and DGatheringLoop == false then 
            while VisibleNode == "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false do 
                LogInfo("[Diadem Gathering] [Node Type] This is a Max Integrity Node, time to start buffing/smacking")
                PlayerWait()
                yield("/wait 0.1")
                while BuffYield2 and GetGp() >= 500 and HasStatusId(219) == false and GetLevel() >= 40 and IsInZone(886) == false do -- 
                    if debug then yield("/e [Debug] Should be applying Kings Yield 2") end
                    UseSkill(Yield2)
                    StatusCheck()
                end
                while BuffGift2 and GetGp() >= 300 and HasStatusId(759) == false and GetLevel() >= 50 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Mountaineer's Gift 2'") end
                    UseSkill(Gift2) -- Mountaineer's Gift 2 (Min)
                    StatusCheck()
                end
                while BuffTidings2 and GetGp() >= 200 and HasStatusId(2667) == false and GetLevel() >= 81 and IsInZone(886) == false do 
                    if debug then yield("/e [Debug] Should be applying Tidings") end
                    UseSkill(Tidings2) -- Nald'thal's Tidings (Min)
                    StatusCheck()
                end 
                while BuffGift1 and GetGp() >= 50 and HasStatusId(2666) == false and GetLevel() >= 15 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Mountaineer's Gift 1'") end
                    UseSkill(Gift1) -- Mountaineer's Gift 1 (Min)
                    StatusCheck()
                end
                while BuffBYieldHarvest2 and GetGp() >= 100 and HasStatusId(1286) == false and GetLevel() >= 68 and IsInZone(886) == false do
                    if debug then yield("/e [Debug] Should be applying Bountiful Yield 2") end
                    UseSkill(Bountiful2)
                    StatusCheck()
                end 
                DGatheringLoop = true
            end
        elseif VisibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" and DGatheringLoop == false then 
            LogInfo("[Diadem Gathering] [Node Type] Normal Node")
            DGatheringLoop = true
        end 
        yield("/pcall Gathering true "..NodeSelection)
        yield("/wait 0.1")
        while GetCharacterCondition(42) and IsInZone(886) == false do
            yield("/wait 0.2")
        end
        if PathIsRunning() == true then 
            PathStop()
        end
        if GetGp() == GetMaxGp() and ConserveGP == false then -- catches Revisit Procs
            DGatheringLoop = false
            yield("/wait 0.1")
        end
        BountifulYieldII()
    end 
    LogInfo("DGathering -> Completed")
end

function FoodCheck() 
    LoopClear()
    while (GetStatusTimeRemaining(48) <= FoodTimeRemaining or HasStatusId(48) == false) and Food_Tick < FoodTimeout do 
        yield("/item "..FoodKind)
        yield("/wait 2")
        Food_Tick = Food_Tick + 1 
        if Food_Tick == FoodTimeout then 
            yield("/e [Diadem Gathering] Hmm... either you put in a food that doesn't exist. Or you don't have anymore of that food. Either way, disabling it for now")
            UseFood = false 
        end
    end
    LogInfo("FoodCheck -> Completed")
end

function TargetedInteract(target)
    yield("/target "..target.."")
    repeat
        yield("/wait 0.1")
    until GetDistanceToTarget() < 6
    yield("/interact")
    repeat
        yield("/wait 0.1")
    until IsAddonReady("SelectIconString")
    LogInfo("TargetedInteract -> Completed")
end

function LoopClear()
    KillLoop = 0
    Food_Tick = 0 
    DGatheringLoop = false 
    LogInfo("LoopClear -> Completed")
end

function UiElementSelector()
    if IsAddonVisible("_TargetInfoMainTarget") then 
        VisibleNode = GetNodeText("_TargetInfoMainTarget", 3)
    elseif IsAddonVisible("_TargetInfo") then 
        VisibleNode = GetNodeText("_TargetInfo", 34)
    end 
end 

function weathercheck()
    if GatherUmbrals == true and GetActiveWeatherID() >= 133 and GetActiveWeatherID() <= 136 then
        return true -- umbral weather detected
    else
        return false -- umbral weather not detected or set to not gather umbral nodes
    end
end

function BountifulYieldII()
    if ConserveGP ~= true then
        if GetGp() >= GPReserve and GetGp() >= YieldGP and GetLevel() >= 68 and VisibleNode ~= "Max GP ≥ 858 → Gathering Attempts/Integrity +5" then 
            LogInfo("Popping Yield 2 Buff")
            yield("/ac "..Bountiful2)
            StatusCheck()
        end
    end
end 

function UmbralSwap()
Current_job = GetClassJobId()
if (Current_job == 17) or (Current_job == 16) then
    if GetClassJobId() == 17 then -- Botanist
        if GetActiveWeatherID() == 133 or GetActiveWeatherID() == 135  then
            yield("/echo Swapping to Miner for Umbral Node")
            yield("/gearset change Miner")
            Yield2 = "\"King's Yield II\""
            Gift2 = "\"Mountaineer's Gift II\""
            Gift1 = "\"Mountaineer's Gift I\""
            Tidings2 = "\"Nald'thal's Tidings\""
            Bountiful2 = "\"Bountiful Yield II\""
        end 
    elseif GetClassJobId() == 16 then  --Miner
        if GetActiveWeatherID() == 134 or GetActiveWeatherID() == 136  then
           yield("/echo Swapping to Botanist for Umbral Node")
           yield("/gearset change Botanist")
           Yield2 = "\"Blessed Harvest II\""
           Gift2 = "\"Pioneer's Gift II\""
           Gift1 = "\"Pioneer's Gift I\""
           Tidings2 = "\"Nophica's Tidings\""
           Bountiful2 = "\"Bountiful Harvest II\""
        end 
    end
end
end

function JobCheck(i)
Current_job = GetClassJobId()
if (Current_job == 17) or (Current_job == 16) then
    if GetClassJobId() == 17 then -- Botanist
        if gather_table[i][5] == 0 or gather_table[i][5] == 1 then
            yield("/echo Swapping back to Miner")
            yield("/gearset change Miner")
            Yield2 = "\"King's Yield II\""
            Gift2 = "\"Mountaineer's Gift II\""
            Gift1 = "\"Mountaineer's Gift I\""
            Tidings2 = "\"Nald'thal's Tidings\""
            Bountiful2 = "\"Bountiful Yield II\""
            StatusCheck()
        end 
    elseif GetClassJobId() == 16 then  --Miner
        if gather_table[i][5] == 2 or gather_table[i][5] == 3 then
           yield("/echo Swapping back to Botanist")
           yield("/gearset change Botanist")
           Yield2 = "\"Blessed Harvest II\""
           Gift2 = "\"Pioneer's Gift II\""
           Gift1 = "\"Pioneer's Gift I\""
           Tidings2 = "\"Nophica's Tidings\""
           Bountiful2 = "\"Bountiful Harvest II\""
           StatusCheck()
        end 
    end
end
end
    
function Dismount()
    a=0
    if GetCharacterCondition(4) or GetCharacterCondition(77) and IsInZone(886) == false then
        yield("/ac dismount")
        yield("/wait 0.3")
    while GetCharacterCondition(77) and a < 4 and IsInZone(886) == false do
        yield("/wait 0.5")
        a=a+1
    end
        if a == 4 then
            yield("/wait 0.1")
            yield("/gaction jump")
            yield("/send SPACE")
            ClearTarget() 
            PathStop()
            LogInfo("Dismount -> BailoutCommanced")
        end
    end
    LogInfo("Dismount -> Completed")
end

function UseSkill(SkillName)
    yield("/ac "..SkillName)
    yield("/wait 0.1")
end 

::SettingNodeValues:: 
NodeSelection = GatheringSlot - 1
NodeSelectionUmbral = UmbralGatheringSlot - 1
Counter = 0
FoodTimeRemaining = RemainingFoodTimer * 60
DGatheringLoop = false 
KillLoop = 0

::JobTester::
Current_job = GetClassJobId()
if (Current_job == 17) or (Current_job == 16) then
    if GetClassJobId() == 17 then -- Botanist
        if RouteType == "RedRoute" or RouteType == "MinerDoubleRoute" or RouteType == "SilexRoute" or RouteType == "SilexDoubleRoute" then
            if AutoSwap == true then
                yield("/echo Hmm... You're on Botanist, yet you chose "..RouteType..". Changing to Miner.")
                yield("/gearset change Miner")
                StatusCheck()
                Yield2 = "\"King's Yield II\""
                Gift2 = "\"Mountaineer's Gift II\""
                Gift1 = "\"Mountaineer's Gift I\""
                Tidings2 = "\"Nald'thal's Tidings\""
                Bountiful2 = "\"Bountiful Yield II\""
                goto Waypoints
            else
                yield("/echo You're on Botanist but have "..RouteType.." selected, switch to Miner and start the script again; or setup AutoSwap.")
                yield("/snd stop") 
            end
        end
    elseif GetClassJobId() == 16 then  -- Miner
        if RouteType == "PinkRoute" or RouteType == "BotanyDoubleRoute" or RouteType == "BarbRoute" or RouteType == "BarbDoubleRoute" then
            if AutoSwap == true then
                yield("/echo Hmm... You're on Miner, yet you chose "..RouteType..". Changing to Botanist.")
                yield("/gearset change Botanist")
                StatusCheck()
                Yield2 = "\"Blessed Harvest II\""
                Gift2 = "\"Pioneer's Gift II\""
                Gift1 = "\"Pioneer's Gift I\""
                Tidings2 = "\"Nophica's Tidings\""
                Bountiful2 = "\"Bountiful Harvest II\""
            else
                yield("/echo You're on Miner but have "..RouteType.." selected, switch to Botanist and start the script again; or setup AutoSwap.")
                yield("/snd stop")
            end
        end    
    end
    goto Enter
else
    yield("/echo Hmm... You're not on a gathering job, switch to one and start the script again.")
    yield("/snd stop")
end   

if Self_Repair and Npc_Repair then
    Npc_Repair=false
    yield("/echo You can only select one repair setting. Setting Npc Repair false")
end

::Enter::

if IsInZone(939) and GetCharacterCondition(45, false) then
    goto DiademFarming
end

while not IsInZone(886) and GetCharacterCondition(45, false) do
    yield("/wait 0.2")
end
while IsPlayerAvailable() == false do
    yield("/wait 0.1")
end
PathStop()

::RepairMode::

-- If you have the ability to repair your gear, this will allow you to do so. 
-- Currently will repair when your gear gets to 50% or below, but you can change the value to be whatever you would like
if NeedsRepair(Repair_Amount) and Self_Repair then
    yield("/generalaction repair")
    yield("/waitaddon Repair")
    yield("/pcall Repair true 0")
    yield("/wait 0.1")
    if IsAddonVisible("SelectYesno") then
        yield("/pcall SelectYesno true 0")
        yield("/wait 0.1")
    end
    while GetCharacterCondition(39) do yield("/wait 1") end
    yield("/wait 1")
    yield("/pcall Repair true -1")
end
if NeedsRepair(Repair_Amount) and Npc_Repair then
    if IsInZone(886) then -- Check if in Firmament
        WalkTo(47, -16, 151)
        TargetedInteract("Eilonwy") -- Interact with target named "Eilonwy"
        yield("/pcall SelectIconString false 1") 
        while not IsAddonReady("Repair") do 
        yield("/wait 0.1")
    end
    yield("/pcall Repair true 0") 
    yield("/wait 0.1")
    if IsAddonReady("SelectYesno") then
        yield("/pcall SelectYesno true 0")
        yield("/wait 0.1")
    end
    yield("/pcall Repair true -1") 
    yield("/wait 0.1")
    WalkTo(-18.5, -16, 142) --Walks to target named "Eilonwy"
    else
        yield("/echo You are not in Firmament") -- Notify if not in Firmament
    end
end 

::DiademEntry::
if IsInZone(886) then
    while GetCharacterCondition(34, false) and GetCharacterCondition(45, false) do
        if IsAddonVisible("ContentsFinderConfirm") then
            yield("/pcall ContentsFinderConfirm true 8")
        elseif GetTargetName()=="" then
            yield("/target Aurvael")
        elseif GetCharacterCondition(32, false) then
            yield("/interact")
        end
        if IsAddonVisible("Talk") then yield("/click  Talk Click") end
        if IsAddonVisible("SelectString") then yield("/pcall SelectString true 0") end
        if IsAddonVisible("SelectYesno") then yield("/pcall SelectYesno true 0") end
        yield("/wait 0.5")
    end
    while GetCharacterCondition(35, false) do yield("/wait 1") end
    while GetCharacterCondition(35) do yield("/wait 1") end
    yield("/wait 3")
    UmbralGathered = 0
end

::DiademFarming::

while IsInZone(939) and GetCharacterCondition(45, false) do
    for i=1, #gather_table do
        if GetCharacterCondition(45, false) then 
            if UseFood and (GetStatusTimeRemaining(48) <= FoodTimeRemaining or HasStatusId(48) == false) then 
                yield("/e [Diadem Gathering] Food seems to have ran out, going to re-food")
                FoodCheck()
            end
            MountFly()
            if TargetOption == 4 and GetDiademAetherGaugeBarCount() == AetherBar then
                for i=1, #mob_table do
                    X = mob_table[i][2]
                    Y = mob_table[i][3]
                    Z = mob_table[i][4]
                    ClearTarget()
                    VNavMoveTimeDivert(i)
                    while GetDiademAetherGaugeBarCount() >= 1 do
                        KillTarget()
                    end
                end
                MountFly()
            end
            if GatherUmbrals == true and weathercheck() == true then
                if UmbralGathered == 0 then
                    ConserveGP = true
                    if UmbralGathered == 0 and GetGp() >= UmbralYieldGP and gather_table[i][5] ~= 99 then
                        for i=1, #umbral_table do
                            if umbral_table[i][8] == GetActiveWeatherID() then 
                                X = umbral_table[i][1]
                                Y = umbral_table[i][2]
                                Z = umbral_table[i][3]
                                ClearTarget()
                                UmbralSwap()    
                                if weathercheck() == true then -- weatherchecks to make sure weather is still active before moving to node and when tryign to gather to prevent unecessary reset when node not found.
                                    VNavMoveTimeUmbralDivert(i)
                                end
                                if weathercheck() == true and umbral_table[i][5] ~= 99 then -- 99 is the code imma use if I don't want it gathering anything, and make sure it's not the coords I want to use as a midpoint
                                    UmbralGatheringTarget(i)
                                end 
                                UmbralGathered = 1
                                ConserveGP = false
                                if PrioritizeUmbrals == true and weathercheck() == true then
                                    yield("/e Resetting instance to allow gathering of another umbral node")
                                    StatusCheck()
                                    LeaveDuty()
                                    while IsInZone(886) == false do
                                        yield("/wait 2")
                                    end
                                end
                                MountFly()
                            end
                        end    
                    end
                end
            elseif GatherUmbrals == true and weathercheck() == false then
                if UmbralGathered == 1 then
                    UmbralGathered = 0
                    ConserveGP = false
                else
                    ConserveGP = false
                end
            end
            X = gather_table[i][1]
            Y = gather_table[i][2]
            Z = gather_table[i][3]
            ClearTarget()
            if AutoSwap == true then
                JobCheck(i)
            end    
            VNavMoveTime(i) 
            if gather_table[i][5] ~= 99 then -- 99 is the code imma use if I don't want it gathering anything, and make sure it's not the coords I want to use as a midpoint
                GatheringTarget(i)
            end 
            if gather_table[i][7] == 1 then
                Counter = Counter + 1
                if AntiStutterOpen and Counter >= AntiStutter then
                    LogInfo("AntiStutter -> Completed")
                    yield("/runmacro DiademV2")
                end
            end 

            if GetInventoryFreeSlotCount() == 0 then 
                LogInfo("It seems like your inventory has reached Max Capacity slot wise. For the safety of you (and to help you not just stand there for hours on end), we're going to stop the script here and leave the instance")
                yield("/e It seems like your inventory has reached Max Capacity slot wise. For the safety of you (and to help you not just stand there for hours on end), we're going to stop the script here and leave the instance")
                DutyLeave()
                yield("/snd stop")
            end
        end 
    end
end 

goto Enter
