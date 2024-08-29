-- sv_storage.lua
local ESX = exports['es_extended']:getSharedObject()
local storageInventory = {}

ESX.RegisterServerCallback('vigneron:isEmployee', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.job.name == 'vigneron' then
        cb(true)
    else
        cb(false)
    end
end)

ESX.RegisterServerCallback('vigneron:getStorageInventory', function(source, cb)
    cb(storageInventory)
end)

RegisterServerEvent('vigneron:storeItem')
AddEventHandler('vigneron:storeItem', function(itemName, count)
    local xPlayer = ESX.GetPlayerFromId(source)

    if exports.ox_inventory:RemoveItem(source, itemName, count) then
        if storageInventory[itemName] then
            storageInventory[itemName].count = storageInventory[itemName].count + count
        else
            storageInventory[itemName] = { name = itemName, count = count }
        end
        TriggerClientEvent('esx:showNotification', source, 'Vous avez déposé ' .. count .. 'x ' .. itemName .. ' dans le coffre.')
    else
        TriggerClientEvent('esx:showNotification', source, 'Impossible de déposer l\'item.')
    end
end)

RegisterServerEvent('vigneron:retrieveItem')
AddEventHandler('vigneron:retrieveItem', function(itemName, count)
    local xPlayer = ESX.GetPlayerFromId(source)

    if storageInventory[itemName] and storageInventory[itemName].count >= count then
        if exports.ox_inventory:AddItem(source, itemName, count) then
            storageInventory[itemName].count = storageInventory[itemName].count - count
            TriggerClientEvent('esx:showNotification', source, 'Vous avez retiré ' .. count .. 'x ' .. itemName .. ' du coffre.')
        else
            TriggerClientEvent('esx:showNotification', source, 'Impossible de retirer l\'item.')
        end
    else
        TriggerClientEvent('esx:showNotification', source, 'Item non disponible dans le coffre.')
    end
end)
