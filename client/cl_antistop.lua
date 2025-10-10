local cfg = Config.ResourceStop or {}
if not cfg.enable then return end
local DEBUG = cfg.debug
local NS = cfg.namespace or "rsstop"
local function maco(n) return ("%s:%s"):format(NS,n) end

local playerServerId = nil
local serverToken = nil
local tokenExpire = 0

local function d(fmt,...) if DEBUG then print(("[rsstop] "..fmt):format(...)) end end
local function now() return GetGameTimer() end
local function seconds() return math.floor(GetGameTimer()/1000) end

-- rate limiting local
local reports = { ts = seconds(), count = 0 }
local function canReport()
    local s = seconds()
    if s ~= reports.ts then reports.ts = s; reports.count = 0 end
    reports.count = reports.count + 1
    return reports.count <= (cfg.maxReportsPerMin or 6)
end

local function localFallback(res,reason)
    if not cfg.localFallback then return end
    if cfg.fallbackAction == "freeze" then
        CreateThread(function()
            local ped = PlayerPedId()
            FreezeEntityPosition(ped, true)
            while true do Wait(1000) end
        end)
    else
        CreateThread(function() while true do Wait(100) end end)
    end
end

local function sendPanic(res,reason,meta)
    if not canReport() then d("rate limit reached for panic"); return end
    local payload = { resource = res, reason = reason, meta = meta or {}, token = serverToken, ts = seconds() }
    local ok,err = pcall(TriggerServerEvent, maco("panic"), payload)
    if ok then
        d("panic event triggered server")
        return true
    else
        d("panic trigger failed: %s", tostring(err))
        return false
    end
end

local function react(res,reason,meta)
    d("react: %s -> %s", tostring(res), tostring(reason))
    local notified = false
    if cfg.serverNotify then notified = sendPanic(res,reason,meta) end
    if not notified then localFallback(res,reason) end
end

-- WATCHER A: full resource state scan (all client resources)
local function resourceWatcher()
    Wait(cfg.initialDelay or 7000)
    math.randomseed(GetGameTimer())
    local snap = {}
    local function take()
        local n = GetNumResources()
        for i=0,n-1 do
            local r = GetResourceByFindIndex(i)
            if r then snap[r] = GetResourceState(r) end
        end
    end
    take()
    while true do
        Wait((cfg.checkIntervalBase or 3000) + math.random(200,1000))
        local n = GetNumResources()
        for i=0,n-1 do
            local r = GetResourceByFindIndex(i)
            if not r then goto cont end
            local state = GetResourceState(r)
            if not state or state == "missing" or state == "stopped" then
                react(r,"resource_stopped_or_missing",{state=state})
                return
            end
            if snap[r] and snap[r] ~= state then
                react(r,"resource_state_changed",{from=snap[r],to=state})
                return
            end
            snap[r] = state
            ::cont::
        end
    end
end

-- WATCHER B: event integrity (ensure critical globals & functions exist)
local function eventIntegrityWatcher()
    Wait(cfg.initialDelay or 7000)
    while true do
        Wait((cfg.eventCheckBase or 3500) + math.random(100,900))
        if not TriggerServerEvent or not _G then
            react("env","event_integrity_failure")
            return
        end
        if type(TriggerServerEvent) ~= "function" then
            react("env","trigger_missing")
            return
        end
    end
end

-- WATCHER C: self-watchdog that ensures watchers are alive by using heartbeat tokens
local watchdogState = {resourceAlive=true,eventAlive=true,lastPing=seconds()}
local function selfWatchdog()
    Wait(cfg.initialDelay or 7000)
    while true do
        Wait((cfg.selfWatchBase or 4500) + math.random(200,1000))
        -- quick checks
        local ok, err = pcall(function()
            if not next then error() end
        end)
        if not ok then react("self","pcall_failed"); return end

        -- if token expired or nil, request a fresh one
        if not serverToken or seconds() >= tokenExpire then
            pcall(TriggerServerEvent, maco("request_token"))
            d("requested new server token")
        end

        -- periodic innocuous ping to server to confirm connectivity
        if cfg.serverNotify and math.random(1,10) == 1 then pcall(TriggerServerEvent, maco("ping"), {ts=seconds()}) end
    end
end

-- guard to detect attempts to stop this resource specifically using direct API
local function selfProtect()
    Wait(200)
    while true do
        Wait(1000 + math.random(0,500))
        local state = GetResourceState(GetCurrentResourceName())
        if not state or state == "stopped" or state=="missing" then
            react("self","self_stopped", {state=state})
            return
        end
    end
end

-- server -> client handlers
RegisterNetEvent(maco("issue_token"), function(token,ttl)
    serverToken = token
    tokenExpire = seconds() + (ttl or cfg.tokenLifetime or 30)
    d("received token (expires in %ds)", ttl or cfg.tokenLifetime or 30)
end)

RegisterNetEvent(maco("server_confirm"), function(action)
    if action == "kick" and cfg.kickOnServerConfirm then
        CreateThread(function() Wait(300) DropPlayer() end)
    end
end)

-- boot
CreateThread(function()
    Wait(100)
    CreateThread(resourceWatcher)
    CreateThread(eventIntegrityWatcher)
    CreateThread(selfWatchdog)
    CreateThread(selfProtect)
    d("monitors launched")
end)
