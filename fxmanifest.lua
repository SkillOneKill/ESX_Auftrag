fx_version 'cerulean'
game 'gta5'

author 'Dein Name'
description 'Auftragssystem für bestimmte Jobs mit Cooldown, Items, und Belohnung'
version '1.0.0'

-- Client und Server Scripte
client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua', -- falls du MySQL brauchst
    'config.lua',
    'server.lua'
}

-- Abhängigkeiten
dependencies {
    'es_extended',
    'ox_inventory',
    'ox_target',
    'ox_lib'
}

-- Ressourcen, die als Shared genutzt werden können
shared_script '@es_extended/imports.lua'
shared_script '@ox_lib/init.lua'

lua54 'yes'
