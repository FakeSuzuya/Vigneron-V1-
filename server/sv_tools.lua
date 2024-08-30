ESX = ESX or exports['es_extended']:getSharedObject()

local Config = {
    ToolName = 'secateur',  -- Nom de l'outil dans l'inventaire
    HarvestDurabilityLoss = 1,  -- Perte de durabilité par récolte
    MaxDurability = 100,  -- Durabilité maximale du sécateur
    MinDurabilityToRepair = 80  -- Seuil de durabilité minimale pour autoriser la réparation
}

-- Callback pour vérifier si le joueur a un sécateur et récupérer sa durabilité
ESX.RegisterServerCallback('vigneron:hasTool', function(source, cb, toolName)
    local xPlayer = ESX.GetPlayerFromId(source)
    local toolItem = xPlayer.getInventoryItem(toolName or Config.ToolName)

    if toolItem and toolItem.count > 0 then
        -- Exemple : La durabilité peut être stockée dans une métadonnée de l'objet ou dans la base de données
        -- Pour cet exemple, supposons que la durabilité est stockée dans une propriété `durability`
        local durability = toolItem.metadata and toolItem.metadata.durability or Config.MaxDurability
        cb(true, durability)
    else
        cb(false)
    end
end)

-- Fonction pour déduire la durabilité après chaque récolte
RegisterServerEvent('vigneron:deductDurability')
AddEventHandler('vigneron:deductDurability', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local toolItem = xPlayer.getInventoryItem(Config.ToolName)

    if toolItem and toolItem.count > 0 then
        local durability = toolItem.metadata and toolItem.metadata.durability or Config.MaxDurability

        -- Réduire la durabilité
        durability = durability - Config.HarvestDurabilityLoss

        -- Assurez-vous que la durabilité ne passe pas en dessous de zéro
        if durability < 0 then
            durability = 0
        end

        -- Mise à jour de la durabilité dans les métadonnées de l'item
        toolItem.metadata.durability = durability

        -- Mettre à jour l'inventaire du joueur avec la nouvelle durabilité
        xPlayer.setInventoryItem(Config.ToolName, toolItem.count, toolItem.metadata)

        -- Notification de durabilité réduite (si souhaité, vous pouvez ajouter des notifications côté client)
    else
        -- Le joueur n'a pas de sécateur (vous pouvez gérer cela si nécessaire)
    end
end)

-- Callback pour réparer le sécateur
ESX.RegisterServerCallback('vigneron:repairTool', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local toolItem = xPlayer.getInventoryItem(Config.ToolName)

    if toolItem and toolItem.count > 0 then
        local durability = toolItem.metadata and toolItem.metadata.durability or Config.MaxDurability

        -- Vérifier si la réparation est possible (durabilité < 80)
        if durability < Config.MinDurabilityToRepair then
            -- Remettre la durabilité à son maximum
            toolItem.metadata.durability = Config.MaxDurability

            -- Mettre à jour l'inventaire du joueur avec la nouvelle durabilité
            xPlayer.setInventoryItem(Config.ToolName, toolItem.count, toolItem.metadata)

            cb(true)
        else
            cb(false)  -- La réparation n'est pas nécessaire
        end
    else
        cb(false)  -- Pas de sécateur trouvé
    end
end)
