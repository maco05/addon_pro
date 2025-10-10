if Config.EntityManipulation.enable then
    for i = 0, Config.EntityManipulation.max_bucket_used do
        SetRoutingBucketPopulationEnabled(i, false)
    end

    local lastDetection = 0 

    AddEventHandler('entityCreated', function(entity)
        if not DoesEntityExist(entity) then return end

        local popType = GetEntityPopulationType(entity)
        if popType ~= 5 then return end

        local entity_type = GetEntityType(entity)
        if entity_type ~= 2 and entity_type ~= 1 then return end

        local owner = NetworkGetEntityOwner(entity)
        if not owner or owner == 0 or owner == -1 then return end

        local currentTime = os.time()
        if currentTime - lastDetection < 15 then
            return
        end

        lastDetection = currentTime

        if Config.EntityManipulation.debugMode then
            print(string.format("[DEBUG] Entity detected: type=%d, popType=%d, owner=%d", entity_type, popType, owner))
        end

        DeleteEntity(entity)
        DropPlayer(owner, "You have been removed for spawning a forbidden entity.")
    end)
end
