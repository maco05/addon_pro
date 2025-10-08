local requiredResources = {}
local playerSpawned = false

local function contains(table, element)
    for _, value in pairs(table) do
        if value == element then
            return true
        end
    end
    return false
end

AddEventHandler("playerSpawned", function()
    playerSpawned = true
end)

RegisterNetEvent("maco:sendResourceList", function(resourceList)
    requiredResources = resourceList
end)

CreateThread(function()
    while not playerSpawned do
        Wait(100)
    end

    TriggerServerEvent("maco:requestResourceList")

    while #requiredResources == 0 do
        Wait(100)
    end

    while true do
        Wait(Config.checkTime)

        for _, resourceName in pairs(requiredResources) do
            if resourceName:match("%.json$") then
                goto continue
            end

            if GetResourceState(resourceName) ~= "started" and not contains(Config.resourcesToIgnore, resourceName) then
                TriggerServerEvent("maco:resourceMissing", resourceName)
            elseif Config.debugMode then
                print("All required resources started: " .. resourceName) 
            end

            ::continue::
        end
    end
end)