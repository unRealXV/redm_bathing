fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

name 'redm_bathing'
description 'ported from rsg-bathing by unRealXV'
version '1.0.0'

shared_scripts {
    'config.lua'
}

client_scripts {
    'client/client.lua',
    'client/structs.js'
}

server_scripts {
    'server/server.lua'
}

files {
    'locales/*.lua'
}

dependencies {
    'vorp_core',
    'vorp_character',
}

lua54 'yes'
