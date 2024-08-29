Config = {}
Config.Locale = 'fr' -- or 'en'
Config.Items = {} -- Initialisation correcte de Config.Items

Config.WinePriceMultiplier = 1.0 -- Modificateur de prix par défaut

Config.Tools = {
    ['secateur'] = {
        label = 'Secateur',
        durability = 100
    }
}

Locales = {
    ['fr'] = {
        ['harvest_grapes'] = 'Récolter des raisins',
    ['processing_grapes'] = 'Traitement des raisins',
    ['npc_menu_title'] = 'Panel Vigneron',
    ['view_employees'] = 'Voir les employés en service',
    ['check_wine_price'] = 'Voir le prix du vin actuel',
    ['call_dealer'] = 'Appeler le revendeur',
    ['start_shift'] = 'Prendre service',
    ['end_shift'] = 'Finir service',
    ['failed_harvest'] = 'Vous avez raté la récolte.',
    ['failed_processing'] = 'Le traitement a échoué.',
    ['start_shift_msg'] = 'Vous avez pris votre service.',
    ['end_shift_msg'] = 'Vous avez terminé votre service.',
    ['dealer_arrival'] = 'Le revendeur est arrivé, chargez le vin dans le van.',
    ['delivery_complete'] = 'Livraison complète. Vous avez reçu votre paiement.',
    ['inventory_full'] = 'Vous n\'avez pas assez de place.',
    ['not_enough_grapes'] = 'Vous n\'avez pas assez de raisins.',
    ['paid'] = 'Vous avez été payé.',
    ['wine_price_update'] = 'Le prix actuel du vin est de $%s par bouteille.',
    ['use_wine'] = 'Vous avez utilisé une bouteille de vin.',
    ['tool_durability'] = 'Votre outil a %s%% de durabilité restante.',
    ['tool_broken'] = 'Votre outil est cassé.',
    ['no_tool'] = 'Vous n\'avez pas l\'outil nécessaire.',
    ['van_spawn_failed'] = 'Échec du spawn de la camionnette',
    ['model_not_loaded'] = 'Le modèle du véhicule n\'est pas chargé.',
    ['van_not_spawned'] = 'La camionnette n\'a pas pu être créée.',
    ['driver_not_spawned'] = 'Le conducteur n\'a pas pu être créé.',
    ['van_lost'] = 'Camionnette Perdue',
    ['van_not_arrived'] = 'La camionnette n\'est pas arrivée.',
    ['bad_weather'] = 'Mauvais temps',
    ['harvest_difficult'] = 'Il est difficile de récolter par ce temps.',
    ['loading_wine'] = 'Chargement du vin...',
    ['load_wine'] = 'Charger le vin',
    ['repair_tool'] = 'Réparer l\'outil',
    ['tool_repaired'] = 'Outil réparé',
    ['tool_repaired_desc'] = 'Votre outil a été réparé avec succès.',
    ['repair_failed'] = 'Réparation échouée',
    ['repair_failed_desc'] = 'La réparation de l\'outil a échoué. Essayez plus tard.',
    ['tool_required'] = 'Vous avez besoin d\'un sécateur pour récolter les raisins.'
    },
    ['en'] = {
    ['harvest_grapes'] = 'Harvest Grapes',
    ['processing_grapes'] = 'Processing Grapes',
    ['npc_menu_title'] = 'Vigneron Panel',
    ['view_employees'] = 'View On-Duty Employees',
    ['check_wine_price'] = 'Check Current Wine Price',
    ['call_dealer'] = 'Call the Dealer',
    ['start_shift'] = 'Start Shift',
    ['end_shift'] = 'End Shift',
    ['failed_harvest'] = 'You failed to harvest the grapes.',
    ['failed_processing'] = 'You failed to process the grapes.',
    ['start_shift_msg'] = 'You have started your shift.',
    ['end_shift_msg'] = 'You have ended your shift.',
    ['dealer_arrival'] = 'The dealer has arrived, load the wine into the van.',
    ['delivery_complete'] = 'Delivery complete. You received your payment.',
    ['inventory_full'] = 'You don\'t have enough space.',
    ['not_enough_grapes'] = 'You don\'t have enough grapes.',
    ['paid'] = 'You have been paid.',
    ['wine_price_update'] = 'The current wine price is $%s per bottle.',
    ['use_wine'] = 'You used a bottle of wine.',
    ['tool_durability'] = 'Your tool has %s%% durability left.',
    ['tool_broken'] = 'Your tool is broken.',
    ['no_tool'] = 'You don\'t have the necessary tool.',
    ['van_spawn_failed'] = 'Van Spawn Failed',
    ['model_not_loaded'] = 'Vehicle model not loaded.',
    ['van_not_spawned'] = 'Van could not be spawned.',
    ['driver_not_spawned'] = 'Driver could not be spawned.',
    ['van_lost'] = 'Van Lost',
    ['van_not_arrived'] = 'The van did not arrive.',
    ['bad_weather'] = 'Bad Weather',
    ['harvest_difficult'] = 'It is difficult to harvest in this weather.',
    ['loading_wine'] = 'Loading Wine...',
    ['load_wine'] = 'Load Wine',
    ['repair_tool'] = 'Repair Tool',
    ['tool_repaired'] = 'Tool Repaired',
    ['tool_repaired_desc'] = 'Your tool has been successfully repaired.',
    ['repair_failed'] = 'Repair Failed',
    ['repair_failed_desc'] = 'The tool repair failed. Try again later.',
    ['tool_required'] = 'You need a secateur to harvest grapes.'
 		 }
}

function _U(entry, ...)
    if Locales[Config.Locale] and Locales[Config.Locale][entry] then
        return string.format(Locales[Config.Locale][entry], ...)
    else
        return 'Translation [' .. entry .. '] does not exist'
    end
end

Config.Levels = {
    [1] = { xpRequired = 0,   label = "Apprenti Vigneron" },
    [2] = { xpRequired = 1000, label = "Vigneron Junior" },
    [3] = { xpRequired = 2500, label = "Vigneron" },
    [4] = { xpRequired = 5000, label = "Vigneron Expérimenté" },
    [5] = { xpRequired = 10000, label = "Maître Vigneron" }
}

Config.XPPerHarvest = 10 -- XP gagné par récolte

Config.GrapeTypes = {
    [1] = 'grape_basic',
    [2] = 'grape_good',
    [3] = 'grape_good',
    [4] = 'grape_premium',
    [5] = 'grape_premium'
}

Config.Items = {
    ['grape_basic'] = { label = 'Grappes Basique' },
    ['grape_good'] = { label = 'Grappes de Bonne Qualité' },
    ['grape_premium'] = { label = 'Grappes Premium' }
}

-- Modificateurs de qualité
Config.QualityModifiers = {
    badWeather = -20,
    goodTool = 10,
    experienceBonus = 5
}

Config.HarvestLocations = {
    { coords = vector3(2000.0, 5000.0, 41.0) },
    { coords = vector3(2010.0, 4995.0, 42.0) },
    { coords = vector3(2020.0, 5005.0, 43.0) },
    { coords = vector3(2030.0, 5010.0, 44.0) },
    { coords = vector3(2040.0, 5020.0, 45.0) },
    { coords = vector3(2050.0, 5030.0, 46.0) },
    { coords = vector3(2060.0, 5040.0, 47.0) },
    { coords = vector3(2070.0, 5050.0, 48.0) }
}
