------------------------------------------------------------------------------
----------------------------  GLX DEVELOPEMENT  ------------------------------
------------------------------------------------------------------------------
----------------------  https://discord.gg/sYG2WnpQa7  -----------------------
------------------------------------------------------------------------------
------------------------------------------------------------------------------



Config = {}

Config.CoreName = 'qb-core'

Config.AFK = {
    ignoredGroups = {
        ['mod'] = true,
        ['admin'] = true,
        ['god'] = true
    },
    secondsUntilTP = 1800,    
    TPInCharMenu = false 
}

Config.WebhookUrl = "https://discord.com/api/webhooks/1091970338851668071/YRCWtDtcrOS--I6l11zrD2mXrHTSYmuB8VKgdNoQOcN90-cQMZc0JTMGA4aHMKFPCpqA"

Config.afkLocation = vector3(-1334.53, 147.95, -99.19)

Config.afkRadius = 5 

Config.AFKCameraCoords = vector3(-1344.6, 136.83, -97.13)

Config.AFKCameraRotation = vector3(-20.0, 0.0, -45.0)

Config.goafkCommand = true

Config.animations = {
    { animDict = 'timetable@tracy@sleep@', animName = 'base' },
    { animDict = 'amb@world_human_bum_slumped@male@laying_on_left_side@idle_a', animName = 'idle_b' },
    { animDict = 'timetable@jimmy@mics3_ig_15@', animName = 'idle_a_jimmy' },
    -- Add more animations here if needed
}

