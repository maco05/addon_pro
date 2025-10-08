fx_version 'cerulean'
game 'gta5'

author 'maco_05'
description 'Anticheat Addon'
version '1.0.0'

data_file "DLC_ITYP_REQUEST" "stream/mads_no_exp_pumps.ytyp"

shared_script 'config.lua'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}
