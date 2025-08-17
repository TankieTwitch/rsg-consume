local config = require 'shared'
---@type table
local isBusy = false
---@type number
local alcoholCount = 0
---@type boolean
local effectActive = false

-- =========================================================================================
-- Helper Functions
-- =========================================================================================

---Gets the player's ped.
---@return number
local function getPed()
    return cache.ped or PlayerPedId()
end

---Plays an animation on a ped.
---@param ped number The ped to play the animation on.
---@param dict string The animation dictionary.
---@param anim string The animation name.
---@param flag number|nil The animation flag. (Default: 1)
---@param duration number|nil The duration of the animation. (Default: -1 for infinite)
local function playAnim(ped, dict, anim, flag, duration)
    lib.requestAnimDict(dict)
    TaskPlayAnim(ped, dict, anim, 8.0, -8.0, duration or -1, flag or 1, 0, true, false, false)
    RemoveAnimDict(dict)
end

---Applies a post-process effect.
---@param effectName string The name of the effect to apply.
local function applyEffect(effectName)
    if effectName then AnimpostfxPlay(effectName) end
end

---Stops a post-process effect.
---@param effectName string The name of the effect to stop.
local function stopEffect(effectName)
    if effectName then AnimpostfxStop(effectName) end
end

---Sets the ped's drunk level for the wobbly walk style.
---@param ped number The ped to apply the effect to.
---@param level number The drunk effect level (0.0 to 1.0).
local function setDrunkEffect(ped, level)
    Citizen.InvokeNative(0x406CCF555B04FAD3, ped, 1, level)
end

---Creates and attaches a prop to a ped's bone.
---@param ped number The ped to attach the prop to.
---@param propName string The name of the prop model.
---@param boneName string The name of the bone to attach to.
---@param x number X offset.
---@param y number Y offset.
---@param z number Z offset.
---@param rotX number X rotation.
---@param rotY number Y rotation.
---@param rotZ number Z rotation.
---@return number The created prop object.
local function attachProp(ped, propName, boneName, x, y, z, rotX, rotY, rotZ)
    local coords = GetEntityCoords(ped)
    local prop = CreateObject(propName, coords.x, coords.y, coords.z, true, false, false)
    AttachEntityToEntity(
        prop, ped, GetEntityBoneIndexByName(ped, boneName),
        x, y, z, rotX, rotY, rotZ,
        true, true, false, true, 1, true
    )
    return prop
end

---Safely deletes an object, ensuring it exists first.
---@param obj number The object handle to delete.
local function safeDelete(obj)
    if DoesEntityExist(obj) then
        DetachEntity(obj, true, true)
        DeleteObject(obj)
    end
end

-- =========================================================================================
-- Alcohol System
-- =========================================================================================

---Handles the full pass-out sequence for the player.
---@param ped number The player ped.
local function handlePassOut(ped)
    lib.notify(config.AlcoholEffects.PassOutNotification)

    playAnim(ped, 'amb_misc@world_human_vomit@male_a@idle_b', 'idle_f', 31, config.AlcoholEffects.VomitDuration)
    ClearPedTasks(ped)

    playAnim(ped, 'amb_rest@world_human_sleep_ground@arm@male_b@idle_b', 'idle_f', 1, config.AlcoholEffects.SleepDuration)

    applyEffect(config.AlcoholEffects.PassOutEffect)
    DoScreenFadeOut(config.AlcoholEffects.FadeOutDuration)
    Wait(config.AlcoholEffects.FadeOutDuration)

    ClearPedTasks(ped)
    Citizen.InvokeNative(0x58F7DB5BD8FA2288, ped)

    alcoholCount = 0
    applyEffect(config.AlcoholEffects.GroggyEffectName)
    setDrunkEffect(ped, 0.95)

    applyEffect(config.AlcoholEffects.WakeUpEffect)
    DoScreenFadeIn(config.AlcoholEffects.FadeInDuration)
    Wait(config.AlcoholEffects.FadeInDuration)
    stopEffect(config.AlcoholEffects.WakeUpEffect)
    lib.notify(config.AlcoholEffects.WakeUpNotification)

    Wait(config.AlcoholEffects.GroggyDuration)
    stopEffect(config.AlcoholEffects.GroggyEffectName)
    setDrunkEffect(ped, 0.0)

    if effectActive then
        stopEffect(config.AlcoholEffects.DrunkEffectName)
        effectActive = false
    end

    lib.notify(config.AlcoholEffects.SoberNotification)
end

---Applies drunk effects to the ped.
---@param ped number The player ped.
local function handleDrunk(ped)
    setDrunkEffect(ped, 0.95)
    if not effectActive then
        applyEffect(config.AlcoholEffects.DrunkEffectName)
        effectActive = true
        lib.notify(config.AlcoholEffects.DrunkNotification)
    end
end

---Stops drunk effects and makes the ped sober.
---@param ped number The player ped.
local function handleSober(ped)
    setDrunkEffect(ped, 0.0)
    if effectActive then
        stopEffect(config.AlcoholEffects.DrunkEffectName)
        effectActive = false
        lib.notify(config.AlcoholEffects.SoberNotification)
    end
end

CreateThread(function()
    while true do
        local ped = getPed()
        if alcoholCount > 0 then
            Wait(config.AlcoholSystem.DecreaseInterval)
            alcoholCount = math.max(0, alcoholCount - config.AlcoholSystem.DecreaseAmount)

            if alcoholCount > config.AlcoholSystem.PassOutThreshold then
                handlePassOut(ped)
            elseif alcoholCount > config.AlcoholSystem.DrunkThreshold then
                handleDrunk(ped)
            else
                handleSober(ped)
            end
        else
            Wait(2000)
        end
    end
end)

-- =========================================================================================
-- Generic Consumption Handler
-- =========================================================================================

---Handles the full consumption sequence for any item.
---@param itemName string The name of the item being consumed (key in config.Consumables).
---@param type "Eat"|"Drink"|"Stew"|"Hotdrinks"|"Eatcanned" The type of consumable.
local function handleConsumption(itemName, type)
    if isBusy or not config.Consumables[type][itemName] then return end

    local ped = getPed()
    local data = config.Consumables[type][itemName]

    isBusy = true
    LocalPlayer.state:set("inv_busy", true, true)
    SetCurrentPedWeapon(ped, `WEAPON_UNARMED`)

    local prop, prop2
    local taskDuration = 4000

    if type == "Eat" then
        prop = attachProp(ped, data.propname, "SKEL_L_Finger01", 0.04, -0.03, -0.01, 0.0, 19.0, 46.0)
        playAnim(ped, 'mech_inventory@eating@multi_bite@sphere_d8-2_sandwich', 'quick_left_hand', 31, -1)
        taskDuration = 5000

    elseif type == "Drink" then
        prop = attachProp(ped, data.propname, "PH_R_HAND", 0.0, 0.0, 0.04, 0.0, 0.0, 0.0)
        if not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) then
            playAnim(ped, 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5', 'uncork', 31, 500)
            playAnim(ped, 'mech_inventory@drinking@bottle_cylinder_d1-3_h30-5_neck_a13_b2-5', 'chug_a', 31, -1)
            taskDuration = 5000
        else
            TaskItemInteraction_2(ped, 1737033966, prop, `p_bottleJD01x_ph_r_hand`, `DRINK_Bottle_Cylinder_d1-55_H18_Neck_A8_B1-8_QUICK_RIGHT_HAND`, true, 0, 0)
            taskDuration = 4000
        end

    elseif type == "Stew" then
        prop = CreateObject(`p_bowl04x_stew`, GetEntityCoords(ped), true, true, false, false, true)
        prop2 = CreateObject(`p_spoon01x`, GetEntityCoords(ped), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, prop, 0, "Stew_Fill", 1.0)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, prop, 20)
        Citizen.InvokeNative(0xCAAF2BCCFEF37F77, prop2, 82)
        TaskItemInteraction_2(ped, 599184882, prop, `p_bowl04x_stew_ph_l_hand`, -583731576, 1, 0, 0.0)
        TaskItemInteraction_2(ped, 599184882, prop2, `p_spoon01x_ph_r_hand`, -583731576, 1, 0, 0.0)
        Citizen.InvokeNative(0xB35370D5353995CB, ped, -583731576, 1.0)
        taskDuration = 5000

    elseif type == "Hotdrinks" then
        prop = CreateObject(`P_MUGCOFFEE01X`, GetEntityCoords(ped), true, true, false, false, true)
        Citizen.InvokeNative(0x669655FFB29EF1A9, prop, 0, "CTRL_cupFill", 1.0)
        TaskItemInteraction_2(ped, `CONSUMABLE_COFFEE`, prop, `P_MUGCOFFEE01X_PH_R_HAND`, `DRINK_COFFEE_HOLD`, 1, 0, -1)
        taskDuration = 5000

    elseif type == "Eatcanned" then
        prop = attachProp(ped, data.propname, "SKEL_L_Finger00", 0.10, -0.03, 0.02, 20.0, -70.0)
    elseif type == "Eatcanned" then
        prop = attachProp(ped, data.propname, "SKEL_L_Finger00", 0.10, -0.03, 0.02, 20.0, -70.0, -20.0)
        if not IsPedOnMount(ped) and not IsPedInAnyVehicle(ped) and not IsPedUsingAnyScenario(ped) then
            playAnim(ped, 'mech_inventory@eating@canned_food@cylinder@d8-2_h10-5', 'left_hand', 31, -1)
            taskDuration = 2750
        else
            TaskItemInteraction(ped, nil, `EAT_CANNED_FOOD_CYLINDER@D8-2_H10-5_QUICK_LEFT`, true, 0, 0)
            taskDuration = 2750
        end
    end

    Wait(taskDuration)
    ClearPedTasks(ped)
    safeDelete(prop)
    safeDelete(prop2)

    if data.alcohol then
        if data.alcohol > 0 then
            alcoholCount = math.min(config.AlcoholSystem.MaxAlcoholLevel, alcoholCount + data.alcohol)
        else
            alcoholCount = math.max(0, alcoholCount + data.alcohol)
        end
    end
    TriggerServerEvent('rsg-consume:server:removeitem', data.item, 1)
    if data.hunger then
        TriggerEvent('hud:client:UpdateHunger', LocalPlayer.state.hunger + data.hunger)
    end
    if data.thirst then
        TriggerEvent('hud:client:UpdateThirst', LocalPlayer.state.thirst + data.thirst)
    end
    if data.stress and data.stress > 0 then
        TriggerEvent('hud:client:RelieveStress', data.stress)
    end
    TriggerEvent('rsg-consume:client:onConsume', data)
    LocalPlayer.state:set("inv_busy", false, true)
    isBusy = false
end

-- =========================================================================================
-- Event bindings
-- =========================================================================================

---Consumes a food item.
---@param itemName string The name of the food item.
RegisterNetEvent('rsg-consume:client:eat', function(itemName)
    handleConsumption(itemName, "Eat")
end)

---Consumes a drink item.
---@param itemName string The name of the drink item.
RegisterNetEvent('rsg-consume:client:drink', function(itemName)
    handleConsumption(itemName, "Drink")
end)

---Consumes a stew.
---@param itemName string The name of the stew item.
RegisterNetEvent('rsg-consume:client:stew', function(itemName)
    handleConsumption(itemName, "Stew")
end)

---Consumes a hot drink (e.g., coffee).
---@param itemName string The name of the hot drink item.
RegisterNetEvent('rsg-consume:client:drinkcoffee', function(itemName)
    handleConsumption(itemName, "Hotdrinks")
end)

---Consumes a canned food item.
---@param itemName string The name of the canned food item.
RegisterNetEvent('rsg-consume:client:eatcanned', function(itemName)
    handleConsumption(itemName, "Eatcanned")
end)
