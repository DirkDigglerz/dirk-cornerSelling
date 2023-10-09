currentLevels = {}

GetLevelFromXP = function(xp)
  print('Checking XP ', xp)
  local level = 1
  for k,v in pairs(Config.levels) do 
    local nextLevel = Config.levels[k+1]
    if (xp >= v.minXP) and (not nextLevel or xp < nextLevel.minXP) then 
      level = k
    end
  end
  return level
end

GetLevelInfo = function(level)
  return Config.levels[level]
end

GetPlayerLevelInfo = function(ply)
  local id = Core.Player.Id(ply)
  local xp = currentLevels[id] or 0
  local level = GetLevelFromXP(xp)
  return level, GetLevelInfo(level)
end

AddXP = function(ply, amount)
  local id = Core.Player.Id(ply)
  local currentXP = currentLevels[id] or 0
  local currentLevel = GetLevelFromXP(currentXP)
  local newXP = currentXP + amount
  local newLevel = GetLevelFromXP(newXP)
  if newLevel > currentLevel then 
    Core.UI.Notify(ply, "You are now a "..Config.levels[newLevel].label)
  else
    Core.UI.Notify(ply, "You have gained "..amount.." XP for corner-selling")
  end
  currentLevels[id] = newXP
  Core.Files.Save("cornerSaleLevels.json", currentLevels)
end

CreateThread(function() 
  while not Core do Wait(500); end 
  currentLevels = Core.Files.Load("cornerSaleLevels.json") or {}

  Core.Callback("Dirk-CornerSell:MakeSale", function(src,cb, zone)
    --## Check what they have to sell 
    local inv = Core.Player.Inventory(src)
    local amountToSell = 0
    local myLevel, myLevelInfo = GetPlayerLevelInfo(src)
    local thisZone = Config.sellZones[zone]
    for k,v in pairs(inv) do 
      if Config.drugs[v.name] and amountToSell < Config.maxDrugsPerSale then 
        local randomAmount = math.random(Config.drugs[v.name].amount[1], Config.drugs[v.name].amount[2])
        local zoneQuantModif = thisZone.quantityModifier * randomAmount
        local levelQuantModif = myLevelInfo.quantityModifier * randomAmount
        randomAmount = math.floor(randomAmount + zoneQuantModif + levelQuantModif)
        print('This is the new random amount because of level and zone modifiers', randomAmount)
        local randomPrice = math.random(Config.drugs[v.name].price[1], Config.drugs[v.name].price[2])
        local zonePriceModif = thisZone.priceModifier * randomPrice
        local levelPriceModif = myLevelInfo.priceModifier * randomPrice
        randomPrice = math.floor(randomPrice + zonePriceModif + levelPriceModif)
        print('This is the new random price because of level and zone modifiers', randomPrice)
        local thisSale = {
          name = v.name,
          amount = randomAmount <= v.count and randomAmount or v.count,
          price  = randomPrice,
        }
        Core.Player.RemoveItem(src, v.name, thisSale.amount)
        Core.Player.AddMoney(src, Config.dealerAccount, thisSale.price * thisSale.amount)
        amountToSell = amountToSell + 1
        AddXP(src, Config.drugs[v.name].xpPerDrug * thisSale.amount)
        Core.UI.Notify(src, "You sold "..thisSale.amount.." "..Config.drugs[v.name].label.." for $"..thisSale.price * thisSale.amount)
      end
    end
    if amountToSell > 0  then return cb(true); end
    if amountToSell == 0 then return cb(false), Core.UI.Notify(src, "You have nothing to sell"); end 
  end)
end) 


RegisterCommand("TestAddXP", function(source,args)
  AddXP(source, tonumber(args[1]))
end)

RegisterCommand("CornerSell:CheckLevel", function(source,args)
  local id = Core.Player.Id(source)
  local xp = currentLevels[id] or 0
  local level = GetLevelFromXP(xp)
  local levelInfo = GetLevelInfo(level)
  Core.UI.Notify(source,"Your XP is "..xp)
  Core.UI.Notify(source,"Your level is "..level)
  Core.UI.Notify(source,"Your level name is "..levelInfo.label)
end)


