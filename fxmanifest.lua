fx_version 'cerulean'
game 'gta5'

author 'SkillOneKill'
description 'Auftragssystem für bestimmte Jobs mit Cooldown, Items, und Belohnung'
version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', 
    'config.lua',
    'server.lua'
}

dependencies {
    'es_extended',
    'ox_inventory',
    'ox_target',
    'ox_lib'
}

shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'
lua54 'yes'
