local QBCore = exports[Config.CoreName]:GetCoreObject()
local isLoggedIn = LocalPlayer.state.isLoggedIn
local checkUser = true
local prevPos = nil
local timeMinutes = {
    ['900'] = 'minutes',
    ['600'] = 'minutes',
    ['300'] = 'minutes',
    ['150'] = 'minutes',
    ['60'] = 'minutes',
    ['30'] = 'seconds',
    ['20'] = 'seconds',
    ['10'] = 'seconds',
}


local afkLocation = Config.afkLocation
local afkRadius = Config.afkRadius 
local isAFK = false 
local originalLocation = nil 
local inAFKLocation = false
local isNotificationShown = false
local showAfkText = false

local function updatePermissionLevel()
    QBCore.Functions.TriggerCallback('glx-AFK:server:GetPermissions', function(userGroups)
        for k in pairs(userGroups) do
            if Config.AFK.ignoredGroups[k] then
                checkUser = false
                break
            end
            checkUser = true
        end
    end)
end

local function GetRandomAfkLocations(center, radius)
    local angle = math.rad(math.random(0, 360))
    local distance = math.random() * radius
    local x = center.x + distance * math.cos(angle)
    local y = center.y + distance * math.sin(angle)
    local z = center.z 
    return vector3(x, y, z)
end

local randomAfkLocation = GetRandomAfkLocations(afkLocation, afkRadius)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    updatePermissionLevel()
    isLoggedIn = true
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnPermissionUpdate')
AddEventHandler('QBCore:Client:OnPermissionUpdate', function()
    updatePermissionLevel()
end)

function TeleportPlayerToLocation(x, y, z)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, x, y, z, false, false, false, false)
end

function StoreInitialLocation()
    local playerPed = PlayerPedId()
    local x, y, z = table.unpack(GetEntityCoords(playerPed, true))
    originalLocation = vector3(x, y, z)
end

function TeleportBackToInitialLocation()
    if isAFK and originalLocation then
        TeleportPlayerToLocation(originalLocation.x, originalLocation.y, originalLocation.z)
        FreezeEntityPosition(PlayerPedId(), false)
        isAFK = false
        inAFKLocation = false
        originalLocation = nil 
        TriggerEvent('cd_drawtextui:HideUI')
    end
end

function PlayRandomAnimation()
    local animations = Config.animations

    local randomIndex = math.random(1, #animations)
    local randomAnimation = animations[randomIndex]

    RequestAnimDict(randomAnimation.animDict)
    while not HasAnimDictLoaded(randomAnimation.animDict) do
        Citizen.Wait(500)
    end

    TaskPlayAnim(PlayerPedId(), randomAnimation.animDict, randomAnimation.animName, 8.0, -8.0, -1, 1, 0, false, false, false)
end

function DrawTxt(x, y, width, height, scale, text, r, g, b, a, _)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end


CreateThread(function()
    while true do
        Citizen.Wait(10000)
        local playerPed = PlayerPedId()
        if isLoggedIn == true or Config.AFK.TPInCharMenu == true then
            if checkUser then
                local currentPos = GetEntityCoords(playerPed, true)
                if prevPos then
                    if currentPos == prevPos then
                        if time then
                            if time > 0 then
                                local _type = timeMinutes[tostring(time)]
                                if _type == 'minutes' then
                                    if not isAFK and not isNotificationShown then 
                                        QBCore.Functions.Notify('You are AFK and will be teleported to AFK area in ' .. math.ceil(time / 60) .. ' minute(s)!', 'error')
                                        isNotificationShown = true 
                                    end
                                elseif _type == 'seconds' then
                                    if not isAFK and not isNotificationShown then 
                                        QBCore.Functions.Notify('You are AFK and will be teleported to AFK area in ' .. time .. ' seconds!', 'error')
                                        isNotificationShown = true 
                                    end
                                end
                                time = time - 10
                            else
                                if not originalLocation then
                                    StoreInitialLocation()
                                end

                                if not inAFKLocation then
                                    local AFKcamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)

                                    TeleportPlayerToLocation(randomAfkLocation.x, randomAfkLocation.y, randomAfkLocation.z)
                                    showAfkText = true  
                                    
                                    SetCamCoord(AFKcamera, Config.AFKCameraCoords.x, Config.AFKCameraCoords.y, Config.AFKCameraCoords.z)
                                    SetCamRot(AFKcamera, Config.AFKCameraRotation.x, Config.AFKCameraRotation.y, Config.AFKCameraRotation.z)
                                    RenderScriptCams(true, false, 0, true, true)
                                    SetTimecycleModifier("scanline_cam_cheap")
                                    SetTimecycleModifierStrength(1.0)
                                    Citizen.Wait(1000)
                                    PlayRandomAnimation() 
                                    isAFK = true
                                    inAFKLocation = true
                                end
                            end
                        else
                            time = Config.AFK.secondsUntilTP
                        end
                    else
                        time = Config.AFK.secondsUntilTP
                        isNotificationShown = false 
                    end
                end
                prevPos = currentPos
            end
        end
    end
end)

Citizen.CreateThread(function()	
	while true do
		Citizen.Wait(1000)
	
		if inAFKLocation then
			local player = PlayerId()
			local playerPed = PlayerPedId()
			
			DisablePlayerFiring(player,true)
            FreezeEntityPosition(PlayerPedId(), true)
			SetPlayerInvincible(player, true)
            NetworkSetFriendlyFireOption(false)
			ClearPlayerWantedLevel(PlayerId())
		else
			local player = PlayerPedId()
            
            DisablePlayerFiring(player,false)
			SetPlayerInvincible(player, false)
            NetworkSetFriendlyFireOption(true)

		end
	end
end)

CreateThread(function()
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        
        if showAfkText then
            local coords = GetEntityCoords(playerPed)
            local distance = #(vector3(randomAfkLocation.x, randomAfkLocation.y, randomAfkLocation.z) - coords)
            
            if distance <= 10.0 then
                DrawTxt(0.93, 1.44, 1.0, 1.0, 0.6, '[~g~E~s~] to quit AFK ZONE', 255, 255, 255, 255)

                if IsControlJustReleased(0, 38) then
                    TeleportBackToInitialLocation()
                    ClearPedTasks(PlayerPedId())
                    
                    RenderScriptCams(false, false, 0, true, true)
                    DestroyCam(AFKcamera, false)
                    ClearTimecycleModifier("scanline_cam_cheap")
                    
                    isNotificationShown = false
                    showAfkText = false
                end
            end
        end
    end
end)


RegisterCommand("goafk", function()
    if Config.goafkCommand then
        if not originalLocation then
            StoreInitialLocation()
        end
    
        if not inAFKLocation then
            local AFKcamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    
            TeleportPlayerToLocation(randomAfkLocation.x, randomAfkLocation.y, randomAfkLocation.z)
            showAfkText = true 
            SetCamCoord(AFKcamera, Config.AFKCameraCoords.x, Config.AFKCameraCoords.y, Config.AFKCameraCoords.z)
            SetCamRot(AFKcamera, Config.AFKCameraRotation.x, Config.AFKCameraRotation.y, Config.AFKCameraRotation.z)
            RenderScriptCams(true, false, 0, true, true)
            SetTimecycleModifier("scanline_cam_cheap")
            SetTimecycleModifierStrength(1.0)
            Citizen.Wait(1000)
            PlayRandomAnimation() 
            isAFK = true
            inAFKLocation = true
        end
    end    
end)





