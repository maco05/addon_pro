local modelsToDelete = {
    [-1809822327] = true,
    [-1177863319] = true,
    [1728666326] = true,
}

AddEventHandler('entityCreated', function(entity)
    if not DoesEntityExist(entity) then return end

    local model = GetEntityModel(entity)
    if modelsToDelete[model] then
        local owner = NetworkGetEntityOwner(entity)
        local playerName = GetPlayerName(owner) or "Onbekend"
        DeleteEntity(entity)
    end
end)
