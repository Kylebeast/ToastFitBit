fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Kyle'
description 'QBCore Fitbit item w/ NUI alerts'
version '1.0.0'

shared_scripts {
  'config.lua',
  '@qb-core/shared/locale.lua'
}

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
  'config.lua',
  'html/index.html',
  'html/style.css',
  'html/app.js'
}