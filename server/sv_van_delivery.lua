ESX = ESX or exports['es_extended']:getSharedObject()

-- Calcul du paiement basé sur les prix actuels du marché
local function calculatePayment(wineLoaded, currentPrices)
    local totalPayment = 0
    for wineType, amount in pairs(wineLoaded) do
        local winePrice = currentPrices[wineType].current
        totalPayment = totalPayment + (winePrice * amount)
    end
    return totalPayment
end

RegisterServerEvent('vigneron:loadVan')
AddEventHandler('vigneron:loadVan', function(netVanId)
    local xPlayer = ESX.GetPlayerFromId(source)
    local wineLoaded = {
        ['wine_basic'] = 0,
        ['wine_good'] = 0,
        ['wine_premium'] = 0
    }

    -- Charger les bouteilles de vin du joueur dans le van
    for wineType, _ in pairs(wineLoaded) do
        local wineCount = xPlayer.getInventoryItem(wineType).count
        if wineCount > 0 then
            xPlayer.removeInventoryItem(wineType, wineCount)
            wineLoaded[wineType] = wineCount
        end
    end

    -- Stocker les informations sur le chargement du van pour le paiement
    TriggerClientEvent('vigneron:vanLoaded', source, netVanId, wineLoaded)
end)

RegisterServerEvent('vigneron:payPlayer')
AddEventHandler('vigneron:payPlayer', function(wineLoaded)
    local xPlayer = ESX.GetPlayerFromId(source)

    -- Récupérer les prix actuels des vins depuis le marché
    ESX.TriggerServerCallback('vigneron:checkWinePrices', function(currentPrices)
        local payment = calculatePayment(wineLoaded, currentPrices)

        if payment > 0 then
            xPlayer.addMoney(payment)
            TriggerClientEvent('esx:showNotification', source, 'Vous avez reçu $' .. payment .. ' pour la livraison de vin.')
        else
            TriggerClientEvent('esx:showNotification', source, 'Aucune bouteille de vin n\'a été livrée.')
        end
    end)
end)
