-- boss_npc.lua
local bossLocation = vector3(-1892.87, 2070.49, 140.98)  -- Coordonnées du NPC Boss
local bossHeading = 340.0 -- Orientation du NPC
local bossModel = 'a_m_m_business_01' -- Modèle de NPC pour le patron

ESX = ESX or exports['es_extended']:getSharedObject()

CreateThread(function()
    -- Charger le modèle de NPC
    RequestModel(GetHashKey(bossModel))
    while not HasModelLoaded(GetHashKey(bossModel)) do
        Wait(1)
    end

    -- Créer le NPC Boss
    local npcBoss = CreatePed(4, bossModel, bossLocation.x, bossLocation.y, bossLocation.z, bossHeading, false, true)
    FreezeEntityPosition(npcBoss, true)
    SetEntityInvincible(npcBoss, true)
    SetBlockingOfNonTemporaryEvents(npcBoss, true)

    -- Ajouter l'interaction pour le NPC Boss via ox_target
    exports.ox_target:addLocalEntity(npcBoss, {
        {
            name = 'boss_menu',
            label = _U('npc_boss_menu'),
            icon = 'fa-solid fa-user-tie',
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
        }
    })
end)

-- Gestion des actions du menu Boss
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
