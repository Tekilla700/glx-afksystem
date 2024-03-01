local QBCore = exports[Config.CoreName]:GetCoreObject()

QBCore.Functions.CreateCallback('glx-AFK:server:GetPermissions', function(source, cb)
    cb(QBCore.Functions.GetPermission(source))
end)

RegisterNetEvent('playerWentAFK')
AddEventHandler('playerWentAFK', function()
    local webhookUrl = Config.WebhookUrl
    local playerName = GetPlayerName(source)
    local player = QBCore.Functions.GetPlayer(source)

    if player then
        local playerLicense = player.PlayerData.license
        local playerCitizenID = player.PlayerData.citizenid
        local playerFirstName = player.PlayerData.charinfo.firstname
        local playerLastName = player.PlayerData.charinfo.lastname

        local embedData = {
            {
                ['title'] = 'Player Went AFK',
                ['color'] = 16711680, 
                ['footer'] = {
                    ['text'] = os.date('%c'),
                },
                ['description'] = playerName .. ' has gone AFK!\nLicense: ' .. playerLicense .. '\nCitizen ID: ' .. playerCitizenID .. '\nName: ' .. playerFirstName .. ' ' .. playerLastName,
                ['author'] = {
                    ['name'] = 'AFK LOGS',
                    ['icon_url'] = 'https://cdn.discordapp.com/attachments/1060772347986055180/1212945626992476230/myLogo.png?ex=65f3aea4&is=65e139a4&hm=e04344ea59bd12e3dd26822c10a1ab6024da1cb428e4060a9d924c174c8b8f0f&', -- Replace with your own icon URL
                },
            }
        }

        PerformHttpRequest(webhookUrl, function(err, text, headers) end, 'POST', json.encode({ username = 'AFK LOGS', embeds = embedData}), { ['Content-Type'] = 'application/json' })
    end
end)
