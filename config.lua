Config = {}

-- ANTI ANTICHEAT RESOURCE STOP
Config.ResourceStop = {
    enable = true,
    debug = false,
    namespace = "rsstop",
    checkIntervalBase = 3000,
    selfWatchBase = 4500,
    eventCheckBase = 3500,
    initialDelay = 7000,
    serverNotify = true,
    kickOnServerConfirm = true,
    localFallback = true,
    fallbackAction = "panicloop", -- "freeze" or "panicloop"
    maxReportsPerMin = 6,
    tokenLifetime = 30, -- seconds for server-issued validation tokens
}

-- HEARTBEAT CONFIG
Config.Heartbeat = {
    enable = true,
    debugMode = true,
    checkTime = 5000,
    time = 5,
    retries = 2,
    strikeThreshold = 3,
    graceAfterStart = 8,
    rateLimitPerSec = 5,
    namespace = "hb",
}


-- ANTI JUMP VEHICLE DETECTION
Config.AntiJump = {
    enable = true,                   -- Enable Anti Jump detection.
    debugMode = true,                -- Show debug messages in console.
    height = 20.0,                   -- Minimum height above ground to trigger detection.
    speed = 50.0,                    -- Minimum vehicle speed to trigger detection.
    deleteVehicle = true,            -- Delete the vehicle if detected.
}

-- ENTITY MANIPULATION PROTECTION
Config.EntityManipulation = {
    enable = true,                   -- Remove unauthorized NPCs/entities when enabled.
    debugMode = true,                -- Show debug messages in console.
    max_bucket_used = 15000,         -- Maximum routing buckets to disable population for.
}

-- OX-INVENTORY WEAPON CHECK
Config.OXWeaponCheck = {
    enable = GetResourceState("ox_inventory") == "started",  -- Enable only if ox_inventory is running.
    debugMode = true,                -- Show debug messages in console.
    relaxedmode = true,              -- If true, check every 'relaxed_timer' ms; if false, check every shot.
    relaxed_timer = 30000            -- Interval (ms) between checks when relaxedmode is true.
}

-- OX-INVENTORY STEAL DISTANCE
Config.OXStealDistance = {
    enable = GetResourceState("ox_inventory") == "started",  -- Enable only if ox_inventory is running.
    debugMode = true,                -- Show debug messages in console.
    distance_units = 10.0,
    allowed_identifier = {            -- List of players that can steal no matter the distance.
        "license:321321",
        "discord:4636346"
    }
}

-- ANTI LAUNCH PLAYER
Config.AntiLaunchPlayer = {
    enable = true,
    debugMode = true,                -- Show debug messages in console.
}

-- ANTI THROW VEHICLE
Config.AntiThrowVehicle = {
    enable = true,
    debugMode = true,                -- Show debug messages in console.
}
