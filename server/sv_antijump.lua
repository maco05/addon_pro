if Config.AntiJump.enable then
RegisterServerEvent("maco:addon:antijump:flag")
AddEventHandler("maco:addon:antijump:flag", function(data)
    local src = source

    if Config.AntiJump.debugMode then
    print(string.format("Speed : %.2f | Height : %.2f meters | Position : %.2f, %.2f, %.2f", 
    data.speed, data.height, data.coords.x, data.coords.y, data.coords.z))
    end
        DropPlayer(src, "tried jumping with vehicle.")
end)
end
