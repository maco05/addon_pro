local code = LoadResourceFile(GetCurrentResourceName(), "client/cl_antistop2.lua")

local serverCallbacks = {}

local clientRequests = {}
local RequestId = 0

---@param eventName string
---@param callback function
RegisterServerCallback = function(eventName, callback)
    serverCallbacks[eventName] = callback
end

-- exports('RegisterServerCallback', RegisterServerCallback)

RegisterNetEvent('maco:triggerServerCallback', function(eventName, requestId, invoker, ...)
    if not serverCallbacks[eventName] then
        return print(('[^1ERROR^7] Server Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))
    end

    local source = source

    serverCallbacks[eventName](source, function(...)
        TriggerClientEvent('maco:serverCallback', source, requestId, invoker, ...)
    end, ...)
end)

---@param player number playerId
---@param eventName string
---@param callback function
---@param ... any
TriggerClientCallback = function(player, eventName, callback, ...)
    clientRequests[RequestId] = callback

    TriggerClientEvent('maco:triggerClientCallback', player, eventName, RequestId, GetInvokingResource() or 'unknown', ...)

    RequestId = RequestId + 1
end

RegisterNetEvent('maco:clientCallback', function(requestId, invoker, ...)
    if not clientRequests[requestId] then
        return print(('[^1ERROR^7] Client Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist.'):format(requestId, invoker))
    end

    clientRequests[requestId](...)
    clientRequests[requestId] = nil
end)


RegisterServerCallback('maco:gotoClient', function(source, cb)
    cb(code)
end)

local RessoureName = Config.ResourceStop.anticheatName
local checkInterval = Config.ResourceStop.checkTime

local playerStates = {}

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

Citizen.CreateThread(function()
    local function a()
        for playerId, state in pairs(playerStates) do
            if not state.isResourceActive then
                DropPlayer(playerId, "Tried stopping anticheat")
            end
        end
        SetTimeout(checkInterval, a)
    end
    SetTimeout(checkInterval, a)
end)

RegisterNetEvent("maco:resourceState")
AddEventHandler("maco:resourceState", function(isResourceActive)
    local playerId = source
    playerStates[playerId] = { isResourceActive = isResourceActive }
end)
