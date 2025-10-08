function Debug(msg)
    if Config.Heartbeat.debugMode then
        print("[Debug] "..msg)
    end
end

if Config.Heartbeat.enable then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.HeartBeat.checkTime)
            TriggerServerEvent("maco:check:fivem")
            Debug("[DEBUG] Sending the heartbeat to the server")
        end
    end)
end
