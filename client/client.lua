local RSGCore = exports['rsg-core']:GetCoreObject()
local isBusy = false

function loadAnimDict(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

-----------------------
-- eating
-----------------------
RegisterNetEvent('rsg-consume:client:eat', function(itemName)
    if isBusy then return end
    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    SetCurrentPedWeapon(cache.ped, GetHashKey("weapon_unarmed"))
    local pcoords = GetEntityCoords(cache.ped)
    itemInHand = CreateObject(Config.Consumables.Eat[itemName].propname, pcoords.x, pcoords.y, pcoords.z, true, false, false)
    AttachEntityToEntity(itemInHand, cache.ped, GetEntityBoneIndexByName(cache.ped, "SKEL_L_Finger01"), 0.04, -0.03, -0.01, 0.0, 19.0, 46.0, true, true, false, true, 1, true)
    if not IsPedOnMount(cache.ped) and not IsPedInAnyVehicle(cache.ped) and not IsPedUsingAnyScenario(cache.ped) then
        local dict = loadAnimDict('mech_inventory@eating@multi_bite@sphere_d8-2_sandwich')
        TaskPlayAnim(cache.ped, dict, 'quick_left_hand', 5.0, 5.0, -1, 31, false, false, false)
        Wait(5000)
        ClearPedTasks(cache.ped)
    elseif IsPedOnMount(cache.ped) or IsPedUsingAnyScenario(cache.ped) then
        TaskItemInteraction(cache.ped, nil, GetHashKey("EAT_MULTI_BITE_FOOD_SPHERE_D8-2_SANDWICH_QUICK_LEFT_HAND"), true, 0, 0)
        Wait(4000)
    end
    DeleteObject(itemInHand)
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
    TriggerServerEvent('rsg-consume:server:addHunger', RSGCore.Functions.GetPlayerData().metadata.hunger + Config.Consumables.Eat[itemName].hunger)
    TriggerServerEvent('rsg-consume:server:addThirst', RSGCore.Functions.GetPlayerData().metadata.thirst + Config.Consumables.Eat[itemName].thirst)
    TriggerServerEvent('hud:server:RelieveStress', Config.Consumables.Eat[itemName].stress)
    TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Eat[itemName].item, 1)
end)

-----------------------
-- drinking
-----------------------
RegisterNetEvent('rsg-consume:client:drink', function(itemName)
    if isBusy then return end
    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    SetCurrentPedWeapon(cache.ped, GetHashKey("weapon_unarmed"))
    local pcoords = GetEntityCoords(cache.ped)
    local hcoords = GetEntityHeading(cache.ped)
    itemInHand = CreateObject(Config.Consumables.Drink[itemName].propname, pcoords.x, pcoords.y, pcoords.z, true, false, false)
    AttachEntityToEntity(itemInHand, cache.ped, GetEntityBoneIndexByName(cache.ped, "PH_R_HAND"), 0.00, 0.00, 0.04, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    if not IsPedOnMount(cache.ped) and not IsPedInAnyVehicle(cache.ped) and not IsPedUsingAnyScenario(cache.ped) then
        local dict = loadAnimDict('mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5')
        TaskPlayAnim(cache.ped, dict, 'uncork', 5.0, 5.0, -1, 31, false, false, false)
        Wait(500)
        local dict = loadAnimDict('mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5')
        TaskPlayAnim(cache.ped, dict, 'chug_a', 5.0, 5.0, -1, 31, false, false, false)
        Wait(5000)
        ClearPedTasks(cache.ped)
    elseif IsPedOnMount(cache.ped) or IsPedUsingAnyScenario(cache.ped) then
        TaskItemInteraction_2(cache.ped, 1737033966, itemInHand, GetHashKey("p_bottleJD01x_ph_r_hand"), GetHashKey("DRINK_Bottle_Cylinder_d1-55_H18_Neck_A8_B1-8_QUICK_RIGHT_HAND"), true, 0, 0)
        Citizen.InvokeNative(0x2208438012482A1A, cache.ped, true, true)
        Wait(4000)
    end
    DeleteObject(itemInHand)
    TriggerServerEvent('rsg-consume:server:addHunger', RSGCore.Functions.GetPlayerData().metadata.hunger + Config.Consumables.Drink[itemName].hunger)
    TriggerServerEvent('rsg-consume:server:addThirst', RSGCore.Functions.GetPlayerData().metadata.thirst + Config.Consumables.Drink[itemName].thirst)
    TriggerServerEvent('hud:server:RelieveStress', Config.Consumables.Drink[itemName].stress)
    TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Drink[itemName].item, 1)
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
end)

-------------------------
---- eating stew
-------------------------
RegisterNetEvent("rsg-consume:client:stew", function(itemName)
   if isBusy then
        return
   else
        isBusy = not isBusy
        sleep = 5000
        SetCurrentPedWeapon(cache.ped, GetHashKey("weapon_unarmed"))
        local bowl = CreateObject("p_bowl04x_stew", GetEntityCoords(cache.ped), true, true, false, false, true)
        local spoon = CreateObject("p_spoon01x", GetEntityCoords(cache.ped), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, bowl, 0, "Stew_Fill", 1.0)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, bowl, 20)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, spoon, 82)
        TaskItemInteraction_2(cache.ped, 599184882, bowl, GetHashKey("p_bowl04x_stew_ph_l_hand"), -583731576, 1, 0, 0.0)
        TaskItemInteraction_2(cache.ped, 599184882, spoon, GetHashKey("p_spoon01x_ph_r_hand"), -583731576, 1, 0, 0.0)
        Citizen.InvokeNative(0xB35370D5353995CB, cache.ped, -583731576, 1.0)
        TriggerServerEvent('rsg-consume:server:addHunger', RSGCore.Functions.GetPlayerData().metadata.hunger + Config.Consumables.Stew[itemName].hunger)
        TriggerServerEvent('rsg-consume:server:addThirst', RSGCore.Functions.GetPlayerData().metadata.thirst + Config.Consumables.Stew[itemName].thirst)
        TriggerServerEvent('hud:server:RelieveStress', Config.Consumables.Stew[itemName].stress)
        TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Stew[itemName].item, 1)
        isBusy = not isBusy
    end
end)

-------------------------
---- Hot Drinks
-------------------------
RegisterNetEvent("rsg-consume:client:drinkcoffee", function(itemName)
    if isBusy then
        return
    else
        isBusy = not isBusy
        sleep = 5000
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_unarmed"))
        local kopi = CreateObject("P_MUGCOFFEE01X", GetEntityCoords(PlayerPedId()), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, kopi, 0, "CTRL_cupFill", 1.0)
        TaskItemInteraction_2(PlayerPedId(), GetHashKey("CONSUMABLE_COFFEE"), kopi, GetHashKey("P_MUGCOFFEE01X_PH_R_HAND"), GetHashKey("DRINK_COFFEE_HOLD"), 1, 0, -1)
        TriggerServerEvent("RSGCore:Server:SetMetaData", "thirst", RSGCore.Functions.GetPlayerData().metadata.thirst + Config.Consumables.Hotdrinks[itemName].thirst)
        TriggerServerEvent('hud:server:RelieveStress', math.random(10, 20))
        TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Hotdrinks[itemName].item, 1)
       
        isBusy = not isBusy
    end
end)
