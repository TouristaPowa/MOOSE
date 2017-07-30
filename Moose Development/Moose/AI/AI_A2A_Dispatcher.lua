--BASE:TraceClass("AI_A2A_DISPATCHER")
--BASE:TraceClass("AI_A2A_GCICAP")

--- **AI** - The AI_A2A_DISPATCHER creates an automatic A2A defense system based on an EWR network targets and coordinating CAP and GCI.
-- 
-- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia1.JPG)
-- 
-- ====
--
-- # QUICK START GUIDE
-- 
-- There are basically two classes available to model an A2A defense system.
-- 
-- AI\_A2A\_DISPATCHER is the main A2A defense class that models the A2A defense system.
-- AI\_A2A\_GCICAP derives or inherits from AI\_A2A\_DISPATCHER and is a more **noob** user friendly class, but is less flexible.
-- 
-- Before you start using the AI\_A2A\_DISPATCHER or AI\_A2A\_GCICAP ask youself the following questions.
-- 
-- ## 0. Do I need AI\_A2A\_DISPATCHER or do I need AI\_A2A\_GCICAP?
-- 
-- AI\_A2A\_GCICAP, automates a lot of the below questions using the mission editor and requires minimal lua scripting.
-- But the AI\_A2A\_GCICAP provides less flexibility and a lot of options are defaulted.
-- With AI\_A2A\_DISPATCHER you can setup a much more **fine grained** A2A defense mechanism, but some more (easy) lua scripting is required.
-- 
-- ## 1. Which Coalition am I modeling an A2A defense system for? blue or red?
-- 
-- One AI\_A2A\_DISPATCHER object can create a defense system for **one coalition**, which is blue or red.
-- If you want to create a **mutual defense system**, for both blue and red, then you need to create **two** AI\_A2A\_DISPATCHER **objects**,
-- each governing their defense system.
-- 
--      
-- ## 2. Which type of EWR will I setup? Grouping based per AREA, per TYPE or per UNIT? (Later others will follow).
-- 
-- The MOOSE framework leverages the @{Detection} classes to perform the EWR detection.
-- Several types of @{Detection} classes exist, and the most common characteristics of these classes is that they:
-- 
--    * Perform detections from multiple FACs as one co-operating entity.
--    * Communicate with a Head Quarters, which consolidates each detection.
--    * Groups detections based on a method (per area, per type or per unit).
--    * Communicates detections.
-- 
-- ## 3. Which EWR units will be used as part of the detection system? Only Ground or also Airborne?
-- 
-- Typically EWR networks are setup using 55G6 EWR, 1L13 EWR, Hawk sr and Patriot str ground based radar units. 
-- These radars have different ranges and 55G6 EWR and 1L13 EWR radars are Eastern Bloc units (eg Russia, Ukraine, Georgia) while the Hawk and Patriot radars are Western (eg US).
-- Additionally, ANY other radar capable unit can be part of the EWR network! Also AWACS airborne units, planes, helicopters can help to detect targets, as long as they have radar.
-- The position of these units is very important as they need to provide enough coverage 
-- to pick up enemy aircraft as they approach so that CAP and GCI flights can be tasked to intercept them.
-- 
-- ## 4. Is a border required?
-- 
-- Is this a cold car or a hot war situation? In case of a cold war situation, a border can be set that will only trigger defenses
-- if the border is crossed by enemy units.
-- 
-- ## 5. What maximum range needs to be checked to allow defenses to engage any attacker?
-- 
-- A good functioning defense will have a "maximum range" evaluated to the enemy when CAP will be engaged or GCI will be spawned.
-- 
-- ## 6. Which Airbases, Carrier Ships, Farps will take part in the defense system for the Coalition?
-- 
-- Carefully plan which airbases will take part in the coalition. Color each airbase in the color of the coalition.
-- 
-- ## 7. Which Squadrons will I create and which name will I give each Squadron?
-- 
-- The defense system works with Squadrons. Each Squadron must be given a unique name, that forms the **key** to the defense system.
-- Several options and activities can be set per Squadron.
-- 
-- ## 8. Where will the Squadrons be located? On Airbases? On Carrier Ships? On Farps?
-- 
-- Squadrons are placed as the "home base" on an airfield, carrier or farp.
-- Carefully plan where each Squadron will be located as part of the defense system.
-- 
-- ## 9. Which plane models will I assign for each Squadron? Do I need one plane model or more plane models per squadron?
-- 
-- Per Squadron, one or multiple plane models can be allocated as **Templates**.
-- These are late activated groups with one airplane or helicopter that start with a specific name, called the **template prefix**.
-- The A2A defense system will select from the given templates a random template to spawn a new plane (group).
--  
-- ## 10. Which payloads, skills and skins will these plane models have?
-- 
-- Per Squadron, even if you have one plane model, you can still allocate multiple templates of one plane model, 
-- each having different payloads, skills and skins. 
-- The A2A defense system will select from the given templates a random template to spawn a new plane (group).
-- 
-- ## 11. For each Squadron, which will perform CAP?
-- 
-- Per Squadron, evaluate which Squadrons will perform CAP.
-- Not all Squadrons need to perform CAP.
-- 
-- ## 12. For each Squadron doing CAP, in which ZONE(s) will the CAP be performed?
-- 
-- Per CAP, evaluate **where** the CAP will be performed, in other words, define the **zone**.
-- Near the border or a bit further away?
-- 
-- ## 13. For each Squadron doing CAP, which zone types will I create?
-- 
-- Per CAP zone, evaluate whether you want:
-- 
--    * simple trigger zones
--    * polygon zones
--    * moving zones
-- 
-- Depending on the type of zone selected, a different @{Zone} object needs to be created from a ZONE_ class.
-- 
-- ## 14. For each Squadron doing CAP, what are the time intervals and CAP amounts to be performed?
-- 
-- For each CAP:
-- 
--    * **How many** CAP you want to have airborne at the same time?
--    * **How frequent** you want the defense mechanism to check whether to start a new CAP?
-- 
-- ## 15. For each Squadron, which will perform GCI?
-- 
-- For each Squadron, evaluate which Squadrons will perform GCI?
-- Not all Squadrons need to perform GCI.
-- 
-- ## 16. For each Squadron, which takeoff method will I use?
-- 
-- For each Squadron, evaluate which takeoff method will be used:
-- 
--    * Straight from the air
--    * From the runway
--    * From a parking spot with running engines
--    * From a parking spot with cold engines
-- 
-- **The default takeoff method is staight in the air.**
-- 
-- ## 17. For each Squadron, which landing method will I use?
-- 
-- For each Squadron, evaluate which landing method will be used:
-- 
--    * Despawn near the airbase when returning
--    * Despawn after landing on the runway
--    * Despawn after engine shutdown after landing
--    
-- **The default landing method is despawn when near the airbase when returning.**
-- 
-- ## 18. For each Squadron, which overhead will I use?
-- 
-- For each Squadron, depending on the airplane type (modern, old) and payload, which overhead is required to provide any defense?
-- In other words, if **X** attacker airplanes are detected, how many **Y** defense airplanes need to be spawned per squadron?
-- The **Y** is dependent on the type of airplane (era), payload, fuel levels, skills etc.
-- The overhead is a **factor** that will calculate dynamically how many **Y** defenses will be required based on **X** attackers detected.
-- 
-- **The default overhead is 1. A value greater than 1, like 1.5 will increase the overhead with 50%, a value smaller than 1, like 0.5 will decrease the overhead with 50%.**
-- 
-- ## 19. For each Squadron, which grouping will I use?
-- 
-- When multiple targets are detected, how will defense airplanes be grouped when multiple defense airplanes are spawned for multiple attackers?
-- Per one, two, three, four?
-- 
-- **The default grouping is 1. That means, that each spawned defender will act individually.**
-- 
-- ===
-- 
-- ### Authors: **Sven Van de Velde (FlightControl)** rework of GCICAP + introduction of new concepts (squadrons).
-- ### Authors: **Stonehouse**, **SNAFU** in terms of the advice, documentation, and the original GCICAP script.
-- 
-- @module AI_A2A_Dispatcher



do -- AI_A2A_DISPATCHER

  --- AI_A2A_DISPATCHER class.
  -- @type AI_A2A_DISPATCHER
  -- @extends Tasking.DetectionManager#DETECTION_MANAGER

  --- # AI\_A2A\_DISPATCHER class, extends @{Tasking#DETECTION_MANAGER}
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia1.JPG)
  -- 
  -- The @{#AI_A2A_DISPATCHER} class is designed to create an automatic air defence system for a coalition. 
  -- 
  -- ====
  -- 
  -- # Demo Missions
  -- 
  -- ### [AI\_A2A\_DISPATCHER Demo Mission](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/release-2-2-pre/AID%20-%20AI%20Dispatching/AID-100%20-%20AI_A2A%20-%20Demonstration)
  -- 
  -- ### [AI\_A2A\_DISPATCHER Mission, only for beta testers](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/AID%20-%20AI%20Dispatching/AID-100%20-%20AI_A2A%20-%20Demonstration)
  --
  -- ### [ALL Demo Missions pack of the last release](https://github.com/FlightControl-Master/MOOSE_MISSIONS/releases)
  -- 
  -- ====
  -- 
  -- # YouTube Channel
  -- 
  -- ### [---]()
  -- 
  -- ===
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia3.JPG)
  -- 
  -- It includes automatic spawning of Combat Air Patrol aircraft (CAP) and Ground Controlled Intercept aircraft (GCI) in response to enemy air movements that are detected by a ground based radar network. 
  -- CAP flights will take off and proceed to designated CAP zones where they will remain on station until the ground radars direct them to intercept detected enemy aircraft or they run short of fuel and must return to base (RTB). When a CAP flight leaves their zone to perform an interception or return to base a new CAP flight will spawn to take their place.
  -- If all CAP flights are engaged or RTB then additional GCI interceptors will scramble to intercept unengaged enemy aircraft under ground radar control.
  -- With a little time and with a little work it provides the mission designer with a convincing and completely automatic air defence system. 
  -- In short it is a plug in very flexible and configurable air defence module for DCS World.
  -- 
  -- Note that in order to create a two way A2A defense system, two AI\_A2A\_DISPATCHER defense system may need to be created, for each coalition one.
  -- This is a good implementation, because maybe in the future, more coalitions may become available in DCS world.
  -- 
  -- ===
  --
  -- # USAGE GUIDE
  -- 
  -- ## 1. AI\_A2A\_DISPATCHER constructor:
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_1.JPG)
  -- 
  -- 
  -- The @{#AI_A2A_DISPATCHER.New}() method creates a new AI\_A2A\_DISPATCHER instance.
  -- 
  -- ### 1.1. Define the **EWR network**:
  -- 
  -- As part of the AI\_A2A\_DISPATCHER :New() constructor, an EWR network must be given as the first parameter.
  -- An EWR network, or, Early Warning Radar network, is used to early detect potential airborne targets and to understand the position of patrolling targets of the enemy.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia5.JPG)
  -- 
  -- Typically EWR networks are setup using 55G6 EWR, 1L13 EWR, Hawk sr and Patriot str ground based radar units. 
  -- These radars have different ranges and 55G6 EWR and 1L13 EWR radars are Eastern Bloc units (eg Russia, Ukraine, Georgia) while the Hawk and Patriot radars are Western (eg US).
  -- Additionally, ANY other radar capable unit can be part of the EWR network! Also AWACS airborne units, planes, helicopters can help to detect targets, as long as they have radar.
  -- The position of these units is very important as they need to provide enough coverage 
  -- to pick up enemy aircraft as they approach so that CAP and GCI flights can be tasked to intercept them.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia7.JPG)
  --  
  -- Additionally in a hot war situation where the border is no longer respected the placement of radars has a big effect on how fast the war escalates. 
  -- For example if they are a long way forward and can detect enemy planes on the ground and taking off 
  -- they will start to vector CAP and GCI flights to attack them straight away which will immediately draw a response from the other coalition. 
  -- Having the radars further back will mean a slower escalation because fewer targets will be detected and 
  -- therefore less CAP and GCI flights will spawn and this will tend to make just the border area active rather than a melee over the whole map. 
  -- It all depends on what the desired effect is. 
  -- 
  -- EWR networks are **dynamically constructed**, that is, they form part of the @{Functional#DETECTION_BASE} object that is given as the input parameter of the AI\_A2A\_DISPATCHER class.
  -- By defining in a **smart way the names or name prefixes of the groups** with EWR capable units, these groups will be **automatically added or deleted** from the EWR network, 
  -- increasing or decreasing the radar coverage of the Early Warning System.
  -- 
  -- See the following example to setup an EWR network containing EWR stations and AWACS.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_2.JPG)
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_3.JPG)
  -- 
  --     -- Define a SET_GROUP object that builds a collection of groups that define the EWR network.
  --     -- Here we build the network with all the groups that have a name starting with DF CCCP AWACS and DF CCCP EWR.
  --     DetectionSetGroup = SET_GROUP:New()
  --     DetectionSetGroup:FilterPrefixes( { "DF CCCP AWACS", "DF CCCP EWR" } )
  --     DetectionSetGroup:FilterStart()
  --     
  --     -- Setup the detection.
  --     Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )
  --
  --     -- Setup the A2A dispatcher, and initialize it.
  --     A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
  --     
  -- The above example creates a SET_GROUP instance, and stores this in the variable (object) **DetectionSetGroup**.
  -- **DetectionSetGroup** is then being configured to filter all active groups with a group name starting with **DF CCCP AWACS** or **DF CCCP EWR** to be included in the Set.
  -- **DetectionSetGroup** is then being ordered to start the dynamic filtering. Note that any destroy or new spawn of a group with the above names will be removed or added to the Set.
  -- 
  -- Then a new Detection object is created from the class DETECTION_AREAS. A grouping radius of 30000 is choosen, which is 30km.
  -- The **Detection** object is then passed to the @{#AI_A2A_DISPATCHER.New}() method to indicate the EWR network configuration and setup the A2A defense detection mechanism.
  -- 
  -- You could build a **mutual defense system** like this:
  -- 
  --      A2ADispatcher_Red = AI_A2A_DISPATCHER:New( EWR_Red )
  --      A2ADispatcher_Blue = AI_A2A_DISPATCHER:New( EWR_Blue )
  --    
   -- ### 2. Define the detected **target grouping radius**:
  -- 
  -- The target grouping radius is a property of the Detection object, that was passed to the AI\_A2A\_DISPATCHER object, but can be changed.
  -- The grouping radius should not be too small, but also depends on the types of planes and the era of the simulation.
  -- Fast planes like in the 80s, need a larger radius than WWII planes.  
  -- Typically I suggest to use 30000 for new generation planes and 10000 for older era aircraft.
  -- 
  -- Note that detected targets are constantly re-grouped, that is, when certain detected aircraft are moving further than the group radius, then these aircraft will become a separate
  -- group being detected. This may result in additional GCI being started by the dispatcher! So don't make this value too small!
  -- 
  -- ## 3. Set the **Engage radius**:
  -- 
  -- Define the radius to engage any target by airborne friendlies, which are executing cap or returning from an intercept mission.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia10.JPG)
  -- 
  -- So, if there is a target area detected and reported, 
  -- then any friendlies that are airborne near this target area, 
  -- will be commanded to (re-)engage that target when available (if no other tasks were commanded).
  -- For example, if 100000 is given as a value, then any friendly that is airborne within 100km from the detected target, 
  -- will be considered to receive the command to engage that target area.
  -- You need to evaluate the value of this parameter carefully.
  -- If too small, more intercept missions may be triggered upon detected target areas.
  -- If too large, any airborne cap may not be able to reach the detected target area in time, because it is too far.
  -- 
  -- In this example an engage radius is set to 80 km.
  -- 
  --     -- Initialize the dispatcher, setting up a radius of 80km where any airborne friendly 
  --     -- without an assignment within 80km radius from a detected target, will engage that target.
  --     A2ADispatcher:SetEngageRadius( 80000 )
  -- 
  -- ## 4. Set the **Intercept radius** or **Gci radius**:
  -- 
  -- When targets are detected that are still really far off, you don't want the AI_A2A_DISPATCHER to launch intercepts just yet.
  -- You want it to wait until a certain intercept range is reached, which is the distance of the closest airbase to targer being smaller than the **Gci radius**.
  -- The Gci radius is by default defined as 200km. This value can be overridden using the method @{#AI_A2A_DISPATCHER.SetGciRadius}().
  -- Override the default Gci radius when the era of the warfare is early, or, when you don't want to let the AI_A2A_DISPATCHER react immediately when
  -- a certain border or area is not being crossed.
  -- 
  -- In this example, the GCI radius is setto 150 km:
  -- 
  --     -- Initialize the dispatcher, setting up a GCI radius of 150km where no GCI will be started if the target is further than 150 km from the closest airabse.
  --     A2ADispatcher:SetGciRadius( 80000 )
  -- 
  -- ## 5. Set the **borders**:
  -- 
  -- According to the tactical and strategic design of the mission broadly decide the shape and extent of red and blue territories. 
  -- They should be laid out such that a border area is created between the two coalitions.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia4.JPG)
  -- 
  -- Define a border area to simulate a **cold war** scenario and use the method @{#AI_A2A_DISPATCHER.SetBorderZone}() to create a border zone for the dispatcher.
  -- 
  -- A **cold war** is one where CAP aircraft patrol their territory but will not attack enemy aircraft or launch GCI aircraft unless enemy aircraft enter their territory. In other words the EWR may detect an enemy aircraft but will only send aircraft to attack it if it crosses the border.
  -- A **hot war** is one where CAP aircraft will intercept any detected enemy aircraft and GCI aircraft will launch against detected enemy aircraft without regard for territory. In other words if the ground radar can detect the enemy aircraft then it will send CAP and GCI aircraft to attack it.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia9.JPG)
  -- 
  -- If it’s a cold war then the **borders of red and blue territory** need to be defined using a @{zone} object derived from @{Zone#ZONE_BASE}.
  -- If a hot war is chosen then **no borders** actually need to be defined using the helicopter units other than 
  -- it makes it easier sometimes for the mission maker to envisage where the red and blue territories roughly are. 
  -- In a hot war the borders are effectively defined by the ground based radar coverage of a coalition.
  -- 
  -- In this example a border is set for the CCCP A2A dispatcher:
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_4.JPG)
  -- 
  --     -- Setup the A2A dispatcher, and initialize it.
  --     A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )
  --     
  --     -- Setup the border.
  --     -- Initialize the dispatcher, setting up a border zone. This is a polygon, 
  --     -- which takes the waypoints of a late activated group with the name CCCP Border as the boundaries of the border area.
  --     -- Any enemy crossing this border will be engaged.
  -- 
  --     CCCPBorderZone = ZONE_POLYGON:New( "CCCP Border", GROUP:FindByName( "CCCP Border" ) )
  --     A2ADispatcher:SetBorderZone( CCCPBorderZone )
  --     
  -- ## 6. Squadrons: 
  -- 
  -- The AI\_A2A\_DISPATCHER works with **Squadrons**, that need to be defined using the different methods available.
  -- 
  -- Use the method @{#AI_A2A_DISPATCHER.SetSquadron}() to **setup a new squadron** active at an airfield, 
  -- while defining which plane types are being used by the squadron and how many resources are available.
  -- 
  -- Squadrons:
  -- 
  --   * Have name (string) that is the identifier or key of the squadron.
  --   * Have specific plane types.
  --   * Are located at one airbase.
  --   * Have a limited set of resources.
  -- 
  -- The name of the squadron given acts as the **squadron key** in the AI\_A2A\_DISPATCHER:Squadron...() methods.
  -- 
  -- Additionally, squadrons have specific configuration options to:
  -- 
  --   * Control how new aircraft are taking off from the airfield (in the air, cold, hot, at the runway).
  --   * Control how returning aircraft are landing at the airfield (in the air near the airbase, after landing, after engine shutdown).
  --   * Control the **grouping** of new aircraft spawned at the airfield. If there is more than one aircraft to be spawned, these may be grouped.
  --   * Control the **overhead** or defensive strength of the squadron. Depending on the types of planes and amount of resources, the mission designer can choose to increase or reduce the amount of planes spawned.
  --   
  -- For performance and bug workaround reasons within DCS, squadrons have different methods to spawn new aircraft or land returning or damaged aircraft.
  -- 
  -- This example defines a couple of squadrons. Note the templates defined within the Mission Editor.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_5.JPG)
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_6.JPG)
  -- 
  --      -- Setup the squadrons.
  --      A2ADispatcher:SetSquadron( "Mineralnye", AIRBASE.Caucasus.Mineralnye_Vody, { "SQ CCCP SU-27" }, 20 )
  --      A2ADispatcher:SetSquadron( "Maykop", AIRBASE.Caucasus.Maykop_Khanskaya, { "SQ CCCP MIG-31" }, 20 )
  --      A2ADispatcher:SetSquadron( "Mozdok", AIRBASE.Caucasus.Mozdok, { "SQ CCCP MIG-31" }, 20 )
  --      A2ADispatcher:SetSquadron( "Sochi", AIRBASE.Caucasus.Sochi_Adler, { "SQ CCCP SU-27" }, 20 )
  --      A2ADispatcher:SetSquadron( "Novo", AIRBASE.Caucasus.Novorossiysk, { "SQ CCCP SU-27" }, 20 )
  -- 
  -- ### 6.1. Set squadron take-off methods
  -- 
  -- Use the various SetSquadronTakeoff... methods to control how squadrons are taking-off from the airfield:
  -- 
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoff}() is the generic configuration method to control takeoff from the air, hot, cold or from the runway. See the method for further details.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffInAir}() will spawn new aircraft from the squadron directly in the air.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffFromParkingCold}() will spawn new aircraft in without running engines at a parking spot at the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffFromParkingHot}() will spawn new aircraft in with running engines at a parking spot at the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffFromRunway}() will spawn new aircraft at the runway at the airfield.
  -- 
  -- **The default landing method is to spawn new aircraft directly in the air.**
  -- **The default takeoff method can be set for ALL squadrons that don't have an individual takeoff method configured.**
  -- 
  --   * @{#AI_A2A_DISPATCHER.SetDefaultTakeoff}() is the generic configuration method to control takeoff by default from the air, hot, cold or from the runway. See the method for further details.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultTakeoffInAir}() will spawn by default new aircraft from the squadron directly in the air.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultTakeoffFromParkingCold}() will spawn by default new aircraft in without running engines at a parking spot at the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultTakeoffFromParkingHot}() will spawn by default new aircraft in with running engines at a parking spot at the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultTakeoffFromRunway}() will spawn by default new aircraft at the runway at the airfield.
  -- 
  -- Use these methods to fine-tune for specific airfields that are known to create bottlenecks, or have reduced airbase efficiency.
  -- The more and the longer aircraft need to taxi at an airfield, the more risk there is that:
  -- 
  --   * aircraft will stop waiting for each other or for a landing aircraft before takeoff.
  --   * aircraft may get into a "dead-lock" situation, where two aircraft are blocking each other.
  --   * aircraft may collide at the airbase.
  --   * aircraft may be awaiting the landing of a plane currently in the air, but never lands ...
  --   
  -- Currently within the DCS engine, the airfield traffic coordination is erroneous and contains a lot of bugs.
  -- If you experience while testing problems with aircraft take-off or landing, please use one of the above methods as a solution to workaround these issues!
  -- 
  -- This example sets the default takeoff method to be from the runway.
  -- And for a couple of squadrons overrides this default method.
  -- 
  --      -- Setup the Takeoff methods
  --      
  --      -- The default takeoff
  --      A2ADispatcher:SetDefaultTakeOffFromRunway()
  --      
  --      -- The individual takeoff per squadron
  --      A2ADispatcher:SetSquadronTakeoff( "Mineralnye", AI_A2A_DISPATCHER.Takeoff.Air )
  --      A2ADispatcher:SetSquadronTakeoffInAir( "Sochi" )
  --      A2ADispatcher:SetSquadronTakeoffFromRunway( "Mozdok" )
  --      A2ADispatcher:SetSquadronTakeoffFromParkingCold( "Maykop" )
  --      A2ADispatcher:SetSquadronTakeoffFromParkingHot( "Novo" )  
  -- 
  -- 
  -- ### 6.2. Set squadron landing methods
  -- 
  -- In analogy with takeoff, the landing methods are to control how squadrons land at the airfield:
  -- 
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLanding}() is the generic configuration method to control landing, namely despawn the aircraft near the airfield in the air, right after landing, or at engine shutdown.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLandingNearAirbase}() will despawn the returning aircraft in the air when near the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLandingAtRunway}() will despawn the returning aircraft directly after landing at the runway.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLandingAtEngineShutdown}() will despawn the returning aircraft when the aircraft has returned to its parking spot and has turned off its engines.
  -- 
  -- **The default landing method can be set for ALL squadrons that don't have an individual landing method configured.**
  -- 
  --   * @{#AI_A2A_DISPATCHER.SetDefaultLanding}() is the generic configuration method to control by default landing, namely despawn the aircraft near the airfield in the air, right after landing, or at engine shutdown.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultLandingNearAirbase}() will despawn by default the returning aircraft in the air when near the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultLandingAtRunway}() will despawn by default the returning aircraft directly after landing at the runway.
  --   * @{#AI_A2A_DISPATCHER.SetDefaultLandingAtEngineShutdown}() will despawn by default the returning aircraft when the aircraft has returned to its parking spot and has turned off its engines.
  -- 
  -- You can use these methods to minimize the airbase coodination overhead and to increase the airbase efficiency.
  -- When there are lots of aircraft returning for landing, at the same airbase, the takeoff process will be halted, which can cause a complete failure of the
  -- A2A defense system, as no new CAP or GCI planes can takeoff.
  -- Note that the method @{#AI_A2A_DISPATCHER.SetSquadronLandingNearAirbase}() will only work for returning aircraft, not for damaged or out of fuel aircraft.
  -- Damaged or out-of-fuel aircraft are returning to the nearest friendly airbase and will land, and are out of control from ground control.
  -- 
  -- This example defines the default landing method to be at the runway.
  -- And for a couple of squadrons overrides this default method.
  -- 
  --      -- Setup the Landing methods
  -- 
  --      -- The default landing method
  --      A2ADispatcher:SetDefaultLandingAtRunway()
  -- 
  --      -- The individual landing per squadron
  --      A2ADispatcher:SetSquadronLandingAtRunway( "Mineralnye" )
  --      A2ADispatcher:SetSquadronLandingNearAirbase( "Sochi" )
  --      A2ADispatcher:SetSquadronLandingAtEngineShutdown( "Mozdok" )
  --      A2ADispatcher:SetSquadronLandingNearAirbase( "Maykop" )
  --      A2ADispatcher:SetSquadronLanding( "Novo", AI_A2A_DISPATCHER.Landing.AtRunway )
  -- 
  -- 
  -- ### 6.3. Set squadron grouping
  -- 
  -- Use the method @{#AI_A2A_DISPATCHER.SetSquadronGrouping}() to set the grouping of CAP or GCI flights that will take-off when spawned.
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia12.JPG)
  -- 
  -- In the case of GCI, the @{#AI_A2A_DISPATCHER.SetSquadronGrouping}() method has additional behaviour. When there aren't enough CAP flights airborne, a GCI will be initiated for the remaining
  -- targets to be engaged. Depending on the grouping parameter, the spawned flights for GCI are grouped into this setting.   
  -- For example with a group setting of 2, if 3 targets are detected and cannot be engaged by CAP or any airborne flight, 
  -- a GCI needs to be started, the GCI flights will be grouped as follows: Group 1 of 2 flights and Group 2 of one flight!
  -- 
  -- The **grouping value is set for a Squadron**, and can be **dynamically adjusted** during mission execution, so to adjust the defense flights grouping when the tactical situation changes.
  -- 
  -- **The default grouping value can be set for ALL squadrons that don't have an individual grouping value configured.**
  -- 
  -- Use the method @{#AI_A2A_DISPATCHER.SetDefaultGrouping}() to set the **default grouping** of spawned airplanes for all squadrons.
  -- 
  -- ### 6.4. Balance or setup effectiveness of the air defenses in case of GCI
  -- 
  -- The effectiveness can be set with the **overhead parameter**. This is a number that is used to calculate the amount of Units that dispatching command will allocate to GCI in surplus of detected amount of units.
  -- The **default value** of the overhead parameter is 1.0, which means **equal balance**. 
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia11.JPG)
  -- 
  -- However, depending on the (type of) aircraft (strength and payload) in the squadron and the amount of resources available, this parameter can be changed.
  -- 
  -- The @{#AI_A2A_DISPATCHER.SetSquadronOverhead}() method can be used to tweak the defense strength,
  -- taking into account the plane types of the squadron. 
  -- 
  -- For example, a MIG-31 with full long-distance A2A missiles payload, may still be less effective than a F-15C with short missiles...
  -- So in this case, one may want to use the @{#AI_A2A_DISPATCHER.SetOverhead}() method to allocate more defending planes as the amount of detected attacking planes.
  -- The overhead must be given as a decimal value with 1 as the neutral value, which means that overhead values: 
  -- 
  --   * Higher than 1.0, for example 1.5, will increase the defense unit amounts. For 4 planes detected, 6 planes will be spawned.
  --   * Lower than 1, for example 0.75, will decrease the defense unit amounts. For 4 planes detected, only 3 planes will be spawned.
  -- 
  -- The amount of defending units is calculated by multiplying the amount of detected attacking planes as part of the detected group 
  -- multiplied by the Overhead and rounded up to the smallest integer. 
  -- 
  -- The **overhead value is set for a Squadron**, and can be **dynamically adjusted** during mission execution, so to adjust the defense overhead when the tactical situation changes.
  --
  -- **The default overhead value can be set for ALL squadrons that don't have an individual overhead value configured.**
  --
  -- Use the @{#AI_A2A_DISPATCHER.SetDefaultOverhead}() method can be used to set the default the defense strength for ALL squadrons.
  --
  -- ## 7. Setup a squadron for CAP
  -- 
  -- ### 7.1. Set the CAP zones
  -- 
  -- CAP zones are patrol areas where Combat Air Patrol (CAP) flights loiter until they either return to base due to low fuel or are assigned an interception task by ground control.
  --   
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia6.JPG)
  -- 
  --   * As the CAP flights wander around within the zone waiting to be tasked, these zones need to be large enough that the aircraft are not constantly turning 
  --   but do not have to be big and numerous enough to completely cover a border.
  --   
  --   * CAP zones can be of any type, and are derived from the @{Zone#ZONE_BASE} class. Zones can be @{Zone#ZONE}, @{Zone#ZONE_POLYGON}, @{Zone#ZONE_UNIT}, @{Zone#ZONE_GROUP}, etc.
  --   This allows to setup **static, moving and/or complex zones** wherein aircraft will perform the CAP.
  --   
  --   * Typically 20000-50000 metres width is used and they are spaced so that aircraft in the zone waiting for tasks don’t have to far to travel to protect their coalitions important targets. 
  --   These targets are chosen as part of the mission design and might be an important airfield or town etc. 
  --   Zone size is also determined somewhat by territory size, plane types 
  --   (eg WW2 aircraft might mean smaller zones or more zones because they are slower and take longer to intercept enemy aircraft).
  --   
  --   * In a **cold war** it is important to make sure a CAP zone doesn’t intrude into enemy territory as otherwise CAP flights will likely cross borders 
  --   and spark a full scale conflict which will escalate rapidly.
  --   
  --   * CAP flights do not need to be in the CAP zone before they are “on station” and ready for tasking. 
  --   
  --   * Typically if a CAP flight is tasked and therefore leaves their zone empty while they go off and intercept their target another CAP flight will spawn to take their place.
  --  
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia7.JPG)
  -- 
  -- The following example illustrates how CAP zones are coded:
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_8.JPG) 
  -- 
  --      -- CAP Squadron execution.
  --      CAPZoneEast = ZONE_POLYGON:New( "CAP Zone East", GROUP:FindByName( "CAP Zone East" ) )
  --      A2ADispatcher:SetSquadronCap( "Mineralnye", CAPZoneEast, 4000, 10000, 500, 600, 800, 900 )
  --      A2ADispatcher:SetSquadronCapInterval( "Mineralnye", 2, 30, 60, 1 )
  --      
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_7.JPG) 
  --        
  --      CAPZoneWest = ZONE_POLYGON:New( "CAP Zone West", GROUP:FindByName( "CAP Zone West" ) )
  --      A2ADispatcher:SetSquadronCap( "Sochi", CAPZoneWest, 4000, 8000, 600, 800, 800, 1200, "BARO" )
  --      A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_DISPATCHER-ME_9.JPG) 
  --        
  --      CAPZoneMiddle = ZONE:New( "CAP Zone Middle")
  --      A2ADispatcher:SetSquadronCap( "Maykop", CAPZoneMiddle, 4000, 8000, 600, 800, 800, 1200, "RADIO" )
  --      A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  --  
  -- Note the different @{Zone} MOOSE classes being used to create zones of different types. Please click the @{Zone} link for more information about the different zone types.
  -- Zones can be circles, can be setup in the mission editor using trigger zones, but can also be setup in the mission editor as polygons and in this case GROUP objects are being used!
  -- 
  -- ## 7.2. Set the squadron to execute CAP:
  --      
  -- The method @{#AI_A2A_DISPATCHER.SetSquadronCap}() defines a CAP execution for a squadron.
  -- 
  -- Setting-up a CAP zone also requires specific parameters:
  -- 
  --   * The minimum and maximum altitude
  --   * The minimum speed and maximum patrol speed
  --   * The minimum and maximum engage speed
  --   * The type of altitude measurement
  -- 
  -- These define how the squadron will perform the CAP while partrolling. Different terrain types requires different types of CAP. 
  -- 
  -- The @{#AI_A2A_DISPATCHER.SetSquadronCapInterval}() method specifies **how much** and **when** CAP flights will takeoff.
  -- 
  -- It is recommended not to overload the air defense with CAP flights, as these will decrease the performance of the overall system. 
  -- 
  -- For example, the following setup will create a CAP for squadron "Sochi":
  -- 
  --      A2ADispatcher:SetSquadronCap( "Sochi", CAPZoneWest, 4000, 8000, 600, 800, 800, 1200, "BARO" )
  --      A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  -- 
  -- ## 8. Setup a squadron for GCI:
  -- 
  -- The method @{#AI_A2A_DISPATCHER.SetSquadronGci}() defines a GCI execution for a squadron.
  -- 
  -- Setting-up a GCI readiness also requires specific parameters:
  -- 
  --   * The minimum speed and maximum patrol speed
  -- 
  -- Essentially this controls how many flights of GCI aircraft can be active at any time.
  -- Note allowing large numbers of active GCI flights can adversely impact mission performance on low or medium specification hosts/servers.
  -- GCI needs to be setup at strategic airbases. Too far will mean that the aircraft need to fly a long way to reach the intruders, 
  -- too short will mean that the intruders may have alraedy passed the ideal interception point!
  -- 
  -- For example, the following setup will create a GCI for squadron "Sochi":
  -- 
  --      A2ADispatcher:SetSquadronGci( "Mozdok", 900, 1200 )
  -- 
  -- ## 9. Other configuration options
  -- 
  -- ### 9.1. Set a tactical display panel:
  -- 
  -- Every 30 seconds, a tactical display panel can be shown that illustrates what the status is of the different groups controlled by AI\_A2A\_DISPATCHER.
  -- Use the method @{#AI_A2A_DISPATCHER.SetTacticalDisplay}() to switch on the tactical display panel. The default will not show this panel.
  -- Note that there may be some performance impact if this panel is shown.
  -- 
  -- ## 10. Q & A:
  -- 
  -- ### 10.1. Which countries will be selected for each coalition?
  -- 
  -- Which countries are assigned to a coalition influences which units are available to the coalition. 
  -- For example because the mission calls for a EWR radar on the blue side the Ukraine might be chosen as a blue country 
  -- so that the 55G6 EWR radar unit is available to blue.  
  -- Some countries assign different tasking to aircraft, for example Germany assigns the CAP task to F-4E Phantoms but the USA does not.  
  -- Therefore if F4s are wanted as a coalition’s CAP or GCI aircraft Germany will need to be assigned to that coalition. 
  -- 
  -- ### 10.2. Country, type, load out, skill and skins for CAP and GCI aircraft?
  -- 
  --   * Note these can be from any countries within the coalition but must be an aircraft with one of the main tasks being “CAP”.
  --   * Obviously skins which are selected must be available to all players that join the mission otherwise they will see a default skin.
  --   * Load outs should be appropriate to a CAP mission eg perhaps drop tanks for CAP flights and extra missiles for GCI flights. 
  --   * These decisions will eventually lead to template aircraft units being placed as late activation units that the script will use as templates for spawning CAP and GCI flights. Up to 4 different aircraft configurations can be chosen for each coalition. The spawned aircraft will inherit the characteristics of the template aircraft.
  --   * The selected aircraft type must be able to perform the CAP tasking for the chosen country. 
  -- 
  -- 
  -- @field #AI_A2A_DISPATCHER
  AI_A2A_DISPATCHER = {
    ClassName = "AI_A2A_DISPATCHER",
    Detection = nil,
  }


  --- Enumerator for spawns at airbases
  -- @type AI_A2A_DISPATCHER.Takeoff
  -- @extends Wrapper.Group#GROUP.Takeoff
  
  --- @field #AI_A2A_DISPATCHER.Takeoff Takeoff
  AI_A2A_DISPATCHER.Takeoff = GROUP.Takeoff
  
  --- Defnes Landing location.
  -- @field Landing
  AI_A2A_DISPATCHER.Landing = {
    NearAirbase = 1,
    AtRunway = 2,
    AtEngineShutdown = 3,
  }
  
  --- AI_A2A_DISPATCHER constructor.
  -- This is defining the A2A DISPATCHER for one coaliton.
  -- The Dispatcher works with a @{Functional#Detection} object that is taking of the detection of targets using the EWR units.
  -- The Detection object is polymorphic, depending on the type of detection object choosen, the detection will work differently.
  -- @param #AI_A2A_DISPATCHER self
  -- @param Functional.Detection#DETECTION_BASE Detection The DETECTION object that will detects targets using the the Early Warning Radar network.
  -- @return #AI_A2A_DISPATCHER self
  -- @usage
  --   
  --   -- Setup the Detection, using DETECTION_AREAS.
  --   -- First define the SET of GROUPs that are defining the EWR network.
  --   -- Here with prefixes DF CCCP AWACS, DF CCCP EWR.
  --   DetectionSetGroup = SET_GROUP:New()
  --   DetectionSetGroup:FilterPrefixes( { "DF CCCP AWACS", "DF CCCP EWR" } )
  --   DetectionSetGroup:FilterStart()
  --   
  --   -- Define the DETECTION_AREAS, using the DetectionSetGroup, with a 30km grouping radius.
  --   Detection = DETECTION_AREAS:New( DetectionSetGroup, 30000 )
  -- 
  --   -- Now Setup the A2A dispatcher, and initialize it using the Detection object.
  --   A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )  --   
  -- 
  function AI_A2A_DISPATCHER:New( Detection )

    -- Inherits from DETECTION_MANAGER
    local self = BASE:Inherit( self, DETECTION_MANAGER:New( nil, Detection ) ) -- #AI_A2A_DISPATCHER
    
    self.Detection = Detection -- Functional.Detection#DETECTION_AREAS
    
    -- This table models the DefenderSquadron templates.
    self.DefenderSquadrons = {} -- The Defender Squadrons.
    self.DefenderSpawns = {}
    self.DefenderTasks = {} -- The Defenders Tasks.
    self.DefenderDefault = {} -- The Defender Default Settings over all Squadrons.
    
    -- TODO: Check detection through radar.
    self.Detection:FilterCategories( { Unit.Category.AIRPLANE, Unit.Category.HELICOPTER } )
    --self.Detection:InitDetectRadar( true )
    self.Detection:SetDetectionInterval( 30 )

    self:SetEngageRadius()
    self:SetGciRadius()
    
    self:SetDefaultTakeoff( AI_A2A_DISPATCHER.Takeoff.Air )
    self:SetDefaultLanding( AI_A2A_DISPATCHER.Landing.NearAirbase )
    self:SetDefaultOverhead( 1 )
    self:SetDefaultGrouping( 1 )
    
    
    self:AddTransition( "Started", "Assign", "Started" )
    
    --- OnAfter Transition Handler for Event Assign.
    -- @function [parent=#AI_A2A_DISPATCHER] OnAfterAssign
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From The From State string.
    -- @param #string Event The Event string.
    -- @param #string To The To State string.
    -- @param Tasking.Task_A2A#AI_A2A Task
    -- @param Wrapper.Unit#UNIT TaskUnit
    -- @param #string PlayerName
    
    self:AddTransition( "*", "CAP", "*" )

    --- CAP Handler OnBefore for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] OnBeforeCAP
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From
    -- @param #string Event
    -- @param #string To
    -- @return #boolean
    
    --- CAP Handler OnAfter for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] OnAfterCAP
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From
    -- @param #string Event
    -- @param #string To
    
    --- CAP Trigger for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] CAP
    -- @param #AI_A2A_DISPATCHER self
    
    --- CAP Asynchronous Trigger for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] __CAP
    -- @param #AI_A2A_DISPATCHER self
    -- @param #number Delay
    
    self:AddTransition( "*", "GCI", "*" )

    --- GCI Handler OnBefore for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] OnBeforeGCI
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From
    -- @param #string Event
    -- @param #string To
    -- @return #boolean
    
    --- GCI Handler OnAfter for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] OnAfterGCI
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From
    -- @param #string Event
    -- @param #string To
    
    --- GCI Trigger for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] GCI
    -- @param #AI_A2A_DISPATCHER self
    
    --- GCI Asynchronous Trigger for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] __GCI
    -- @param #AI_A2A_DISPATCHER self
    -- @param #number Delay
    
    self:AddTransition( "*", "ENGAGE", "*" )
        
    --- ENGAGE Handler OnBefore for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] OnBeforeENGAGE
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From
    -- @param #string Event
    -- @param #string To
    -- @return #boolean
    
    --- ENGAGE Handler OnAfter for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] OnAfterENGAGE
    -- @param #AI_A2A_DISPATCHER self
    -- @param #string From
    -- @param #string Event
    -- @param #string To
    
    --- ENGAGE Trigger for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] ENGAGE
    -- @param #AI_A2A_DISPATCHER self
    
    --- ENGAGE Asynchronous Trigger for AI_A2A_DISPATCHER
    -- @function [parent=#AI_A2A_DISPATCHER] __ENGAGE
    -- @param #AI_A2A_DISPATCHER self
    -- @param #number Delay
    
    
    -- Subscribe to the CRASH event so that when planes are shot
    -- by a Unit from the dispatcher, they will be removed from the detection...
    -- This will avoid the detection to still "know" the shot unit until the next detection.
    -- Otherwise, a new intercept or engage may happen for an already shot plane!
    
    self:HandleEvent( EVENTS.Crash, self.OnEventCrashOrDead )
    self:HandleEvent( EVENTS.Dead, self.OnEventCrashOrDead )
    
    self:HandleEvent( EVENTS.Land )
    self:HandleEvent( EVENTS.EngineShutdown )
    
    self:SetTacticalDisplay( false )
    
    self:__Start( 5 )
    
    return self
  end

  --- @param #AI_A2A_DISPATCHER self
  -- @param Core.Event#EVENTDATA EventData
  function AI_A2A_DISPATCHER:OnEventCrashOrDead( EventData )
    self.Detection:ForgetDetectedUnit( EventData.IniUnitName ) 
  end

  --- @param #AI_A2A_DISPATCHER self
  -- @param Core.Event#EVENTDATA EventData
  function AI_A2A_DISPATCHER:OnEventLand( EventData )
    self:F( "Landed" )
    local DefenderUnit = EventData.IniUnit
    local Defender = EventData.IniGroup
    local Squadron = self:GetSquadronFromDefender( Defender )
    if Squadron then
      self:F( { SquadronName = Squadron.Name } )
      local LandingMethod = self:GetSquadronLanding( Squadron.Name )
      if LandingMethod == AI_A2A_DISPATCHER.Landing.AtRunway then
        local DefenderSize = Defender:GetSize()
        if DefenderSize == 1 then
          self:RemoveDefenderFromSquadron( Squadron, Defender )
        end
        DefenderUnit:Destroy()
        return
      end
      if DefenderUnit:GetLife() ~= DefenderUnit:GetLife0() then
        -- Damaged units cannot be repaired anymore.
        DefenderUnit:Destroy()
        return
      end        
    end 
  end
  
  --- @param #AI_A2A_DISPATCHER self
  -- @param Core.Event#EVENTDATA EventData
  function AI_A2A_DISPATCHER:OnEventEngineShutdown( EventData )
    local DefenderUnit = EventData.IniUnit
    local Defender = EventData.IniGroup
    local Squadron = self:GetSquadronFromDefender( Defender )
    if Squadron then
      self:F( { SquadronName = Squadron.Name } )
      local LandingMethod = self:GetSquadronLanding( Squadron.Name )
      if LandingMethod == AI_A2A_DISPATCHER.Landing.AtEngineShutdown then
        local DefenderSize = Defender:GetSize()
        if DefenderSize == 1 then
          self:RemoveDefenderFromSquadron( Squadron, Defender )
        end
        DefenderUnit:Destroy()
      end
    end 
  end
  
  --- Define the radius to engage any target by airborne friendlies, which are executing cap or returning from an intercept mission.
  -- So, if there is a target area detected and reported, 
  -- then any friendlies that are airborne near this target area, 
  -- will be commanded to (re-)engage that target when available (if no other tasks were commanded).
  -- For example, if 100000 is given as a value, then any friendly that is airborne within 100km from the detected target, 
  -- will be considered to receive the command to engage that target area.
  -- You need to evaluate the value of this parameter carefully.
  -- If too small, more intercept missions may be triggered upon detected target areas.
  -- If too large, any airborne cap may not be able to reach the detected target area in time, because it is too far.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #number EngageRadius (Optional, Default = 100000) The radius to report friendlies near the target.
  -- @return #AI_A2A_DISPATCHER
  -- @usage
  -- 
  --   -- Set 50km as the radius to engage any target by airborne friendlies.
  --   Dispatcher:SetEngageRadius( 50000 )
  --   
  --   -- Set 100km as the radius to engage any target by airborne friendlies.
  --   Dispatcher:SetEngageRadius() -- 100000 is the default value.
  --   
  function AI_A2A_DISPATCHER:SetEngageRadius( EngageRadius )

    self.Detection:SetFriendliesRange( EngageRadius )
  
    return self
  end
  
  --- Define the radius to check if a target can be engaged by an ground controlled intercept.
  -- So, if there is a target area detected and reported, 
  -- and a GCI is to be executed, 
  -- then it will be check if the target is within the GCI from the nearest airbase.
  -- For example, if 150000 is given as a value, then any airbase within 150km from the detected target, 
  -- will be considered to receive the command to GCI.
  -- You need to evaluate the value of this parameter carefully.
  -- If too small, intercept missions may be triggered too late.
  -- If too large, intercept missions may be triggered when the detected target is too far.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #number GciRadius (Optional, Default = 200000) The radius to ground control intercept detected targets from the nearest airbase.
  -- @return #AI_A2A_DISPATCHER
  -- @usage
  -- 
  --   -- Now Setup the A2A dispatcher, and initialize it using the Detection object.
  --   A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )  --   
  --   
  --   -- Set 100km as the radius to ground control intercept detected targets from the nearest airbase.
  --   A2ADispatcher:SetGciRadius( 100000 )
  --   
  --   -- Set 200km as the radius to ground control intercept.
  --   A2ADispatcher:SetGciRadius() -- 200000 is the default value.
  --   
  function AI_A2A_DISPATCHER:SetGciRadius( GciRadius )

    self.GciRadius = GciRadius or 200000 
  
    return self
  end
  
  
  
  --- Define a border area to simulate a **cold war** scenario.
  -- A **cold war** is one where CAP aircraft patrol their territory but will not attack enemy aircraft or launch GCI aircraft unless enemy aircraft enter their territory. In other words the EWR may detect an enemy aircraft but will only send aircraft to attack it if it crosses the border.
  -- A **hot war** is one where CAP aircraft will intercept any detected enemy aircraft and GCI aircraft will launch against detected enemy aircraft without regard for territory. In other words if the ground radar can detect the enemy aircraft then it will send CAP and GCI aircraft to attack it.
  -- If it’s a cold war then the **borders of red and blue territory** need to be defined using a @{zone} object derived from @{Zone#ZONE_BASE}. This method needs to be used for this.
  -- If a hot war is chosen then **no borders** actually need to be defined using the helicopter units other than it makes it easier sometimes for the mission maker to envisage where the red and blue territories roughly are. In a hot war the borders are effectively defined by the ground based radar coverage of a coalition. Set the noborders parameter to 1
  -- @param #AI_A2A_DISPATCHER self
  -- @param Core.Zone#ZONE_BASE BorderZone An object derived from ZONE_BASE, or a list of objects derived from ZONE_BASE.
  -- @return #AI_A2A_DISPATCHER
  -- @usage
  -- 
  --   -- Now Setup the A2A dispatcher, and initialize it using the Detection object.
  --   A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )  
  --   
  --   -- Set one ZONE_POLYGON object as the border for the A2A dispatcher.
  --   local BorderZone = ZONE_POLYGON( "CCCP Border", GROUP:FindByName( "CCCP Border" ) ) -- The GROUP object is a late activate helicopter unit.
  --   A2ADispatcher:SetBorderZone( BorderZone )
  --   
  -- or
  --   
  --   -- Set two ZONE_POLYGON objects as the border for the A2A dispatcher.
  --   local BorderZone1 = ZONE_POLYGON( "CCCP Border1", GROUP:FindByName( "CCCP Border1" ) ) -- The GROUP object is a late activate helicopter unit.
  --   local BorderZone2 = ZONE_POLYGON( "CCCP Border2", GROUP:FindByName( "CCCP Border2" ) ) -- The GROUP object is a late activate helicopter unit.
  --   A2ADispatcher:SetBorderZone( { BorderZone1, BorderZone2 } )
  --   
  --   
  function AI_A2A_DISPATCHER:SetBorderZone( BorderZone )

    self.Detection:SetAcceptZones( BorderZone )

    return self
  end
  
  --- Display a tactical report every 30 seconds about which aircraft are:
  --   * Patrolling
  --   * Engaging
  --   * Returning
  --   * Damaged
  --   * Out of Fuel
  --   * ...
  -- @param #AI_A2A_DISPATCHER self
  -- @param #boolean TacticalDisplay Provide a value of **true** to display every 30 seconds a tactical overview.
  -- @return #AI_A2A_DISPATCHER
  -- @usage
  -- 
  --   -- Now Setup the A2A dispatcher, and initialize it using the Detection object.
  --   A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )  
  --   
  --   -- Now Setup the Tactical Display for debug mode.
  --   A2ADispatcher:SetTacticalDisplay( true )
  --   
  function AI_A2A_DISPATCHER:SetTacticalDisplay( TacticalDisplay )
    
    self.TacticalDisplay = TacticalDisplay
    
    return self
  end  

  --- Calculates which AI friendlies are nearby the area
  -- @param #AI_A2A_DISPATCHER self
  -- @param DetectedItem
  -- @return #number, Core.CommandCenter#REPORT
  function AI_A2A_DISPATCHER:GetAIFriendliesNearBy( DetectedItem )
  
    local FriendliesNearBy = self.Detection:GetFriendliesDistance( DetectedItem )
    
    return FriendliesNearBy
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:GetDefenderTasks()
    return self.DefenderTasks or {}
  end
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:GetDefenderTask( Defender )
    return self.DefenderTasks[Defender]
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:GetDefenderTaskFsm( Defender )
    return self:GetDefenderTask( Defender ).Fsm
  end
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:GetDefenderTaskTarget( Defender )
    return self:GetDefenderTask( Defender ).Target
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:ClearDefenderTask( Defender )
    if Defender:IsAlive() and self.DefenderTasks[Defender] then
      local Target = self.DefenderTasks[Defender].Target
      local Message = "Clearing (" .. self.DefenderTasks[Defender].Type .. ") " 
      Message = Message .. Defender:GetName() 
      if Target then
        Message = Message .. ( Target and ( " from " .. Target.Index .. " [" .. Target.Set:Count() .. "]" ) ) or ""
      end
      self:F( { Target = Message } )
    end
    self.DefenderTasks[Defender] = nil
    return self
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:ClearDefenderTaskTarget( Defender )
    
    local DefenderTask = self:GetDefenderTask( Defender )
    
    if Defender:IsAlive() and DefenderTask then
      local Target = DefenderTask.Target
      local Message = "Clearing (" .. DefenderTask.Type .. ") " 
      Message = Message .. Defender:GetName() 
      if Target then
        Message = Message .. ( Target and ( " from " .. Target.Index .. " [" .. Target.Set:Count() .. "]" ) ) or ""
      end
      self:F( { Target = Message } )
    end
    if Defender and DefenderTask and DefenderTask.Target then
      DefenderTask.Target = nil
    end
--    if Defender and DefenderTask then
--      if DefenderTask.Fsm:Is( "Fuel" ) 
--      or DefenderTask.Fsm:Is( "LostControl") 
--      or DefenderTask.Fsm:Is( "Damaged" ) then
--        self:ClearDefenderTask( Defender )
--      end
--    end
    return self
  end

  
  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:SetDefenderTask( Defender, Type, Fsm, Target )
  
    self.DefenderTasks[Defender] = self.DefenderTasks[Defender] or {}
    self.DefenderTasks[Defender].Type = Type
    self.DefenderTasks[Defender].Fsm = Fsm

    if Target then
      self:SetDefenderTaskTarget( Defender, Target )
    end
    return self
  end
  
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param Wrapper.Group#GROUP AIGroup
  function AI_A2A_DISPATCHER:SetDefenderTaskTarget( Defender, Target )
    
    local Message = "(" .. self.DefenderTasks[Defender].Type .. ") " 
    Message = Message .. Defender:GetName() 
    Message = Message .. ( Target and ( " target " .. Target.Index .. " [" .. Target.Set:Count() .. "]" ) ) or ""
    self:F( { Target = Message } )
    if Target then
      self.DefenderTasks[Defender].Target = Target
    end
    return self
  end


  --- This is the main method to define Squadrons programmatically.  
  -- Squadrons:
  -- 
  --   * Have a **name or key** that is the identifier or key of the squadron.
  --   * Have **specific plane types** defined by **templates**.
  --   * Are **located at one specific airbase**. Multiple squadrons can be located at one airbase through.
  --   * Have a limited set of **resources**.
  -- 
  -- The name of the squadron given acts as the **squadron key** in the AI\_A2A\_DISPATCHER:Squadron...() methods.
  -- 
  -- Additionally, squadrons have specific configuration options to:
  -- 
  --   * Control how new aircraft are **taking off** from the airfield (in the air, cold, hot, at the runway).
  --   * Control how returning aircraft are **landing** at the airfield (in the air near the airbase, after landing, after engine shutdown).
  --   * Control the **grouping** of new aircraft spawned at the airfield. If there is more than one aircraft to be spawned, these may be grouped.
  --   * Control the **overhead** or defensive strength of the squadron. Depending on the types of planes and amount of resources, the mission designer can choose to increase or reduce the amount of planes spawned.
  --   
  -- For performance and bug workaround reasons within DCS, squadrons have different methods to spawn new aircraft or land returning or damaged aircraft.
  -- 
  -- @param #AI_A2A_DISPATCHER self
  -- 
  -- @param #string SquadronName A string (text) that defines the squadron identifier or the key of the Squadron. 
  -- It can be any name, for example `"104th Squadron"` or `"SQ SQUADRON1"`, whatever. 
  -- As long as you remember that this name becomes the identifier of your squadron you have defined. 
  -- You need to use this name in other methods too!
  -- 
  -- @param #string AirbaseName The airbase name where you want to have the squadron located. 
  -- You need to specify here EXACTLY the name of the airbase as you see it in the mission editor. 
  -- Examples are `"Batumi"` or `"Tbilisi-Lochini"`. 
  -- EXACTLY the airbase name, between quotes `""`.
  -- To ease the airbase naming when using the LDT editor and IntelliSense, the @{Airbase#AIRBASE} class contains enumerations of the airbases of each map.
  --    
  --    * Caucasus: @{Airbase#AIRBASE.Caucaus}
  --    * Nevada or NTTR: @{Airbase#AIRBASE.Nevada}
  --    * Normandy: @{Airbase#AIRBASE.Normandy}
  -- 
  -- @param #string SpawnTemplates A string or an array of strings specifying the **prefix names of the templates** (not going to explain what is templates here again). 
  -- Examples are `{ "104th", "105th" }` or `"104th"` or `"Template 1"` or `"BLUE PLANES"`. 
  -- Just remember that your template (groups late activated) need to start with the prefix you have specified in your code.
  -- If you have only one prefix name for a squadron, you don't need to use the `{ }`, otherwise you need to use the brackets.
  -- 
  -- @param #number Resources A number that specifies how many resources are in stock of the squadron. It is still a bit buggy, this part. Just make this a large number for the moment. This will be fine tuned later.
  -- 
  -- @usage
  --   -- Now Setup the A2A dispatcher, and initialize it using the Detection object.
  --   A2ADispatcher = AI_A2A_DISPATCHER:New( Detection )  
  -- @usage
  --   -- This will create squadron "Squadron1" at "Batumi" airbase, and will use plane types "SQ1" and has 40 planes in stock...  
  --   A2ADispatcher:SetSquadron( "Squadron1", "Batumi", "SQ1", 40 )
  -- @usage
  --   -- This will create squadron "Sq 1" at "Batumi" airbase, and will use plane types "Mig-29" and "Su-27" and has 20 planes in stock...
  --   -- Note that in this implementation, the A2A dispatcher will select a random plane when a new plane (group) needs to be spawned for defenses.
  --   -- Note the usage of the {} for the airplane templates list.
  --   A2ADispatcher:SetSquadron( "Sq 1", "Batumi", { "Mig-29", "Su-27" }, 40 )
  -- @usage
  --   -- This will create 2 squadrons "104th" and "23th" at "Batumi" airbase, and will use plane types "Mig-29" and "Su-27" respectively and each squadron has 10 planes in stock...
  --   -- Note that in this implementation, the A2A dispatcher will select a random plane when a new plane (group) needs to be spawned for defenses.
  --   A2ADispatcher:SetSquadron( "104th", "Batumi", "Mig-29", 10 )
  --   A2ADispatcher:SetSquadron( "23th", "Batumi", "Su-27", 10 )
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadron( SquadronName, AirbaseName, SpawnTemplates, Resources )
  
    self:E( { SquadronName = SquadronName, AirbaseName = AirbaseName, SpawnTemplates = SpawnTemplates, Resources = Resources } )
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 

    local DefenderSquadron = self.DefenderSquadrons[SquadronName]
    
    DefenderSquadron.Name = SquadronName
    DefenderSquadron.Airbase = AIRBASE:FindByName( AirbaseName )
    if not DefenderSquadron.Airbase then
      error( "Cannot find airbase with name:" .. AirbaseName )
    end
    
    DefenderSquadron.Spawn = {}
    if type( SpawnTemplates ) == "string" then
      local SpawnTemplate = SpawnTemplates
      self.DefenderSpawns[SpawnTemplate] = self.DefenderSpawns[SpawnTemplate] or SPAWN:New( SpawnTemplate ) -- :InitCleanUp( 180 )
      DefenderSquadron.Spawn[1] = self.DefenderSpawns[SpawnTemplate]
    else
      for TemplateID, SpawnTemplate in pairs( SpawnTemplates ) do
        self.DefenderSpawns[SpawnTemplate] = self.DefenderSpawns[SpawnTemplate] or SPAWN:New( SpawnTemplate ) -- :InitCleanUp( 180 )
        DefenderSquadron.Spawn[#DefenderSquadron.Spawn+1] = self.DefenderSpawns[SpawnTemplate]
      end
    end
    DefenderSquadron.Resources = Resources
    
    return self
  end
  
  --- Get an item from the Squadron table.
  -- @param #AI_A2A_DISPATCHER self
  -- @return #table
  function AI_A2A_DISPATCHER:GetSquadron( SquadronName )
    local DefenderSquadron = self.DefenderSquadrons[SquadronName]
    
    if not DefenderSquadron then
      error( "Unknown Squadron:" .. SquadronName )
    end
    
    return DefenderSquadron
  end

  
  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The squadron name.
  -- @param Core.Zone#ZONE_BASE Zone The @{Zone} object derived from @{Zone#ZONE_BASE} that defines the zone wherein the CAP will be executed.
  -- @param #number FloorAltitude The minimum altitude at which the cap can be executed.
  -- @param #number CeilingAltitude the maximum altitude at which the cap can be executed.
  -- @param #number PatrolMinSpeed The minimum speed at which the cap can be executed.
  -- @param #number PatrolMaxSpeed The maximum speed at which the cap can be executed.
  -- @param #number EngageMinSpeed The minimum speed at which the engage can be executed.
  -- @param #number EngageMaxSpeed The maximum speed at which the engage can be executed.
  -- @param #number AltType The altitude type, which is a string "BARO" defining Barometric or "RADIO" defining radio controlled altitude.
  -- @return #AI_A2A_DISPATCHER
  -- @usage
  -- 
  --        -- CAP Squadron execution.
  --        CAPZoneEast = ZONE_POLYGON:New( "CAP Zone East", GROUP:FindByName( "CAP Zone East" ) )
  --        A2ADispatcher:SetSquadronCap( "Mineralnye", CAPZoneEast, 4000, 10000, 500, 600, 800, 900 )
  --        A2ADispatcher:SetSquadronCapInterval( "Mineralnye", 2, 30, 60, 1 )
  --        
  --        CAPZoneWest = ZONE_POLYGON:New( "CAP Zone West", GROUP:FindByName( "CAP Zone West" ) )
  --        A2ADispatcher:SetSquadronCap( "Sochi", CAPZoneWest, 4000, 8000, 600, 800, 800, 1200, "BARO" )
  --        A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  --        
  --        CAPZoneMiddle = ZONE:New( "CAP Zone Middle")
  --        A2ADispatcher:SetSquadronCap( "Maykop", CAPZoneMiddle, 4000, 8000, 600, 800, 800, 1200, "RADIO" )
  --        A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  -- 
  function AI_A2A_DISPATCHER:SetSquadronCap( SquadronName, Zone, FloorAltitude, CeilingAltitude, PatrolMinSpeed, PatrolMaxSpeed, EngageMinSpeed, EngageMaxSpeed, AltType )
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Cap = self.DefenderSquadrons[SquadronName].Cap or {}
    
    local DefenderSquadron = self:GetSquadron( SquadronName )

    local Cap = self.DefenderSquadrons[SquadronName].Cap
    Cap.Name = SquadronName
    Cap.Zone = Zone
    Cap.FloorAltitude = FloorAltitude
    Cap.CeilingAltitude = CeilingAltitude
    Cap.PatrolMinSpeed = PatrolMinSpeed
    Cap.PatrolMaxSpeed = PatrolMaxSpeed
    Cap.EngageMinSpeed = EngageMinSpeed
    Cap.EngageMaxSpeed = EngageMaxSpeed
    Cap.AltType = AltType

    self:SetSquadronCapInterval( SquadronName, 2, 180, 600, 1 )
    
    return self
  end
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The squadron name.
  -- @return #AI_A2A_DISPATCHER
  -- @usage
  -- 
  --        -- CAP Squadron execution.
  --        CAPZoneEast = ZONE_POLYGON:New( "CAP Zone East", GROUP:FindByName( "CAP Zone East" ) )
  --        A2ADispatcher:SetSquadronCap( "Mineralnye", CAPZoneEast, 4000, 10000, 500, 600, 800, 900 )
  --        A2ADispatcher:SetSquadronCapInterval( "Mineralnye", 2, 30, 60, 1 )
  --        
  --        CAPZoneWest = ZONE_POLYGON:New( "CAP Zone West", GROUP:FindByName( "CAP Zone West" ) )
  --        A2ADispatcher:SetSquadronCap( "Sochi", CAPZoneWest, 4000, 8000, 600, 800, 800, 1200, "BARO" )
  --        A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  --        
  --        CAPZoneMiddle = ZONE:New( "CAP Zone Middle")
  --        A2ADispatcher:SetSquadronCap( "Maykop", CAPZoneMiddle, 4000, 8000, 600, 800, 800, 1200, "RADIO" )
  --        A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  -- 
  function AI_A2A_DISPATCHER:SetSquadronCapInterval( SquadronName, CapLimit, LowInterval, HighInterval, Probability )
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Cap = self.DefenderSquadrons[SquadronName].Cap or {}

    local DefenderSquadron = self:GetSquadron( SquadronName )

    local Cap = self.DefenderSquadrons[SquadronName].Cap
    if Cap then
      Cap.LowInterval = LowInterval or 300
      Cap.HighInterval = HighInterval or 600
      Cap.Probability = Probability or 1
      Cap.CapLimit = CapLimit
      Cap.Scheduler = Cap.Scheduler or SCHEDULER:New( self ) 
      local Scheduler = Cap.Scheduler -- Core.Scheduler#SCHEDULER
      local Variance = ( Cap.HighInterval - Cap.LowInterval ) / 2
      local Median = Cap.LowInterval + Variance
      local Randomization = Variance / Median
      Scheduler:Schedule(self, self.SchedulerCAP, { SquadronName }, Median, Median, Randomization )
    else
      error( "This squadron does not exist:" .. SquadronName )
    end

  end
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The squadron name.
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:GetCAPDelay( SquadronName )
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Cap = self.DefenderSquadrons[SquadronName].Cap or {}

    local DefenderSquadron = self:GetSquadron( SquadronName )

    local Cap = self.DefenderSquadrons[SquadronName].Cap
    if Cap then
      return math.random( Cap.LowInterval, Cap.HighInterval )
    else
      error( "This squadron does not exist:" .. SquadronName )
    end
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The squadron name.
  -- @return #table DefenderSquadron
  function AI_A2A_DISPATCHER:CanCAP( SquadronName )
    self:F({SquadronName = SquadronName})
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Cap = self.DefenderSquadrons[SquadronName].Cap or {}

    local DefenderSquadron = self:GetSquadron( SquadronName )

    if DefenderSquadron.Resources > 0 then

      local Cap = DefenderSquadron.Cap
      if Cap then
        local CapCount = self:CountCapAirborne( SquadronName )
        if CapCount < Cap.CapLimit then
          local Probability = math.random()
          if Probability <= Cap.Probability then
            return DefenderSquadron
          end
        end
      end
    end
    return nil
  end


  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The squadron name.
  -- @return #table DefenderSquadron
  function AI_A2A_DISPATCHER:CanGCI( SquadronName )
    self:F({SquadronName = SquadronName})
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Cap = self.DefenderSquadrons[SquadronName].Cap or {}

    local DefenderSquadron = self:GetSquadron( SquadronName )

    if DefenderSquadron.Resources > 0 then
      local Gci = DefenderSquadron.Gci
      if Gci then
        return DefenderSquadron
      end
    end
    return nil
  end

  
  ---
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The squadron name.
  -- @param #number EngageMinSpeed The minimum speed at which the gci can be executed.
  -- @param #number EngageMaxSpeed The maximum speed at which the gci can be executed.
  -- @usage 
  -- 
  --        -- GCI Squadron execution.
  --        A2ADispatcher:SetSquadronGci( "Mozdok", 900, 1200 )
  --        A2ADispatcher:SetSquadronGci( "Novo", 900, 2100 )
  --        A2ADispatcher:SetSquadronGci( "Maykop", 900, 1200 )
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronGci( SquadronName, EngageMinSpeed, EngageMaxSpeed )
  
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Gci = self.DefenderSquadrons[SquadronName].Gci or {}
    
    local Intercept = self.DefenderSquadrons[SquadronName].Gci
    Intercept.Name = SquadronName
    Intercept.EngageMinSpeed = EngageMinSpeed
    Intercept.EngageMaxSpeed = EngageMaxSpeed
  end
  
  --- Defines the default amount of extra planes that will take-off as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #number Overhead The %-tage of Units that dispatching command will allocate to intercept in surplus of detected amount of units.
  -- The default overhead is 1, so equal balance. The @{#AI_A2A_DISPATCHER.SetOverhead}() method can be used to tweak the defense strength,
  -- taking into account the plane types of the squadron. For example, a MIG-31 with full long-distance A2A missiles payload, may still be less effective than a F-15C with short missiles...
  -- So in this case, one may want to use the Overhead method to allocate more defending planes as the amount of detected attacking planes.
  -- The overhead must be given as a decimal value with 1 as the neutral value, which means that Overhead values: 
  -- 
  --   * Higher than 1, will increase the defense unit amounts.
  --   * Lower than 1, will decrease the defense unit amounts.
  -- 
  -- The amount of defending units is calculated by multiplying the amount of detected attacking planes as part of the detected group 
  -- multiplied by the Overhead and rounded up to the smallest integer. 
  -- 
  -- The Overhead value set for a Squadron, can be programmatically adjusted (by using this SetOverhead method), to adjust the defense overhead during mission execution.
  -- 
  -- See example below.
  --  
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- An overhead of 1,5 with 1 planes detected, will allocate 2 planes ( 1 * 1,5 ) = 1,5 => rounded up gives 2.
  --   -- An overhead of 1,5 with 2 planes detected, will allocate 3 planes ( 2 * 1,5 ) = 3 =>  rounded up gives 3.
  --   -- An overhead of 1,5 with 3 planes detected, will allocate 5 planes ( 3 * 1,5 ) = 4,5 => rounded up gives 5 planes.
  --   -- An overhead of 1,5 with 4 planes detected, will allocate 6 planes ( 4 * 1,5 ) = 6  => rounded up gives 6 planes.
  --   
  --   Dispatcher:SetDefaultOverhead( 1.5 )
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetDefaultOverhead( Overhead )

    self.DefenderDefault.Overhead = Overhead
    
    return self
  end


  --- Defines the amount of extra planes that will take-off as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @param #number Overhead The %-tage of Units that dispatching command will allocate to intercept in surplus of detected amount of units.
  -- The default overhead is 1, so equal balance. The @{#AI_A2A_DISPATCHER.SetOverhead}() method can be used to tweak the defense strength,
  -- taking into account the plane types of the squadron. For example, a MIG-31 with full long-distance A2A missiles payload, may still be less effective than a F-15C with short missiles...
  -- So in this case, one may want to use the Overhead method to allocate more defending planes as the amount of detected attacking planes.
  -- The overhead must be given as a decimal value with 1 as the neutral value, which means that Overhead values: 
  -- 
  --   * Higher than 1, will increase the defense unit amounts.
  --   * Lower than 1, will decrease the defense unit amounts.
  -- 
  -- The amount of defending units is calculated by multiplying the amount of detected attacking planes as part of the detected group 
  -- multiplied by the Overhead and rounded up to the smallest integer. 
  -- 
  -- The Overhead value set for a Squadron, can be programmatically adjusted (by using this SetOverhead method), to adjust the defense overhead during mission execution.
  -- 
  -- See example below.
  --  
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- An overhead of 1,5 with 1 planes detected, will allocate 2 planes ( 1 * 1,5 ) = 1,5 => rounded up gives 2.
  --   -- An overhead of 1,5 with 2 planes detected, will allocate 3 planes ( 2 * 1,5 ) = 3 =>  rounded up gives 3.
  --   -- An overhead of 1,5 with 3 planes detected, will allocate 5 planes ( 3 * 1,5 ) = 4,5 => rounded up gives 5 planes.
  --   -- An overhead of 1,5 with 4 planes detected, will allocate 6 planes ( 4 * 1,5 ) = 6  => rounded up gives 6 planes.
  --   
  --   Dispatcher:SetSquadronOverhead( "SquadronName", 1.5 )
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronOverhead( SquadronName, Overhead )

    local DefenderSquadron = self:GetSquadron( SquadronName )
    DefenderSquadron.Overhead = Overhead
    
    return self
  end


  --- Sets the default grouping of new airplanes spawned.
  -- Grouping will trigger how new airplanes will be grouped if more than one airplane is spawned for defense.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #number Grouping The level of grouping that will be applied of the CAP or GCI defenders. 
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Set a grouping by default per 2 airplanes.
  --   Dispatcher:SetDefaultGrouping( 2 )
  -- 
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetDefaultGrouping( Grouping )
  
    self.DefenderDefault.Grouping = Grouping
    
    return self
  end


  --- Sets the grouping of new airplanes spawned.
  -- Grouping will trigger how new airplanes will be grouped if more than one airplane is spawned for defense.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @param #number Grouping The level of grouping that will be applied of the CAP or GCI defenders. 
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Set a grouping per 2 airplanes.
  --   Dispatcher:SetSquadronGrouping( "SquadronName", 2 )
  -- 
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronGrouping( SquadronName, Grouping )
  
    local DefenderSquadron = self:GetSquadron( SquadronName )
    DefenderSquadron.Grouping = Grouping
    
    return self
  end


  --- Defines the default method at which new flights will spawn and take-off as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #number Takeoff From the airbase hot, from the airbase cold, in the air, from the runway.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default take-off in the air.
  --   Dispatcher:SetDefaultTakeoff( AI_A2A_Dispatcher.Takeoff.Air )
  --   
  --   -- Let new flights by default take-off from the runway.
  --   Dispatcher:SetDefaultTakeoff( AI_A2A_Dispatcher.Takeoff.Runway )
  --   
  --   -- Let new flights by default take-off from the airbase hot.
  --   Dispatcher:SetDefaultTakeoff( AI_A2A_Dispatcher.Takeoff.Hot )
  -- 
  --   -- Let new flights by default take-off from the airbase cold.
  --   Dispatcher:SetDefaultTakeoff( AI_A2A_Dispatcher.Takeoff.Cold )
  -- 
  -- 
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetDefaultTakeoff( Takeoff )

    self.DefenderDefault.Takeoff = Takeoff
    
    return self
  end

  --- Defines the method at which new flights will spawn and take-off as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @param #number Takeoff From the airbase hot, from the airbase cold, in the air, from the runway.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off in the air.
  --   Dispatcher:SetSquadronTakeoff( "SquadronName", AI_A2A_Dispatcher.Takeoff.Air )
  --   
  --   -- Let new flights take-off from the runway.
  --   Dispatcher:SetSquadronTakeoff( "SquadronName", AI_A2A_Dispatcher.Takeoff.Runway )
  --   
  --   -- Let new flights take-off from the airbase hot.
  --   Dispatcher:SetSquadronTakeoff( "SquadronName", AI_A2A_Dispatcher.Takeoff.Hot )
  -- 
  --   -- Let new flights take-off from the airbase cold.
  --   Dispatcher:SetSquadronTakeoff( "SquadronName", AI_A2A_Dispatcher.Takeoff.Cold )
  -- 
  -- 
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetSquadronTakeoff( SquadronName, Takeoff )

    local DefenderSquadron = self:GetSquadron( SquadronName )
    DefenderSquadron.Takeoff = Takeoff
    
    return self
  end
  

  --- Gets the default method at which new flights will spawn and take-off as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @return #number Takeoff From the airbase hot, from the airbase cold, in the air, from the runway.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default take-off in the air.
  --   local TakeoffMethod = Dispatcher:GetDefaultTakeoff()
  --   if TakeOffMethod == , AI_A2A_Dispatcher.Takeoff.InAir then
  --     ...
  --   end
  --   
  function AI_A2A_DISPATCHER:GetDefaultTakeoff( )

    return self.DefenderDefault.Takeoff
  end
  
  --- Gets the method at which new flights will spawn and take-off as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @return #number Takeoff From the airbase hot, from the airbase cold, in the air, from the runway.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off in the air.
  --   local TakeoffMethod = Dispatcher:GetSquadronTakeoff( "SquadronName" )
  --   if TakeOffMethod == , AI_A2A_Dispatcher.Takeoff.InAir then
  --     ...
  --   end
  --   
  function AI_A2A_DISPATCHER:GetSquadronTakeoff( SquadronName )

    local DefenderSquadron = self:GetSquadron( SquadronName )
    return DefenderSquadron.Takeoff or self.DefenderDefault.Takeoff
  end
  

  --- Sets flights to default take-off in the air, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default take-off in the air.
  --   Dispatcher:SetDefaultTakeoffInAir()
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetDefaultTakeoffInAir()

    self:SetDefaultTakeoff( AI_A2A_DISPATCHER.Takeoff.Air )
    
    return self
  end

  
  --- Sets flights to take-off in the air, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off in the air.
  --   Dispatcher:SetSquadronTakeoffInAir( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetSquadronTakeoffInAir( SquadronName )

    self:SetSquadronTakeoff( SquadronName, AI_A2A_DISPATCHER.Takeoff.Air )
    
    return self
  end


  --- Sets flights by default to take-off from the runway, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default take-off from the runway.
  --   Dispatcher:SetDefaultTakeoffFromRunway()
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetDefaultTakeoffFromRunway()

    self:SetDefaultTakeoff( AI_A2A_DISPATCHER.Takeoff.Runway )
    
    return self
  end

  
  --- Sets flights to take-off from the runway, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off from the runway.
  --   Dispatcher:SetSquadronTakeoffFromRunway( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetSquadronTakeoffFromRunway( SquadronName )

    self:SetSquadronTakeoff( SquadronName, AI_A2A_DISPATCHER.Takeoff.Runway )
    
    return self
  end
  

  --- Sets flights by default to take-off from the airbase at a hot location, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default take-off at a hot parking spot.
  --   Dispatcher:SetDefaultTakeoffFromParkingHot()
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetDefaultTakeoffFromParkingHot()

    self:SetDefaultTakeoff( AI_A2A_DISPATCHER.Takeoff.Hot )
    
    return self
  end

  --- Sets flights to take-off from the airbase at a hot location, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off in the air.
  --   Dispatcher:SetSquadronTakeoffFromParkingHot( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetSquadronTakeoffFromParkingHot( SquadronName )

    self:SetSquadronTakeoff( SquadronName, AI_A2A_DISPATCHER.Takeoff.Hot )
    
    return self
  end
  
  
  --- Sets flights to by default take-off from the airbase at a cold location, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off from a cold parking spot.
  --   Dispatcher:SetDefaultTakeoffFromParkingCold()
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetDefaultTakeoffFromParkingCold()

    self:SetDefaultTakeoff( AI_A2A_DISPATCHER.Takeoff.Cold )
    
    return self
  end
  

  --- Sets flights to take-off from the airbase at a cold location, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights take-off from a cold parking spot.
  --   Dispatcher:SetSquadronTakeoffFromParkingCold( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  -- 
  function AI_A2A_DISPATCHER:SetSquadronTakeoffFromParkingCold( SquadronName )

    self:SetSquadronTakeoff( SquadronName, AI_A2A_DISPATCHER.Takeoff.Cold )
    
    return self
  end
  

  --- Defines the default method at which flights will land and despawn as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #number Landing The landing method which can be NearAirbase, AtRunway, AtEngineShutdown
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default despawn near the airbase when returning.
  --   Dispatcher:SetDefaultLanding( AI_A2A_Dispatcher.Landing.NearAirbase )
  --   
  --   -- Let new flights by default despawn after landing land at the runway.
  --   Dispatcher:SetDefaultLanding( AI_A2A_Dispatcher.Landing.AtRunway )
  --   
  --   -- Let new flights by default despawn after landing and parking, and after engine shutdown.
  --   Dispatcher:SetDefaultLanding( AI_A2A_Dispatcher.Landing.AtEngineShutdown )
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetDefaultLanding( Landing )

    self.DefenderDefault.Landing = Landing
    
    return self
  end
  

  --- Defines the method at which flights will land and despawn as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @param #number Landing The landing method which can be NearAirbase, AtRunway, AtEngineShutdown
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights despawn near the airbase when returning.
  --   Dispatcher:SetSquadronLanding( "SquadronName", AI_A2A_Dispatcher.Landing.NearAirbase )
  --   
  --   -- Let new flights despawn after landing land at the runway.
  --   Dispatcher:SetSquadronLanding( "SquadronName", AI_A2A_Dispatcher.Landing.AtRunway )
  --   
  --   -- Let new flights despawn after landing and parking, and after engine shutdown.
  --   Dispatcher:SetSquadronLanding( "SquadronName", AI_A2A_Dispatcher.Landing.AtEngineShutdown )
  -- 
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronLanding( SquadronName, Landing )

    local DefenderSquadron = self:GetSquadron( SquadronName )
    DefenderSquadron.Landing = Landing
    
    return self
  end
  

  --- Gets the default method at which flights will land and despawn as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @return #number Landing The landing method which can be NearAirbase, AtRunway, AtEngineShutdown
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights by default despawn near the airbase when returning.
  --   local LandingMethod = Dispatcher:GetDefaultLanding( AI_A2A_Dispatcher.Landing.NearAirbase )
  --   if LandingMethod == AI_A2A_Dispatcher.Landing.NearAirbase then
  --    ...
  --   end
  -- 
  function AI_A2A_DISPATCHER:GetDefaultLanding()

    return self.DefenderDefault.Landing
  end
  

  --- Gets the method at which flights will land and despawn as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @return #number Landing The landing method which can be NearAirbase, AtRunway, AtEngineShutdown
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let new flights despawn near the airbase when returning.
  --   local LandingMethod = Dispatcher:GetSquadronLanding( "SquadronName", AI_A2A_Dispatcher.Landing.NearAirbase )
  --   if LandingMethod == AI_A2A_Dispatcher.Landing.NearAirbase then
  --    ...
  --   end
  -- 
  function AI_A2A_DISPATCHER:GetSquadronLanding( SquadronName )

    local DefenderSquadron = self:GetSquadron( SquadronName )
    return DefenderSquadron.Landing or self.DefenderDefault.Landing
  end
  

  --- Sets flights by default to land and despawn near the airbase in the air, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let flights by default to land near the airbase and despawn.
  --   Dispatcher:SetDefaultLandingNearAirbase()
  --   
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetDefaultLandingNearAirbase()

    self:SetDefaultLanding( AI_A2A_DISPATCHER.Landing.NearAirbase )
    
    return self
  end
  

  --- Sets flights to land and despawn near the airbase in the air, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let flights to land near the airbase and despawn.
  --   Dispatcher:SetSquadronLandingNearAirbase( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronLandingNearAirbase( SquadronName )

    self:SetSquadronLanding( SquadronName, AI_A2A_DISPATCHER.Landing.NearAirbase )
    
    return self
  end
  

  --- Sets flights by default to land and despawn at the runway, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let flights by default land at the runway and despawn.
  --   Dispatcher:SetDefaultLandingAtRunway()
  --   
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetDefaultLandingAtRunway()

    self:SetDefaultLanding( AI_A2A_DISPATCHER.Landing.AtRunway )
    
    return self
  end
  

  --- Sets flights to land and despawn at the runway, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let flights land at the runway and despawn.
  --   Dispatcher:SetSquadronLandingAtRunway( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronLandingAtRunway( SquadronName )

    self:SetSquadronLanding( SquadronName, AI_A2A_DISPATCHER.Landing.AtRunway )
    
    return self
  end
  

  --- Sets flights by default to land and despawn at engine shutdown, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let flights by default land and despawn at engine shutdown.
  --   Dispatcher:SetDefaultLandingAtEngineShutdown()
  --   
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetDefaultLandingAtEngineShutdown()

    self:SetDefaultLanding( AI_A2A_DISPATCHER.Landing.AtEngineShutdown )
    
    return self
  end
  

  --- Sets flights to land and despawn at engine shutdown, as part of the defense system.
  -- @param #AI_A2A_DISPATCHER self
  -- @param #string SquadronName The name of the squadron.
  -- @usage:
  -- 
  --   local Dispatcher = AI_A2A_DISPATCHER:New( ... )
  --   
  --   -- Let flights land and despawn at engine shutdown.
  --   Dispatcher:SetSquadronLandingAtEngineShutdown( "SquadronName" )
  --   
  -- @return #AI_A2A_DISPATCHER
  function AI_A2A_DISPATCHER:SetSquadronLandingAtEngineShutdown( SquadronName )

    self:SetSquadronLanding( SquadronName, AI_A2A_DISPATCHER.Landing.AtEngineShutdown )
    
    return self
  end
  

  --- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:AddDefenderToSquadron( Squadron, Defender )
    self.Defenders = self.Defenders or {}
    local DefenderName = Defender:GetName()
    self.Defenders[ DefenderName ] = Squadron
    Squadron.Resources = Squadron.Resources - Defender:GetSize()
    self:F( { DefenderName = DefenderName, SquadronResources = Squadron.Resources } )
  end

  --- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:RemoveDefenderFromSquadron( Squadron, Defender )
    self.Defenders = self.Defenders or {}
    local DefenderName = Defender:GetName()
    Squadron.Resources = Squadron.Resources + Defender:GetSize()
    self.Defenders[ DefenderName ] = nil
    self:F( { DefenderName = DefenderName, SquadronResources = Squadron.Resources } )
  end
  
  function AI_A2A_DISPATCHER:GetSquadronFromDefender( Defender )
    self.Defenders = self.Defenders or {}
    local DefenderName = Defender:GetName()
    self:F( { DefenderName = DefenderName } )
    return self.Defenders[ DefenderName ] 
  end

  
  --- Creates an SWEEP task when there are targets for it.
  -- @param #AI_A2A_DISPATCHER self
  -- @param Functional.Detection#DETECTION_BASE.DetectedItem DetectedItem
  -- @return Set#SET_UNIT TargetSetUnit: The target set of units.
  -- @return #nil If there are no targets to be set.
  function AI_A2A_DISPATCHER:EvaluateSWEEP( DetectedItem )
    self:F( { DetectedItem.ItemID } )
  
    local DetectedSet = DetectedItem.Set
    local DetectedZone = DetectedItem.Zone


    if DetectedItem.IsDetected == false then

      -- Here we're doing something advanced... We're copying the DetectedSet.
      local TargetSetUnit = SET_UNIT:New()
      TargetSetUnit:SetDatabase( DetectedSet )
      TargetSetUnit:FilterOnce() -- Filter but don't do any events!!! Elements are added manually upon each detection.
    
      return TargetSetUnit
    end
    
    return nil
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:CountCapAirborne( SquadronName )

    local CapCount = 0
    
    local DefenderSquadron = self.DefenderSquadrons[SquadronName]
    if DefenderSquadron then
      for AIGroup, DefenderTask in pairs( self:GetDefenderTasks() ) do
        if DefenderTask.Type == "CAP" then
          if AIGroup:IsAlive() then
            -- Check if the CAP is patrolling or engaging. If not, this is not a valid CAP, even if it is alive!
            -- The CAP could be damaged, lost control, or out of fuel!
            if DefenderTask.Fsm:Is( "Patrolling" ) or DefenderTask.Fsm:Is( "Engaging" ) then
              CapCount = CapCount + 1
            end
          end
        end
      end
    end

    return CapCount
  end
  
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:CountDefendersEngaged( Target )

    -- First, count the active AIGroups Units, targetting the DetectedSet
    local AIUnitCount = 0
    
    local DefenderTasks = self:GetDefenderTasks()
    for AIGroup, DefenderTask in pairs( DefenderTasks ) do
      local AIGroup = AIGroup -- Wrapper.Group#GROUP
      local DefenderTask = self:GetDefenderTaskTarget( AIGroup )
      if DefenderTask and DefenderTask.Index == Target.Index then
        AIUnitCount = AIUnitCount + AIGroup:GetSize()
      end
    end

    return AIUnitCount
  end
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:CountDefendersToBeEngaged( DetectedItem, DefenderCount )
  
    local Friendlies = nil

    local DetectedSet = DetectedItem.Set
    local DetectedCount = DetectedSet:Count()

    local AIFriendlies = self:GetAIFriendliesNearBy( DetectedItem )
    
    for FriendlyDistance, AIFriendly in UTILS.spairs( AIFriendlies or {} ) do
      -- We only allow to ENGAGE targets as long as the Units on both sides are balanced.
      if DetectedCount > DefenderCount then 
        local Friendly = AIFriendly:GetGroup() -- Wrapper.Group#GROUP
        if Friendly and Friendly:IsAlive() then
          -- Ok, so we have a friendly near the potential target.
          -- Now we need to check if the AIGroup has a Task.
          local DefenderTask = self:GetDefenderTask( Friendly )
          if DefenderTask then
            -- The Task should be CAP or GCI
            if DefenderTask.Type == "CAP" or DefenderTask.Type == "GCI" then
              -- If there is no target, then add the AIGroup to the ResultAIGroups for Engagement to the TargetSet
              if DefenderTask.Target == nil then
                if DefenderTask.Fsm:Is( "Returning" )
                or DefenderTask.Fsm:Is( "Patrolling" ) then
                  Friendlies = Friendlies or {}
                  Friendlies[Friendly] = Friendly
                  DefenderCount = DefenderCount + Friendly:GetSize()
                  self:F( { Friendly = Friendly:GetName(), FriendlyDistance = FriendlyDistance } )
                end
              end
            end
          end 
        end
      else
        break
      end
    end

    return Friendlies
  end

  
  
  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:onafterCAP( From, Event, To, SquadronName )
  
    self:F({SquadronName = SquadronName})
    self.DefenderSquadrons[SquadronName] = self.DefenderSquadrons[SquadronName] or {} 
    self.DefenderSquadrons[SquadronName].Cap = self.DefenderSquadrons[SquadronName].Cap or {}
    
    local DefenderSquadron = self:CanCAP( SquadronName )
    
    if DefenderSquadron then
  
      local Cap = DefenderSquadron.Cap
    
      if Cap then
    
        local Spawn = DefenderSquadron.Spawn[ math.random( 1, #DefenderSquadron.Spawn ) ] -- Functional.Spawn#SPAWN
        local DefenderGrouping = DefenderSquadron.Grouping or self.DefenderDefault.Grouping
        Spawn:InitGrouping( DefenderGrouping )

        local TakeoffMethod = self:GetSquadronTakeoff( SquadronName )
        local DefenderCAP = Spawn:SpawnAtAirbase( DefenderSquadron.Airbase, TakeoffMethod )
        self:AddDefenderToSquadron( DefenderSquadron, DefenderCAP )
  
        if DefenderCAP then
  
          local Fsm = AI_A2A_CAP:New( DefenderCAP, Cap.Zone, Cap.FloorAltitude, Cap.CeilingAltitude, Cap.PatrolMinSpeed, Cap.PatrolMaxSpeed, Cap.EngageMinSpeed, Cap.EngageMaxSpeed, Cap.AltType )
          Fsm:SetDispatcher( self )
          Fsm:SetHomeAirbase( DefenderSquadron.Airbase )
          Fsm:Start()
          Fsm:__Patrol( 1 )
  
          self:SetDefenderTask( DefenderCAP, "CAP", Fsm )
        end
      end
    end
    
  end


  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:onafterENGAGE( From, Event, To, Target, AIGroups )
  
    if AIGroups then

      for AIGroupID, AIGroup in pairs( AIGroups ) do

        local Fsm = self:GetDefenderTaskFsm( AIGroup )
        Fsm:__Engage( 1, Target.Set ) -- Engage on the TargetSetUnit
        
        self:SetDefenderTaskTarget( AIGroup, Target )

        function Fsm:onafterRTB( AIGroup, From, Event, To )
          self:F({"CAP RTB"})
          self:GetParent(self).onafterRTB( self, AIGroup, From, Event, To )
          local Dispatcher = self:GetDispatcher() -- #AI_A2A_DISPATCHER
          local AIGroup = self:GetControllable()
          Dispatcher:ClearDefenderTaskTarget( AIGroup )
        end

        --- @param #AI_A2A_DISPATCHER self
        function Fsm:onafterHome( Defender, From, Event, To )
          self:F({"CAP Home"})
          self:GetParent(self).onafterHome( self, Defender, From, Event, To )
          
          local Dispatcher = self:GetDispatcher() -- #AI_A2A_DISPATCHER
          local AIGroup = self:GetControllable()
          local Squadron = Dispatcher:GetSquadronFromDefender( AIGroup )
          if Dispatcher:GetSquadronLanding( Squadron.Name ) == AI_A2A_DISPATCHER.Landing.NearAirbase then
            Dispatcher:RemoveDefenderFromSquadron( Squadron, AIGroup )
            AIGroup:Destroy()
          end
        end

      end
    end
  end

  ---
  -- @param #AI_A2A_DISPATCHER self
  function AI_A2A_DISPATCHER:onafterGCI( From, Event, To, Target, DefendersMissing, AIGroups )

    local AttackerCount = Target.Set:Count()
    local DefendersCount = 0

    for AIGroupID, AIGroup in pairs( AIGroups or {} ) do

      local Fsm = self:GetDefenderTaskFsm( AIGroup )
      Fsm:__Engage( 1, Target.Set ) -- Engage on the TargetSetUnit
      
      self:SetDefenderTaskTarget( AIGroup, Target )

      DefendersCount = DefendersCount + AIGroup:GetSize()
    end

    DefendersCount = DefendersMissing

    local ClosestDistance = 0
    local ClosestDefenderSquadronName = nil
    
    while( DefendersCount > 0 ) do
    
      for SquadronName, DefenderSquadron in pairs( self.DefenderSquadrons or {} ) do
        for InterceptID, Intercept in pairs( DefenderSquadron.Gci or {} ) do
    
          self:E( { DefenderSquadron } )
          local SpawnCoord = DefenderSquadron.Airbase:GetCoordinate() -- Core.Point#COORDINATE
          local TargetCoord = Target.Set:GetFirst():GetCoordinate()
          if TargetCoord then
            local Distance = SpawnCoord:Get2DDistance( TargetCoord )
            
            if ClosestDistance == 0 or Distance < ClosestDistance then
              
              -- Only intercept if the distance to target is smaller or equal to the GciRadius limit.
              if Distance <= self.GciRadius then
                ClosestDistance = Distance
                ClosestDefenderSquadronName = SquadronName
              end
            end
          end
        end
      end
      
      if ClosestDefenderSquadronName then
      
        local DefenderSquadron = self:CanGCI( ClosestDefenderSquadronName )
        
        if DefenderSquadron then

          local Gci = self.DefenderSquadrons[ClosestDefenderSquadronName].Gci
          
          if Gci then
        
            local DefenderOverhead = DefenderSquadron.Overhead or self.DefenderDefault.Overhead
            local DefenderGrouping = DefenderSquadron.Grouping or self.DefenderDefault.Grouping
            local DefendersNeeded = math.ceil( DefendersCount * DefenderOverhead )
          
            local Spawn = DefenderSquadron.Spawn[ math.random( 1, #DefenderSquadron.Spawn ) ]
            if DefenderGrouping then
              Spawn:InitGrouping( ( DefenderGrouping < DefendersNeeded ) and DefenderGrouping or DefendersNeeded )
            else
              Spawn:InitGrouping()
            end
            
            local TakeoffMethod = self:GetSquadronTakeoff( ClosestDefenderSquadronName )
            local DefenderGCI = Spawn:SpawnAtAirbase( DefenderSquadron.Airbase, TakeoffMethod )
            self:F( { GCIDefender = DefenderGCI:GetName() } )
    
            self:AddDefenderToSquadron( DefenderSquadron, DefenderGCI )
            
      
            if DefenderGCI then
    
              DefendersCount = DefendersCount - DefenderGCI:GetSize()
              
              local Fsm = AI_A2A_GCI:New( DefenderGCI, Gci.EngageMinSpeed, Gci.EngageMaxSpeed )
              Fsm:SetDispatcher( self )
              Fsm:SetHomeAirbase( DefenderSquadron.Airbase )
              Fsm:Start()
              Fsm:__Engage( 5, Target.Set ) -- Engage on the TargetSetUnit
    
      
              self:SetDefenderTask( DefenderGCI, "GCI", Fsm, Target )
              
              
              function Fsm:onafterRTB( Defender, From, Event, To )
                self:F({"GCI RTB"})
                self:GetParent(self).onafterRTB( self, Defender, From, Event, To )
                
                local Dispatcher = self:GetDispatcher() -- #AI_A2A_DISPATCHER
                local AIGroup = self:GetControllable()
                Dispatcher:ClearDefenderTaskTarget( AIGroup )
              end
              
              --- @param #AI_A2A_DISPATCHER self
              function Fsm:onafterHome( Defender, From, Event, To )
                self:F({"GCI Home"})
                self:GetParent(self).onafterHome( self, Defender, From, Event, To )
                
                local Dispatcher = self:GetDispatcher() -- #AI_A2A_DISPATCHER
                local AIGroup = self:GetControllable()
                local Squadron = Dispatcher:GetSquadronFromDefender( AIGroup )
                if Dispatcher:GetSquadronLanding( Squadron.Name ) == AI_A2A_DISPATCHER.Landing.NearAirbase then
                  Dispatcher:RemoveDefenderFromSquadron( Squadron, AIGroup )
                  AIGroup:Destroy()
                end
              end
            end
          end
        end
      else
        -- There isn't any closest airbase anymore, break the loop.
        break
      end
    end
  end



  --- Creates an ENGAGE task when there are human friendlies airborne near the targets.
  -- @param #AI_A2A_DISPATCHER self
  -- @param Functional.Detection#DETECTION_BASE.DetectedItem DetectedItem
  -- @return Set#SET_UNIT TargetSetUnit: The target set of units.
  -- @return #nil If there are no targets to be set.
  function AI_A2A_DISPATCHER:EvaluateENGAGE( DetectedItem )
    self:F( { DetectedItem.ItemID } )
  
    -- First, count the active AIGroups Units, targetting the DetectedSet
    local DefenderCount = self:CountDefendersEngaged( DetectedItem )
    local DefenderGroups = self:CountDefendersToBeEngaged( DetectedItem, DefenderCount )

    self:F( { DefenderCount = DefenderCount } )
    
    -- Only allow ENGAGE when:
    -- 1. There are friendly units near the detected attackers.
    -- 2. There is sufficient fuel
    -- 3. There is sufficient ammo
    -- 4. The plane is not damaged
    if DefenderGroups and DetectedItem.IsDetected == true then
      
      return DefenderGroups
    end
    
    return nil, nil
  end
  
  --- Creates an GCI task when there are targets for it.
  -- @param #AI_A2A_DISPATCHER self
  -- @param Functional.Detection#DETECTION_BASE.DetectedItem DetectedItem
  -- @return Set#SET_UNIT TargetSetUnit: The target set of units.
  -- @return #nil If there are no targets to be set.
  function AI_A2A_DISPATCHER:EvaluateGCI( Target )
    self:F( { Target.ItemID } )
  
    local AttackerSet = Target.Set
    local AttackerCount = AttackerSet:Count()

    -- First, count the active AIGroups Units, targetting the DetectedSet
    local DefenderCount = self:CountDefendersEngaged( Target )
    local DefendersMissing = AttackerCount - DefenderCount
    self:F( { AttackerCount = AttackerCount, DefenderCount = DefenderCount, DefendersMissing = DefendersMissing } )

    local Friendlies = self:CountDefendersToBeEngaged( Target, DefenderCount )

    if Target.IsDetected == true then
      
      return DefendersMissing, Friendlies
    end
    
    return nil, nil
  end


  --- Assigns A2A AI Tasks in relation to the detected items.
  -- @param #AI_A2A_DISPATCHER self
  -- @param Functional.Detection#DETECTION_BASE Detection The detection created by the @{Detection#DETECTION_BASE} derived object.
  -- @return #boolean Return true if you want the task assigning to continue... false will cancel the loop.
  function AI_A2A_DISPATCHER:ProcessDetected( Detection )
  
    local AreaMsg = {}
    local TaskMsg = {}
    local ChangeMsg = {}
    
    local TaskReport = REPORT:New()

          
    for AIGroup, DefenderTask in pairs( self:GetDefenderTasks() ) do
      local AIGroup = AIGroup -- Wrapper.Group#GROUP
      if not AIGroup:IsAlive() then
        self:ClearDefenderTask( AIGroup )
      else
        if DefenderTask.Target then
          local Target = Detection:GetDetectedItem( DefenderTask.Target.Index )
          if not Target then
            self:F( { "Removing obsolete Target:", DefenderTask.Target.Index } )
            self:ClearDefenderTaskTarget( AIGroup )
            
          else
            if DefenderTask.Target.Set then
              if DefenderTask.Target.Set:Count() == 0 then
                self:F( { "All Targets destroyed in Target, removing:", DefenderTask.Target.Index } )
                self:ClearDefenderTaskTarget( AIGroup )
              end
            end
          end
        end
      end
    end

    local Report = REPORT:New( "\nTactical Overview" )

    -- Now that all obsolete tasks are removed, loop through the detected targets.
    for DetectedItemID, DetectedItem in pairs( Detection:GetDetectedItems() ) do
    
      local DetectedItem = DetectedItem -- Functional.Detection#DETECTION_BASE.DetectedItem
      local DetectedSet = DetectedItem.Set -- Core.Set#SET_UNIT
      local DetectedCount = DetectedSet:Count()
      local DetectedZone = DetectedItem.Zone

      self:F( { "Target ID", DetectedItem.ItemID } )
      DetectedSet:Flush()

      local DetectedID = DetectedItem.ID
      local DetectionIndex = DetectedItem.Index
      local DetectedItemChanged = DetectedItem.Changed
      
      do 
        local Friendlies = self:EvaluateENGAGE( DetectedItem ) -- Returns a SetUnit if there are targets to be GCIed...
        if Friendlies then
          self:F( { AIGroups = Friendlies } )
          self:ENGAGE( DetectedItem, Friendlies )
        end
      end

      do
        local DefendersMissing, Friendlies = self:EvaluateGCI( DetectedItem )
        if DefendersMissing then
          self:F( { DefendersMissing = DefendersMissing } )
          self:GCI( DetectedItem, DefendersMissing, Friendlies )
        end
      end

      if self.TacticalDisplay then      
        -- Show tactical situation
        Report:Add( string.format( "\n - Target %s ( %s ): ( #%d ) %s" , DetectedItem.ItemID, DetectedItem.Index, DetectedItem.Set:Count(), DetectedItem.Set:GetObjectNames() ) )
        for Defender, DefenderTask in pairs( self:GetDefenderTasks() ) do
          local Defender = Defender -- Wrapper.Group#GROUP
           if DefenderTask.Target and DefenderTask.Target.Index == DetectedItem.Index then
             Report:Add( string.format( "   - %s ( %s - %s ): ( #%d ) %s", Defender:GetName(), DefenderTask.Type, DefenderTask.Fsm:GetState(), Defender:GetSize(), Defender:HasTask() == true and "Executing" or "Idle" ) )
           end
        end
      end
    end

    if self.TacticalDisplay then
      Report:Add( "\n - No Targets:")
      local TaskCount = 0
      for Defender, DefenderTask in pairs( self:GetDefenderTasks() ) do
        TaskCount = TaskCount + 1
        local Defender = Defender -- Wrapper.Group#GROUP
        if not DefenderTask.Target then
          local DefenderHasTask = Defender:HasTask()
          Report:Add( string.format( "   - %s ( %s - %s ): ( #%d ) %s", Defender:GetName(), DefenderTask.Type, DefenderTask.Fsm:GetState(), Defender:GetSize(), Defender:HasTask() == true and "Executing" or "Idle" ) )
        end
      end
      Report:Add( string.format( "\n - %d Tasks", TaskCount ) )
  
      self:T( Report:Text( "\n" ) )
      trigger.action.outText( Report:Text( "\n" ), 25 )
    end
    
    return true
  end

end

do

  --- Calculates which HUMAN friendlies are nearby the area
  -- @param #AI_A2A_DISPATCHER self
  -- @param DetectedItem
  -- @return #number, Core.CommandCenter#REPORT
  function AI_A2A_DISPATCHER:GetPlayerFriendliesNearBy( DetectedItem )
  
    local DetectedSet = DetectedItem.Set
    local PlayersNearBy = self.Detection:GetPlayersNearBy( DetectedItem )
    
    local PlayerTypes = {}
    local PlayersCount = 0

    if PlayersNearBy then
      local DetectedTreatLevel = DetectedSet:CalculateThreatLevelA2G()
      for PlayerUnitName, PlayerUnitData in pairs( PlayersNearBy ) do
        local PlayerUnit = PlayerUnitData -- Wrapper.Unit#UNIT
        local PlayerName = PlayerUnit:GetPlayerName()
        --self:E( { PlayerName = PlayerName, PlayerUnit = PlayerUnit } )
        if PlayerUnit:IsAirPlane() and PlayerName ~= nil then
          local FriendlyUnitThreatLevel = PlayerUnit:GetThreatLevel()
          PlayersCount = PlayersCount + 1
          local PlayerType = PlayerUnit:GetTypeName()
          PlayerTypes[PlayerName] = PlayerType
          if DetectedTreatLevel < FriendlyUnitThreatLevel + 2 then
          end
        end
      end
      
    end

    --self:E( { PlayersCount = PlayersCount } )
    
    local PlayerTypesReport = REPORT:New()
    
    if PlayersCount > 0 then
      for PlayerName, PlayerType in pairs( PlayerTypes ) do
        PlayerTypesReport:Add( string.format('"%s" in %s', PlayerName, PlayerType ) )
      end
    else
      PlayerTypesReport:Add( "-" )
    end
    
    
    return PlayersCount, PlayerTypesReport
  end

  --- Calculates which friendlies are nearby the area
  -- @param #AI_A2A_DISPATCHER self
  -- @param DetectedItem
  -- @return #number, Core.CommandCenter#REPORT
  function AI_A2A_DISPATCHER:GetFriendliesNearBy( Target )
  
    local DetectedSet = Target.Set
    local FriendlyUnitsNearBy = self.Detection:GetFriendliesNearBy( Target )
    
    local FriendlyTypes = {}
    local FriendliesCount = 0

    if FriendlyUnitsNearBy then
      local DetectedTreatLevel = DetectedSet:CalculateThreatLevelA2G()
      for FriendlyUnitName, FriendlyUnitData in pairs( FriendlyUnitsNearBy ) do
        local FriendlyUnit = FriendlyUnitData -- Wrapper.Unit#UNIT
        if FriendlyUnit:IsAirPlane() then
          local FriendlyUnitThreatLevel = FriendlyUnit:GetThreatLevel()
          FriendliesCount = FriendliesCount + 1
          local FriendlyType = FriendlyUnit:GetTypeName()
          FriendlyTypes[FriendlyType] = FriendlyTypes[FriendlyType] and ( FriendlyTypes[FriendlyType] + 1 ) or 1
          if DetectedTreatLevel < FriendlyUnitThreatLevel + 2 then
          end
        end
      end
      
    end

    --self:E( { FriendliesCount = FriendliesCount } )
    
    local FriendlyTypesReport = REPORT:New()
    
    if FriendliesCount > 0 then
      for FriendlyType, FriendlyTypeCount in pairs( FriendlyTypes ) do
        FriendlyTypesReport:Add( string.format("%d of %s", FriendlyTypeCount, FriendlyType ) )
      end
    else
      FriendlyTypesReport:Add( "-" )
    end
    
    
    return FriendliesCount, FriendlyTypesReport
  end

  ---
  -- @param AI_A2A_DISPATCHER
  -- @param #string SquadronName The squadron name.
  function AI_A2A_DISPATCHER:SchedulerCAP( SquadronName )
    self:CAP( SquadronName )
  end

end

do

  --- @type AI_A2A_GCICAP
  -- @extends #AI_A2A_DISPATCHER

  --- # AI\_A2A\_GCICAP class, extends @{AI_A2A_Dispatcher#AI_A2A_DISPATCHER}
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia1.JPG)
  -- 
  -- The AI_A2A_GCICAP class is designed to create an automatic air defence system for a coalition setting up GCI and CAP air defenses. 
  -- The class derives from @{AI#AI_A2A_DISPATCHER} and thus, all the methods that are defined in the @{AI#AI_A2A_DISPATCHER} class, can be used also in AI\_A2A\_GCICAP.
  -- 
  -- ====
  -- 
  -- # Demo Missions
  -- 
  -- ### [AI\_A2A\_GCICAP for Caucasus](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/release-2-2-pre/AID%20-%20AI%20Dispatching/AID-200%20-%20AI_A2A%20-%20GCICAP%20Demonstration)
  -- ### [AI\_A2A\_GCICAP for NTTR](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/release-2-2-pre/AID%20-%20AI%20Dispatching/AID-210%20-%20NTTR%20AI_A2A_GCICAP%20Demonstration)
  -- ### [AI\_A2A\_GCICAP for Normandy](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/release-2-2-pre/AID%20-%20AI%20Dispatching/AID-220%20-%20NORMANDY%20AI_A2A_GCICAP%20Demonstration)
  -- 
  -- ### [AI\_A2A\_GCICAP for beta testers](https://github.com/FlightControl-Master/MOOSE_MISSIONS/tree/master/AID%20-%20AI%20Dispatching)
  --
  -- ====
  -- 
  -- # YouTube Channel
  -- 
  -- ### [---]()
  -- 
  -- ===
  -- 
  -- ![Banner Image](..\Presentations\AI_A2A_DISPATCHER\Dia3.JPG)
  -- 
  -- AI\_A2A\_GCICAP includes automatic spawning of Combat Air Patrol aircraft (CAP) and Ground Controlled Intercept aircraft (GCI) in response to enemy 
  -- air movements that are detected by an airborne or ground based radar network. 
  -- 
  -- With a little time and with a little work it provides the mission designer with a convincing and completely automatic air defence system.
  -- 
  -- The AI_A2A_GCICAP provides a lightweight configuration method using the mission editor. Within a very short time, and with very little coding, 
  -- the mission designer is able to configure a complete A2A defense system for a coalition using the DCS Mission Editor available functions. 
  -- Using the DCS Mission Editor, you define borders of the coalition which are guarded by GCICAP, 
  -- configure airbases to belong to the coalition, define squadrons flying certain types of planes or payloads per airbase, and define CAP zones.
  -- **Very little lua needs to be applied, a one liner**, which is fully explained below, which can be embedded 
  -- right in a DO SCRIPT trigger action or in a larger DO SCRIPT FILE trigger action. 
  -- 
  -- CAP flights will take off and proceed to designated CAP zones where they will remain on station until the ground radars direct them to intercept 
  -- detected enemy aircraft or they run short of fuel and must return to base (RTB). 
  -- 
  -- When a CAP flight leaves their zone to perform a GCI or return to base a new CAP flight will spawn to take its place.
  -- If all CAP flights are engaged or RTB then additional GCI interceptors will scramble to intercept unengaged enemy aircraft under ground radar control.
  -- 
  -- In short it is a plug in very flexible and configurable air defence module for DCS World.
  -- 
  -- ====
  -- 
  -- # The following actions need to be followed when using AI\_A2A\_GCICAP in your mission:
  -- 
  -- ## 1) Configure a working AI\_A2A\_GCICAP defense system for ONE coalition. 
  --   
  -- ### 1.1) Define which airbases are for which coalition. 
  -- 
  -- ![Mission Editor Action](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_GCICAP-ME_1.JPG)
  -- 
  -- Color the airbases red or blue. You can do this by selecting the airbase on the map, and select the coalition blue or red.
  -- 
  -- ### 1.2) Place groups of units given a name starting with a **EWR prefix** of your choice to build your EWR network. 
  -- 
  -- ![Mission Editor Action](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_GCICAP-ME_2.JPG)
  --       
  -- **All EWR groups starting with the EWR prefix (text) will be included in the detection system.**  
  -- 
  -- An EWR network, or, Early Warning Radar network, is used to early detect potential airborne targets and to understand the position of patrolling targets of the enemy.
  -- Typically EWR networks are setup using 55G6 EWR, 1L13 EWR, Hawk sr and Patriot str ground based radar units. 
  -- These radars have different ranges and 55G6 EWR and 1L13 EWR radars are Eastern Bloc units (eg Russia, Ukraine, Georgia) while the Hawk and Patriot radars are Western (eg US).
  -- Additionally, ANY other radar capable unit can be part of the EWR network! 
  -- Also AWACS airborne units, planes, helicopters can help to detect targets, as long as they have radar.
  -- The position of these units is very important as they need to provide enough coverage 
  -- to pick up enemy aircraft as they approach so that CAP and GCI flights can be tasked to intercept them.
  -- 
  -- Additionally in a hot war situation where the border is no longer respected the placement of radars has a big effect on how fast the war escalates. 
  -- For example if they are a long way forward and can detect enemy planes on the ground and taking off 
  -- they will start to vector CAP and GCI flights to attack them straight away which will immediately draw a response from the other coalition. 
  -- Having the radars further back will mean a slower escalation because fewer targets will be detected and 
  -- therefore less CAP and GCI flights will spawn and this will tend to make just the border area active rather than a melee over the whole map. 
  -- It all depends on what the desired effect is. 
  -- 
  -- EWR networks are **dynamically maintained**. By defining in a **smart way the names or name prefixes of the groups** with EWR capable units, these groups will be **automatically added or deleted** from the EWR network, 
  -- increasing or decreasing the radar coverage of the Early Warning System.
  -- 
  -- ### 1.3) Place Airplane or Helicopter Groups with late activation switched on above the airbases to define Squadrons. 
  -- 
  -- ![Mission Editor Action](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_GCICAP-ME_3.JPG)
  -- 
  -- These are **templates**, with a given name starting with a **Template prefix** above each airbase that you wanna have a squadron. 
  -- These **templates** need to be within 1.5km from the airbase center. They don't need to have a slot at the airplane, they can just be positioned above the airbase, 
  -- without a route, and should only have ONE unit.
  -- 
  -- ![Mission Editor Action](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_GCICAP-ME_4.JPG)
  -- 
  -- **All airplane or helicopter groups that are starting with any of the choosen Template Prefixes will result in a squadron created at the airbase.**  
  -- 
  -- ### 1.4) Place floating helicopters to create the CAP zones defined by its route points. 
  -- 
  -- ![Mission Editor Action](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_GCICAP-ME_5.JPG)
  -- 
  -- **All airplane or helicopter groups that are starting with any of the choosen Template Prefixes will result in a squadron created at the airbase.**  
  -- 
  -- The helicopter indicates the start of the CAP zone. 
  -- The route points define the form of the CAP zone polygon. 
  -- 
  -- ![Mission Editor Action](..\Presentations\AI_A2A_DISPATCHER\AI_A2A_GCICAP-ME_6.JPG)
  -- 
  -- **The place of the helicopter is important, as the airbase closest to the helicopter will be the airbase from where the CAP planes will take off for CAP.**
  -- 
  -- ## 2) There are a lot of defaults set, which can be further modified using the methods in @{AI#AI_A2A_DISPATCHER}:
  -- 
  -- ### 2.1) Planes are taking off in the air from the airbases.
  -- 
  -- This prevents airbases to get cluttered with airplanes taking off, it also reduces the risk of human players colliding with taxiiing airplanes,
  -- resulting in the airbase to halt operations.
  -- 
  -- You can change the way how planes take off by using the inherited methods from AI\_A2A\_DISPATCHER:
  -- 
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoff}() is the generic configuration method to control takeoff from the air, hot, cold or from the runway. See the method for further details.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffInAir}() will spawn new aircraft from the squadron directly in the air.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffFromParkingCold}() will spawn new aircraft in without running engines at a parking spot at the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffFromParkingHot}() will spawn new aircraft in with running engines at a parking spot at the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronTakeoffFromRunway}() will spawn new aircraft at the runway at the airfield.
  -- 
  -- Use these methods to fine-tune for specific airfields that are known to create bottlenecks, or have reduced airbase efficiency.
  -- The more and the longer aircraft need to taxi at an airfield, the more risk there is that:
  -- 
  --   * aircraft will stop waiting for each other or for a landing aircraft before takeoff.
  --   * aircraft may get into a "dead-lock" situation, where two aircraft are blocking each other.
  --   * aircraft may collide at the airbase.
  --   * aircraft may be awaiting the landing of a plane currently in the air, but never lands ...
  --   
  -- Currently within the DCS engine, the airfield traffic coordination is erroneous and contains a lot of bugs.
  -- If you experience while testing problems with aircraft take-off or landing, please use one of the above methods as a solution to workaround these issues!
  -- 
  -- ### 2.2) Planes return near the airbase or will land if damaged.
  -- 
  -- When damaged airplanes return to the airbase, they will be routed and will dissapear in the air when they are near the airbase.
  -- There are exceptions to this rule, airplanes that aren't "listening" anymore due to damage or out of fuel, will return to the airbase and land.
  -- 
  -- You can change the way how planes land by using the inherited methods from AI\_A2A\_DISPATCHER:
  -- 
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLanding}() is the generic configuration method to control landing, namely despawn the aircraft near the airfield in the air, right after landing, or at engine shutdown.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLandingNearAirbase}() will despawn the returning aircraft in the air when near the airfield.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLandingAtRunway}() will despawn the returning aircraft directly after landing at the runway.
  --   * @{#AI_A2A_DISPATCHER.SetSquadronLandingAtEngineShutdown}() will despawn the returning aircraft when the aircraft has returned to its parking spot and has turned off its engines.
  -- 
  -- You can use these methods to minimize the airbase coodination overhead and to increase the airbase efficiency.
  -- When there are lots of aircraft returning for landing, at the same airbase, the takeoff process will be halted, which can cause a complete failure of the
  -- A2A defense system, as no new CAP or GCI planes can takeoff.
  -- Note that the method @{#AI_A2A_DISPATCHER.SetSquadronLandingNearAirbase}() will only work for returning aircraft, not for damaged or out of fuel aircraft.
  -- Damaged or out-of-fuel aircraft are returning to the nearest friendly airbase and will land, and are out of control from ground control.
  -- 
  -- ### 2.3) CAP operations setup for specific airbases, will be executed with the following parameters: 
  -- 
  --   * The altitude will range between 6000 and 10000 meters. 
  --   * The CAP speed will vary between 500 and 800 km/h. 
  --   * The engage speed between 800 and 1200 km/h.
  --   
  -- You can change or add a CAP zone by using the inherited methods from AI\_A2A\_DISPATCHER:
  -- 
  -- The method @{#AI_A2A_DISPATCHER.SetSquadronCap}() defines a CAP execution for a squadron.
  -- 
  -- Setting-up a CAP zone also requires specific parameters:
  -- 
  --   * The minimum and maximum altitude
  --   * The minimum speed and maximum patrol speed
  --   * The minimum and maximum engage speed
  --   * The type of altitude measurement
  -- 
  -- These define how the squadron will perform the CAP while partrolling. Different terrain types requires different types of CAP. 
  -- 
  -- The @{#AI_A2A_DISPATCHER.SetSquadronCapInterval}() method specifies **how much** and **when** CAP flights will takeoff.
  -- 
  -- It is recommended not to overload the air defense with CAP flights, as these will decrease the performance of the overall system. 
  -- 
  -- For example, the following setup will create a CAP for squadron "Sochi":
  -- 
  --    A2ADispatcher:SetSquadronCap( "Sochi", CAPZoneWest, 4000, 8000, 600, 800, 800, 1200, "BARO" )
  --    A2ADispatcher:SetSquadronCapInterval( "Sochi", 2, 30, 120, 1 )
  -- 
  -- ### 2.4) Each airbase will perform GCI when required, with the following parameters:
  -- 
  --   * The engage speed is between 800 and 1200 km/h.
  -- 
  -- You can change or add a GCI parameters by using the inherited methods from AI\_A2A\_DISPATCHER:
  -- 
  -- The method @{#AI_A2A_DISPATCHER.SetSquadronGci}() defines a GCI execution for a squadron.
  -- 
  -- Setting-up a GCI readiness also requires specific parameters:
  -- 
  --   * The minimum speed and maximum patrol speed
  -- 
  -- Essentially this controls how many flights of GCI aircraft can be active at any time.
  -- Note allowing large numbers of active GCI flights can adversely impact mission performance on low or medium specification hosts/servers.
  -- GCI needs to be setup at strategic airbases. Too far will mean that the aircraft need to fly a long way to reach the intruders, 
  -- too short will mean that the intruders may have alraedy passed the ideal interception point!
  -- 
  -- For example, the following setup will create a GCI for squadron "Sochi":
  -- 
  --    A2ADispatcher:SetSquadronGci( "Mozdok", 900, 1200 )
  -- 
  -- ### 2.5) Grouping or detected targets.
  -- 
  -- Detected targets are constantly re-grouped, that is, when certain detected aircraft are moving further than the group radius, then these aircraft will become a separate
  -- group being detected.
  -- 
  -- Targets will be grouped within a radius of 30km by default.
  -- 
  -- The radius indicates that detected targets need to be grouped within a radius of 30km.
  -- The grouping radius should not be too small, but also depends on the types of planes and the era of the simulation.
  -- Fast planes like in the 80s, need a larger radius than WWII planes.  
  -- Typically I suggest to use 30000 for new generation planes and 10000 for older era aircraft.
  -- 
  -- ## 3) Additional notes:
  -- 
  -- In order to create a two way A2A defense system, **two AI\_A2A\_GCICAP defense systems must need to be created**, for each coalition one.
  -- Each defense system needs its own EWR network setup, airplane templates and CAP configurations.
  -- 
  -- This is a good implementation, because maybe in the future, more coalitions may become available in DCS world.
  -- 
  -- ## 4) Coding examples how to use the AI\_A2A\_GCICAP class:
  -- 
  -- ### 4.1) An easy setup:
  -- 
  --      -- Setup the AI_A2A_GCICAP dispatcher for one coalition, and initialize it.
  --      GCI_Red = AI_A2A_GCICAP:New( "EWR CCCP", "SQUADRON CCCP", "CAP CCCP", 2 )
  --   -- 
  -- The following parameters were given to the :New method of AI_A2A_GCICAP, and mean the following:
  -- 
  --    * `"EWR CCCP"`: Groups of the blue coalition are placed that define the EWR network. These groups start with the name `EWR CCCP`.
  --    * `"SQUADRON CCCP"`: Late activated Groups objects of the red coalition are placed above the relevant airbases that will contain these templates in the squadron.
  --      These late activated Groups start with the name `SQUADRON CCCP`. Each Group object contains only one Unit, and defines the weapon payload, skin and skill level.
  --    * `"CAP CCCP"`: CAP Zones are defined using floating, late activated Helicopter Group objects, where the route points define the route of the polygon of the CAP Zone.
  --      These Helicopter Group objects start with the name `CAP CCCP`, and will be the locations wherein CAP will be performed.
  --    * `2` Defines how many CAP airplanes are patrolling in each CAP zone defined simulateneously.  
  -- 
  -- 
  -- ### 4.2) A more advanced setup:
  -- 
  --      -- Setup the AI_A2A_GCICAP dispatcher for the blue coalition.
  -- 
  --      A2A_GCICAP_Blue = AI_A2A_GCICAP:New( { "BLUE EWR" }, { "104th", "105th", "106th" }, { "104th CAP" }, 4 ) 
  -- 
  -- The following parameters for the :New method have the following meaning:
  -- 
  --    * `{ "BLUE EWR" }`: An array of the group name prefixes of the groups of the blue coalition are placed that define the EWR network. These groups start with the name `BLUE EWR`.
  --    * `{ "104th", "105th", "106th" } `: An array of the group name prefixes of the Late activated Groups objects of the blue coalition are 
  --      placed above the relevant airbases that will contain these templates in the squadron.
  --      These late activated Groups start with the name `104th` or `105th` or `106th`. 
  --    * `{ "104th CAP" }`: An array of the names of the CAP zones are defined using floating, late activated helicopter group objects, 
  --      where the route points define the route of the polygon of the CAP Zone.
  --      These Helicopter Group objects start with the name `104th CAP`, and will be the locations wherein CAP will be performed.
  --    * `4` Defines how many CAP airplanes are patrolling in each CAP zone defined simulateneously.  
  -- 
  -- @field #AI_A2A_GCICAP
  AI_A2A_GCICAP = {
    ClassName = "AI_A2A_GCICAP",
    Detection = nil,
  }


  --- AI_A2A_GCICAP constructor.
  -- @param #AI_A2A_GCICAP self
  -- @param #string EWRPrefixes A list of prefixes that of groups that setup the Early Warning Radar network.
  -- @param #string TemplatePrefixes A list of template prefixes.
  -- @param #string CapPrefixes A list of CAP zone prefixes (polygon zones).
  -- @param #number CapLimit A number of how many CAP maximum will be spawned.
  -- @param #number GroupingRadius The radius in meters wherein detected planes are being grouped as one target area. 
  -- For airplanes, 6000 (6km) is recommended, and is also the default value of this parameter.
  -- @param #number EngageRadius The radius in meters wherein detected airplanes will be engaged by airborne defenders without a task.
  -- @param #number GciRadius The radius in meters wherein detected airplanes will GCI.
  -- @return #AI_A2A_GCICAP
  -- @usage
  --   
  --   -- Set a new AI A2A GCICAP object, based on an EWR network with a 30 km grouping radius
  --   -- This for ground and awacs installations.
  --   
  --   A2ADispatcher = AI_A2A_GCICAP:New( { "BlueEWRGroundRadars", "BlueEWRAwacs" }, 30000 )
  --   
  function AI_A2A_GCICAP:New( EWRPrefixes, TemplatePrefixes, CapPrefixes, CapLimit, GroupingRadius, EngageRadius, GciRadius )

    GroupingRadius = GroupingRadius or 30000
    EngageRadius = EngageRadius or 100000
    GciRadius = GciRadius or 150000

    local EWRSetGroup = SET_GROUP:New()
    EWRSetGroup:FilterPrefixes( EWRPrefixes )
    EWRSetGroup:FilterStart()

    local Detection  = DETECTION_AREAS:New( EWRSetGroup, GroupingRadius )

    local self = BASE:Inherit( self, AI_A2A_DISPATCHER:New( Detection ) ) -- #AI_A2A_GCICAP
    
    self:SetEngageRadius( EngageRadius )
    self:SetGciRadius( GciRadius )

    -- Determine the coalition of the EWRNetwork, this will be the coalition of the GCICAP.
    local EWRFirst = EWRSetGroup:GetFirst() -- Wrapper.Group#GROUP
    local EWRCoalition = EWRFirst:GetCoalition()
    
    -- Determine the airbases belonging to the coalition.
    local AirbaseNames = {} -- #list<#string>
    for AirbaseID, AirbaseData in pairs( _DATABASE.AIRBASES ) do
      local Airbase = AirbaseData -- Wrapper.Airbase#AIRBASE
      local AirbaseName = Airbase:GetName()
      if Airbase:GetCoalition() == EWRCoalition then
        table.insert( AirbaseNames, AirbaseName )
      end
    end    
    
    self.Templates = SET_GROUP
      :New()
      :FilterPrefixes( TemplatePrefixes )
      :FilterOnce()

    -- Setup squadrons
    
    self:F( { Airbases = AirbaseNames  } )
    
    for AirbaseID, AirbaseName in pairs( AirbaseNames ) do
      local Airbase = _DATABASE:FindAirbase( AirbaseName ) -- Wrapper.Airbase#AIRBASE
      local AirbaseName = Airbase:GetName()
      local AirbaseCoord = Airbase:GetCoordinate()
      local AirbaseZone = ZONE_RADIUS:New( "Airbase", AirbaseCoord:GetVec2(), 3000 )
      local Templates = nil
      for TemplateID, Template in pairs( self.Templates:GetSet() ) do
        local Template = Template -- Wrapper.Group#GROUP
        self:F( { Template = Template:GetName() } )
        local TemplateCoord = Template:GetCoordinate()
        if AirbaseZone:IsVec2InZone( TemplateCoord:GetVec2() ) then
          Templates = Templates or {}
          table.insert( Templates, Template:GetName() )
        end
      end
      if Templates then
        self:SetSquadron( AirbaseName, AirbaseName, Templates, 30 )
      end
    end

    -- Setup CAP.
    -- Find for each CAP the nearest airbase to the (start or center) of the zone. 
    -- CAP will be launched from there.
    
    self.CAPTemplates = SET_GROUP:New()
    self.CAPTemplates:FilterPrefixes( CapPrefixes )
    self.CAPTemplates:FilterOnce()
    
    for CAPID, CAPTemplate in pairs( self.CAPTemplates:GetSet() ) do
      local CAPZone = ZONE_POLYGON:New( CAPTemplate:GetName(), CAPTemplate )
      -- Now find the closest airbase from the ZONE (start or center)
      local AirbaseDistance = 99999999
      local AirbaseClosest = nil -- Wrapper.Airbase#AIRBASE
      for AirbaseID, AirbaseName in pairs( AirbaseNames ) do
        local Airbase = _DATABASE:FindAirbase( AirbaseName ) -- Wrapper.Airbase#AIRBASE
        local AirbaseName = Airbase:GetName()
        local AirbaseCoord = Airbase:GetCoordinate()
        local Squadron = self.DefenderSquadrons[AirbaseName]
        if Squadron then
          local Distance = AirbaseCoord:Get2DDistance( CAPZone:GetCoordinate() )
          if Distance < AirbaseDistance then
            AirbaseDistance = Distance
            AirbaseClosest = Airbase
          end
        end
      end
      if AirbaseClosest then
        self:SetSquadronCap( AirbaseClosest:GetName(), CAPZone, 6000, 10000, 500, 800, 800, 1200, "RADIO" )
        self:SetSquadronCapInterval( AirbaseClosest:GetName(), CapLimit, 300, 600, 1 )
      end          
    end    

    -- Setup GCI.
    -- GCI is setup for all Squadrons.
    for AirbaseID, AirbaseName in pairs( AirbaseNames ) do
      local Airbase = _DATABASE:FindAirbase( AirbaseName ) -- Wrapper.Airbase#AIRBASE
      local AirbaseName = Airbase:GetName()
      local Squadron = self.DefenderSquadrons[AirbaseName]
      if Squadron then
        self:SetSquadronGci( AirbaseName, 800, 1200 )
      end
    end
    
    self:__Start( 5 )
    
    self:HandleEvent( EVENTS.Crash, self.OnEventCrashOrDead )
    self:HandleEvent( EVENTS.Dead, self.OnEventCrashOrDead )
    
    self:HandleEvent( EVENTS.Land )
    self:HandleEvent( EVENTS.EngineShutdown )
    
    return self
  end

  --- AI_A2A_GCICAP constructor with border.
  -- @param #AI_A2A_GCICAP self
  -- @param #string EWRPrefixes A list of prefixes that of groups that setup the Early Warning Radar network.
  -- @param #string TemplatePrefixes A list of template prefixes.
  -- @param #string BorderPrefix A Border Zone Prefix.
  -- @param #string CapPrefixes A list of CAP zone prefixes (polygon zones).
  -- @param #number CapLimit A number of how many CAP maximum will be spawned.
  -- @param #number GroupingRadius The radius in meters wherein detected planes are being grouped as one target area. 
  -- For airplanes, 6000 (6km) is recommended, and is also the default value of this parameter.
  -- @param #number EngageRadius The radius in meters wherein detected airplanes will be engaged by airborne defenders without a task.
  -- @param #number GciRadius The radius in meters wherein detected airplanes will GCI.
  -- @return #AI_A2A_GCICAP
  -- @usage
  --   
  --   -- Set a new AI A2A GCICAP object, based on an EWR network with a 30 km grouping radius
  --   -- This for ground and awacs installations.
  --   
  --   A2ADispatcher = AI_A2A_GCICAP:New( { "BlueEWRGroundRadars", "BlueEWRAwacs" }, 30000 )
  --   
  function AI_A2A_GCICAP:NewWithBorder( EWRPrefixes, TemplatePrefixes, BorderPrefix, CapPrefixes, CapLimit, GroupingRadius, EngageRadius, GciRadius )

    local self = AI_A2A_GCICAP:New( EWRPrefixes, TemplatePrefixes, CapPrefixes, CapLimit, GroupingRadius, EngageRadius, GciRadius )

    if BorderPrefix then
      self:SetBorderZone( ZONE_POLYGON:New( BorderPrefix, GROUP:FindByName( BorderPrefix ) ) )
    end
    
    return self

  end

end

