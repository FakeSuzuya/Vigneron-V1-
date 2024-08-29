ESX = ESX or exports['es_extended']:getSharedObject()
RegisterNetEvent('vigneron:updateGrapeQuality', function(quality)
    SendNUIMessage({
        action = 'updateQuality',
        quality = quality
    })
end)
