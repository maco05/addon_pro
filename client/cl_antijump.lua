if Config.AntiJump.enable then
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local playerPed = PlayerPedId()
        local playerVeh = GetVehiclePedIsIn(playerPed, false)

        if DoesEntityExist(playerVeh) and playerPed == GetPedInVehicleSeat(playerVeh, -1) then
            local vehCoords = GetEntityCoords(playerVeh)
            local velocity = GetEntityVelocity(playerVeh)
            local speed = math.sqrt(velocity.x^2 + velocity.y^2 + velocity.z^2)
            local _, groundZ = GetGroundZFor_3dCoord(vehCoords.x, vehCoords.y, vehCoords.z, true)
            local heightAboveGround = vehCoords.z - groundZ

            if speed > Config.AntiJump.speed and heightAboveGround > Config.Height then
                TriggerServerEvent("maco:addon:antijump:flag", {speed = speed, height = heightAboveGround, coords = vehCoords})
                if Config.AntiJump.deleteVehicle then
                    DeleteEntity(playerVeh)
                end
            end
        end
    end
end)
end
