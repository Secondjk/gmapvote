MapVote.NominatedMaps = MapVote.NominatedMaps or {}
MapVote.Votes = MapVote.Votes or {}
MapVote.RTVs = MapVote.RTVs or {}

util.AddNetworkString("MapVote_Start")
util.AddNetworkString("MapVote_Update")
util.AddNetworkString("MapVote_Cancel")
util.AddNetworkString("MapVote_End")
util.AddNetworkString("MapVote_SendMessage")

net.Receive("MapVote_Update", function(len, ply)
    if ( MapVote.Allow && IsValid(ply) ) then
        local map_id = net.ReadUInt(32)

        if ( MapVote.CurrentMaps[map_id] ) then
            MapVote.Votes[ply:SteamID()] = map_id

            net.Start("MapVote_Update")
                net.WriteEntity(ply)
                net.WriteUInt(map_id, 32)
            net.Broadcast()
        end
    end
end)

function MapVote.SendMessage(msg, ply)
    net.Start("MapVote_SendMessage")
    net.WriteString(msg)
    net.WriteColor(MapVote.Config.PreColor)
    net.WriteString(MapVote.Config.Prefix)

    if ( IsValid(ply) ) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function MapVote.RTV(ply)
    if ( MapVote.Allow ) then return end

    if ( MapVote.RTVs[ply:SteamID()] ) then
        MapVote.SendMessage("You have already rocked the vote!", ply)
    else
        MapVote.RTVActual = MapVote.RTVActual + 1
        if ( MapVote.RTVActual < MapVote.RTVAmount ) then
            MapVote.SendMessage(string.sub(ply:Nick(), 1, 16) .. " has rocked the vote! " .. MapVote.RTVAmount - MapVote.RTVActual .. " more votes required to start a vote.", ply)
        end
        MapVote.RTVs[ply:SteamID()] = true
    end
end

function MapVote.PlayerDisconnect(ply)
    if ( MapVote.RTVs[ply:SteamID()] ) then
        MapVote.RTVs[ply:SteamID()] = false
        MapVote.RTVActual = MapVote.RTVActual - 1
    end
end
hook.Add("PlayerDisconnected", "MapVote_PlayerDisconnected", MapVote.PlayerDisconnect)

function MapVote.UpdateNominatedMap(ply, map)
    if !( isAvailableMap(map) && table.HasValue(MapVote.AllMaps, map) &&
        !MapVote.Allow && MapVote.NominatedMaps[ply:SteamID()] != map ) then return false end

    MapVote.NominatedMaps[ply:SteamID()] = map
    return true
end

function MapVote.RTVCommand(ply, text)
    for _, v in pairs(MapVote.Config.RTVCommands) do
        if (string.match(string.lower(text), "^[!/:.]" .. v)) then
            MapVote.RTV(ply)
        end
    end
end
hook.Add("PlayerSay", "MapVote_RTVChatCommands", MapVote.RTVCommand)

function MapVote.NominateChatCommands(ply, text)
    local arguments = string.Split(text, " ")

    if ( table.HasValue(MapVote.Config.NominateCommands, string.sub(string.lower(arguments[1]), 2)) &&
        arguments[2] != nil ) then
        local map = arguments[2]

        if ( MapVote.UpdateNominatedMap(ply, map) ) then
            MapVote.SendMessage(ply:Nick() .. " has nominated a" .. map)
        else
            MapVote.SendMessage("Can't nominated " .. map, ply)
        end
    end
end

if ( MapVote.Config.PlayersCanNominateMaps ) then
    hook.Add("PlayerSay", "MapVote_NominateChatCommands", MapVote.NominateChatCommands)
end

function MapVote.PlayerDisconnect(ply)
    if ( MapVote.NominatedMaps[ply:SteamID()] ) then
        MapVote.NominatedMaps[ply:SteamID()] = nil
    end
end
hook.Add("PlayerDisconnected", "MapVote_Disconnect", MapVote.PlayerDisconnect)

print("sv_netmessages loaded")