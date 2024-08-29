local vanModel = GetHashKey('Bison')
local vanSpawnLocation = vector3(-1900.0, 2000.0, 140.0) -- Example spawn location
local vanDestination = vector3(-1600.0, 3000.0, 35.0) -- Example destination location
ESX = ESX or exports['es_extended']:getSharedObject()
-- Load van model
RequestModel(vanModel)
while not HasModelLoaded(vanModel) do
    Wait(500)
end

RegisterNetEvent('vigneron:callVan')
AddEventHandler('vigneron:callVan', function()
    -- Create van at spawn location
    if not HasModelLoaded(vanModel) then
        lib.notify({
            title = _U('van_spawn_failed'),
            description = _U('model_not_loaded'),
            type = 'error'
        })
        return
    end

    local van = CreateVehicle(vanModel, vanSpawnLocation, 0.0, true, false)
    if not DoesEntityExist(van) then
        lib.notify({
            title = _U('van_spawn_failed'),
            description = _U('van_not_spawned'),
            type = 'error'
        })
        return
    end

    local vanDriver = CreatePedInsideVehicle(van, 4, GetHashKey('s_m_y_blackops_01'), -1, true, false)
    if not DoesEntityExist(vanDriver) then
        lib.notify({
            title = _U('van_spawn_failed'),
            description = _U('driver_not_spawned'),
            type = 'error'
        })
        return
    end
    
    TaskVehicleDriveToCoord(vanDriver, van, GetEntityCoords(PlayerPedId()), 20.0, 0, vanModel, 786603, 1.0, true)
    
    -- Wait for the van to arrive
    local arrived = false
    while not arrived do
        Wait(500)
        if not DoesEntityExist(van) or not DoesEntityExist(vanDriver) then
            lib.notify({
                title = _U('van_lost'),
                description = _U('van_not_arrived'),
                type = 'error'
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

    -- Allow loading wine into van
    exports.ox_target:addLocalEntity(NetworkGetNetworkIdFromEntity(van), {
        label = _U('load_wine'),
        icon = 'box',
        onSelect = function()
            RequestAnimDict('anim@heists@box_carry@')
            while not HasAnimDictLoaded('anim@heists@box_carry@') do
                Wait(100)
            end
            TaskPlayAnim(PlayerPedId(), 'anim@heists@box_carry@', 'idle', 8.0, 1.0, -1, 1, 0, false, false, false)
            local finished = lib.progressBar({
                duration = 5000,
                label = _U('loading_wine'),
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
        title = _U('dealer_arrived'),
        description = _U('dealer_load_wine'),
        type = 'inform'
    })
end)

RegisterNetEvent('vigneron:vanDeparture')
AddEventHandler('vigneron:vanDeparture', function(van, vanDriver)
    TaskVehicleDriveToCoord(vanDriver, van, vanDestination, 20.0, 0, vanModel, 786603, 1.0, true)
    Wait(3000) -- Wait a bit for the van to start moving
    local vanDistance = #(GetEntityCoords(van) - vanDestination)
    while vanDistance > 10.0 do
        Wait(1000)
        vanDistance = #(GetEntityCoords(van) - vanDestination)
    end

    -- Van despawns when it reaches the destination
    DeleteVehicle(van)
    DeleteEntity(vanDriver)

    lib.notify({
        title = _U('delivery_complete'),
        description = _U('payment_received'),
        type = 'success'
    })

    TriggerServerEvent('vigneron:payPlayer')
end)
