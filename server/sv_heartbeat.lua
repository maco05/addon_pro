if Config.HeartBeat.enable then
    local lastHeartbeat = {}

    function Debug(msg)
        if Config.HeartBeat.debugMode then
            print("[DEBUG] "..msg)
        end
    end

    function getPlayerPlaytime(identifier, callback)
        local playtime = math.random(1, 100)
        if callback then
            callback(playtime)
        end
    end

    RegisterNetEvent("maco:check:fivem")
    AddEventHandler("maco:check:fivem", function()
        local src = source
        lastHeartbeat[src] = os.time()
        Debug("[DEBUG] Heartbeat received from : " .. src)
    end)

    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.HeartBeat.checkTime) 
            
            for src, lastTime in pairs(lastHeartbeat) do
                if GetPlayerName(src) ~= nil then
                    if os.time() - lastTime > Config.HeartBeat.time then 
                        local playerName = GetPlayerName(src)
                        local identifier = GetPlayerIdentifier(src, 0) or "Unknown"
                        
                        print("[ALERTE] The player " .. playerName .. " (ID:" .. src .. ", Identifier:" .. identifier .. ") no longer responds to the heartbeat !")
                        
                        getPlayerPlaytime(identifier, function(playtime)
                            print("[ALERTE] The player " .. playerName .. " (ID:" .. src .. ", Identifier:" .. identifier .. " , Playtime Total:" .. playtime .. ") seems to have disabled its client-side script")
                        end)
                        
                        Debug("Running the DropPlayer for the player " .. playerName .. " (ID: " .. src .. ")")
                        DropPlayer(src, "No heartbeat received.")
                        
                        lastHeartbeat[src] = nil
                        Debug("Player Reset " .. playerName .. " (ID: " .. src .. ") in the lastHeartbeat table.")
                    end
                else
                    lastHeartbeat[src] = nil
                    Debug("Deleting the ID entry " .. src .. " because the player is no longer present.")
                end
            end
        end
    end)
end
