local cfg = Config.ResourceStop or {}
local NS = cfg.namespace or "rsstop"
local function maco(n) return ("%s:%s"):format(NS,n) end
local tokenStore = {} -- tokenStore[src] = {token = X, exp = ts}

local function genToken()
    return tostring(math.random(1e9,9e9)) .. "-" .. tostring(os.time())
end

RegisterNetEvent(maco("request_token"), function()
    local src = source
    if not src then return end
    local token = genToken()
    tokenStore[src] = { token = token, exp = os.time() + (cfg.tokenLifetime or 30) }
    TriggerClientEvent(maco("issue_token"), src, token, cfg.tokenLifetime or 30)
end)

local reports = {}
local function canReport(src)
    reports[src] = reports[src] or { ts = os.time(), count = 0 }
    if reports[src].ts ~= os.time() then reports[src].ts = os.time(); reports[src].count = 0 end
    reports[src].count = reports[src].count + 1
    return reports[src].count <= (cfg.maxReportsPerMin or 6)
end

RegisterNetEvent(maco("panic"), function(payload)
    local src = source
    if not src or type(payload) ~= "table" then return end
    if not canReport(src) then return end
    local tokenEntry = tokenStore[src]
    local valid = false
    if tokenEntry and tokenEntry.token and tokenEntry.exp and os.time() < tokenEntry.exp then
        if tostring(payload.token) == tostring(tokenEntry.token) then valid = true end
    end

    local playerName = GetPlayerName(src) or "unknown"
    print(("[rsstop] report from %s id=%s valid=%s res=%s reason=%s"):format(playerName, src, tostring(valid), tostring(payload.resource), tostring(payload.reason)))

    if not valid then
        -- treat invalid token as suspicious; increase severity
        DropPlayer(src, "Tampering detected: invalid report token.")
        return
    end

    -- valid report: take configured action
    if cfg.kickOnServerConfirm then
        DropPlayer(src, "Tampering detected: " .. tostring(payload.resource) .. " -> " .. tostring(payload.reason))
    end

    -- clear token after use
    tokenStore[src] = nil
end)

RegisterNetEvent(maco("ping"), function(meta)
    -- optional monitoring ping
end)

AddEventHandler("playerDropped", function()
    tokenStore[source] = nil
end)
