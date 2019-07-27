local identifiers = {}
function ShowInfo(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentSubstringPlayerName(text)
    DrawNotification(false, false)
end

Citizen.CreateThread(function()
    local myIdss = getIdentifiers()
    print(myIdss)
    while true do
        Citizen.Wait(4000)
        TriggerServerEvent('primerp_vehwl:reloadwl') 
        TriggerServerEvent('primerp_vehwl:Server:Check')
    end
end)
function getConfig()
    return LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
end
AddEventHandler("playerSpawned", function()
    TriggerServerEvent("primerp_vehwl:reloadwl")
end)

function getIdentifiers()
    return identifiers
end

RegisterNetEvent('primerp_vehwl:RunCode:Client')
AddEventHandler('primerp_vehwl:RunCode:Client', function(cfg)
    --
    local ped = GetPlayerPed(-1)
    local inVeh = IsPedInAnyVehicle(ped, false)
    local veh = GetVehiclePedIsUsing(ped)
    local driver = GetPedInVehicleSeat(veh, -1)
    local spawncode = GetEntityModel(veh)
    local allowed = false
    local exists = false
    local myIds = {}
    myIds = getIdentifiers()
    if (inVeh) and (driver == ped) then
        for pair,_ in pairs(cfg) do
            -- Pair
            for _,vehic in ipairs(cfg[pair]) do
                print("Checking if exists with vehic.spawncode == " .. string.upper(vehic.spawncode) .. " and spawncode == "
                    .. string.upper(spawncode))
                if (GetHashKey(vehic.spawncode) == spawncode) then
                    exists = true
                end
            end
            if (pair == myIds[1]) then
                for _,v in ipairs(cfg[pair]) do
                    --print(v.allowed)
                    --print("The vehicle is " .. v.spawncode .. " and allowed = " .. tostring(v.allowed) .. " with ID as " .. tostring(pair))
                    if (spawncode == GetHashKey(v.spawncode)) and (v.allowed) then
                        allowed = true
                        print("Allowed was set to true with vehicle == " .. v.spawncode)
                    end
                end
            end
        end
    end
    --print("Value of exists == " .. tostring(exists) .. " and value of allowed == " .. tostring(allowed))
    if (exists and not allowed) then
        print("It should delete the vehicle for " .. GetPlayerName(source))
        DeleteEntity(veh)
        ClearPedTasksImmediately(ped)
        TriggerEvent('primerp_vehwl:RunCode:Success', source)
    end
end)

RegisterNetEvent('primerp_vehwl:RunCode:Success')
AddEventHandler('primerp_vehwl:RunCode:Success', function()
    ShowInfo('~r~ERROR: You do not have access to this personal vehicle')
end)

RegisterNetEvent("primerp_vehwl:loadIdentifiers")
AddEventHandler("primerp_vehwl:loadIdentifiers", function(id)
    identifiers = id
end)

RegisterCommand("reloadwl", function(source)
    TriggerServerEvent("primerp_vehwl:reloadwl")
end)

--[[
    Commands:
        /setOwner <id> <spawncode>
        /trust <id> <spawncode>
        /untrust <id> <spawncode>
        /vehicle list
--]]--