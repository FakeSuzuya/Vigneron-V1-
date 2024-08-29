ESX = ESX or exports['es_extended']:getSharedObject()

local repairLocations = {
    vector3(1187.45, 2641.67, 37.05)
}

CreateThread(function()
    for _, location in ipairs(repairLocations) do
        exports.ox_target:addBoxZone({
            coords = location,
            size = vec3(2, 2, 2),
            options = {
                {
                    label = _U('repair_tool'),
                    icon = 'wrench',
                    onSelect = function()
                        ESX.TriggerServerCallback('vigneron:repairTool', function(success)
                            if success then
                                lib.notify({
                                    title = _U('tool_repaired'),
                                    description = _U('tool_repaired_desc'),
                                    type = 'success'
                                })
                            else
                                lib.notify({
                                    title = _U('repair_failed'),
                                    description = _U('repair_failed_desc'),
                                    type = 'error'
                                })
                            end
                        end)
                    end
                }
            }
        })
    end
end)
