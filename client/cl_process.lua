local processLocation = vector3(1112.45, 3143.67, 40.00)
ESX = ESX or exports['es_extended']:getSharedObject()

local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
end

local function PlayProcessingAnimation()
    local playerPed = PlayerPedId()
    LoadAnimDict('anim@amb@business@coc@coc_packing_hi@')
    TaskPlayAnim(playerPed, 'anim@amb@business@coc@coc_packing_hi@', 'full_cycle_v1_pressoperator', 8.0, -8.0, -1, 1, 0, false, false, false)
end

local function PlayProcessingEffect(coords)
    UseParticleFxAssetNextCall('core')
    StartParticleFxNonLoopedAtCoord('ent_dst_electrical', coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
end

CreateThread(function()
    exports.ox_target:addBoxZone({
        coords = processLocation,
        size = vec3(2, 2, 2),
        options = {
            {
                label = _U('processing_grapes'),
                icon = 'fa-solid fa-wine-bottle',
                onSelect = function()
                    ESX.TriggerServerCallback('vigneron:hasGrapes', function(hasGrapes, grapeType)
                        if not hasGrapes then
                            lib.notify({
                                title = 'Aucune Grappe',
                                description = _U('no_grapes'),
                                type = 'error'
                            })
                            return
                        end

                        local success = lib.skillCheck('medium', {'e'})
                        if success then
                            PlayProcessingAnimation()
                            PlayProcessingEffect(processLocation)

                            local finished = lib.progressBar({
                                duration = 10000,  -- Ajuster la durée du traitement
                                label = _U('processing_grapes'),
                                canCancel = true,
                                disable = { car = true, combat = true }
                            })

                            ClearPedTasks(PlayerPedId())

                            if finished then
                                TriggerServerEvent('vigneron:processGrapes', grapeType)
                            else
                                lib.notify({
                                    title = 'Échec',
                                    description = _U('failed_processing'),
                                    type = 'error'
                                })
                            end
                        else
                            lib.notify({
                                title = 'Échec',
                                description = _U('failed_skill_check'),
                                type = 'error'
                            })
                        end
                    end)
                end
            }
        }
    })
end)
