CreateThread(function() 
  while not Core do Wait(500); end 
  while not Core.Player.Ready() do Wait(500); end 
end) 

local cornerSelling = false
local inSale        = false
CornerSell = function()
  if cornerSelling then return Core.UI.Notify("You are already selling..."); end 
  startPos      = GetEntityCoords(PlayerPedId())
  local thisZone = false
  for k,v in pairs(Config.sellZones) do 
    if Core.Zones.IsPointInside(startPos, v.polyzone) then 
      thisZone = k
    end
  end
  if not thisZone then return Core.UI.Notify("You are not in a selling zone"); end
  cornerSelling = true 
  inSale        = false
  timeUntilNext = math.random(Config.timeBetweenSales.Min, Config.timeBetweenSales.Max) * 1000

  local start_time = GetGameTimer()
  print('Starting loop')
  Core.UI.Notify("You have begun corner selling")
  while cornerSelling do 
    local wait_time = 1000
    local now = GetGameTimer()
    local pos = GetEntityCoords(PlayerPedId())
    if #(startPos - pos) >= Config.maxRoamDist then 
      cornerSelling = false
      local ped = Core.Objects.Get("cornerSalePed")
      if ped then 
        ped.remove()
      end
      return Core.UI.Notify("You have moved too far away from your corner")
    end

    if (now - start_time) >= timeUntilNext and not inSale then 
      inSale = true
      local ply = PlayerPedId()
      local randoX, randoY = math.random(Config.minSpawnDist, Config.maxSpawnDist) * 1.0, math.random(Config.minSpawnDist, Config.maxSpawnDist) * 1.0
      local offset = GetOffsetFromEntityInWorldCoords(ply, randoX, randoY, 0.0)
      local model = Config.pedModels[math.random(1, #Config.pedModels)]

      Core.Objects.Register("cornerSalePed", {
        Type         = "ped",
        Pos          = offset,
        Network      = true, 
        Model        = model,
        InteractDist = ((not Settings.UsingTarget and 1.5) or false), 
        RenderDist   = 100.0, 
        },function(type, data)
        if type == "spawn" then 
          PlaceObjectOnGroundProperly(data.entity)
          SetBlockingOfNonTemporaryEvents(data.entity, true)
          SetEntityAsMissionEntity(data.entity, true, true)
          TaskGoToEntity(data.entity, ply, -1, 1.0, 10.0, 1073741824, 0)
          while true do 
            local entCoords = GetEntityCoords(data.entity)
            local plyCoords = GetEntityCoords(ply)
            local dist = #(entCoords - plyCoords)
            if dist <= 1.5 then 
           
              TaskTurnPedToFaceEntity(data.entity, ply, 1000)
              TaskTurnPedToFaceEntity(ply, data.entity, 1000)
              Wait(1000)
              FreezeEntityPosition(data.entity, true)
              FreezeEntityPosition(ply, true)
              print('Calling back for sale')
              Core.Callback("Dirk-CornerSell:MakeSale", function(madeSale)
                if madeSale then 
                  HandOver(ply, data.entity, Config.drugObject)
                  HandOver(data.entity, ply, Config.moneyObject)
                else
                  cornerSelling = false
                  Core.UI.Notify("You are no longer selling drugs")
                end
              
                FreezeEntityPosition(data.entity, false)
                FreezeEntityPosition(ply, false)
                SetEntityAsNoLongerNeeded(data.entity)
                SetTimeout(6000, function()
                  -- ClearPedTasks(ply)
                  if ped then 
                    DeleteEntity(ped.entity)
                  end
                  inSale = false
                  timeUntilNext = math.random(Config.timeBetweenSales.Min, Config.timeBetweenSales.Max) * 1000
                  start_time = GetGameTimer()
                end)
              end, thisZone)
              break
            end
            Wait(0)
          end
        end
      end)
    end
    Wait(wait_time)
  end
end


RegisterCommand("SellDrugs", CornerSell)


HandOver = function(ent,rec, object)
  FreezeEntityPosition(ent, false)
  FreezeEntityPosition(rec, false)
  TaskTurnPedToFaceEntity(rec, ent, -1)
  TaskTurnPedToFaceEntity(ent, rec, -1)
  while not IsPedFacingPed(rec,ent, 20.0) do Wait(0); end 
  while not IsPedFacingPed(ent,rec, 20.0) do Wait(0); end 
  Wait(500)
  local objectHash = GetHashKey(object)
  RequestAnimDict("mp_common")
  while not HasAnimDictLoaded("mp_common") do Wait(0); end
  RequestModel(objectHash)
  while not HasModelLoaded(objectHash) do Wait(0) end;
  local thisProp = CreateObject(objectHash, GetEntityCoords(ent), true, true) 
  Wait(100)
  AttachEntityToEntity(thisProp, ent, GetPedBoneIndex(ent, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
  TaskPlayAnim(ent, "mp_common", 'givetake1_b', 8.0, 8.0, -1, 2, true,true,true)
  TaskPlayAnim(rec, "mp_common", 'givetake1_a', 8.0, 8.0, -1, 2, true,true,true)
  Wait(1000)
  DetachEntity(thisProp,false,false)
  AttachEntityToEntity(thisProp,rec, GetPedBoneIndex(rec, 28422), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
  Wait(500)
  ClearPedTasksImmediately(rec)
  ClearPedTasksImmediately(ent)
  DeleteEntity(thisProp)
end

RegisterCommand("getRandoPos", function()
  local ply = PlayerPedId()
  local randoX, randoY = math.random(Config.minSpawnDist, Config.maxSpawnDist) * 1.0, math.random(Config.minSpawnDist, Config.maxSpawnDist) * 1.0
  local offset = GetOffsetFromEntityInWorldCoords(ply, randoX, randoY, 0.0)
  while true do 
    DrawMarker(1, offset.x, offset.y, offset.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 5.0, 255, 0, 0, 100, false, true, 2, false, false, false, false)
    Wait(0)     
  end
end)

