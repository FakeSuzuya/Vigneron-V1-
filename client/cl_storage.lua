-- cl_storage.lua
ESX = ESX or exports['es_extended']:getSharedObject()
local storageLocation = vector3(-1892.87, 2075.49, 140.98)

CreateThread(function()
    exports.ox_target:addSphereZone({
        coords = storageLocation,
        radius = 2.0,
        options = {
            {
                label = 'Coffre de Stockage',
                icon = 'box',
                onSelect = function()
                    ESX.TriggerServerCallback('vigneron:isEmployee', function(isEmployee)
                        if isEmployee then
                            ESX.TriggerServerCallback('vigneron:getStorageInventory', function(storageItems, playerItems)
                                OpenStorageMenu(storageItems, playerItems)
                            end)
                        else
                            ESX.ShowNotification('Vous devez être un employé pour accéder à ce coffre.')
                        end
                    end)
                end
            }
        }
    })
end)

function OpenStorageMenu(storageItems, playerItems)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openStorage',
        storageItems = storageItems,
        playerItems = playerItems
    })
end

RegisterNUICallback('closeStorage', function()
    SetNuiFocus(false, false)
end)

RegisterNUICallback('storeItem', function(data, cb)
    TriggerServerEvent('vigneron:storeItem', data.itemName, data.count)
    cb('ok')
end)

RegisterNUICallback('retrieveItem', function(data, cb)
    TriggerServerEvent('vigneron:retrieveItem', data.itemName, data.count)
    cb('ok')
end)
