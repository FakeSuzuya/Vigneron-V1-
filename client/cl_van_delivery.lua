local vanModel = GetHashKey('Bison')
local vanSpawnLocation = vector3(-1900.0, 2000.0, 140.0) -- Exemple de point de spawn du van
local vanDestination = vector3(-1600.0, 3000.0, 35.0) -- Exemple de destination du van
ESX = ESX or exports['es_extended']:getSharedObject()

-- Charger le modèle du van
RequestModel(vanModel)
while not HasModelLoaded(vanModel) do
    Wait(500)
end

RegisterNetEvent('vigneron:callVan')
AddEventHandler('vigneron:callVan', function()
    -- Créer le van à l'emplacement de spawn
    if not HasModelLoaded(vanModel) then
        lib.notify({
            title = 'Erreur de Spawn',
            description = 'Le modèle du van n\'a pas pu être chargé.',
            type = 'error',
            icon = 'fa-solid fa-truck'
        })
        return
    end

    local van = CreateVehicle(vanModel, vanSpawnLocation, 0.0, true, false)
    if not DoesEntityExist(van) then
        lib.notify({
            title = 'Erreur de Spawn',
            description = 'Le van n\'a pas pu être créé.',
            type = 'error',
            icon = 'fa-solid fa-truck'
        })
        return
    end

    local vanDriver = CreatePedInsideVehicle(van, 4, GetHashKey('s_m_y_blackops_01'), -1, true, false)
    if not DoesEntityExist(vanDriver) then
        lib.notify({
            title = 'Erreur de Spawn',
            description = 'Le conducteur du van n\'a pas pu être créé.',
            type = 'error',
            icon = 'fa-solid fa-user'
        })
        return
    end
    
    -- Le van se dirige vers le joueur
    TaskVehicleDriveToCoord(vanDriver, van, GetEntityCoords(PlayerPedId()), 20.0, 0, vanModel, 786603, 1.0, true)
    
    local arrived = false
    while not arrived do
        Wait(500)
        if not DoesEntityExist(van) or not DoesEntityExist(vanDriver) then
            lib.notify({
                title = 'Van perdu',
                description = 'Le van n\'a pas atteint votre position.',
                type = 'error',
                icon = 'fa-solid fa-exclamation-triangle'
            })
            return
        end

        local vanCoords = GetEntityCoords(van)
        local playerCoords = GetEntityCoords(PlayerPedId())
        if #(vanCoords - playerCoords) < 10.0 then
            TaskVehiclePark(vanDriver, van, vanCoords.x, vanCoords.y, vanCoords.z, GetEntityHeading(van), 1, 1.0, false)
            arrived = true
        end
    end

    -- Permettre le chargement du vin dans le van
    exports.ox_target:addLocalEntity(NetworkGetNetworkIdFromEntity(van), {
        label = 'Charger le Vin',
        icon = 'fa-solid fa-box',
        onSelect = function()
            RequestAnimDict('anim@heists@box_carry@')
            while not HasAnimDictLoaded('anim@heists@box_carry@') do
                Wait(100)
            end
            TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 1.0, -1, 1, 0, false, false, false)
            local finished = lib.progressBar({
                duration = 5000,
                label = 'Chargement du vin...',
                canCancel = true,
                disable = { car = true, combat = true }
            })
            ClearPedTasks(PlayerPedId())
            if finished then
                TriggerServerEvent('vigneron:loadVan', NetworkGetNetworkIdFromEntity(van))
                TriggerEvent('vigneron:vanDeparture', van, vanDriver)
            end
        end
    })

    lib.notify({
        title = 'Le Van est Arrivé',
        description = 'Chargez le vin dans le van pour la livraison.',
        type = 'inform',
        icon = 'fa-solid fa-truck-loading'
    })
end)

RegisterNetEvent('vigneron:vanLoaded')
AddEventHandler('vigneron:vanLoaded', function(netVanId, wineLoaded)
    -- Affichage des notifications pour chaque type de vin chargé dans le van
    for wineType, count in pairs(wineLoaded) do
        if count > 0 then
            local wineLabel = ''
            if wineType == 'wine_basic' then
                wineLabel = 'Vin Basique'
            elseif wineType == 'wine_good' then
                wineLabel = 'Vin de Bonne Qualité'
            elseif wineType == 'wine_premium' then
                wineLabel = 'Vin Premium'
            end

            lib.notify({
                title = 'Vin Chargé',
                description = string.format('Vous avez chargé %d bouteilles de %s dans le van.', count, wineLabel),
                type = 'inform',
                icon = 'fa-solid fa-wine-bottle'
            })
        end
    end
end)

RegisterNetEvent('vigneron:vanDeparture')
AddEventHandler('vigneron:vanDeparture', function(van, vanDriver)
    TaskVehicleDriveToCoord(vanDriver, van, vanDestination, 20.0, 0, vanModel, 786603, 1.0, true)
    Wait(3000) -- Attendre un peu pour que le van commence à bouger
    local vanDistance = #(GetEntityCoords(van) - vanDestination)
    while vanDistance > 10.0 do
        Wait(1000)
        vanDistance = #(GetEntityCoords(van) - vanDestination)
    end

    -- Le van disparaît lorsqu'il atteint la destination
    DeleteVehicle(van)
    DeleteEntity(vanDriver)

    lib.notify({
        title = 'Livraison Complète',
        description = 'Vous avez reçu votre paiement.',
        type = 'success',
        icon = 'fa-solid fa-money-bill-wave'
    })

    TriggerServerEvent('vigneron:payPlayer')
end)
