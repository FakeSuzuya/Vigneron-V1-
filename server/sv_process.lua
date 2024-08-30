ESX = ESX or exports['es_extended']:getSharedObject()

-- Configuration des Items
Config.Items = {
    ['grape_basic'] = { label = 'Grappes Basique', minQuality = 50, maxQuality = 70 },
    ['grape_good'] = { label = 'Grappes de Bonne Qualité', minQuality = 70, maxQuality = 90 },
    ['grape_premium'] = { label = 'Grappes Premium', minQuality = 90, maxQuality = 100 }
}

-- Callback pour vérifier si le joueur a des grappes et retourner le type de grappe
ESX.RegisterServerCallback('vigneron:hasGrapes', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)

    for grapeType, _ in pairs(Config.Items) do
        local grapeItem = xPlayer.getInventoryItem(grapeType)
        if grapeItem and grapeItem.count > 0 then
            cb(true, grapeType)
            return
        end
    end

    cb(false)
end)

-- Gestion de la transformation des grappes en vin
RegisterServerEvent('vigneron:processGrapes')
AddEventHandler('vigneron:processGrapes', function(grapeType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local grapeItem = xPlayer.getInventoryItem(grapeType)
    
    if grapeItem and grapeItem.count > 0 then
        local amount = math.min(grapeItem.count, 1) -- Exemple : transformer 1 grappe à la fois
        xPlayer.removeInventoryItem(grapeType, amount)

        -- Calculer la qualité du vin produit en fonction du type de grappe
        local itemConfig = Config.Items[grapeType]
        local wineQuality = math.random(itemConfig.minQuality, itemConfig.maxQuality)

        -- Ajouter du vin dans l'inventaire du joueur
        xPlayer.addInventoryItem('wine', 1, { quality = wineQuality })

        TriggerClientEvent('esx:showNotification', source, 'Vous avez transformé ' .. itemConfig.label .. ' en vin de qualité : ' .. math.floor(wineQuality) .. '/100.')
    else
        TriggerClientEvent('esx:showNotification', source, 'Vous n\'avez pas de grappes.')
    end
end)
