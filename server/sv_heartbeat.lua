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

local function dbg(fmt, ...) if DEBUG then print(("[heartbeat] " .. fmt):format(...)) end end

local function maco(name) return ("%s:%s"):format(NS, name) end

local heartbeats = {}
local rate = {} -- rate[src] = {count, ts}
local strikes = {} -- strikes[src] = {count, lastStrikeTs}
local serverStart = os.time()

local function now() return os.time() end
local function genNonce()
    local t = tostring(now()) .. "-" .. tostring(math.random(0, 1e9)) .. "-" .. tostring(math.random(0, 1e9))
    return t
end

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
    if not entry then
        dbg("src %s acked but no entry", src)
        return
    end

    if seq ~= entry.seq then
        dbg("src %s seq mismatch (got %s expected %s) -> immediate strike", src, tostring(seq), tostring(entry.seq))
        strikes[src] = { (strikes[src] and strikes[src].count or 0) + 1, now() }
        heartbeats[src] = nil
        if strikes[src].count >= STRIKE_LIMIT then
            dbg("src %s strike limit reached -> dropping", src)
            DropPlayer(src, "Heartbeat failed: repeated invalid responses.")
            strikes[src] = nil
        end
        return
    end

    if tostring(payload) ~= tostring(entry.payload) then
        dbg("src %s payload mismatch -> strike", src)
        strikes[src] = { (strikes[src] and strikes[src].count or 0) + 1, now() }
        heartbeats[src] = nil
        if strikes[src].count >= STRIKE_LIMIT then
            dbg("src %s strike limit reached -> dropping", src)
            DropPlayer(src, "Heartbeat failed: invalid acknowledgement.")
            strikes[src] = nil
        end
        return
    end

    local elapsed = now() - entry.issuedAt
    if elapsed > TIMEOUT_S then
        dbg("src %s ack arrived but too late (%ds > %ds) -> inc strike", src, elapsed, TIMEOUT_S)
        strikes[src] = { (strikes[src] and strikes[src].count or 0) + 1, now() }
        heartbeats[src] = nil
        if strikes[src].count >= STRIKE_LIMIT then
            dbg("src %s strike limit reached -> dropping", src)
            DropPlayer(src, "Heartbeat timeout.")
            strikes[src] = nil
        end
        return
    end

    heartbeats[src] = nil
    strikes[src] = nil
    dbg("src %s valid ack seq=%s payload=%s (elapsed %ds)", src, tostring(seq), tostring(payload), elapsed)
end)

AddEventHandler("playerDropped", function()
    heartbeats[source] = nil
    rate[source] = nil
    strikes[source] = nil
    dbg("cleaned %s on drop", source)
end)

CreateThread(function()
    if not ENABLE then return end
    math.randomseed(os.time() % 2147483647)
    while true do
        Wait(INTERVAL_MS)
        local players = GetPlayers()
        local tick = now()

        for _, pid in ipairs(players) do
            local src = tonumber(pid)
            if not src then goto cont end

            if tick - serverStart < GRACE then
                goto cont
            end

            if heartbeats[src] then
                local e = heartbeats[src]
                if tick > e.expires then
                    e.retries = (e.retries or 0) + 1
                    if e.retries > RETRIES then
                        dbg("src %s missed payload %s retries=%d -> drop", src, tostring(e.payload), e.retries)
                        DropPlayer(src, "Connection lost: Heartbeat timeout.")
                        heartbeats[src] = nil
                        goto cont
                    else
                        local payload = genNonce()
                        local seq = (e.seq or 0) + 1
                        heartbeats[src] = { payload = payload, seq = seq, issuedAt = tick, expires = tick + TIMEOUT_S, retries = e.retries }
                        TriggerClientEvent(maco("check"), src, payload, seq)
                        dbg("resend to %s payload=%s seq=%s retries=%d", src, tostring(payload), seq, e.retries)
                        goto cont
                    end
                else
                    goto cont
                end
            end

            local payload = genNonce()
            local seq = math.random(1, 1e9)
            heartbeats[src] = { payload = payload, seq = seq, issuedAt = tick, expires = tick + TIMEOUT_S, retries = 0 }
            TriggerClientEvent(maco("check"), src, payload, seq)
            dbg("sent to %s payload=%s seq=%s expires=%s", src, tostring(payload), seq, tostring(tick + TIMEOUT_S))

            ::cont::
        end
    end
end)