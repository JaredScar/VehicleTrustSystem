
prefix = '^0[^6VehicleTrustSystem^0] '

-- Code --
RegisterServerEvent("primerp_vehwl:reloadwl")
AddEventHandler("primerp_vehwl:reloadwl", function()
    local _source = source
    local identifiers = GetPlayerIdentifiers(_source)
    TriggerClientEvent("primerp_vehwl:loadIdentifiers", _source, identifiers)
end)

AddEventHandler("playerSpawned", function()
    TriggerEvent("primerp_vehwl:getIdentifiers")
end)

RegisterServerEvent("primerp_vehwl:saveFile")
AddEventHandler("primerp_vehwl:saveFile", function(data)
    SaveResourceFile(GetCurrentResourceName(), "whitelist.json", json.encode(data, { indent = true }), -1)
end)
function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end
function get_index (tab, val)
	local counter = 1
    for index, value in ipairs(tab) do
        if value == val then
            return counter
        end
		counter = counter + 1
    end

    return nil
end
RegisterNetEvent('primerp_vehwl:Server:Check')
AddEventHandler('primerp_vehwl:Server:Check', function()
	local config = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(config)
    TriggerClientEvent('primerp_vehwl:RunCode:Client', source, cfg)
end)

--- COMMANDS ---
RegisterCommand("vehicles", function(source, args, rawCommand)
    -- Get the vehicles they can drive
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    local allowed = {}
    local myIds = GetPlayerIdentifiers(source)
    for pair,_ in pairs(cfg) do
        -- Pair
        if (pair == myIds[1]) then
            for _,v in ipairs(cfg[pair]) do
                --print(v.allowed)
                --print("The vehicle is " .. v.spawncode .. " and allowed = " .. tostring(v.allowed) .. " with ID as " .. tostring(pair))
                if (v.allowed) then
                    table.insert(allowed, v.spawncode)
                end
            end
        end
    end
    if #allowed > 0 then
        TriggerClientEvent('chatMessage', source, prefix .. "^2You are allowed access to drive the following vehicles:")
        TriggerClientEvent('chatMessage', source, "^0" .. table.concat(allowed, ', '))
    end
end)
RegisterCommand("clear", function(source, args, rawCommand)
	-- /clear <spawncode> == Basically reset a vehicle's data (owners and allowed to drive)
    if IsPlayerAceAllowed(source, "VehwlCommands.Access") then
    	-- Check args
        if #args < 1 then
        	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: Not enough arguments... ^1Valid: /clear <spawncode>")
        	return;
        end
    	local vehicle = string.upper(args[1])
    	local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    	local cfg = json.decode(al)
    	for pair,_ in pairs(cfg) do
        	-- Pair
        	local ind = 0
        	for _,veh in ipairs(cfg[pair]) do
        		ind = ind + 1
        		if string.upper(veh.spawncode) == string.upper(vehicle) then
                    table.remove(cfg[pair], ind)
        		end
        	end
        end
        TriggerClientEvent('chatMessage', source, prefix .. "^2Success: Removed all data of vehicle ^5" .. vehicle .. "^2")
        TriggerClientEvent('vehwl:Cache:Update:ClearVeh', -1, vehicle)
        TriggerEvent("primerp_vehwl:saveFile", cfg)
    end
end)
RegisterCommand("setOwner", function(source, args, rawCommand)
    -- Needs a staff Ace perm to do this
    if IsPlayerAceAllowed(source, "VehwlCommands.Access") then
	    if #args < 2 then
	        -- Too low args
	        TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: Not enough arguments... ^1Valid: /setOwner <id> <vehicleSpawncode>")
	        return;
	    end
	    local id = tonumber(args[1])
	    --print(GetPlayerIdentifiers(id)[1])
	    if GetPlayerIdentifiers(id)[1] == nil then
	    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: That is not a valid server ID of a player...")
	    	return;
	    end
	    -- /setOwner <id> <vehicle>
	    local vehicle = string.upper(args[2])
	    local identifiers = GetPlayerIdentifiers(id)
	    local steam = identifiers[1]
	    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
	    local cfg = json.decode(al)
	    -- Check that no one owns this vehicle before setting it:
	    local vehicledOwned = false
	    -- Check below:
	    for pair,_ in pairs(cfg) do
	    	-- Pair
	    	for _,veh in ipairs(cfg[pair]) do
	    		if string.upper(veh.spawncode) == string.upper(vehicle) then
	    			if veh.owner == true then
	    				vehicledOwned = true
	    			end
	    		end
	    	end
	    end
	    -- Is it owned already?
	    if not vehicledOwned then
		    local vehiclesList = cfg[steam]
		    if vehiclesList == nil then
		    	cfg[steam] = {}
		    	vehiclesList = {}
		    end
		    local hasValue = false
		    local index = nil
		    for i = 1, #vehiclesList do
		    	if string.upper(vehicle) == string.upper(vehiclesList[i].spawncode) then
		    		hasValue = true
		    		index = i
		    	end
		    end
		    if not hasValue then
		    	-- Doesn't have it, add it
		    	table.insert(vehiclesList, {
		    		owner=true,
		   			allowed=true,
		   			spawncode=vehicle,
		    	})
		    else
		    	-- It does have it, set it
		    	vehiclesList[index].owner = true
		    	vehiclesList[index].allowed = true
		    end
		    cfg[steam] = vehiclesList
		    TriggerEvent("primerp_vehwl:saveFile", cfg)		 
		    TriggerClientEvent('chatMessage', source, prefix .. "^2Success: You have set ^5" 
		    	.. GetPlayerName(id) .. "^2 as the owner to the vehicle, ^5" .. vehicle)
		    TriggerClientEvent('chatMessage', id, prefix .. "^2You have been set " 
		    	.. " to the owner of vehicle, ^5" .. vehicle .. "^2 by ^5" .. GetPlayerName(source))
		else
			-- Vehicle is owned, need to /clear it first
			TriggerClientEvent('chatMessage', source, prefix .. 
				"^1ERROR: That vehicle is owned by someone already... Use /clear <spawncode> to clear it's data")
		end
	end -- Can't use it if not allowed
end)
function isOwner(src)
	-- Check if they own the vehicle
end
RegisterCommand("trust", function(source, args, rawCommand)
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    -- /trust <id> <vehicle>
    local vehicle = string.upper(args[2])
    local id = tonumber(args[1])
    -- Check args
    if #args < 2 then
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: Not enough arguments... ^1Valid: /trust <id> <vehicleSpawncode>")
    	return;
    end
    -- Check if valid id
    if id == source then
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: You cannot trust yourself...")
    	return;
    end
    if GetPlayerIdentifiers(id)[1] == nil then
    	-- It's invalid
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: That is not a valid server ID of a player...")
    	return;
    end
    local steam = GetPlayerIdentifiers(id)[1]
    -- Check if has vehicle ownership and can do this command
    local vehicledOwned = false
    -- Check below:
    for pair,_ in pairs(cfg) do
    	-- Pair
    	if tostring(GetPlayerIdentifiers(source)[1]) == tostring(pair) then 
	    	for _,veh in ipairs(cfg[pair]) do
	    		if string.upper(veh.spawncode) == string.upper(vehicle) then
	    			if veh.owner == true then
	    				vehicledOwned = true
	    			end
	    		end
	    	end
	    end
    end
    if not vehicledOwned then
    	-- They do not own it, end this
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: You do not own this vehicle...")
    	return;
    end
    local vehiclesList = cfg[steam]
    if vehiclesList == nil then
    	cfg[steam] = {}
    	vehiclesList = {}
    end
    local hasValue = false
    local index = nil
    for i = 1, #vehiclesList do
    	if string.upper(vehicle) == string.upper(vehiclesList[i].spawncode) then
    		hasValue = true
    		index = i
    	end
    end
    if not hasValue then
    	-- Doesn't have it, add it
    	table.insert(vehiclesList, {
    		owner=false,
   			allowed=true,
   			spawncode=vehicle,
    	})
    else
    	-- It does have it, set it
    	vehiclesList[index].owner = false
    	vehiclesList[index].allowed = true
    end
    cfg[steam] = vehiclesList
    TriggerEvent("primerp_vehwl:saveFile", cfg)
    TriggerClientEvent('chatMessage', source, prefix .. "^2Success: You have given player ^5" 
    	.. GetPlayerName(id) .. "^2 permission to drive your vehicle ^5"
	 .. vehicle)
    TriggerClientEvent('chatMessage', id, prefix .. "^2You have been trusted " 
		    	.. " to use the vehicle, ^5" .. vehicle .. "^2 by owner ^5" .. GetPlayerName(source))
end)

RegisterCommand("untrust", function(source, args, rawCommand)
    local al = LoadResourceFile(GetCurrentResourceName(), "whitelist.json")
    local cfg = json.decode(al)
    -- /untrust <id> <vehicle>
    local vehicle = string.upper(args[2])
    local id = tonumber(args[1])
    -- Check args
    if #args < 2 then
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: Not enough arguments... ^1Valid: /untrust <id> <vehicleSpawncode>")
    	return;
    end
    -- Check if valid id
    if id == source then
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: You cannot untrust yourself...")
    	return;
    end
    if GetPlayerIdentifiers(id)[1] == nil then
    	-- It's invalid
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: That is not a valid server ID of a player...")
    	return;
    end
    local steam = GetPlayerIdentifiers(id)[1]
    -- Check if has vehicle ownership and can do this command
    local vehicledOwned = false
    -- Check below:
    for pair,_ in pairs(cfg) do
    	-- Pair
    	if tostring(GetPlayerIdentifiers(source)[1]) == tostring(pair) then 
	    	for _,veh in ipairs(cfg[pair]) do
	    		if string.upper(veh.spawncode) == string.upper(vehicle) then
	    			if veh.owner == true then
	    				vehicledOwned = true
	    			end
	    		end
	    	end
	    end
    end
    if not vehicledOwned then
    	-- They do not own it, end this
    	TriggerClientEvent('chatMessage', source, prefix .. "^1ERROR: You do not own this vehicle...")
    	return;
    end
    local vehiclesList = cfg[steam]
    if vehiclesList == nil then
    	cfg[steam] = {}
    	vehiclesList = {}
    end
    local hasValue = false
    local index = nil
    for i = 1, #vehiclesList do
    	if string.upper(vehicle) == string.upper(vehiclesList[i].spawncode) then
    		hasValue = true
    		index = i
    	end
    end
    if not hasValue then
    	-- Doesn't have it, add it
    	table.insert(vehiclesList, {
    		owner=false,
   			allowed=false,
   			spawncode=vehicle,
    	})
    else
    	-- It does have it, set it
    	vehiclesList[index].owner = false
    	vehiclesList[index].allowed = false
    end
    cfg[steam] = vehiclesList
    TriggerEvent("primerp_vehwl:saveFile", cfg)
	TriggerClientEvent('chatMessage', source, prefix .. "^2Success: ^1Player " 
		.. GetPlayerName(id) .. "^1 no longer has permission to drive your vehicle ^5"
	 .. vehicle)
	TriggerClientEvent('chatMessage', id, prefix .. "^1Your " 
		    	.. " trust to use the vehicle, ^5" .. vehicle .. " ^1has been revoked by owner ^5" .. GetPlayerName(source))
end)