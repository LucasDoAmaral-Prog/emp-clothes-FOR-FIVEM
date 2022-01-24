fx_version 'adamant'
game 'gta5'

author 'VoltzDev'
lua54 'yes'

ui_page 'Interface/index.html'

client_scripts {
    
	'@vrp/lib/utils.lua',
	'config.lua',
	'client.lua'
}

server_scripts {

	'@vrp/lib/utils.lua',
	'config.lua',
	'server.lua'
}

files{

	'Interface/index.html',
	'Interface/style.css',
	'Interface/script.js',

	'Interface/assets/*',

}

