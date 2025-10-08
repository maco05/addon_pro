Config = {}

-- ANTI ANTICHEAT RESOURCE STOP
Config.ResourceStop = {
    anticheatName = '', -- Name of the anticheat resource to monitor. Leave empty to disable.
    debugMode = true,                -- Show debug messages in console.
    checkTime = 10000,               -- Interval (ms) to check if the resource is stopped. Default: 10 seconds.
    resourcesToIgnore = {            -- List of resources to ignore when monitoring.
        'monitor',
    }
}

-- HEARTBEAT CONFIG
Config.Heartbeat = {
    enable = true,                   -- Enable client-server heartbeat checks.
    debugMode = true,                -- Show debug messages in console.
    checkTime = 5000,                -- Interval (ms) between heartbeat checks.
    time = 5,                        -- Max allowed heartbeat delay (seconds) before taking action.
}

-- ANTI JUMP VEHICLE DETECTION
Config.AntiJump = {
    enable = true,                   -- Enable Anti-Jump detection.
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
    enable = true
    debugMode = true,                -- Show debug messages in console.
}

-- ANTI THROW VEHICLE
Config.AntiThrowVehicle = {
    enable = true
    debugMode = true,                -- Show debug messages in console.
}
