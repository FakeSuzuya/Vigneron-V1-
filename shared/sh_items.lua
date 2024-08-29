
ESX = exports['es_extended']:getSharedObject()



ESX.RegisterUsableItem('wine', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('ox_lib:notify', source, {type = 'inform', description = _U('use_wine')})
    xPlayer.removeInventoryItem('wine', 1)
    -- Add effects of wine here, like reducing stress or other health benefits.
end)

-- Initialisation de ESX pour les scripts partagés
if IsDuplicityVersion() then
    ESX = exports['es_extended']:getSharedObject()
else
    ESX = ESX or exports['es_extended']:getSharedObject()
end


Config.Items = {
    ['grape_basic'] = {
        label = 'Grappe de Raisin Basique',
        weight = 1,
    },
    ['grape_good'] = {
        label = 'Grappe de Raisin de Bonne Qualité',
        weight = 1,
    },
    ['grape_premium'] = {
        label = 'Grappe de Raisin Premium',
        weight = 1,
    },
    ['secateur'] = {
        label = 'Sécateur',
        weight = 1,
    },
    ['wine'] = {
        label = 'Vin',
        weight = 1,  -- Assurez-vous que ce poids est correct pour l'item 'wine'
    },
    ['vigneron_xp'] = {
        label = 'Expérience Vigneron',
        weight = 0,  -- Item virtuel pour stocker l'XP
    },
}




-- Ensure these items exist in your database or item list
