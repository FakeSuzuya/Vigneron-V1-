local npcLocation = vector3(-1888.87, 2060.49, 140.98)
local npcHeading = 340.0 -- Orientation du NPC
local npcModel = 'a_m_m_farmer_01' -- Exemple de modèle de NPC

ESX = ESX or exports['es_extended']:getSharedObject()

CreateThread(function()
    -- Charger le modèle de NPC
    RequestModel(GetHashKey(npcModel))
    while not HasModelLoaded(GetHashKey(npcModel)) do
        Wait(1)
    end

    -- Créer le NPC
    local npc = CreatePed(4, npcModel, npcLocation.x, npcLocation.y, npcLocation.z, npcHeading, false, true)
    FreezeEntityPosition(npc, true) -- Le NPC reste en place
    SetEntityInvincible(npc, true)  -- Le NPC est invincible
    SetBlockingOfNonTemporaryEvents(npc, true) -- Empêche le NPC de réagir à son environnement

    -- Ajouter l'interaction pour le NPC via ox_target
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'npc_menu',
            label = _U('npc_menu_title'),
            icon = 'fa-solid fa-user',
            distance = 2.0,
            onSelect = function()
                -- Ouvrir le menu NUI lors de l'interaction
                SetNuiFocus(true, true)
                SendNUIMessage({ action = 'openMenu' })
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
