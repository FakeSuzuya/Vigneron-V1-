local processLocation = vector3(1112.45, 3143.67, 40.00)
ESX = ESX or exports['es_extended']:getSharedObject()
CreateThread(function()
    exports.ox_target:addBoxZone({
        coords = processLocation,
        size = vec3(2, 2, 2),
        options = {
            {
                label = _U('processing_grapes'),
                icon = 'hand',
                onSelect = function()
                    local success = lib.skillCheck('medium', {'e'})
                    if success then
                        RequestAnimDict('amb@prop_human_bum_bin@base')
                        while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
                            Wait(100)
                        end
                        TaskPlayAnim(PlayerPedId(), 'amb@prop_human_bum_bin@base', 'base', 8.0, 1.0, -1, 1, 0, false, false, false)
                        local finished = lib.progressBar({
                            duration = 10000,
                            label = _U('processing_grapes'),
                            canCancel = true,
                            disable = { car = true, combat = true }
                        })
                        ClearPedTasks(PlayerPedId())
                        if finished then
                            TriggerServerEvent('vigneron:processGrapes')
                        else
                            lib.notify({
                                title = 'Échec',
                                description = _U('failed_processing'),
                                type = 'error'
                            })
                        end
                    end
                end
            }
        }
    })
end)
