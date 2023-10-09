--## //
Config = {
  moneyObject      = "prop_cash_pile_02", --## Object to use when handing over money
  drugObject       = "prop_meth_bag_01", --## Object to use when handing over drugs
  dealerAccount    = "cash", --## Account to pay money to 
  minSpawnDist     = 5, --## Min distance from player to spawn
  maxSpawnDist     = 13, --## Max distance from player to spawn
  maxRoamDist      = 20, --## Max distance from initial command to roam around before it stops selling
  timeBetweenSales = {Min = 1, Max = 5}, --## In seconds how long between ped spawning
  pedModels = {"a_f_m_bevhills_01","a_f_m_bevhills_02"},
  maxDrugsPerSale = 2, --## Max different drugs per sale

  drugs = { 
    ['weed_skunk'] = {
      label       = "Skunk Weed", 
      price       = {15,45},
      amount      = {5,10},
      xpPerDrug   = 5,  
    }
  },

  levels = {
    [1] = {
      priceModifier    = 0.0, --## You will get 20% on top of 
      quantityModifier = 0.0, --## You will sell 20% more than the regular amount
      name  = "corner_boy",
      label = "Corner boy",
      minXP = 0,
    },
    [2] = {
      priceModifier    = 0.5, --## You will get 50% on top of 
      quantityModifier = 0.5, --## You will sell 50% more than the regular amount
      name             = "og",
      label            = "OG", 
      minXP            = 1000, 
    },
  },

  sellZones = {
    ['City'] = {
      priceModifier    = 0.2, --## You will get 20% more than the regular price
      quantityModifier = 0.3, --## You will sell 30% more drugs than the regular amount
      polyzone = {
        vector3(-2158.48, -512.93, 0.0),
        vector3(-1613.03, -1973.35, 0.0),
        vector3(-2110.00, -3167.14, 0.0),
        vector3(-952.42, -3894.32, 0.0),
        vector3(1483.94, -3458.01, 0.0),
        vector3(1702.12, -979.53, 0.0),
        vector3(1296.06, 456.65, 0.0),
        vector3(156.67, 1117.17, 0.0),
        vector3(-2031.21, 1062.63, 0.0),
        vector3(-2764.54, -185.69, 0.0),
      }
    },
  },
}
 
Core, Settings = exports['dirk-core']:getCore(); 
