local bossLocation = vector3(-1892.87, 2070.49, 140.98)  -- Coordonnées du NPC Boss
ESX = ESX or exports['es_extended']:getSharedObject()

CreateThread(function()
    exports.ox_target:addLocalEntity(bossLocation, {
        label = _U('npc_boss_menu'),
        icon = 'user-tie',
        distance = 2.0,
        onSelect = function()
            ESX.TriggerServerCallback('vigneron:isBoss', function(isBoss)
                if isBoss then
                    SetNuiFocus(true, true)
                    SendNUIMessage({ action = 'openBossMenu' })
                else
                    ESX.ShowNotification('Vous devez être le patron pour accéder à ce menu.')
                end
            end)
        end
    })
end)

RegisterNUICallback('bossMenuAction', function(data, cb)
    if data.action == 'getEmployees' then
        ESX.TriggerServerCallback('vigneron:getEmployees', function(employees)
            SendNUIMessage({ action = 'updateEmployeeList', employees = employees })
        end)
    elseif data.action == 'recruit' then
        TriggerServerEvent('vigneron:recruitPlayer')
    elseif data.action == 'fire' then
        TriggerServerEvent('vigneron:firePlayer', data.employeeId)
    elseif data.action == 'setGrade' then
        TriggerServerEvent('vigneron:setGrade', data.employeeId, data.newGrade)
    elseif data.action == 'addTime' then
        TriggerServerEvent('vigneron:addTime', data.employeeId, data.minutes)
    elseif data.action == 'removeTime' then
        TriggerServerEvent('vigneron:removeTime', data.employeeId, data.minutes)
    end
    cb('ok')
end)
