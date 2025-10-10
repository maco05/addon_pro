local data = LoadResourceFile(GetCurrentResourceName(), 'config.lua')
local Config = data and assert(load(data))()

if not Config or not Config.AntiStopper or not Config.AntiStopper.enable or not Config.ResourceStop then
    return
end

local AntiStopper = Config.AntiStopper
local ResourceStop = Config.ResourceStop
local playerStates = {}

while not READY do
    Citizen.Wait(0)
end

local function check()
    for playerId, state in pairs(playerStates) do
        if not state then
            DropPlayer(playerId, "Tried stopping " .. (ResourceStop.anticheatName or "anticheat") .. ".")
        end
    end
    Citizen.SetTimeout(ResourceStop.checkTime or 10000, check)
end

check()

RegisterNetEvent("maco:addon_pro:resourceState", function(isResourceActive)
    playerStates[source] = isResourceActive
end)
