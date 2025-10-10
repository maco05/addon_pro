local RessoureName = Config.ResourceStop.anticheatName
local checkInterval = Config.ResourceStop.checkTime

CreateThread(function()
    local resources = GetNumResources()
    for i = 0, resources - 1 do
        local resource = GetResourceByFindIndex(i)
        local files = GetNumResourceMetadata(resource, 'client_script')
        for j = 0, files, 1 do
            local x = GetResourceMetadata(resource, 'client_script', j)
            if x ~= nil then
                if string.find(x, "obfuscated") then
                    RessoureName = resource
                    return
                end
            end
        end
    end
end)

local function isResourceActive()
    return GetResourceState(RessoureName) == "started"
end

AddEventHandler("playerSpawned", function()
    TriggerServerEvent("maco:resourceState", isResourceActive())
end)

Citizen.CreateThread(function()
    local function a()
        TriggerServerEvent("maco:resourceState", isResourceActive())
        Citizen.SetTimeout(checkInterval, a)
    end
    Citizen.SetTimeout(checkInterval, a)
end)