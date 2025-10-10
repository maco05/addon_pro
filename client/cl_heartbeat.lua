local cfg = Config.Heartbeat or {}
if not cfg.enable then return end

local DEBUG = cfg.debugMode
local NS = cfg.namespace or "hb"
local function dbg(fmt, ...) if DEBUG then print(("[heartbeat] " .. fmt):format(...)) end end
local function maco(name) return ("%s:%s"):format(NS, name) end

local lastReceivedSeq = {}
local lastAckTs = {}

RegisterNetEvent(maco("check"), function(payload, seq)
    local src = source
    if not payload or not seq then return end

    if lastReceivedSeq[GetPlayerServerId(PlayerId())] == seq then
        dbg("duplicate seq %s ignored", tostring(seq))
        return
    end

    lastReceivedSeq[GetPlayerServerId(PlayerId())] = seq
    lastAckTs[seq] = os.time()
    TriggerServerEvent(maco("ack"), payload, seq)
    dbg("acked payload=%s seq=%s", tostring(payload), tostring(seq))
end)

CreateThread(function()
    while true do
        Wait(60000)
        dbg("client heartbeat alive")
    end
end)