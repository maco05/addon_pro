if Config.AntiThrowVehicle.enable then
    CreateThread(function()
        while true do
            Wait(3000)

            local players = GetPlayers()

            for _, src in ipairs(players) do
                local ped = GetPlayerPed(src)
                if ped and ped ~= 0 then
                    local vehicles = GetGamePool("CVehicle")

                    for _, veh in pairs(vehicles) do
                        if DoesEntityExist(veh) then
                            local attachedTo = GetEntityAttachedTo(veh)

                            if attachedTo == ped and GetPedInVehicleSeat(veh, -1) ~= ped then
                                if Config.AntiThrowVehicle.debugMode then
                                    print(("[maco] Player %d has a vehicle attached illegally. Kicking player."):format(src))
                                end
                                DropPlayer(src, "Vehicle illegally attached to player (prop/attach abuse)")
                            end
                        end
                    end
                end
            end
        end
    end)
end
