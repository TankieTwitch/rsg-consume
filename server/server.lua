-- =========================================================================================
-- Server-side event registration & item handling
-- =========================================================================================
local config = require 'config'
---@type table
local RSGCore = exports['rsg-core']:GetCoreObject()

---Registers usable items on the server based on the configuration.
---@param category string The category of consumables (e.g., "Eat", "Drink").
---@param clientEvent string The client-side event to trigger when the item is used.
local function registerConsumables(category, clientEvent)
    if not config.Consumables[category] then return end

    for itemName, _ in pairs(config.Consumables[category]) do
        ---Registers a usable item.
        ---@param source number The source ID of the player who used the item.
        ---@param item table The item data.
        RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
            TriggerClientEvent(clientEvent, source, item.name)
        end)
    end
end

-- =========================================================================================
-- Registering Consumables
-- =========================================================================================

registerConsumables("Eat",       'rsg-consume:client:eat')
registerConsumables("Drink",     'rsg-consume:client:drink')
registerConsumables("Hotdrinks", 'rsg-consume:client:drinkcoffee')
registerConsumables("Stew",      'rsg-consume:client:stew')
registerConsumables("Eatcanned", 'rsg-consume:client:eatcanned')

-- =========================================================================================
-- Server Events
-- =========================================================================================

---Removes a consumed item from the player's inventory.
---@param item string The name of the item to remove.
---@param amount number The number of items to remove.
RegisterNetEvent('rsg-consume:server:removeitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player or not item or not amount then return end

    if Player.Functions.RemoveItem(item, amount) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)
    end
end)
