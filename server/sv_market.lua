-- sv_market.lua

-- Load the locale
local ESX = exports['es_extended']:getSharedObject()
Locales = {}
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
MySQL.ready(function()
    -- Include the locale file
    if Config.Locale == 'en' then
        Locales['en'] = {
            ['wine_market_update'] = 'Wine Market Update',
            ['wine_price_update'] = 'The current wine price is $%s per bottle.'
        }
    elseif Config.Locale == 'fr' then
        Locales['fr'] = {
            ['wine_market_update'] = 'Mise à jour du marché du vin',
            ['wine_price_update'] = 'Le prix actuel du vin est de $%s par bouteille.'
        }
    end
end)

-- Example usage of _U function
local winePrice = 2000
local winePriceMin = 1500
local winePriceMax = 3000
local priceChangeInterval = 30 * 60000 -- 30 minutes in milliseconds

CreateThread(function()
    while true do
        Wait(priceChangeInterval)
        winePrice = math.random(winePriceMin, winePriceMax)
        TriggerClientEvent('vigneron:updateMarketPrice', -1, winePrice)
        TriggerClientEvent('ox_lib:notify', -1, {
            title = _U('wine_market_update'),
            description = _U('wine_price_update', winePrice),
            type = 'inform',
            duration = 15000,
            icon = 'fa-wine-bottle'
        })
    end
end)

ESX.RegisterServerCallback('vigneron:checkWinePrice', function(source, cb)
    cb(winePrice)
end)
