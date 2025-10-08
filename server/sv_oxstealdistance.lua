local admins = {}

local function isit(tbl, val)
    for _, v in ipairs(tbl) do
        if v == val then
            return true
        end
    end
    return false
end

if Config.OXStealDistance.enable then
    hookId = exports.ox_inventory:registerHook('swapItems', function(payload)
        local src = payload.source
        if admins[src] then return true end
        if payload.toType ~= 'player' then return end

        local identifiers = GetPlayerIdentifiers(src)
        for _, id in ipairs(identifiers) do
            if isit(Config.OXStealDistance.allowed_identifier, id) then
                admins[src] = true
                return true
            end
        end

        local his_src = payload.toInventory
        if tonumber(his_src) == tonumber(src) then
            his_src = payload.fromInventory
        end

        local player1 = GetEntityCoords(GetPlayerPed(src))
        local player2 = GetEntityCoords(GetPlayerPed(his_src))
        local dist = #(player1 - player2)

        if dist > Config.OXStealDistance.distance_units then
            if Config.OXStealDistance.debugMode then
                print(("[DEBUG] Player %d tried to steal items from a distance of %.2f units. Dropping player."):format(src, dist))
            end
            DropPlayer(src, "Tried to take player items from a distance")
            return false
        end

        return true
    end, { print = false })
end
