AddEventHandler('explosionEvent', function(src, data)
    if data.explosionType == 7 and data.f104 == 0 then
        CancelEvent()
        DropPlayer(src, "attempted to spawn explosions.")
    end
end)