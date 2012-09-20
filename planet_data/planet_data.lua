function guessSomBodyFullnameFromShortname(Shortname)
  -- added in v0.003
  --print("guessSomBodyFullnameFromShortname got shortname " .. Shortname)
  localFullName = "Unknown_Full_Name"
  if Shortname == "Kerbin" then
    return "KSP_Galaxy1_Kerbol_Kerbin"
  elseif Shortname == "Mun" then
    return "KSP_Galaxy1_Kerbol_Kerbin_Mun"
  elseif Shortname == "Minmus" then
    return "KSP_Galaxy1_Kerbol_Kerbin_Minmus"
  elseif Shortname == "Moho" then
    return "KSP_Galaxy1_Kerbol_Moho"
  elseif Shortname == "Eve" then
    return "KSP_Galaxy1_Kerbol_Eve"
  elseif Shortname == "Gilly" then
    return "KSP_Galaxy1_Kerbol_Eve_Gilly"
  elseif Shortname == "Duna" then
    return "KSP_Galaxy1_Kerbol_Duna"
  elseif Shortname == "Ike" then
    return "KSP_Galaxy1_Kerbol_Duna_Ike"
  elseif Shortname == "Jool" then
    return "KSP_Galaxy1_Kerbol_Jool"
  elseif Shortname == "Laythe" then
    return "KSP_Galaxy1_Kerbol_Jool_Laythe"
  elseif Shortname == "Vall" then
    return "KSP_Galaxy1_Kerbol_Jool_Vall"
  elseif Shortname == "Tylo" then
    return "KSP_Galaxy1_Kerbol_Jool_Tylo"
  elseif Shortname == "Bop" then
    return "KSP_Galaxy1_Kerbol_Jool_Bop"
  elseif Shortname == "Sun" then
    return "KSP_Galaxy1_Kerbol"
  elseif Shortname == nil then
    return nil
  end
end


  globalRadiansToDegreesMultiplier = 180/math.pi -- in pure units.  Multiply radians by this to get degrees.
  globalDegreesToRadiansMultiplier = 1/(180/math.pi) -- in pure units.  Multiply degrees by this to get radians.
  
  
  
function reportSkomKSPCurrentOrbitalElementsDegreesFromObt(Orbit)
  -- added in v0.003, variables renamed/updated in v0.004 and (orbit) passin added
  -- possible sources of Orbit:
  --   mechjeb.core.targetVessel.orbit (select target Vessel or Debris, NOT Bodies, in Rendevous Module GUI)
  --   mechjeb.core.targetBody.orbit (select target Celestial Body in Rendevous Module GUI)
  --   mechjeb.core.part.vessel.orbit (your own current vessel, but .name shows your craft name)
  --   mechjeb.core.part.orbit (your own current vessel, but .name shows mumech.mechjeb)
  --     local Orbits = script.call("Planetarium.Orbits")
  --     local i = 1
  --     for i = 1, 4 do
  --       
  --     end
  
  -- Simply returns a set of variables for other use.
  -- Apa is the Apoapsis from sea level in meters
  -- Apr is the Apoapsis from the center of the body (radius) in meters
  -- Pea is the Periapsis from sea level in meters
  -- Per is the Periapsis from the center of the body (radius) in meters
  -- Sop is the sidereal orbital period in seconds
  -- Tmtoap is the time to Apoapsis in seconds
  -- Tmtope is the time to Periapsis in seconds
  -- Lan is the Longitude of the Ascending Node in degrees
  -- Ape is the Argument of Periapsis in degrees
  -- Lpe is the Longitude of Periapsis in degrees
  -- Ma is the Mean Anomaly in degrees
  -- Maae is the Mean Anomaly at Epoch in degrees
  -- Ta is the True Anomaly in degrees
  -- Ea is the Eccentric Anomaly in degrees
  -- Epch is the Epoch in seconds since the start of the KSP universe (i.e. since time 0 in persistence.sfs or vessel.time, etc.)
  -- Strtut is the Start of UT in seconds... someone tell me what this is, please?
  -- Inc is the Inclination of the orbit in degrees
  -- Ecc is the eccentricity of the orbit
  -- a is the semi-major axis in meters
  -- Posvec3[1] is the position vector ?x? ??
  -- Posvec3[2] is the position vector ?y? ??
  -- Posvec3[3] is the position vector ?z? ??
  -- Velvec3[1] is the velocity vector ?x? ??
  -- Velvec3[2] is the velocity vector ?y? ??
  -- Velvec3[3] is the velocity vector ?z? ??
  -- l is the semi-latus rectum in meters
  -- Os is the ?? Unknown type does not match navball ?? orbital velocity in m/s
  -- Oe is the ?? Unknown ?? orbital energy in ??
  -- Altunk is the ?? Unknown type - not true, ASL, or bottom ?? altitude in meters
  -- Rfcb is the Radius From Central Body in meters, the distance in meters from the orbiting
  --   object to the center of gravity it's orbiting (i.e. the center of the planet)
  -- Obt is the ??
  -- Obtae is the ?? at epoch
  -- Sevp is the ??
  -- Sevs is the ??
  -- E is the ??
  -- V is the ??
  -- Frme is the ??
  -- Frmv is the ??
  -- Toe is the ??
  -- Tov is the ??
  -- Utappr is the ?? -- probably encounter related
  -- Utsoi is the ?? -- probably hill sphere of influence related
  -- Refbodnamefull is the fully qualified name of the body it's orbiting, i.e. Universe_Galaxy_Solarsystem_Planet_Moon, i.e. KSP_Galaxy1_Kerbol_Kerbin_Mun or RL_MilkyWay_Sol_Earth
  -- Refbodnameshort is the short name of the body its orbiting, i.e. "Mun" or "Jupiter"
  -- Clappr is the ?? -- probably encounter related
  -- Clectr1 is the ?? -- probably encounter related
  -- Clectr2 is the ?? -- probably encounter related
  -- Crappr is the ?? -- probably encounter related
  -- Eccvec3[1] is the ??
  -- Eccvec3[2] is the ??
  -- Eccvec3[3] is the ??
  -- Hvec3[1] is the ??
  -- Hvec3[2] is the ??
  -- Hvec3[3] is the ??
  -- Fevp is the ??
  -- Fevs is the ??
  -- mag is the ??
  -- Clsencbodynamefull is the fully qualified name of the closest encounter body, or nil
  -- Clsencbodynameshort is the fully qualified name of the closest encounter body, or nil
  -- TODO - a few more items, including next patch and previous patch.
  --[[ example:
    require "SimpleKSPOrbitalMechanics"
    do
      local Orbits = script.call("Planetarium.Orbits")
      local i = 1 -- planet
      local j = 1 -- moon
      local localApa, localApr, localPea, localPer, localSop, localTmtoap, localTmtope, localLan, localApe, localLpe, localMa, localMaae, localTa,
      localEa, localEpch, localInc, localEcc, locala, localStrtut, localEndut, localPosvec3, localVelvec3, locall, localOs, localOe, localAltunk, localRfcb,
      localObt, localObtae, localSevp, localSevs, localE, localV, localFrme, localFrmv, localToe, localTov, localUtappr, localUtsoi, localRefbodnamefull,
      localRefbodnameshort, localClappr, localClectr1, localClectr2, localCrappr, localEccvec3, localHvec3, localFevp, localFevs, localMag,
      localClsencbodynamefull, localClsencbodynameshort
-- these are for planets
--      = reportSkomKSPCurrentOrbitalElementsDegreesFromObt(Orbits[2].referenceBody.orbitingBodies[i].orbit)
      = reportSkomKSPCurrentOrbitalElementsDegreesFromObt(Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].orbit)
      --  = reportSkomKSPCurrentOrbitalElementsDegreesFromObt(mechjeb.core.part.vessel.orbit)
--      print("Nameshort " .. Orbits[2].referenceBody.orbitingBodies[i].name)
--      print("Namefull " .. guessSomBodyFullnameFromShortname(Orbits[2].referenceBody.orbitingBodies[i].name))
--      --print(Orbits[2].referenceBody.orbitingBodies[2].gravParameter .. " " .. Orbits[1].referenceBody.orbitingBodies[2].name)
--      print("Gm " .. Orbits[2].referenceBody.orbitingBodies[i].gravParameter)
--      print("Hsoi " .. Orbits[2].referenceBody.orbitingBodies[i].hillSphere)
--      print("Radius " .. Orbits[2].referenceBody.orbitingBodies[i].Radius)
--      --print("Rotates " .. Orbits[2].referenceBody.orbitingBodies[i].rotates)
--      print("RotationPeriod " .. Orbits[2].referenceBody.orbitingBodies[i].rotationPeriod)
--      print("Soi " .. Orbits[2].referenceBody.orbitingBodies[i].sphereOfInfluence)
      print("Nameshort " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].name)
      print("Namefull " .. guessSomBodyFullnameFromShortname(Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].name))
      print("Nameindex " .. i .. "," .. j)
      --print(Orbits[2].referenceBody.orbitingBodies[2].gravParameter .. " " .. Orbits[1].referenceBody.orbitingBodies[2].name)
      print("Gm " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].gravParameter)
      print("Hsoi " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].hillSphere)
      print("Radius " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].Radius)
      --print("Rotates " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].rotates)
      print("RotationPeriod " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].rotationPeriod)
      print("Soi " .. Orbits[2].referenceBody.orbitingBodies[i].orbitingBodies[j].sphereOfInfluence)

      print("Apa " .. localApa)
      print("Apr " .. localApr)
      print("Pea " .. localPea)
      print("Per " .. localPer)
      print("Sop " .. localSop)
      print("Tmtoap " .. localTmtoap)
      print("Tmtope " .. localTmtope)
      print("Lan " .. localLan)
      print("Ape " .. localApe)
      print("Lpe " .. localLpe)
      print("Ma " .. localMa)
      print("Ta " .. localTa)
      print("Ea " .. localEa)
      print("Maae " .. localMaae)
      print("Epch " .. localEpch)
      print("Inc " .. localInc)
      print("Ecc " .. localEcc)
      print("a " .. locala)
      print("Strtut " .. localStrtut)
      print("Endut " .. localEndut)
      print("Pos[1] " .. localPosvec3[1])
      print("Pos[2] " .. localPosvec3[2])
      print("Pos[3] " .. localPosvec3[3])
      print("Vel[1] " .. localVelvec3[1])
      print("Vel[2] " .. localVelvec3[2])
      print("Vel[3] " .. localVelvec3[3])
      print("l " .. locall)
      print("Os " .. localOs)
      print("Oe " .. localOe)
      print("Altunk " .. localAltunk)
      print("Rfcb " .. localRfcb)
      print("Obt " .. localObt)
      print("Obtae " .. localObtae)
      print("Sevp " .. localSevp)
      print("Sevs " .. localSevs)
      print("E " .. localE)
      print("V " .. localV)
      print("Frme " .. localFrme)
      print("Frmv " .. localFrmv)
      print("Toe " .. localToe)
      print("Tov " .. localTov)
      print("Utappr " .. localUtappr)
      print("Utsoi " .. localUtsoi)
      print("Refbodnamefull " .. localRefbodnamefull)
      print("Refbodnameshort " .. localRefbodnameshort)
      print("Clappr " .. localClappr)
      print("Clectr1 " .. localClectr1)
      print("Clectr2 " .. localClectr2)
      print("Crappr " .. localCrappr)
      print("Eccvec3[1] " .. localEccvec3[1])
      print("Eccvec3[2] " .. localEccvec3[2])
      print("Eccvec3[3] " .. localEccvec3[3])
      print("Hvec3[1] " .. localHvec3[1])
      print("Hvec3[2] " .. localHvec3[2])
      print("Hvec3[3] " .. localHvec3[3])
      print("Fevp " .. localFevp)
      print("Fevs " .. localFevs)
      print("Mag " .. localMag)
      if localClsencbodynamefull ~= nil then
        print("Clsencbodynamefull " .. localClsencbodynamefull)
        print("Clsencbodynameshort " .. localClsencbodynameshort)
      else
        print("Clsencbodynamefull nil")
        print("Clsencbodynameshort nil")
      end
    end
  ]]
  local localClosestEncounterBodyNameshort = nil
  if Orbit.closestEncounterBody ~= nil then
    localClosestEncounterBodyNameshort = Orbit.closestEncounterBody.name
  end
  return Orbit.ApA, Orbit.ApR, Orbit.PeA, Orbit.PeR, Orbit.period, Orbit.timeToAp, Orbit.timeToPe, Orbit.LAN, Orbit.argumentOfPeriapsis,
    calcSomLpeFromLanApe(Orbit.LAN, Orbit.argumentOfPeriapsis), (Orbit.meanAnomaly * globalRadiansToDegreesMultiplier),
    (Orbit.meanAnomalyAtEpoch * globalRadiansToDegreesMultiplier), Orbit.trueAnomaly, (Orbit.eccentricAnomaly * globalRadiansToDegreesMultiplier),
    Orbit.epoch, Orbit.inclination, Orbit.eccentricity,
    Orbit.semiMajorAxis, Orbit.StartUT, Orbit.EndUT, Orbit.pos, Orbit.vel, Orbit.semiLatusRectum, Orbit.orbitalSpeed, Orbit.orbitalEnergy,
    Orbit.altitude, Orbit.radius, Orbit.ObT, Orbit.ObTAtEpoch, Orbit.SEVp, Orbit.SEVs, Orbit.E, Orbit.V, Orbit.fromE, Orbit.fromV, Orbit.toE, Orbit.toV,
    Orbit.UTappr, Orbit.UTsoi, guessSomBodyFullnameFromShortname(Orbit.referenceBody.name), Orbit.referenceBody.name, Orbit.ClAppr, Orbit.ClEctr1, Orbit.ClEctr2, Orbit.CrAppr,
    Orbit.eccVec, Orbit.h, Orbit.FEVp, Orbit.FEVs, Orbit.mag, guessSomBodyFullnameFromShortname(localClosestEncounterBodyNameshort)
    localClosestEncounterBodyNameshort
    
end
