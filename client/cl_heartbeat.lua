local function Debug(msg)
    if Config and Config.HeartBeat and Config.HeartBeat.debugMode then
        print("[DEBUG] " .. msg)
    end
end

if Config and Config.HeartBeat and Config.HeartBeat.enable then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.HeartBeat.checkTime)
            TriggerServerEvent("maco:check:fivem")
            Debug("Sending the heartbeat to the server")
        end
    end)
end
