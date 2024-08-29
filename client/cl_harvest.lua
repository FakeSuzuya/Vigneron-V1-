-- cl_harvest.lua
ESX = ESX or exports['es_extended']:getSharedObject()
local isBadWeather = false
local activeHarvestPoint = nil
local harvestBlip = nil
local harvestCount = 0
local rewardThreshold = 5  -- Récompense toutes les 5 récoltes
local currentLevel = 1

-- Vérification du mauvais temps toutes les 30 secondes
CreateThread(function()
    while true do
        Wait(30000)
        local weather = GetWeatherTypeTransition()
        isBadWeather = (weather == 'THUNDER' or weather == 'CLEARING' or weather == 'XMAS')
    end
end)

-- Sélection aléatoire d'un point de récolte parmi les 8 points définis
function selectRandomHarvestPoint()
    local randomIndex = math.random(1, #Config.HarvestLocations)
    activeHarvestPoint = Config.HarvestLocations[randomIndex]

    -- Ajouter un blip pour le point de récolte
    if harvestBlip then
        RemoveBlip(harvestBlip)
    end
    harvestBlip = AddBlipForCoord(activeHarvestPoint.coords)
    SetBlipSprite(harvestBlip, 1)
    SetBlipDisplay(harvestBlip, 4)
    SetBlipScale(harvestBlip, 0.8)
    SetBlipColour(harvestBlip, 2)
    SetBlipAsShortRange(harvestBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(_U('harvest_grapes'))
    EndTextCommandSetBlipName(harvestBlip)
end

-- Création de la zone de récolte
function createHarvestZone()
    if activeHarvestPoint then
        exports.ox_target:addSphereZone({
            coords = activeHarvestPoint.coords,
            radius = 2.0,
            options = {
                {
                    label = _U('harvest_grapes'),
                    icon = 'hand',
                    onSelect = function()
                        ESX.TriggerServerCallback('vigneron:checkToolAndExperience', function(hasTool, durability, experience)
                            if not hasTool then
                                lib.notify({
                                    title = _U('no_tool'),
                                    description = _U('tool_required'),
                                    type = 'error'
                                })
                                return
                            end

                            -- Notification en cas de mauvais temps
                            if isBadWeather then
                                lib.notify({
                                    title = 'Attention!',
                                    description = 'Le mauvais temps peut affecter la qualité des grappes.',
                                    type = 'warning'
                                })
                            end

                            -- Démarrage de l'animation de récolte
                            startHarvestAnimation()

                            local quality = calculateGrapeQuality(durability, experience)
                            TriggerServerEvent('vigneron:giveGrapes', quality, experience)
                            TriggerServerEvent('vigneron:reduceToolDurability')
                            TriggerServerEvent('vigneron:addXP', Config.XPPerHarvest)

                            -- Effet visuel après la récolte
                            playHarvestEffect(activeHarvestPoint.coords)

                            -- Fin de l'animation après un certain temps
                            Wait(5000)
                            ClearPedTasks(PlayerPedId())

                            lib.notify({
                                title = 'Récolte Terminée',
                                description = 'Vous avez terminé de récolter.',
                                type = 'success'
                            })

                            -- Mise à jour du niveau et attribution de la récompense
                            updateLevelAndReward(experience + Config.XPPerHarvest)

                            -- Changement du point de récolte après une récolte réussie
                            selectRandomHarvestPoint()
                            createHarvestZone()
                        end)
                    end
                }
            }
        })
    end
end

-- Mise à jour du niveau et attribution de la récompense
function updateLevelAndReward(newXP)
    local newLevel = currentLevel

    for level, data in pairs(Config.Levels) do
        if newXP >= data.xpRequired and level > newLevel then
            newLevel = level
        end
    end

    if newLevel > currentLevel then
        currentLevel = newLevel
        local reward = 10000 * currentLevel  -- Récompense de 10000$ par niveau atteint
        lib.notify({
            title = 'Niveau Atteint!',
            description = string.format('Félicitations! Vous êtes maintenant %s et avez reçu $%d.', Config.Levels[currentLevel].label, reward),
            type = 'success'
        })
        TriggerServerEvent('vigneron:giveReward', reward)
    end
end

-- Fonction pour jouer un effet visuel lors de la récolte
function playHarvestEffect(coords)
    local particleDict = "core"
    local particleName = "ent_sht_electrical_box_sp"
    RequestNamedPtfxAsset(particleDict)
    while not HasNamedPtfxAssetLoaded(particleDict) do
        Wait(100)
    end
    UseParticleFxAssetNextCall(particleDict)
    StartParticleFxNonLoopedAtCoord(particleName, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
end

-- Fonction pour démarrer l'animation de récolte
function startHarvestAnimation()
    local playerPed = PlayerPedId()
    RequestAnimDict('amb@prop_human_bum_bin@base')
    while not HasAnimDictLoaded('amb@prop_human_bum_bin@base') do
        Wait(100)
    end
    TaskPlayAnim(playerPed, 'amb@prop_human_bum_bin@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
end

-- Calcul de la qualité des grappes
function calculateGrapeQuality(durability, experience)
    local baseQuality = math.random(70, 100)
    local hour = GetClockHours()

    -- Bonus si la récolte se fait entre 18h et 6h
    if hour >= 18 or hour <= 6 then
        baseQuality = baseQuality + 5
        lib.notify({
            title = 'Récolte Nocturne',
            description = 'Les températures fraîches de la nuit ont amélioré la qualité des grappes.',
            type = 'info'
        })
    end

    -- Chance de bonus aléatoire
    if math.random(1, 100) <= 10 then  -- 10% de chance d'avoir un bonus
        baseQuality = baseQuality + 10
        lib.notify({
            title = 'Bonus!',
            description = 'Vous avez reçu un bonus pour cette récolte!',
            type = 'success'
        })
    end

    -- Multiplicateur en fonction de l'expérience
    if experience > 1000 then
        baseQuality = baseQuality + 10  -- Bonus pour les joueurs expérimentés
        lib.notify({
            title = 'Expert Récolteur',
            description = 'Votre expérience vous permet de récolter des grappes de meilleure qualité.',
            type = 'info'
        })
    end

    if isBadWeather then
        baseQuality = baseQuality + Config.QualityModifiers.badWeather
    end

    if durability > 80 then
        baseQuality = baseQuality + Config.QualityModifiers.goodTool
    end

    baseQuality = baseQuality + (experience * Config.QualityModifiers.experienceBonus)

    local grapeQuality = math.max(baseQuality, 50)  -- S'assurer que la qualité ne descend pas en dessous de 50

    -- Notifications en fonction de la qualité
    if grapeQuality > 90 then
        lib.notify({
            title = 'Récolte Excellente!',
            description = 'Vous avez récolté des grappes de qualité supérieure.',
            type = 'success'
        })
    elseif grapeQuality > 70 then
        lib.notify({
            title = 'Récolte Bonne!',
            description = 'Vous avez récolté des grappes de bonne qualité.',
            type = 'info'
        })
    else
        lib.notify({
            title = 'Récolte Moyenne...',
            description = 'Les grappes récoltées sont de qualité moyenne.',
            type = 'warning'
        })
    end

    return grapeQuality
end

-- Initialisation du point de récolte au début de la session
CreateThread(function()
    selectRandomHarvestPoint()
    createHarvestZone()
end)
