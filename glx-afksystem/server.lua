local QBCore = exports[Config.CoreName]:GetCoreObject()

QBCore.Functions.CreateCallback('glx-AFK:server:GetPermissions', function(source, cb)
    cb(QBCore.Functions.GetPermission(source))
end)
