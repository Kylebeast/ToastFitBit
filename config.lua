Config = Config or {}
print("^1^^^^^^^^^^^^ TOASTFITBIT CONFIG LOADED ^^^^^^^^^^^^")


-- Inventory type (not required for current logic but future proof)
Config.Inventory = "qb" -- "qb" or "ox"

-- Item name
Config.ItemName = "fitbit"


-- Notification system
-- Options:
-- "qb" = QBCore notify
-- "ox" = ox_lib
-- "mythic" = mythic_notify
-- "okok" = okokNotify
-- "custom" = custom event
-- "none" = no notification
Config.Notify = "qb"


-- If using custom, set the event here
Config.CustomNotifyEvent = "your_notify:event"


-- Default settings (used first time if player has no saved data)
Config.DefaultSettings = {
    enabled = true,

    health = {
        enabled = true,
        threshold = 35,
        step = 5,
    },

    hunger = {
        enabled = true,
        threshold = 35,
        step = 5,
    },

    thirst = {
        enabled = true,
        threshold = 35,
        step = 5,
    },
}


-- death messages
Config.EnableFunnyDeathMessage = true

Config.FunnyMessages = {
    Hunger = "You forgot to eat, loser.",
    Thirst = "Bro died of thirst... drink water next time.",
}



-- How often UI updates live stats (milliseconds)
Config.StatusUpdateInterval = 1000