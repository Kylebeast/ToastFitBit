local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateUseableItem("fitbit", function(source, item)
    TriggerClientEvent("fitbit:client:use", source)
end)

local function clamp(n, min, max)
    n = tonumber(n) or 0
    if n < min then return min end
    if n > max then return max end
    return n
end

QBCore.Functions.CreateCallback('fitbit:server:getSettings', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then cb(nil) return end

    local meta = Player.PlayerData.metadata or {}
    cb(meta.fitbit or nil)
end)

RegisterNetEvent('fitbit:server:saveSettings', function(settings)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    settings = settings or {}

    -- defaults + clamps
    local cleaned = {
        enabled = settings.enabled == true,

        health = {
            enabled = settings.health and settings.health.enabled == true,
            threshold = clamp(settings.health and settings.health.threshold, 1, 100),
            step = clamp(settings.health and settings.health.step, 1, 50),
        },

        hunger = {
            enabled = settings.hunger and settings.hunger.enabled == true,
            threshold = clamp(settings.hunger and settings.hunger.threshold, 1, 100),
            step = clamp(settings.hunger and settings.hunger.step, 1, 50),
        },

        thirst = {
            enabled = settings.thirst and settings.thirst.enabled == true,
            threshold = clamp(settings.thirst and settings.thirst.threshold, 1, 100),
            step = clamp(settings.thirst and settings.thirst.step, 1, 50),
        },
    }

    Player.Functions.SetMetaData('fitbit', cleaned)
end)