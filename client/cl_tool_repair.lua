ESX = ESX or exports['es_extended']:getSharedObject()

-- Configuration centralisée
local Config = {
    RepairLocations = {
        { coords = vector3(1187.45, 2641.67, 37.05), label = 'Réparer Sécateur' }
    },
    RepairAnimation = {
        Dict = "mini@repair",
        Anim = "fixing_a_player",
        Duration = 5000 -- Durée de l'animation en millisecondes
    },
    RepairDistance = 2.0,
    MaxDurability = 100,
    MinDurabilityToRepair = 80,
    ToolName = 'secateur',
    Notifications = {
        Success = {
            title = 'Réparation réussie',
            description = 'Votre sécateur a été réparé avec succès !',
            type = 'success',
            duration = 5000, -- en millisecondes
            icon = 'fa-solid fa-thumbs-up'
        },
        Failure = {
            title = 'Échec de la réparation',
            description = 'La réparation a échoué. Veuillez réessayer.',
            type = 'error',
            duration = 5000, -- en millisecondes
            icon = 'fa-solid fa-times-circle'
        },
        TooFar = {
            title = 'Trop éloigné',
            description = 'Vous êtes trop loin du point de réparation.',
            type = 'warning',
            duration = 3000, -- en millisecondes
            icon = 'fa-solid fa-exclamation-triangle'
        },
        ToolTooNew = {
            title = 'Réparation inutile',
            description = 'Votre sécateur est encore en bon état (≥ 80%).',
            type = 'inform',
            duration = 4000, -- en millisecondes
            icon = 'fa-solid fa-wrench'
        },
        NoTool = {
            title = 'Aucun sécateur',
            description = 'Vous n\'avez pas de sécateur sur vous pour effectuer cette réparation.',
            type = 'error',
            duration = 5000, -- en millisecondes
            icon = 'fa-solid fa-tools'
        }
    },
    Effects = {
        RepairSound = 'GENERIC_BOMB_DISARM',
        RepairParticle = 'core',
        RepairParticleFx = 'ent_dst_electrical'
    }
}

-- Chargement des animations
local function LoadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(100)
    end
end

-- Fonction de notification centralisée
local function SendNotification(notification)
    lib.notify({
        title = notification.title,
        description = notification.description,
        type = notification.type,
        duration = notification.duration,
        icon = notification.icon
    })
end

-- Fonction pour jouer un effet sonore
local function PlayRepairSound()
    PlaySoundFrontend(-1, Config.Effects.RepairSound, "HUD_MINI_GAME_SOUNDSET", true)
end

-- Fonction pour jouer un effet visuel
local function PlayRepairParticle(coords)
    UseParticleFxAssetNextCall(Config.Effects.RepairParticle)
    StartParticleFxNonLoopedAtCoord(Config.Effects.RepairParticleFx, coords.x, coords.y, coords.z + 1.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
end

-- Initialisation des points de réparation
CreateThread(function()
    for _, location in ipairs(Config.RepairLocations) do
        exports.ox_target:addBoxZone({
            coords = location.coords,
            size = vec3(2, 2, 2),
            options = {
                {
                    label = location.label,
                    icon = 'fa-solid fa-wrench',
                    distance = Config.RepairDistance,
                    onSelect = function()
                        local playerPed = PlayerPedId()
                        local playerCoords = GetEntityCoords(playerPed)

                        -- Vérification de la distance
                        if #(playerCoords - location.coords) <= Config.RepairDistance then
                            -- Vérification si le joueur a un sécateur sur lui
                            ESX.TriggerServerCallback('vigneron:hasTool', function(hasTool, durability)
                                if hasTool then
                                    if durability < Config.MinDurabilityToRepair then
                                        -- Charger et jouer l'animation de réparation
                                        LoadAnimDict(Config.RepairAnimation.Dict)
                                        TaskPlayAnim(playerPed, Config.RepairAnimation.Dict, Config.RepairAnimation.Anim, 8.0, -8.0, Config.RepairAnimation.Duration, 1, 0, false, false, false)
                                        
                                        -- Jouer le son de réparation
                                        PlayRepairSound()

                                        -- Délai pour la durée de l'animation
                                        Wait(Config.RepairAnimation.Duration)

                                        -- Effet visuel à la fin de la réparation
                                        PlayRepairParticle(location.coords)

                                        -- Réparation sur le serveur
                                        ESX.TriggerServerCallback('vigneron:repairTool', function(success)
                                            if success then
                                                SendNotification(Config.Notifications.Success)
                                            else
                                                SendNotification(Config.Notifications.Failure)
                                            end
                                        end)
                                    else
                                        SendNotification(Config.Notifications.ToolTooNew)
                                    end
                                else
                                    SendNotification(Config.Notifications.NoTool)
                                end
                            end, Config.ToolName)
                        else
                            SendNotification(Config.Notifications.TooFar)
                        end
                    end
                }
            }
        })
    end
end)
