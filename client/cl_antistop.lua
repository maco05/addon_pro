local data = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
local Config = data and assert(load(data))()

if not Config or not Config.ResourceStop or not Config.ResourceStop.anticheatName or Config.ResourceStop.anticheatName == '' then
    return
end

local anticheatName = Config.ResourceStop.anticheatName
local debugMode = Config.ResourceStop.debugMode
local checkTime = Config.ResourceStop.checkTime or 10000

while not READY do
    Citizen.Wait(0)
end

local function Debug(msg)
    if debugMode then
        print("[DEBUG] " .. msg)
    end
end

local function check()
    local state = GetResourceState(anticheatName)
    Debug("Checking resource state for " .. anticheatName .. ": " .. state)
    TriggerServerEvent("maco:addon_pro:resourceState", state == "started")
    Citizen.SetTimeout(checkTime, check)
end

check()
