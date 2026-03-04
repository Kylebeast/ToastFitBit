Config = Config or {}
print("^1^^^^^^^^^^^^ TOASTFITBIT CONFIG LOADED ^^^^^^^^^^^^")
local QBCore = exports['qb-core']:GetCoreObject()

local settings = nil
local fitbitOpen = false

local lastNotified = {
    health = 101,
    hunger = 101,
    thirst = 101
}

local function toInt(n)
    n = tonumber(n) or 0
    return math.floor(n + 0.5)
end

local function notify(msg, ntype)
    local notifyType = ntype or "inform"

    if Config.Notify == "qb" then
        QBCore.Functions.Notify(msg, notifyType)

    elseif Config.Notify == "ox" then
        TriggerEvent('ox_lib:notify', {
            title = 'Fitbit',
            description = msg,
            type = notifyType
        })

    elseif Config.Notify == "mythic" then
        TriggerEvent('mythic_notify:client:SendAlert', {
            type = notifyType,
            text = msg
        })

    elseif Config.Notify == "okok" then
        exports['okokNotify']:Alert("Fitbit", msg, 3000, notifyType)

    elseif Config.Notify == "custom" then
        TriggerEvent(Config.CustomNotifyEvent, msg, notifyType)

    elseif Config.Notify == "none" then
    end
end

local function resetNotifyTrackers()
    lastNotified.health = 101
    lastNotified.hunger = 101
    lastNotified.thirst = 101
end

local function isDowned()
    local pData = QBCore.Functions.GetPlayerData()
    local meta = (pData and pData.metadata) or {}

    if meta.isdead == true then return true end
    if meta.inlaststand == true then return true end

    if tonumber(meta.isdead) == 1 then return true end
    if tonumber(meta.inlaststand) == 1 then return true end

    local ped = PlayerPedId()
    if IsEntityDead(ped) or IsPedFatallyInjured(ped) then return true end

    return false
end

local function getHealthPercent()
    if isDowned() then
        return 0
    end

    local ped = PlayerPedId()
    local hp = GetEntityHealth(ped)

    -- Standard GTA/QB: 100 = dead baseline, 200 = full
    local pct = ((hp - 100) / 100) * 100

    if pct < 0 then pct = 0 end
    if pct > 100 then pct = 100 end

    return math.floor(pct + 0.5)
end

local function getHungerThirst()
    local pData = QBCore.Functions.GetPlayerData()
    local meta = (pData and pData.metadata) or {}
    local hunger = tonumber(meta.hunger) or 100
    local thirst = tonumber(meta.thirst) or 100
    return hunger, thirst
end

local function getDefaultSettings()
    if Config and Config.DefaultSettings then
        return Config.DefaultSettings
    end

    return {
        enabled = true,
        health = { enabled = true, threshold = 35, step = 5 },
        hunger = { enabled = true, threshold = 35, step = 5 },
        thirst = { enabled = true, threshold = 35, step = 5 },
    }
end

local function openFitbit()
    if fitbitOpen then return end
    fitbitOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open", settings = settings })
end

local function closeFitbit()
    fitbitOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
end

RegisterNetEvent('fitbit:client:use', function()
    QBCore.Functions.TriggerCallback('fitbit:server:getSettings', function(s)
        settings = s or getDefaultSettings()
        resetNotifyTrackers()
        openFitbit()
    end)
end)

RegisterNUICallback('close', function(_, cb)
    closeFitbit()
    cb('ok')
end)

RegisterNUICallback('save', function(data, cb)
    settings = data or getDefaultSettings()
    resetNotifyTrackers()

    TriggerServerEvent('fitbit:server:saveSettings', settings)

    notify("Fitbit settings saved.", "success")
    closeFitbit()

    cb('ok')
end)

CreateThread(function()
    while true do
        Wait(5000)

        if not settings or settings.enabled ~= true then
            goto continue
        end

        -- HEALTH
        if settings.health and settings.health.enabled then
            local hpPct = getHealthPercent()
            local threshold = tonumber(settings.health.threshold) or 0
            local step = tonumber(settings.health.step) or 5

            if hpPct <= threshold then
                local bucket = math.floor(hpPct / step) * step
                if bucket < lastNotified.health then
                    lastNotified.health = bucket
                    notify(("Fitbit: Health low (%d%%)"):format(toInt(hpPct)), "error")
                    SendNUIMessage({ action = "toast", label = "Health Low", value = toInt(hpPct) })
                end
            else
                lastNotified.health = 101
            end
        end

        local hunger, thirst = getHungerThirst()

        if settings.hunger and settings.hunger.enabled then
            local threshold = tonumber(settings.hunger.threshold) or 0
            local step = tonumber(settings.hunger.step) or 5

            if hunger <= threshold then
                local bucket = math.floor(hunger / step) * step
                if bucket < lastNotified.hunger then
                    lastNotified.hunger = bucket
                    notify(("Fitbit: Hunger low (%d%%)"):format(toInt(hunger)), "error")
                    SendNUIMessage({ action = "toast", label = "Hunger Low", value = toInt(hunger) })
                end
            else
                lastNotified.hunger = 101
            end
        end

        if settings.thirst and settings.thirst.enabled then
            local threshold = tonumber(settings.thirst.threshold) or 0
            local step = tonumber(settings.thirst.step) or 5

            if thirst <= threshold then
                local bucket = math.floor(thirst / step) * step
                if bucket < lastNotified.thirst then
                    lastNotified.thirst = bucket
                    notify(("Fitbit: Thirst low (%d%%)"):format(toInt(thirst)), "error")
                    SendNUIMessage({ action = "toast", label = "Thirst Low", value = toInt(thirst) })
                end
            else
                lastNotified.thirst = 101
            end
        end

        ::continue::
    end
end)

CreateThread(function()
    while true do
        local interval = 1000
        if Config and Config.StatusUpdateInterval then
            interval = Config.StatusUpdateInterval
        end

        Wait(interval)

        if fitbitOpen then
            local hunger, thirst = getHungerThirst()
            local hpPct = getHealthPercent()

            SendNUIMessage({
                action = "status",
                health = toInt(hpPct),
                hunger = toInt(hunger),
                thirst = toInt(thirst)
            })
        end
    end
end)

local wasDead = false

CreateThread(function()
    while true do
        Wait(1000)

        local ped = PlayerPedId()
        local isDead = IsEntityDead(ped) or IsPedFatallyInjured(ped)

        if isDead and not wasDead then
            wasDead = true

            if Config.EnableFunnyDeathMessage then
                local hunger, thirst = getHungerThirst()

                if hunger <= 5 then
                    notify(Config.FunnyMessages.Hunger, "error")

                elseif thirst <= 5 then
                    notify(Config.FunnyMessages.Thirst, "error")
                end
            end

        elseif not isDead then
            wasDead = false
        end
    end
end)