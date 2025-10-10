local cfg = Config.Heartbeat or {}
local ENABLE = cfg.enable
local DEBUG = cfg.debugMode
local INTERVAL_MS = cfg.checkTime or 5000
local TIMEOUT_S = cfg.time or 5
local RETRIES = cfg.retries or 2
local STRIKE_LIMIT = cfg.strikeThreshold or 3
local GRACE = cfg.graceAfterStart or 8
local RATE_LIMIT = cfg.rateLimitPerSec or 5
local NS = cfg.namespace or "hb"

local function dbg(fmt, ...) if DEBUG then print(("[DEBUG] " .. fmt):format(...)) end end
local function maco(name) return ("%s:%s"):format(NS, name) end

local heartbeats, rate, strikes, readyPlayers = {}, {}, {}, {}
local serverStart = os.time()

local function now() return os.time() end
local function genNonce()
    local t = tostring(now()) .. "-" .. tostring(math.random(0, 1e9)) .. "-" .. tostring(math.random(0, 1e9))
    return t
end

RegisterNetEvent(maco("ready"), function()
    local src = source
    readyPlayers[src] = now()
    dbg("player %s marked ready for heartbeat", src)
end)

RegisterNetEvent(maco("ack"), function(payload, seq)
    local src = source
    if not src then return end

    local r = rate[src] or {0, 0}
    if now() ~= r[2] then r = {0, now()} end
    r[1] = r[1] + 1
    rate[src] = r
    if r[1] > RATE_LIMIT then
        dbg("src %s rate limited (%d/sec)", src, r[1])
        return
    end

    local entry = heartbeats[src]
    if not entry then return end
    if seq ~= entry.seq or tostring(payload) ~= tostring(entry.payload) then
        strikes[src] = { (strikes[src] and strikes[src].count or 0) + 1, now() }
        heartbeats[src] = nil
        if strikes[src].count >= STRIKE_LIMIT then
            DropPlayer(src, "Heartbeat failed: invalid response.")
            strikes[src] = nil
        end
        return
    end

    if now() - entry.issuedAt > TIMEOUT_S then
        strikes[src] = { (strikes[src] and strikes[src].count or 0) + 1, now() }
        heartbeats[src] = nil
        if strikes[src].count >= STRIKE_LIMIT then
            DropPlayer(src, "Heartbeat timeout.")
            strikes[src] = nil
        end
        return
    end

    heartbeats[src], strikes[src] = nil, nil
    dbg("src %s valid ack seq=%s payload=%s", src, tostring(seq), tostring(payload))
end)

AddEventHandler("playerDropped", function()
    local src = source
    heartbeats[src], rate[src], strikes[src], readyPlayers[src] = nil, nil, nil, nil
end)

AddEventHandler("playerJoining", function(src)
    dbg("player %s is joining — waiting for ready signal", src)
end)

CreateThread(function()
    if not ENABLE then return end
    math.randomseed(os.time() % 2147483647)
    while true do
        Wait(INTERVAL_MS)
        local tick = now()

        for _, pid in ipairs(GetPlayers()) do
            local src = tonumber(pid)
            if not src or not readyPlayers[src] then goto cont end
            if tick - serverStart < GRACE then goto cont end

            local entry = heartbeats[src]
            if entry and tick > entry.expires then
                entry.retries = (entry.retries or 0) + 1
                if entry.retries > RETRIES then
                    DropPlayer(src, "Connection lost: Heartbeat timeout.")
                    heartbeats[src] = nil
                    goto cont
                else
                    local payload, seq = genNonce(), (entry.seq or 0) + 1
                    heartbeats[src] = {payload = payload, seq = seq, issuedAt = tick, expires = tick + TIMEOUT_S, retries = entry.retries}
                    TriggerClientEvent(maco("check"), src, payload, seq)
                    dbg("resend to %s payload=%s seq=%s retries=%d", src, payload, seq, entry.retries)
                    goto cont
                end
            end

            if not entry then
                local payload, seq = genNonce(), math.random(1, 1e9)
                heartbeats[src] = {payload = payload, seq = seq, issuedAt = tick, expires = tick + TIMEOUT_S, retries = 0}
                TriggerClientEvent(maco("check"), src, payload, seq)
                dbg("sent to %s payload=%s seq=%s", src, payload, seq)
            end

            ::cont::
        end
    end
end)
