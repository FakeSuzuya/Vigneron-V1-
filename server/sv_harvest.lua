-- sv_harvest.lua
local ESX = exports['es_extended']:getSharedObject()
ESX.RegisterServerCallback('vigneron:checkToolAndExperience', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local tool = xPlayer.getInventoryItem('secateur')
    local xp = xPlayer.getInventoryItem('vigneron_xp').count or 0

    if tool and tool.count > 0 then
        local durability = tool.metadata.durability or 100
        local experience = calculateExperienceLevel(xp)
        cb(true, durability, experience)
    else
        cb(false)
    end
end)

RegisterServerEvent('vigneron:addXP')
AddEventHandler('vigneron:addXP', function(xpToAdd)
    local xPlayer = ESX.GetPlayerFromId(source)
    local currentXP = xPlayer.getInventoryItem('vigneron_xp').count or 0

    local newXP = currentXP + xpToAdd
    xPlayer.setInventoryItem('vigneron_xp', newXP)

    TriggerClientEvent('esx:showNotification', source, 'Vous avez gagné ' .. xpToAdd .. ' XP. Total XP: ' .. newXP)

    local newLevel = calculateExperienceLevel(newXP)
    TriggerClientEvent('vigneron:updateLevel', source, newLevel)
end)

function calculateExperienceLevel(xp)
    local level = 1
    for lvl, data in pairs(Config.Levels) do
        if xp >= data.xpRequired then
            level = lvl
        else
            break
        end
    end
    return level
end

RegisterServerEvent('vigneron:giveGrapes')
AddEventHandler('vigneron:giveGrapes', function(quality, experience)
    local xPlayer = ESX.GetPlayerFromId(source)
    local level = calculateExperienceLevel(xPlayer.getInventoryItem('vigneron_xp').count or 0)

    local grapeType = Config.GrapeTypes[level]  -- Sélectionne le type de raisin en fonction du niveau
    local grapeLabel = Config.Items[grapeType].label

    xPlayer.addInventoryItem(grapeType, 1, { quality = quality })

    TriggerClientEvent('esx:showNotification', source, 'Vous avez récolté une ' .. grapeLabel)
end)

RegisterServerEvent('vigneron:reduceToolDurability')
AddEventHandler('vigneron:reduceToolDurability', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local tool = xPlayer.getInventoryItem('secateur')

    if tool then
        local durabilityReduction = math.random(5, 15)  -- Réduction dynamique
        local durability = (tool.metadata.durability or 100) - durabilityReduction

        if durability > 0 then
            xPlayer.removeInventoryItem('secateur', 1)
            xPlayer.addInventoryItem('secateur', 1, { durability = durability })
        else
            xPlayer.removeInventoryItem('secateur', 1)
            TriggerClientEvent('esx:showNotification', source, 'Votre sécateur est cassé!')
        end
    end
end)
