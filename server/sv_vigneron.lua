local ESX = exports['es_extended']:getSharedObject()
ESX.RegisterServerCallback('vigneron:checkEmployees', function(source, cb)
    local xPlayers = ESX.GetPlayers()
    local employeeList = {}
    for _, playerId in ipairs(xPlayers) do
        local xPlayer = ESX.GetPlayerFromId(playerId)
        if xPlayer.job.name == 'vigneron' then
            table.insert(employeeList, xPlayer.name)
        end
    end
    
    -- Notify the player about the number of employees on duty
    local message = #employeeList > 0 and _U('employees_on_duty', #employeeList) or _U('no_employees_on_duty')
    TriggerClientEvent('ox_lib:notify', source, {type = 'inform', description = message})

    TriggerClientEvent('vigneron:showEmployeeList', source, employeeList)
    cb(employeeList)
end)

ESX.RegisterServerCallback('vigneron:startShift', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.setJob('vigneron', 1)
    TriggerClientEvent('vigneron:startShiftAnimation', source)
    cb(true)
end)

ESX.RegisterServerCallback('vigneron:endShift', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    xPlayer.setJob('unemployed', 0)
    TriggerClientEvent('vigneron:endShiftAnimation', source)
    cb(true)
end)
