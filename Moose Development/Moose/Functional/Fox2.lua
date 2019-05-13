--- **Functional** - (R2.5) - Yet another missile trainer.
-- 
-- 
-- Train to evade missiles without being destroyed.
-- 
--
-- ## Main Features:
-- 
--    * Adaptive update of missile-to-player distance.
--    * Define your own training zones on the map. Player in this zone will be protected.
--    * Define launch zones. Only 
--    * F10 radio menu to adjust settings for each player.
--    * Easy to use.
--    * Handles air-to-air and surface-to-air missiles.
--    * Alert on missile launch (optional).
--    * Marker of missile launch position (optional).
--     
-- ===
--
-- ### Author: **funkyfranky**
-- @module Functional.FOX
-- @image Functional_FOX.png


--- FOX class.
-- @type FOX
-- @field #string ClassName Name of the class.
-- @field #boolean Debug Debug mode. Messages to all about status.
-- @field #string lid Class id string for output to DCS log file.
-- @field #table menuadded Table of groups the menu was added for.
-- @field #table players Table of players.
-- @field #table missiles Table of tracked missiles.
-- @field #table safezones Table of practice zones.
-- @field #table launchzones Table of launch zones.
-- @field Core.Set#SET_GROUP protectedset Set of protected groups.
-- @field #number explosionpower Power of explostion when destroying the missile in kg TNT. Default 5 kg TNT.
-- @field #number explosiondist Missile player distance in meters for destroying the missile. Default 100 m.
-- @field #number dt50 Time step [sec] for missile position updates if distance to target > 50 km. Default 5 sec.
-- @field #number dt10 Time step [sec] for missile position updates if distance to target > 10 km and < 50 km. Default 1 sec.
-- @field #number dt05 Time step [sec] for missile position updates if distance to target > 5 km and < 10 km. Default 0.5 sec.
-- @field #number dt01 Time step [sec] for missile position updates if distance to target > 1 km and < 5 km. Default 0.1 sec.
-- @field #number dt00 Time step [sec] for missile position updates if distance to target < 1 km. Default 0.01 sec.
-- @field #boolean 
-- @extends Core.Fsm#FSM

--- Fox 3!
--
-- ===
--
-- ![Banner Image](..\Presentations\FOX\FOX_Main.png)
--
-- # The FOX Concept
-- 
-- As you probably know [Fox](https://en.wikipedia.org/wiki/Fox_(code_word)) is a NATO brevity code for launching air-to-air munition. Therefore, the class name is not 100% accurate as this
-- script handles air-to-air and surface-to-air missiles.
-- 
-- 
-- 
-- @field #FOX
FOX = {
  ClassName      = "FOX",
  Debug          = false,
  lid            =   nil,
  menuadded      =    {},
  missiles       =    {},
  players        =    {},
  safezones      =    {},
  launchzones    =    {},
  protectedset   =   nil,
  explosionpower =     5,
  explosiondist  =   100,
  destroy        =   nil,
  dt50           =     5,
  dt10           =     1,
  dt05           =   0.5,
  dt01           =   0.1,
  dt00           =  0.01,
}


--- Player data table holding all important parameters of each player.
-- @type FOX.PlayerData
-- @field Wrapper.Unit#UNIT unit Aircraft of the player.
-- @field #string unitname Name of the unit.
-- @field Wrapper.Client#CLIENT client Client object of player.
-- @field #string callsign Callsign of player.
-- @field Wrapper.Group#GROUP group Aircraft group of player.
-- @field #string groupname Name of the the player aircraft group.
-- @field #string name Player name.
-- @field #number coalition Coalition number of player.
-- @field #boolean destroy Destroy missile.
-- @field #boolean launchalert Alert player on detected missile launch.
-- @field #boolean marklaunch Mark position of launched missile on F10 map.
-- @field #number defeated Number of missiles defeated.
-- @field #number dead Number of missiles not defeated.
-- @field #boolean inzone Player is inside a protected zone.

--- Missile data table.
-- @type FOX.MissileData
-- @field Wrapper.Unit#UNIT weapon Missile weapon unit.
-- @field #boolean active If true the missile is active.
-- @field #string missileType Type of missile.
-- @field #number missileRange Range of missile in meters.
-- @field Wrapper.Unit#UNIT shooterUnit Unit that shot the missile.
-- @field Wrapper.Group#GROUP shooterGroup Group that shot the missile.
-- @field #number shooterCoalition Coalition side of the shooter.
-- @field #string shooterName Name of the shooter unit.
-- @field #number shotTime Abs mission time in seconds the missile was fired.
-- @field Core.Point#COORDINATE shotCoord Coordinate where the missile was fired.
-- @field Wrapper.Unit#UNIT targetUnit Unit that was targeted.
-- @field #FOX.PlayerData targetPlayer Player that was targeted or nil.

--- Main radio menu on group level.
-- @field #table MenuF10 Root menu table on group level.
FOX.MenuF10={}

--- Main radio menu on mission level.
-- @field #table MenuF10Root Root menu on mission level.
FOX.MenuF10Root=nil

--- FOX class version.
-- @field #string version
FOX.version="0.3.0"

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ToDo list
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- TODO list:
-- DONE: safe zones
-- DONE: mark shooter on F10

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Constructor
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Create a new FOX class object.
-- @param #FOX self
-- @return #FOX self.
function FOX:New()

  self.lid="FOX | "

  -- Inherit everthing from FSM class.
  local self=BASE:Inherit(self, FSM:New()) -- #FOX
  
  -- Start State.
  self:SetStartState("Stopped")

  -- Add FSM transitions.
  --                 From State   -->   Event        -->     To State
  self:AddTransition("Stopped",           "Start",          "Running")     -- Start FOX script.
  self:AddTransition("*",                "Status",          "*")           -- Status update.
  self:AddTransition("*",         "MissileLaunch",          "*")           -- Missile was launched.
  self:AddTransition("*",      "MissileDestroyed",          "*")           -- Missile was destroyed before impact.
  self:AddTransition("*",         "EnterSafeZone",          "*")           -- Player enters a safe zone.
  self:AddTransition("*",          "ExitSafeZone",          "*")           -- Player exists a safe zone.

  ------------------------
  --- Pseudo Functions ---
  ------------------------

  --- Triggers the FSM event "Start". Starts the FOX. Initializes parameters and starts event handlers.
  -- @function [parent=#FOX] Start
  -- @param #FOX self

  --- Triggers the FSM event "Start" after a delay. Starts the FOX. Initializes parameters and starts event handlers.
  -- @function [parent=#FOX] __Start
  -- @param #FOX self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Stop". Stops the FOX and all its event handlers.
  -- @param #FOX self

  --- Triggers the FSM event "Stop" after a delay. Stops the FOX and all its event handlers.
  -- @function [parent=#FOX] __Stop
  -- @param #FOX self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "Status".
  -- @function [parent=#FOX] Status
  -- @param #FOX self

  --- Triggers the FSM event "Status" after a delay.
  -- @function [parent=#FOX] __Status
  -- @param #FOX self
  -- @param #number delay Delay in seconds.

  --- Triggers the FSM event "MissileLaunch".
  -- @function [parent=#FOX] MissileLaunch
  -- @param #FOX self
  -- @param #FOX.MissileData missile Data of the fired missile.

  --- Triggers the FSM delayed event "MissileLaunch".
  -- @function [parent=#FOX] __MissileLaunch
  -- @param #FOX self
  -- @param #number delay Delay in seconds before the function is called.
  -- @param #FOX.MissileData missile Data of the fired missile.

  --- On after "MissileLaunch" event user function. Called when a missile was launched.
  -- @function [parent=#FOX] OnAfterMissileLaunch
  -- @param #FOX self
  -- @param #string From From state.
  -- @param #string Event Event.
  -- @param #string To To state.
  -- @param #FOX.MissileData missile Data of the fired missile.

  --- Triggers the FSM event "MissileDestroyed".
  -- @function [parent=#FOX] MissileDestroyed
  -- @param #FOX self
  -- @param #FOX.MissileData missile Data of the destroyed missile.

  --- Triggers the FSM delayed event "MissileDestroyed".
  -- @function [parent=#FOX] __MissileDestroyed
  -- @param #FOX self
  -- @param #number delay Delay in seconds before the function is called.
  -- @param #FOX.MissileData missile Data of the destroyed missile.

  --- On after "MissileDestroyed" event user function. Called when a missile was destroyed.
  -- @function [parent=#FOX] OnAfterMissileDestroyed
  -- @param #FOX self
  -- @param #string From From state.
  -- @param #string Event Event.
  -- @param #string To To state.
  -- @param #FOX.MissileData missile Data of the destroyed missile.


  --- Triggers the FSM event "EnterSafeZone".
  -- @function [parent=#FOX] EnterSafeZone
  -- @param #FOX self
  -- @param #FOX.PlayerData player Player data.

  --- Triggers the FSM delayed event "EnterSafeZone".
  -- @function [parent=#FOX] __EnterSafeZone
  -- @param #FOX self
  -- @param #number delay Delay in seconds before the function is called.
  -- @param #FOX.PlayerData player Player data.

  --- On after "EnterSafeZone" event user function. Called when a player enters a safe zone.
  -- @function [parent=#FOX] OnAfterEnterSafeZone
  -- @param #FOX self
  -- @param #string From From state.
  -- @param #string Event Event.
  -- @param #string To To state.
  -- @param #FOX.PlayerData player Player data.


  --- Triggers the FSM event "ExitSafeZone".
  -- @function [parent=#FOX] ExitSafeZone
  -- @param #FOX self
  -- @param #FOX.PlayerData player Player data.

  --- Triggers the FSM delayed event "ExitSafeZone".
  -- @function [parent=#FOX] __ExitSafeZone
  -- @param #FOX self
  -- @param #number delay Delay in seconds before the function is called.
  -- @param #FOX.PlayerData player Player data.

  --- On after "ExitSafeZone" event user function. Called when a player exists a safe zone.
  -- @function [parent=#FOX] OnAfterExitSafeZone
  -- @param #FOX self
  -- @param #string From From state.
  -- @param #string Event Event.
  -- @param #string To To state.
  -- @param #FOX.PlayerData player Player data.

  
  return self
end

--- On after Start event. Starts the missile trainer and adds event handlers.
-- @param #FOX self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function FOX:onafterStart(From, Event, To)

  -- Short info.
  local text=string.format("Starting FOX Missile Trainer %s", FOX.version)
  env.info(text)

  -- Handle events:
  self:HandleEvent(EVENTS.Birth)
  self:HandleEvent(EVENTS.Shot)
  
  if self.Debug then
    self:TraceClass(self.ClassName)
    self:TraceLevel(2)
  end
  
  self:__Status(-10)
end

--- On after Stop event. Stops the missile trainer and unhandles events.
-- @param #FOX self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function FOX:onafterStop(From, Event, To)

  -- Short info.
  local text=string.format("Stopping FOX Missile Trainer %s", FOX.version)
  env.info(text)

  -- Handle events:
  self:UnhandleEvent(EVENTS.Birth)
  self:UnhandleEvent(EVENTS.Shot)

end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- User Functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Add a training zone. Players in the zone are safe.
-- @param #FOX self
-- @param Core.Zone#ZONE zone Training zone.
-- @return #FOX self
function FOX:AddSafeZone(zone)

  table.insert(self.safezones, zone)

  return self
end

--- Add a launch zone. Only missiles launched within these zones will be tracked.
-- @param #FOX self
-- @param Core.Zone#ZONE zone Training zone.
-- @return #FOX self
function FOX:AddLaunchZone(zone)

  table.insert(self.launchzones, zone)

  return self
end

--- Set debug mode on/off.
-- @param #FOX self
-- @param #boolean switch If true debug mode on. If false/nil debug mode off
-- @return #FOX self
function FOX:SetDebugOnOff(switch)

  if switch==nil then
    self.Debug=false
  else
    self.Debug=switch
  end

  return self
end

--- Set debug mode on.
-- @param #FOX self
-- @return #FOX self
function FOX:SetDebugOn()
  self:SetDebugOnOff(true)
  return self
end

--- Set debug mode off.
-- @param #FOX self
-- @return #FOX self
function FOX:SetDebugOff()
  self:SetDebugOff(false)
  return self
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Status Functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Check spawn queue and spawn aircraft if necessary.
-- @param #FOX self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
function FOX:onafterStatus(From, Event, To)

  local fsmstate=self:GetState()
  
  self:I(self.lid..string.format("Missile trainer status: %s", fsmstate))
  
  self:_CheckMissileStatus()

  if fsmstate=="Running" then
    self:__Status(-10)
  end
end

--- Check status of players.
-- @param #FOX self
-- @param #string _unitName Name of player unit.
function FOX:_CheckPlayers()

  for playername,_playersettings in pairs(self.players) do
    local playersettings=_playersettings  --#FOX.PlayerData
    
    local unitname=playersettings.unitname
    local unit=UNIT:FindByName(unitname)
    
    if unit and unit:IsAlive() then
    
      local coord=unit:GetCoordinate()
      
      local issafe=self:_CheckCoordSafe(coord)
      
        
      if issafe then
      
        -----------------------------
        -- Player INSIDE Safe Zone --
        -----------------------------
      
        if not playersettings.inzone then
          self:EnterSafeZone(playersettings)
          playersettings.inzone=true
        end
        
      else
      
        ------------------------------
        -- Player OUTSIDE Safe Zone --
        ------------------------------     
      
        if playersettings.inzone==true then
          self:ExitSafeZone(playersettings)
          playersettings.inzone=false
        end
        
      end
    end
  end

end


--- Missile status 
-- @param #FOX self
function FOX:_CheckMissileStatus()

  local text="Missiles:"
  for i,_missile in pairs(self.missiles) do
    local missile=_missile --#FOX.MissileData
    
    local targetname="unkown"
    if missile.targetUnit then
      targetname=missile.targetUnit:GetName()
    end
    local playername="none"
    if missile.targetPlayer then
      playername=missile.targetPlayer.name
    end
    local active=tostring(missile.active)
    local mtype=missile.missileType
    local dtype=missile.missileType
    local range=UTILS.MetersToNM(missile.missileRange)
    local heading=self:_GetWeapongHeading(missile.weapon)
    
    text=text..string.format("\n[%d] %s: active=%s, range=%.1f NM, heading=%03d, target=%s, player=%s, missilename=%s", i, mtype, active, range, heading, targetname, playername, missile.missileName)
    
  end
  self:I(self.lid..text)

end

--- Missle launch.
-- @param #FOX self
-- @param #string From From state.
-- @param #string Event Event.
-- @param #string To To state.
-- @param #FOX.MissileData missile Fired missile
function FOX:onafterMissileLaunch(From, Event, To, missile)

  -- Tracking info and init of last bomb position.
  self:I(FOX.lid..string.format("FOX: Tracking %s - %s.", missile.missileType, missile.missileName))
  
  -- Loop over players.
  for _,_player in pairs(self.players) do
    local player=_player  --#FOX.PlayerData
    
    -- Player position.
    local playerUnit=player.unit
    
    -- Check that player is alive and of the opposite coalition.
    if playerUnit and playerUnit:IsAlive() and player.coalition~=missile.shooterCoalition then
    
      -- Player missile distance.
      local distance=playerUnit:GetCoordinate():Get3DDistance(missile.shotCoord)
      
      -- Player bearing to missile.
      local bearing=playerUnit:GetCoordinate():HeadingTo(missile.shotCoord)
      
      -- Alert that missile has been launched.
      if player.launchalert then
      
        -- Alert directly targeted players or players that are within missile max range.
        if (missile.targetPlayer and player.unitname==missile.targetPlayer.unitname) or (distance<missile.missileRange)  then
        
          local nr, nl=self:_GetNotchingHeadings(missile.weapon)
      
          -- Inform player.
          local text=string.format("Missile launch detected! Distance %.1f NM, bearing %03d°.", UTILS.MetersToNM(distance), bearing)
          text=text..string.format("\nNotching heading %03d or %03d", nr, nl)
          
          --TODO: ALERT or INFO depending on whether this is a direct target.
          --TODO: lauchalertall option.
          MESSAGE:New(text, 5, "ALERT"):ToClient(player.client)
          
        end
        
      end
        
      -- Mark coordinate.
      if player.marklaunch then
        local text=string.format("Missile launch coordinates:\n%s\n%s", missile.shotCoord:ToStringLLDMS(), missile.shotCoord:ToStringBULLS(player.coalition))          
        missile.shotCoord:MarkToGroup(text, player.group)
      end
        
    end
  end              
  
  -- Init missile position.
  local _lastBombPos = {x=0,y=0,z=0}
  
  -- Missile coordinate.
  local missileCoord = nil --Core.Point#COORDINATE
  
  -- Target unit of the missile.
  local target=nil --Wrapper.Unit#UNIT
      
  --- Function monitoring the position of a bomb until impact.
  local function trackMissile(_ordnance)
  
    -- When the pcall returns a failure the weapon has hit.
    local _status,_bombPos =  pcall(
    function()
      return _ordnance:getPoint()
    end)
  
    -- Check if status is not nil. If so, we have a valid point.
    if _status then
    
      ----------------------------------------------
      -- Still in the air. Remember this position --
      ----------------------------------------------
      
      -- Missile position.
      _lastBombPos = {x=_bombPos.x, y=_bombPos.y, z=_bombPos.z}
      
      -- Missile coordinate.
      missileCoord=COORDINATE:NewFromVec3(_lastBombPos)
      
      -- Missile velocity in m/s.
      local missileVelocity=UTILS.VecNorm(_ordnance:getVelocity())
      
      if missile.targetUnit then
        -----------------------------------
        -- Missile has a specific target --
        -----------------------------------
      
        if missile.targetPlayer then
          -- Target is a player.
          if missile.targetPlayer.destroy==true then
            target=missile.targetUnit
          end
        else
          --TODO: Check if unit is protected.
        end
        
      else
      
        ------------------------------------
        -- Missile has NO specific target --
        ------------------------------------       
        
        -- Distance to closest player.
        local mindist=nil
        
        -- Loop over players.
        for _,_player in pairs(self.players) do
          local player=_player  --#FOX.PlayerData
          
          -- Check that player was not the one who launched the missile.
          if player.unitname~=missile.shooterName then
          
            -- Player position.
            local playerCoord=player.unit:GetCoordinate()
            
            -- Distance.            
            local dist=missileCoord:Get3DDistance(playerCoord)
            
            -- Maxrange from launch point to player.
            local maxrange=playerCoord:Get3DDistance(missile.shotCoord)
            
            -- Update mindist if necessary. Only include players in range of missile.
            if (mindist==nil or dist<mindist) and dist<=maxrange then
              mindist=dist
              target=player.unit
            end
          end            
        end
        
      end
  
      -- Check if missile has a valid target.
      if target then
      
        -- Target coordinate.
        local targetCoord=target:GetCoordinate()
      
        -- Distance from missile to target.
        local distance=missileCoord:Get3DDistance(targetCoord)
        
        local bearing=targetCoord:HeadingTo(missileCoord)
        local eta=distance/missileVelocity
        
        self:T2(self.lid..string.format("Distance = %.1f m, v=%.1f m/s, bearing=%03d°, eta=%.1f sec", distance, missileVelocity, bearing, eta))
      
        -- If missile is 100 m from target ==> destroy missile if in safe zone.
        if distance<=self.explosiondist and self:_CheckCoordSafe(targetCoord)then
        
          -- Destroy missile.
          self:T(self.lid..string.format("Destroying missile at distance %.1f m", distance))
          _ordnance:destroy()
          
          -- Little explosion for the visual effect.
          missileCoord:Explosion(self.explosionpower)
          
          local text=string.format("Destroying missile. %s", self:_DeadText())
          MESSAGE:New(text, 10):ToGroup(target:GetGroup())
          
          -- Terminate timer.
          return nil
        else
        
          -- Time step.
          local dt=1.0          
          if distance>50000 then
            -- > 50 km
            dt=self.dt50 --=5.0
          elseif distance>10000 then
            -- 10-50 km
            dt=self.dt10 --=1.0
          elseif distance>5000 then
            -- 5-10 km
            dt=self.dt05 --0.5
          elseif distance>1000 then
            -- 1-5 km
            dt=self.dt01 --0.1
          else
            -- < 1 km
            dt=self.dt00 --0.01
          end
        
          -- Check again in dt seconds.
          return timer.getTime()+dt
        end
      else
      
        -- No target ==> terminate timer.
        return nil
      end
      
    else
    
      -------------------------------------
      -- Missile does not exist any more --
      -------------------------------------
            
      if target then  
      
        -- Get human player.
        local player=self:_GetPlayerFromUnit(target)
        
        -- Check for player and distance < 10 km.
        if player and player.unit:IsAlive() then -- and missileCoord and player.unit:GetCoordinate():Get3DDistance(missileCoord)<10*1000 then
          local text=string.format("Missile defeated. Well done, %s!", player.name)
          MESSAGE:New(text, 10):ToClient(player.client)
        end
        
      end
      
      -- Missile is not active any more.
      missile.active=false   
              
      --Terminate the timer.
      self:T(FOX.lid..string.format("Terminating missile track timer."))
      return nil
  
    end -- _status check
    
  end -- end function trackBomb
  
  -- Weapon is not yet "alife" just yet. Start timer with a little delay.
  self:T(FOX.lid..string.format("Tracking of missile starts in 0.1 seconds."))
  timer.scheduleFunction(trackMissile, missile.weapon, timer.getTime()+0.0001)

end

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Event Functions
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- FOX event handler for event birth.
-- @param #FOX self
-- @param Core.Event#EVENTDATA EventData
function FOX:OnEventBirth(EventData)
  self:F3({eventbirth = EventData})
  
  -- Nil checks.
  if EventData==nil then
    self:E(self.lid.."ERROR: EventData=nil in event BIRTH!")
    self:E(EventData)
    return
  end
  if EventData.IniUnit==nil then
    self:E(self.lid.."ERROR: EventData.IniUnit=nil in event BIRTH!")
    self:E(EventData)
    return
  end  
  
  -- Player unit and name.
  local _unitName=EventData.IniUnitName
  local playerunit, playername=self:_GetPlayerUnitAndName(_unitName)
  
  -- Debug info.
  self:T(self.lid.."BIRTH: unit   = "..tostring(EventData.IniUnitName))
  self:T(self.lid.."BIRTH: group  = "..tostring(EventData.IniGroupName))
  self:T(self.lid.."BIRTH: player = "..tostring(playername))
      
  -- Check if player entered.
  if playerunit and playername then
  
    local _uid=playerunit:GetID()
    local _group=playerunit:GetGroup()
    local _callsign=playerunit:GetCallsign()
    
    -- Debug output.
    local text=string.format("Pilot %s, callsign %s entered unit %s of group %s.", playername, _callsign, _unitName, _group:GetName())
    self:T(self.lid..text)
    MESSAGE:New(text, 5):ToAllIf(self.Debug)
            
    -- Add Menu commands.
    --self:_AddF10Commands(_unitName)
    SCHEDULER:New(nil, self._AddF10Commands, {self,_unitName}, 0.1)
    
    -- Player data.
    local playerData={} --#FOX.PlayerData
    
    -- Player unit, client and callsign.
    playerData.unit      = playerunit
    playerData.unitname  = _unitName
    playerData.group     = _group
    playerData.groupname = _group:GetName()
    playerData.name      = playername
    playerData.callsign  = playerData.unit:GetCallsign()
    playerData.client    = CLIENT:FindByName(_unitName, nil, true)
    playerData.coalition = _group:GetCoalition()
    
    playerData.destroy=playerData.destroy or true
    playerData.launchalert=playerData.launchalert or true
    playerData.marklaunch=playerData.marklaunch or true
    
    playerData.defeated=playerData.defeated or 0
    playerData.dead=playerData.dead or 0
    
    -- Init player data.
    self.players[playername]=playerData
      
    -- Init player grades table if necessary.
    --self.playerscores[playername]=self.playerscores[playername] or {}    
    
  end 
end

--- FOX event handler for event shot (when a unit releases a rocket or bomb (but not a fast firing gun). 
-- @param #FOX self
-- @param Core.Event#EVENTDATA EventData
function FOX:OnEventShot(EventData)
  self:I({eventshot = EventData})
  
  if EventData.Weapon==nil then
    return
  end
  if EventData.IniDCSUnit==nil then
    return
  end
  
  -- Weapon data.
  local _weapon     = EventData.WeaponName
  local _target     = EventData.Weapon:getTarget()
  local _targetName = "unknown"
  local _targetUnit = nil --Wrapper.Unit#UNIT
  
  -- Weapon descriptor.
  local desc=EventData.Weapon:getDesc()
  self:E({desc=desc})
  
  -- Weapon category: 0=Shell, 1=Missile, 2=Rocket, 3=BOMB
  local weaponcategory=desc.category
  
  -- Missile category: 1=AAM, 2=SAM, 6=OTHER
  local missilecategory=desc.missileCategory
  
  local missilerange=nil
  if missilecategory then
    missilerange=desc.rangeMaxAltMax
  end
  
  -- Debug info.
  self:E(FOX.lid.."EVENT SHOT: FOX")
  self:E(FOX.lid..string.format("EVENT SHOT: Ini unit     = %s", tostring(EventData.IniUnitName)))
  self:E(FOX.lid..string.format("EVENT SHOT: Ini group    = %s", tostring(EventData.IniGroupName)))
  self:E(FOX.lid..string.format("EVENT SHOT: Weapon type  = %s", tostring(_weapon)))
  self:E(FOX.lid..string.format("EVENT SHOT: Weapon categ = %s", tostring(weaponcategory)))
  self:E(FOX.lid..string.format("EVENT SHOT: Missil categ = %s", tostring(missilecategory)))
  self:E(FOX.lid..string.format("EVENT SHOT: Missil range = %s", tostring(missilerange)))
  
  
  -- Check if fired in launch zone.
  if not self:_CheckCoordLaunch(EventData.IniUnit:GetCoordinate()) then
    self:T(self.lid.."Missile was not fired in launch zone. No tracking!")
    return
  end
  
  -- Get the target unit. Note if if _target is not nil, the unit can sometimes not be found!
  if _target then
    self:E({target=_target})
    --_targetName=Unit.getName(_target)
    --_targetUnit=UNIT:FindByName(_targetName)
    _targetUnit=UNIT:Find(_target)
  end
  self:E(FOX.lid..string.format("EVENT SHOT: Target name = %s", tostring(_targetName)))
    
  -- Track missiles of type AAM=1, SAM=2 or OTHER=6
  local _track = weaponcategory==1 and missilecategory and (missilecategory==1 or missilecategory==2 or missilecategory==6)
  
  -- Only track missiles
  if _track then
  
    local missile={} --#FOX.MissileData
    
    missile.active=true
    missile.weapon=EventData.weapon
    missile.missileType=_weapon
    missile.missileRange=missilerange
    missile.missileName=EventData.weapon:getName()
    missile.shooterUnit=EventData.IniUnit
    missile.shooterGroup=EventData.IniGroup
    missile.shooterCoalition=EventData.IniUnit:GetCoalition()
    missile.shooterName=EventData.IniUnitName
    missile.shotTime=timer.getAbsTime()
    missile.shotCoord=EventData.IniUnit:GetCoordinate()
    missile.targetUnit=_targetUnit
    missile.targetPlayer=self:_GetPlayerFromUnit(missile.targetUnit)
    
    -- TODO: or in protected set!
    if missile.targetPlayer then
    
      -- Add missile table.
      table.insert(self.missiles, missile)
      
      self:__MissileLaunch(0.1, missile)
      
    end
    
  end --if _track
  
end


-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- RADIO MENU Functions
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Add menu commands for player.
-- @param #FOX self
-- @param #string _unitName Name of player unit.
function FOX:_AddF10Commands(_unitName)
  self:F(_unitName)
  
  -- Get player unit and name.
  local _unit, playername = self:_GetPlayerUnitAndName(_unitName)
  
  -- Check for player unit.
  if _unit and playername then

    -- Get group and ID.
    local group=_unit:GetGroup()
    local gid=group:GetID()
      
    if group and gid then
  
      if not self.menuadded[gid] then
      
        -- Enable switch so we don't do this twice.
        self.menuadded[gid]=true
        
        -- Set menu root path.
        local _rootPath=nil
        if FOX.MenuF10Root then
          ------------------------
          -- MISSON LEVEL MENUE --
          ------------------------          
           
          -- F10/FOX/...
          _rootPath=FOX.MenuF10Root
         
        else
          ------------------------
          -- GROUP LEVEL MENUES --
          ------------------------
          
          -- Main F10 menu: F10/FOX/
          if FOX.MenuF10[gid]==nil then
            FOX.MenuF10[gid]=missionCommands.addSubMenuForGroup(gid, "FOX")
          end
          
          -- F10/FOX/...
          _rootPath=FOX.MenuF10[gid]
          
        end
        
        
        --------------------------------        
        -- F10/F<X> FOX/F1 Help
        --------------------------------
        local _helpPath=missionCommands.addSubMenuForGroup(gid, "Help", _rootPath)
        -- F10/FOX/F1 Help/
        --missionCommands.addCommandForGroup(gid, "Subtitles On/Off",    _helpPath, self._SubtitlesOnOff,      self, _unitName)   -- F7
        --missionCommands.addCommandForGroup(gid, "Trapsheet On/Off",    _helpPath, self._TrapsheetOnOff,      self, _unitName)   -- F8

        -------------------------
        -- F10/F<X> FOX/
        -------------------------
        
        missionCommands.addCommandForGroup(gid, "Launch Alerts On/Off",    _rootPath, self._ToggleLaunchAlert,     self, _unitName) -- F2
        missionCommands.addCommandForGroup(gid, "Destroy Missiles On/Off", _rootPath, self._ToggleDestroyMissiles, self, _unitName) -- F3
        
      end
    else
      self:E(self.lid..string.format("ERROR: Could not find group or group ID in AddF10Menu() function. Unit name: %s.", _unitName))
    end
  else
    self:E(self.lid..string.format("ERROR: Player unit does not exist in AddF10Menu() function. Unit name: %s.", _unitName))
  end

end


--- Turn player's launch alert on/off.
-- @param #FOX self
-- @param #string _unitname Name of the player unit.
function FOX:_MyStatus(_unitname)
  self:F2(_unitname)
  
  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Player data.  
    local playerData=self.players[playername]  --#FOX.PlayerData
    
    if playerData then
    
      local text=string.format("Status of player %s:", playerData.name)
      
      text=text..string.format("Destroy missiles: %s", playerData.destroy)
      text=text..string.format("Launch alert: %s", playerData.launchalert)
      text=text..string.format("Me target: %d", self:_GetTargetMissiles(playerData.unit))
      text=text..string.format("Am I safe? %s", self:_CheckCoordSafe(playerData.unit:GetCoordinate()))
    
    end
  end
end


--- Turn player's launch alert on/off.
-- @param #FOX self
-- @param #string _unitname Name of the player unit.
function FOX:_ToggleLaunchAlert(_unitname)
  self:F2(_unitname)
  
  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Player data.  
    local playerData=self.players[playername]  --#FOX.PlayerData
    
    if playerData then
    
      -- Invert state.
      playerData.launchalert=not playerData.launchalert
      
      -- Inform player.
      local text=""
      if playerData.launchalert==true then
        text=string.format("%s, missile launch alerts are now ENABLED.", playerData.name)
      else
        text=string.format("%s, missile launch alerts are now DISABLED.", playerData.name)
      end
      MESSAGE:New(text, 5):ToClient(playerData.client)
            
    end
  end
end

--- Turn player's 
-- @param #FOX self
-- @param #string _unitname Name of the player unit.
function FOX:_ToggleDestroyMissiles(_unitname)
  self:F2(_unitname)
  
  -- Get player unit and player name.
  local unit, playername = self:_GetPlayerUnitAndName(_unitname)
  
  -- Check if we have a player.
  if unit and playername then
  
    -- Player data.  
    local playerData=self.players[playername]  --#FOX.PlayerData
    
    if playerData then
    
      -- Invert state.
      playerData.destroy=not playerData.destroy
      
      -- Inform player.
      local text=""
      if playerData.destroy==true then
        text=string.format("%s, incoming missiles will be DESTROYED.", playerData.name)
      else
        text=string.format("%s, incoming missiles will NOT be DESTROYED.", playerData.name)
      end
      MESSAGE:New(text, 5):ToClient(playerData.client)
            
    end
  end
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Misc Functions
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--- Get a random text message in case you die.
-- @param #FOX self
-- @return #string Text in case you die.
function FOX:_DeadText()

  local texts={}
  texts[1]="You're dead!"
  texts[2]="Meet your maker!"
  texts[3]="Time to meet your maker!"
  texts[4]="Well, I guess that was it!"
  texts[5]="Bye, bye!"
  texts[6]="Cheers buddy, was nice knowing you!"
  
  local r=math.random(#texts)
  
  return texts[r]
end


--- Check if a coordinate lies within a safe training zone.
-- @param #FOX self
-- @param Core.Point#COORDINATE coord Coordinate to check.
-- @return #boolean True if safe.
function FOX:_CheckCoordSafe(coord)

  -- No safe zones defined ==> Everything is safe.
  if #self.safezones==0 then
    return true    
  end
  
  -- Loop over all zones.
  for _,_zone in pairs(self.safezones) do
    local zone=_zone --Core.Zone#ZONE
    local inzone=zone:IsCoordinateInZone(coord)
    if inzone then
      return true
    end
  end

  return false
end

--- Check if a coordinate lies within a launch zone.
-- @param #FOX self
-- @param Core.Point#COORDINATE coord Coordinate to check.
-- @return #boolean True if in launch zone.
function FOX:_CheckCoordLaunch(coord)

  -- No safe zones defined ==> Everything is safe.
  if #self.launchzones==0 then
    return true    
  end
  
  -- Loop over all zones.
  for _,_zone in pairs(self.launchzones) do
    local zone=_zone --Core.Zone#ZONE
    local inzone=zone:IsCoordinateInZone(coord)
    if inzone then
      return true
    end
  end

  return false
end

--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #FOX self
-- @param DCS#Weapon weapon The weapon.
-- @return #number Heading of weapon in degrees or -1.
function FOX:_GetWeapongHeading(weapon)

  if weapon and weapon:isExist() then
  
    local wp=weapon:getPosition()
  
    local wph = math.atan2(wp.x.z, wp.x.x)
    
    if wph < 0 then
      wph=wph+2*math.pi
    end
    
    wph=math.deg(wph)
    
    return wph
  end

  return -1
end

--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #FOX self
-- @param DCS#Weapon weapon The weapon.
-- @return #number Notching heading right, i.e. missile heading +90�
-- @return #number Notching heading left, i.e. missile heading -90�.
function FOX:_GetNotchingHeadings(weapon)

  if weapon then
  
    local hdg=self:_GetWeapongHeading(weapon)
    
    local hdg1=hdg+90
    if hdg1>360 then
      hdg1=hdg1-360
    end
    
    local hdg2=hdg-90
    if hdg2<0 then
      hdg2=hdg2+360
    end
  
    return hdg1, hdg2
  end  
  
  return nil, nil
end

--- Returns the player data from a unit name.
-- @param #FOX self
-- @param #string unitName Name of the unit.
-- @return #FOX.PlayerData Player data.
function FOX:_GetPlayerFromUnitname(unitName)

  for _,_player in pairs(self.players) do  
    local player=_player --#FOX.PlayerData
    
    if player.unitname==unitName then
      return player
    end
  end
  
  return nil
end

--- Retruns the player data from a unit.
-- @param #FOX self
-- @param Wrapper.Unit#UNIT unit
-- @return #FOX.PlayerData Player data.
function FOX:_GetPlayerFromUnit(unit)

  if unit and unit:IsAlive() then

    -- Name of the unit
    local unitname=unit:GetName()

    for _,_player in pairs(self.players) do  
      local player=_player --#FOX.PlayerData
      
      if player.unitname==unitname then
        return player
      end
    end

  end
  
  return nil
end

--- Returns the unit of a player and the player name. If the unit does not belong to a player, nil is returned. 
-- @param #FOX self
-- @param #string _unitName Name of the player unit.
-- @return Wrapper.Unit#UNIT Unit of player or nil.
-- @return #string Name of the player or nil.
function FOX:_GetPlayerUnitAndName(_unitName)
  self:F2(_unitName)

  if _unitName ~= nil then
    
    -- Get DCS unit from its name.
    local DCSunit=Unit.getByName(_unitName)
    
    if DCSunit then
    
      -- Get player name if any.
      local playername=DCSunit:getPlayerName()
      
      -- Unit object.
      local unit=UNIT:Find(DCSunit)
    
      -- Debug.
      self:T2({DCSunit=DCSunit, unit=unit, playername=playername})
      
      -- Check if enverything is there.
      if DCSunit and unit and playername then
        self:T(self.lid..string.format("Found DCS unit %s with player %s.", tostring(_unitName), tostring(playername)))
        return unit, playername
      end
      
    end
    
  end
  
  -- Return nil if we could not find a player.
  return nil,nil
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------