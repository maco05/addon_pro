local cfg = Config.Heartbeat or {}
if not cfg.enable then return end

local DEBUG = cfg.debugMode
local NS = cfg.namespace or "hb"
local function dbg(fmt, ...) if DEBUG then print(("[DEBUG] " .. fmt):format(...)) end end
local function maco(name) return ("%s:%s"):format(NS, name) end

local playerReady = false

AddEventHandler("playerSpawned", function()
    if playerReady then return end
    Wait(5000)
    TriggerServerEvent(maco("ready"))
    playerReady = true
    dbg("client marked ready for heartbeat")
end)

RegisterNetEvent(maco("check"), function(payload, seq)
    if not playerReady then return end
    if not payload or not seq then return end
    TriggerServerEvent(maco("ack"), payload, seq)
    dbg("acked payload=%s seq=%s", payload, seq)
end)
