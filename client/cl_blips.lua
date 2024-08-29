-- blips.lua
local blipLocation = vector3(-1888.87, 2060.49, 140.98) -- Coordonnées du blip
local blipSprite = 478 -- Icône du blip (par exemple, 85 pour un magasin)
local blipColor = 50 -- Couleur du blip (par exemple, 2 pour vert)
local blipScale = 0.8 -- Taille du blip

CreateThread(function()
    -- Créer le blip
    local blip = AddBlipForCoord(blipLocation.x, blipLocation.y, blipLocation.z)
    
    -- Configurer le blip
    SetBlipSprite(blip, blipSprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipScale)
    SetBlipColour(blip, blipColor)
    SetBlipAsShortRange(blip, true)

    -- Donner un nom au blip
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Vignoble") -- Nom personnalisé
    EndTextCommandSetBlipName(blip)
end)
