local ESX = exports['es_extended']:getSharedObject()
Locales = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
    -- Chargement des locales
    if Config.Locale == 'en' then
        Locales['en'] = {
            ['wine_market_update'] = 'Wine Market Update',
            ['wine_price_update'] = 'The current price of %s is $%s per bottle.',
            ['wine_basic'] = 'Basic Wine',
            ['wine_good'] = 'Good Wine',
            ['wine_premium'] = 'Premium Wine'
        }
    elseif Config.Locale == 'fr' then
        Locales['fr'] = {
            ['wine_market_update'] = 'Mise à jour du marché du vin',
            ['wine_price_update'] = 'Le prix actuel du %s est de $%s par bouteille.',
            ['wine_basic'] = 'Vin Basique',
            ['wine_good'] = 'Vin de Bonne Qualité',
            ['wine_premium'] = 'Vin Premium'
        }
    end
end)

-- Configuration des prix du vin
local winePrices = {
    ['wine_basic'] = {min = 1000, max = 1500, current = 1200},
    ['wine_good'] = {min = 2000, max = 2500, current = 2200},
    ['wine_premium'] = {min = 3000, max = 3500, current = 3200}
}

local priceChangeInterval = 30 * 60000 -- 30 minutes en millisecondes

-- Mise à jour périodique des prix du vin
CreateThread(function()
    while true do
        Wait(priceChangeInterval)
        for wineType, priceData in pairs(winePrices) do
            winePrices[wineType].current = math.random(priceData.min, priceData.max)
            TriggerClientEvent('vigneron:updateMarketPrice', -1, wineType, winePrices[wineType].current)
            TriggerClientEvent('ox_lib:notify', -1, {
                title = _U('wine_market_update'),
                description = _U('wine_price_update', _U(wineType), winePrices[wineType].current),
                type = 'inform',
                duration = 15000,
                icon = 'fa-wine-bottle'
            })
        end
    end
end)

-- Callback pour vérifier les prix des vins
ESX.RegisterServerCallback('vigneron:checkWinePrices', function(source, cb)
    cb(winePrices)
end)
