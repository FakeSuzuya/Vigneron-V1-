fx_version 'cerulean'
game 'gta5'

author 'JustSuzuya'
description 'Job de Vigneron avec système de récolte'
version '1.2.1'

client_scripts {
    'client/cl_harvest.lua',
    'client/cl_process.lua',
    'client/cl_npc_interaction.lua',
    'client/cl_van_delivery.lua',
    'client/cl_shift.lua',
    'client/cl_tool_repair.lua',
    'client/cl_boss_interaction.lua',
    'client/cl_storage.lua',
    'client/cl_quality.lua',
    'client/cl_blips.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/sv_inventory.lua',
    'server/sv_vigneron.lua',
    'server/sv_market.lua',
    'server/sv_boss.lua',
    'server/sv_storage.lua',
    'server/sv_tools.lua',
    'server/sv_harvest.lua'
}

shared_scripts {
    'shared/sh_config.lua',
    'shared/sh_items.lua'
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/styles.css',
    'ui/menu.js',
    'ui/bossMenu.js',
    'ui/bossMenu.html',
    'ui/bossMenu.css',
    'ui/logo.png', -- Ajoutez les autres fichiers UI si nécessaire
    'ui/market_update.png'
}

dependencies {
    'es_extended',
    'ox_target',
    'ox_lib'
}
