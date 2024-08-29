
local ESX = exports['es_extended']:getSharedObject()

ESX.RegisterServerCallback('vigneron:checkTool', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tool = xPlayer.getInventoryItem('secateur')
    if tool and tool.count > 0 then
        cb(true, tool.metadata.durability or 100)
    else
        cb(false, 0)
    end
end)

ESX.RegisterServerCallback('vigneron:reduceToolDurability', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tool = xPlayer.getInventoryItem('secateur')
    if tool and tool.count > 0 then
        local newDurability = (tool.metadata.durability or 100) - 10
        if newDurability > 0 then
            xPlayer.setInventoryItem('secateur', 1, { durability = newDurability })
            TriggerClientEvent('ox_lib:notify', source, {type = 'inform', description = _U('tool_durability', newDurability)})
        else
            xPlayer.removeInventoryItem('secateur', 1)
            TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = _U('tool_broken')})
        end
    end
end)

ESX.RegisterServerCallback('vigneron:repairTool', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tool = xPlayer.getInventoryItem('secateur')
    if tool and tool.count > 0 then
        xPlayer.setInventoryItem('secateur', 1, { durability = 100 })
        cb(true)
    else
        cb(false)
    end
end)
