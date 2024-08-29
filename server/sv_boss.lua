local ESX = exports['es_extended']:getSharedObject()

-- Vérifie si l'utilisateur est un patron
ESX.RegisterServerCallback('vigneron:isBoss', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local job = xPlayer.getJob()

    if job.name == 'vigneron' and job.grade_name == 'boss' then
        cb(true)
    else
        cb(false)
    end
end)

-- Récupère la liste des employés pour le menu boss
ESX.RegisterServerCallback('vigneron:getEmployees', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM user_vigneron WHERE job_name = @job_name', {
        ['@job_name'] = 'vigneron'
    }, function(employees)
        cb(employees)
    end)
end)

-- Recrute un joueur
RegisterServerEvent('vigneron:recruitPlayer')
AddEventHandler('vigneron:recruitPlayer', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local targetPlayer = GetClosestPlayer(source)

    if targetPlayer then
        local xTarget = ESX.GetPlayerFromId(targetPlayer)
        MySQL.Async.execute('INSERT INTO user_vigneron (identifier, name, job_grade) VALUES (@identifier, @name, @job_grade)', {
            ['@identifier'] = xTarget.identifier,
            ['@name'] = xTarget.getName(),
            ['@job_grade'] = 0
        })
        xTarget.setJob('vigneron', 0)
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Vous avez recruté ' .. xTarget.getName())
        TriggerClientEvent('esx:showNotification', xTarget.source, 'Vous avez été recruté comme vigneron')
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Aucun joueur à proximité')
    end
end)

-- Virer un employé
RegisterServerEvent('vigneron:firePlayer')
AddEventHandler('vigneron:firePlayer', function(employeeId)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchScalar('SELECT identifier FROM user_vigneron WHERE id = @id', {
        ['@id'] = employeeId
    }, function(identifier)
        MySQL.Async.execute('DELETE FROM user_vigneron WHERE id = @id', { ['@id'] = employeeId })
        MySQL.Async.execute('UPDATE users SET job = @job, job_grade = @job_grade WHERE identifier = @identifier', {
            ['@job'] = 'unemployed',
            ['@job_grade'] = 0,
            ['@identifier'] = identifier
        })
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Employé viré avec succès.')
    end)
end)

-- Gérer les grades des employés
RegisterServerEvent('vigneron:setGrade')
AddEventHandler('vigneron:setGrade', function(employeeId, newGrade)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchScalar('SELECT identifier FROM user_vigneron WHERE id = @id', {
        ['@id'] = employeeId
    }, function(identifier)
        MySQL.Async.execute('UPDATE user_vigneron SET job_grade = @job_grade WHERE id = @id', {
            ['@job_grade'] = newGrade,
            ['@id'] = employeeId
        })
        MySQL.Async.execute('UPDATE users SET job_grade = @job_grade WHERE identifier = @identifier', {
            ['@job_grade'] = newGrade,
            ['@identifier'] = identifier
        })
        TriggerClientEvent('esx:showNotification', xPlayer.source, 'Grade mis à jour avec succès.')
    end)
end)

-- Gérer le temps de service
RegisterServerEvent('vigneron:addTime')
AddEventHandler('vigneron:addTime', function(employeeId, minutes)
    MySQL.Async.execute('UPDATE user_vigneron SET service_time = service_time + @minutes WHERE id = @id', {
        ['@minutes'] = minutes,
        ['@id'] = employeeId
    })
end)

RegisterServerEvent('vigneron:removeTime')
AddEventHandler('vigneron:removeTime', function(employeeId, minutes)
    MySQL.Async.execute('UPDATE user_vigneron SET service_time = service_time - @minutes WHERE id = @id AND service_time >= @minutes', {
        ['@minutes'] = minutes,
        ['@id'] = employeeId
    })
end)

-- Fonction pour obtenir le joueur le plus proche
function GetClosestPlayer(source)
    local players = ESX.GetPlayers()
    local closestPlayer = nil
    local closestDistance = -1
    local sourceCoords = GetEntityCoords(GetPlayerPed(source))

    for i = 1, #players, 1 do
        local target = GetPlayerPed(players[i])
        local targetCoords = GetEntityCoords(target)
        local distance = #(sourceCoords - targetCoords)

        if closestDistance == -1 or distance < closestDistance then
            closestPlayer = players[i]
            closestDistance = distance
        end
    end

    return closestPlayer
end
