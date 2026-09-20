local VORPcore = exports.vorp_core:GetCore()
BathingSessions = {}

local function IsPlayerNearBath(src, town, maxDistance)
    local zone = Config.BathingZones[town]
    if not zone then return false end

    local ped = GetPlayerPed(src)
    if not ped or ped == 0 then return false end

    local playerCoords = GetEntityCoords(ped)
    return #(playerCoords - zone.consumer) <= (maxDistance or 3.0)
end

RegisterServerEvent('vorp-bathing:server:canEnterBath')
AddEventHandler('vorp-bathing:server:canEnterBath', function(town)
    local src = source
    if not Config.BathingZones[town] then return end

    if not IsPlayerNearBath(src, town) then return end

    local User = VORPcore.getUser(src)
    if not User then return end
    local Character = User.getUsedCharacter
    if not Character then return end
    local currentMoney = Character.money or 0

    if not BathingSessions[town] then
        if currentMoney >= Config.NormalBathPrice then
            Character.removeCurrency(0, Config.NormalBathPrice)
            BathingSessions[town] = src
            TriggerClientEvent('vorp-bathing:client:ToggleInvincibility', src, true)
            TriggerClientEvent('vorp-bathing:client:StartBath', src, town)
        else
            TriggerClientEvent('vorp-bathing:client:notify', src, locale('notify_not_enough_money'))
        end
    else
        TriggerClientEvent('vorp-bathing:client:notify', src, locale('notify_occupied'))
    end
end)

RegisterServerEvent('vorp-bathing:server:canEnterDeluxeBath')
AddEventHandler('vorp-bathing:server:canEnterDeluxeBath', function(town)
    local src = source
    if not Config.BathingZones[town] then return end
    if BathingSessions[town] == src then

        local User = VORPcore.getUser(src)
        if not User then return end
        local Character = User.getUsedCharacter
        if not Character then return end
        local currentMoney = Character.money or 0

        if currentMoney >= Config.DeluxeBathPrice then
            Character.removeCurrency(0, Config.DeluxeBathPrice)
            TriggerClientEvent('vorp-bathing:client:StartDeluxeBath', src, town)
        else
            TriggerClientEvent('vorp-bathing:client:notify', src, locale('notify_not_enough_money'))
            TriggerClientEvent('vorp-bathing:client:HideDeluxePrompt', src)
        end
    end
end)

RegisterServerEvent('vorp-bathing:server:setBathAsFree')
AddEventHandler('vorp-bathing:server:setBathAsFree', function(town)
    if BathingSessions[town] == source then
        BathingSessions[town] = nil
        TriggerClientEvent('vorp-bathing:client:ToggleInvincibility', source, false)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    for town, player in pairs(BathingSessions) do
        if player == src then
            BathingSessions[town] = nil
        end
    end
end)

RegisterServerEvent('vorp-bathing:server:setCleanliness')
AddEventHandler('vorp-bathing:server:setCleanliness', function(value)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for town, player in pairs(BathingSessions) do
            TriggerClientEvent('vorp-bathing:client:ToggleInvincibility', player, false)
        end
        BathingSessions = {}
    end
end)