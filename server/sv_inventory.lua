-- Fetch player inventory with quality for grapes and wine
local ESX = exports['es_extended']:getSharedObject()
ESX.RegisterServerCallback('vigneron:giveGrapes', function(source, cb, quality)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.canCarryItem('grape', 5) then
        MySQL.Async.execute('INSERT INTO user_inventory (identifier, item, count, quality) VALUES (@identifier, @item, @count, @quality) ON DUPLICATE KEY UPDATE count = count + @count', {
            ['@identifier'] = xPlayer.identifier,
            ['@item'] = 'grape',
            ['@count'] = 5,
            ['@quality'] = quality
        }, function(rowsChanged)
            if rowsChanged > 0 then
                xPlayer.addInventoryItem('grape', 5, { quality = quality })
                cb(true)
            else
                cb(false)
            end
        end)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = _U('inventory_full')})
        cb(false)
    end
end)

ESX.RegisterServerCallback('vigneron:processGrapes', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local grapes = xPlayer.getInventoryItem('grape')
    if grapes.count >= 5 then
        local qualitySum = 0
        for i = 1, 5 do
            qualitySum = qualitySum + (grapes.metadata.quality or 50)
        end
        local wineQuality = math.floor((qualitySum / 5) * 0.8 + math.random(10, 20))

        MySQL.Async.execute('UPDATE user_inventory SET count = count - 5 WHERE identifier = @identifier AND item = @item', {
            ['@identifier'] = xPlayer.identifier,
            ['@item'] = 'grape'
        }, function(rowsChanged)
            if rowsChanged > 0 then
                xPlayer.removeInventoryItem('grape', 5)
                xPlayer.addInventoryItem('wine', 1, { quality = wineQuality })
                cb(true)
            else
                cb(false)
            end
        end)
    else
        TriggerClientEvent('ox_lib:notify', source, {type = 'error', description = _U('not_enough_grapes')})
        cb(false)
    end
end)
