local RSGCore = exports['rsg-core']:GetCoreObject()

local function registerConsumables(category, clientEvent)
    if not Config.Consumables[category] then return end

    for itemName, _ in pairs(Config.Consumables[category]) do
        RSGCore.Functions.CreateUseableItem(itemName, function(source, item)
            TriggerClientEvent(clientEvent, source, item.name)
        end)
    end
end


registerConsumables("Eat",       'rsg-consume:client:eat')
registerConsumables("Drink",     'rsg-consume:client:drink')
registerConsumables("Hotdrinks", 'rsg-consume:client:drinkcoffee')
registerConsumables("Stew",      'rsg-consume:client:stew')
registerConsumables("Eatcanned", 'rsg-consume:client:eatcanned')


RegisterNetEvent('rsg-consume:server:removeitem', function(item, amount)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    if not Player or not item or not amount then return end

    if Player.Functions.RemoveItem(item, amount) then
        TriggerClientEvent('rsg-inventory:client:ItemBox', src, RSGCore.Shared.Items[item], 'remove', amount)
    end
end)