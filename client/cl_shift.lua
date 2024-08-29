ESX = ESX or exports['es_extended']:getSharedObject()
RegisterNetEvent('vigneron:startShiftAnimation', function()
    RequestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    while not HasAnimDictLoaded('anim@heists@prison_heiststation@cop_reactions') do
        Wait(100)
    end

    TaskPlayAnim(PlayerPedId(), 'anim@heists@prison_heiststation@cop_reactions', 'cop_b_idle', 8.0, 1.0, 3000, 49, 0, false, false, false)
    lib.notify({
        title = _U('shift_started'),
        description = _U('start_shift_msg'),
        type = 'success'
    })
end)

RegisterNetEvent('vigneron:endShiftAnimation', function()
    RequestAnimDict('anim@heists@prison_heiststation@cop_reactions')
    while not HasAnimDictLoaded('anim@heists@prison_heiststation@cop_reactions') do
        Wait(100)
    end

    TaskPlayAnim(PlayerPedId(), 'anim@heists@prison_heiststation@cop_reactions', 'cop_a_idle', 8.0, 1.0, 3000, 49, 0, false, false, false)
    lib.notify({
        title = _U('shift_ended'),
        description = _U('end_shift_msg'),
        type = 'success'
    })
end)
