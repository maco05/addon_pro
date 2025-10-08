if Config.OXWeaponCheck.enable then
    local weaponlist = {}
    local function toUnsigned32(n)
        if n < 0 then
            return n + 4294967296
        end
        return n
    end

    local function Debug(msg)
        if Config.OXWeaponCheck.debugMode then
            print("[DEBUG] "..msg)
        end
    end

    Citizen.CreateThread(function()
        Citizen.Wait(1000) 
        local items = exports.ox_inventory:Items()
        if items then
            for name, item in pairs(items) do
                if item.weapon == true then
                    table.insert(weaponlist, item.name:lower())
                    Debug("Loaded weapon: "..item.name:lower())
                end
            end
        end
    end)

    local function GetWeaponNameFromHash(hash)
        local hashUnsigned = toUnsigned32(hash)
        for _, weaponName in pairs(weaponlist) do
            if toUnsigned32(GetHashKey(weaponName)) == hashUnsigned then
                return weaponName
            end
        end
        return nil
    end

    local serv_cooldown2 = {}
    local cooldown_duration2 = Config.OXWeaponCheck.relaxed_timer

    AddEventHandler('weaponDamageEvent', function(shooter, data)
        if data.damageType ~= 3 then return end

        if Config.OXWeaponCheck.relaxedmode then
            local now = GetGameTimer()
            if serv_cooldown2[shooter] and now < serv_cooldown2[shooter] then
                Debug("Skipping check for shooter ID "..shooter.." due to cooldown.")
                return 
            end
            serv_cooldown2[shooter] = now + cooldown_duration2
        end

        local weapon_nameHash = GetWeaponNameFromHash(data.weaponType)
        if not weapon_nameHash then
            Debug("Weapon hash not found for shooter ID "..shooter)
            return 
        end

        local ox_check = exports.ox_inventory:GetItemCount(tonumber(shooter), weapon_nameHash)
        if ox_check > 0 then
            Debug("Shooter ID "..shooter.." has weapon "..weapon_nameHash.." in inventory.")
            return 
        end

        Debug("Dropping shooter ID "..shooter.." for shooting without weapon.")
        DropPlayer(shooter, "Attempted to shoot without weapon in inventory.")
    end)
end
