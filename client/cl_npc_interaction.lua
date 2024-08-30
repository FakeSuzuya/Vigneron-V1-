local npcLocation = vector3(-1888.87, 2060.49, 140.98)
local npcHeading = 340.0 -- Orientation du NPC
local npcModel = 'a_m_m_farmer_01' -- Exemple de modèle de NPC
local npcEntity -- Variable pour stocker l'entité du NPC
local nuiActive = false -- Variable pour suivre l'état du NUI

ESX = ESX or exports['es_extended']:getSharedObject()

CreateThread(function()
    -- Charger le modèle de NPC
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do
        Wait(1)
    end

    -- Créer le NPC
    npcEntity = CreatePed(4, npcModel, npcLocation.x, npcLocation.y, npcLocation.z, npcHeading, false, true)
    FreezeEntityPosition(npcEntity, true) -- Le NPC reste en place
    SetEntityInvincible(npcEntity, true)  -- Le NPC est invincible
    SetBlockingOfNonTemporaryEvents(npcEntity, true) -- Empêche le NPC de réagir à son environnement

    -- Ajouter l'interaction pour le NPC via ox_target
    exports.ox_target:addLocalEntity(npcEntity, {
        {
            name = 'npc_menu',
            label = _U('npc_menu_title'),
            icon = 'fa-solid fa-user',
            distance = 2.0,
            onSelect = function()
                if not nuiActive then
                    -- Vérifie si le joueur est à proximité du NPC avant d'ouvrir le menu
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local npcCoords = GetEntityCoords(npcEntity)
                    local distance = #(playerCoords - npcCoords)

                    if distance <= 2.0 then
                        SetNuiFocus(true, true)
                        SendNUIMessage({ action = 'openMenu' })
                        nuiActive = true -- Mettre à jour l'état NUI
                    end
                end
            end
        }
    })
end)

-- Gestion des actions du menu NUI
RegisterNUICallback('menuAction', function(data, cb)
    if data.action == 'start_shift' then
        TriggerServerEvent('vigneron:startShift')
    elseif data.action == 'end_shift' then
        TriggerServerEvent('vigneron:endShift')
    elseif data.action == 'call_dealer' then
        TriggerEvent('vigneron:callVan')
    elseif data.action == 'check_wine_price' then
        ESX.TriggerServerCallback('vigneron:checkWinePrice', function(price)
            SendNUIMessage({ action = 'updateWinePrice', price = price })
        end)
    elseif data.action == 'view_employees' then
        ESX.TriggerServerCallback('vigneron:checkEmployees', function(employees)
            SendNUIMessage({ action = 'updateEmployeeList', employees = employees })
        end)
    elseif data.action == 'close_menu' then
        -- Fermer le menu NUI
        SetNuiFocus(false, false)
        SendNUIMessage({ action = 'closeMenu' })
        nuiActive = false -- Réinitialiser l'état NUI
    end
    cb('ok')
end)

-- Gestion de l'affichage de la liste des employés en service
RegisterNetEvent('vigneron:showEmployeeList', function(employees)
    if #employees > 0 then
        local employeeList = table.concat(employees, "\n")
        lib.notify({
            title = _U('employees_on_duty_title'),
            description = employeeList,
            type = 'inform',
            duration = 10000 -- afficher pendant 10 secondes
        })
    else
        lib.notify({
            title = _U('no_employees_on_duty_title'),
            description = _U('no_employees_on_duty'),
            type = 'inform'
        })
    end
end)
