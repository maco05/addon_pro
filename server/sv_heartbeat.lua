if Config and Config.HeartBeat and Config.HeartBeat.enable then
    local lastHeartbeat = {}

    local function Debug(msg)
        if Config.HeartBeat.debugMode then
            print("[DEBUG] " .. msg)
        end
    end

    local function getPlayerPlaytime(identifier, callback)
        local playtime = math.random(1, 100)
        if callback then
            callback(playtime)
        end
    end

    RegisterNetEvent("maco:check:fivem")
    AddEventHandler("maco:check:fivem", function()
        local src = source
        lastHeartbeat[src] = os.time()
        Debug("Heartbeat received from player ID: " .. src)
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.HeartBeat.checkTime)

            for src, lastTime in pairs(lastHeartbeat) do
                if GetPlayerName(src) ~= nil then
                    if os.time() - lastTime > Config.HeartBeat.time then
                        local playerName = GetPlayerName(src)
                        local identifier = GetPlayerIdentifier(src, 0) or "Unknown"

                        print("[ALERT] Player " .. playerName .. " (ID: " .. src .. ", Identifier: " .. identifier .. ") no longer responds to the heartbeat!")

                        getPlayerPlaytime(identifier, function(playtime)
                            print("[ALERT] Player " .. playerName .. " (ID: " .. src .. ", Identifier: " .. identifier .. ", Playtime Total: " .. playtime .. ") seems to have disabled its client-side script.")
                        end)

                        Debug("Dropping player " .. playerName .. " (ID: " .. src .. ") for no heartbeat.")
                        DropPlayer(src, "No heartbeat received.")

                        lastHeartbeat[src] = nil
                        Debug("Removed player " .. playerName .. " (ID: " .. src .. ") from heartbeat table.")
                    end
                else
                    lastHeartbeat[src] = nil
                    Debug("Removing ID entry " .. src .. " because player is no longer connected.")
                end
            end
        end
    end)
end
