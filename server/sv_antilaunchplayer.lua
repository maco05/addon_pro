if Config.AntiLaunchPlayer.enable then
    local modelsToDelete = {
        [-1809822327] = true,
        [-1177863319] = true,
        [1728666326] = true,
    }

    AddEventHandler('entityCreated', function(entity)
        if not DoesEntityExist(entity) then
            if Config.AntiLaunchPlayer.debugMode then
                print("[DEBUG] Entity does not exist, skipping.")
            end
            return
        end

        local model = GetEntityModel(entity)

        if Config.AntiLaunchPlayer.debugMode then
            print(string.format("[DEBUG] Entity created (model: %s)", model))
        end

        if modelsToDelete[model] then
            local owner = NetworkGetEntityOwner(entity)
            local playerName = GetPlayerName(owner) or "Unknown"
            local playerId = owner or "N/A"

            DeleteEntity(entity)

            if Config.AntiLaunchPlayer.debugMode then
                print(string.format("[DEBUG] Deleted blocked model (%s) from %s [ID: %s]", model, playerName, playerId))
            end

            if owner and owner ~= -1 then
                DropPlayer(owner, "You have been removed for spawning a forbidden entity.")
                if Config.AntiLaunchPlayer.debugMode then
                    print(string.format("[DEBUG] Dropped player %s [ID: %s] for spawning blocked model (%s)", playerName, playerId, model))
                end
            else
                if Config.AntiLaunchPlayer.debugMode then
                    print("[DEBUG] Could not identify entity owner, skipping DropPlayer.")
                end
            end
        end
    end)
end
