local RSGCore = exports['rsg-core']:GetCoreObject()
local isBusy = false

-- Alcohol system variables
local alcoholCount = 0
local effectActive = false

function loadAnimDict(dict, anim)
    while not HasAnimDictLoaded(dict) do Wait(0) RequestAnimDict(dict) end
    return dict
end

-- Principal thread to manage alcohol effects
CreateThread(function()
    while true do
        Wait(10)
        
        if alcoholCount > 0 then
            Wait(Config.AlcoholSystem.DecreaseInterval)
            alcoholCount = math.max(0, alcoholCount - Config.AlcoholSystem.DecreaseAmount)
            
            -- Pass out condition
            if alcoholCount > Config.AlcoholSystem.PassOutThreshold then
                lib.notify(Config.AlcoholEffects.PassOutNotification)
                
                -- Vomit 
                local dict = loadAnimDict('amb_misc@world_human_vomit@male_a@idle_b')
                TaskPlayAnim(cache.ped, dict, "idle_f", 8.0, -8.0, -1, 31, 0, true, 0, false, 0, false)
                RemoveAnimDict(dict)
                Wait(Config.AlcoholEffects.VomitDuration)
                
                ClearPedTasks(cache.ped)
                
                -- Sleeping + FX
                local dict2 = loadAnimDict('amb_rest@world_human_sleep_ground@arm@male_b@idle_b')
                TaskPlayAnim(cache.ped, dict2, 'idle_f', 8.0, -8.0, -1, 1, 0, true, false, false)
                RemoveAnimDict(dict2)
                
                Wait(Config.AlcoholEffects.SleepDuration)
                AnimpostfxPlay(Config.AlcoholEffects.PassOutEffect)
                DoScreenFadeOut(Config.AlcoholEffects.FadeOutDuration)
                Wait(Config.AlcoholEffects.FadeOutDuration)
                
                -- Smart wake up
                AnimpostfxPlay(Config.AlcoholEffects.WakeUpEffect)
                DoScreenFadeIn(Config.AlcoholEffects.FadeInDuration)
                Wait(Config.AlcoholEffects.FadeInDuration)
                
                alcoholCount = Config.AlcoholSystem.WakeUpLevel -- not at 0 to avoid immediate pass out again
                AnimpostfxStop(Config.AlcoholEffects.WakeUpEffect)
                ClearPedTasks(cache.ped)
                Citizen.InvokeNative(0x58F7DB5BD8FA2288, cache.ped)
                
                if effectActive then
                    AnimpostfxStop(Config.AlcoholEffects.DrunkEffectName)
                    effectActive = false
                end
                
                Citizen.InvokeNative(0x406CCF555B04FAD3, cache.ped, 1, 0.0)
                
            -- Drunk
            elseif alcoholCount > Config.AlcoholSystem.DrunkThreshold then
                Citizen.InvokeNative(0x406CCF555B04FAD3, cache.ped, 1, 0.95) -- drunk
                
                if not effectActive then
                    AnimpostfxPlay(Config.AlcoholEffects.DrunkEffectName)
                    effectActive = true
                    lib.notify(Config.AlcoholEffects.DrunkNotification)
                end
                Wait(2000)
                
            -- Sober
            else
                Citizen.InvokeNative(0x406CCF555B04FAD3, cache.ped, 1, 0.0) -- not drunk
                
                if effectActive then
                    AnimpostfxStop(Config.AlcoholEffects.DrunkEffectName)
                    effectActive = false
                    
                    if alcoholCount == 0 then
                        lib.notify(Config.AlcoholEffects.SoberNotification)
                    end
                end
                Wait(5000)
            end
        else
            Wait(2000)
        end
    end
end)

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
    TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Eat[itemName].item, 1)
    TriggerEvent('hud:client:UpdateHunger', LocalPlayer.state.hunger + Config.Consumables.Eat[itemName].hunger)
    TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + Config.Consumables.Eat[itemName].thirst)
    TriggerEvent('hud:client:RelieveStress', Config.Consumables.Eat[itemName].stress)
    TriggerEvent('rsg-consume:client:onConsume', Config.Consumables.Eat[itemName])
end)

-----------------------
-- drinking (Modifed for alcohol)
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
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
    
    -- Alcohol Level Management
    local drinkConfig = Config.Consumables.Drink[itemName]
    if drinkConfig.alcohol then
        local oldAlcohol = alcoholCount
        if drinkConfig.alcohol > 0 then
            alcoholCount = math.min(Config.AlcoholSystem.MaxAlcoholLevel, alcoholCount + drinkConfig.alcohol)
        else
            alcoholCount = math.max(0, alcoholCount + drinkConfig.alcohol) -- negative values reduce alcohol
        end
        
        -- -- Notification avec alcoolémie
        -- lib.notify({
        --     title = '🍺 ' .. itemName,
        --     description = itemName .. ' consommé\nAlcool: ' .. alcoholCount .. '/' .. Config.AlcoholSystem.DrunkThreshold,
        --     type = alcoholCount >= Config.AlcoholSystem.DrunkThreshold and 'warning' or 'inform',
        --     duration = 3000,
        --     position = 'bottom-right'
        -- })
    end
    
    TriggerServerEvent('rsg-consume:server:removeitem', drinkConfig.item, 1)
    TriggerEvent('hud:client:UpdateHunger', LocalPlayer.state.hunger + drinkConfig.hunger)
    TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + drinkConfig.thirst)
    TriggerEvent('hud:client:RelieveStress', drinkConfig.stress)
    TriggerEvent('rsg-consume:client:onConsume', drinkConfig)
end)

-- Debug command to check alcohol level
RegisterCommand('checkalcohol', function()
    print("Alcool: " .. alcoholCount .. "/" .. Config.AlcoholSystem.DrunkThreshold)
end, false)
-- Debug command to reset alcohol level
RegisterCommand('sobernow', function()
    alcoholCount = 0
    if effectActive then
        AnimpostfxStop(Config.AlcoholEffects.DrunkEffectName)
        effectActive = false
    end
    Citizen.InvokeNative(0x406CCF555B04FAD3, cache.ped, 1, 0.0)
    print("Force Sober")
end, false)

-------------------------
---- eating stew
-------------------------
RegisterNetEvent("rsg-consume:client:stew", function(itemName)
   if isBusy then
        return
   else
        isBusy = true
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
        TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Stew[itemName].item, 1)
        TriggerEvent('hud:client:UpdateHunger', LocalPlayer.state.hunger + Config.Consumables.Stew[itemName].hunger)
        TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + Config.Consumables.Stew[itemName].thirst)
        TriggerEvent('hud:client:RelieveStress', Config.Consumables.Stew[itemName].stress)
        TriggerEvent('rsg-consume:client:onConsume', Config.Consumables.Stew[itemName])
        isBusy = false
    end
end)

-------------------------
---- Hot Drinks
-------------------------
RegisterNetEvent("rsg-consume:client:drinkcoffee", function(itemName)
    if isBusy then
        return
    else
        isBusy = false
        sleep = 5000
        SetCurrentPedWeapon(PlayerPedId(), GetHashKey("weapon_unarmed"))
        local coffee = CreateObject("P_MUGCOFFEE01X", GetEntityCoords(PlayerPedId()), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, coffee, 0, "CTRL_cupFill", 1.0)
        TaskItemInteraction_2(PlayerPedId(), GetHashKey("CONSUMABLE_COFFEE"), coffee, GetHashKey("P_MUGCOFFEE01X_PH_R_HAND"), GetHashKey("DRINK_COFFEE_HOLD"), 1, 0, -1)
        TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Hotdrinks[itemName].item, 1)
        TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + Config.Consumables.Hotdrinks[itemName].thirst)
        TriggerEvent('hud:client:RelieveStress', Config.Consumables.Hotdrinks[itemName].stress)
        TriggerEvent('rsg-consume:client:onConsume', Config.Consumables.Hotdrinks[itemName])
        isBusy = true
    end
end)

-----------------------
-- eating canned food
-----------------------
RegisterNetEvent('rsg-consume:client:eatcanned', function(itemName)
    if isBusy then return end
    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    SetCurrentPedWeapon(cache.ped, GetHashKey("weapon_unarmed"))
    local pcoords = GetEntityCoords(cache.ped)
    local itemInHand = CreateObject(Config.Consumables.Eatcanned[itemName].propname, pcoords.x, pcoords.y, pcoords.z, true, false, false)
    AttachEntityToEntity(itemInHand, cache.ped, GetEntityBoneIndexByName(cache.ped, "SKEL_L_Finger00"), 0.10, -0.03, 0.02, 20.0, -70.0, -20.0, true, true, false, true, 1, true) -- changed bone, x,y,z pos, x,y,z rot
    if not IsPedOnMount(cache.ped) and not IsPedInAnyVehicle(cache.ped) and not IsPedUsingAnyScenario(cache.ped) then
        local dict = loadAnimDict('mech_inventory@eating@canned_food@cylinder@d8-2_h10-5')
        TaskPlayAnim(cache.ped, dict, 'left_hand', 5.0, 5.0, -1, 31, false, false, false)
        Wait(2750)
        ClearPedTasks(cache.ped)
    elseif IsPedOnMount(cache.ped) or IsPedUsingAnyScenario(cache.ped) then
        TaskItemInteraction(cache.ped, nil, GetHashKey("EAT_CANNED_FOOD_CYLINDER@D8-2_H10-5_QUICK_LEFT"), true, 0, 0)
        Wait(2750)
    end
    DetachEntity(itemInHand)
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
    TriggerServerEvent('rsg-consume:server:removeitem', Config.Consumables.Eatcanned[itemName].item, 1)
    TriggerEvent('hud:client:UpdateHunger', LocalPlayer.state.hunger + Config.Consumables.Eatcanned[itemName].hunger)
    TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + Config.Consumables.Eatcanned[itemName].thirst)
    TriggerEvent('hud:client:RelieveStress', Config.Consumables.Eatcanned[itemName].stress)
    TriggerEvent('rsg-consume:client:onConsume', Config.Consumables.Eatcanned[itemName])
end)
