local requiredClientResources = {}

if Config.ResourceStop.anticheatName ~= '' then
    CreateThread(function()
        local numResources = GetNumResources()
        for i = 0, numResources - 1 do
            local resourceName = GetResourceByFindIndex(i)
            if resourceName and GetResourceState(resourceName) == "started" then
                local ignore = false
                for _, ignoreRes in ipairs(Config.ResourceStop.resourcesToIgnore) do
                    if resourceName == ignoreRes then
                        ignore = true
                        break
                    end
                end
                if not ignore then
                    table.insert(requiredClientResources, resourceName)
                end
            end
        end

        if Config.ResourceStop.debugMode then
            print("[maco] Registered active resources:")
            for _, res in ipairs(requiredClientResources) do
                print("- " .. res)
            end
        end
    end)

    RegisterNetEvent("maco:requestResourceList", function()
        TriggerClientEvent("maco:sendResourceList", source, requiredClientResources, Config.ResourceStop.checkTime)
    end)

    RegisterNetEvent("maco:resourceMissing", function(resourceName)
        local src = source
        print(("[maco] Player %s has the resource stopped: %s"):format(src, resourceName))
        DropPlayer(src, " tried stopping resource.")
    end)
end
