MapVote.NominatedMaps = MapVote.NominatedMaps or {}
MapVote.Votes = MapVote.Votes or {}
MapVote.RTVActual = 0

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

function MapVote.SendMessage(ply, msg, locally)
    net.Start("MapVote_SendMessage")
    net.WriteString(msg)

    if ( locally ) then
        net.Send(ply)
    else
        net.Broadcast()
    end
end

function MapVote.RTV(ply)
    if ( !MapVote.Allow ) then return false end

    if ( !ply.RTVed ) then
        MapVote.SendMessage(ply, "You have already rocked the vote!", true)
    else
        MapVote.SendMessage(ply, string.sub(ply:Nick(), 1, 16) .. " has rocked the vote! " .. MapVote.RTVAmount - MapVote.RTVActual .. " more votes required to start a vote.")
        MapVote.RTVActual = MapVote.RTVActual + 1
        ply.RTVed = true
    end

end

function MapVote.UpdateNominatedMap(ply, map)
    if !( isAvailableMap(map) && table.HasValue(MapVote.AllMaps, map) &&
        !MapVote.Allow && MapVote.NominatedMaps[ply:SteamID()] != map ) then return false end

    MapVote.NominatedMaps[ply:SteamID()] = map
    return true
end

function MapVote.RTVCommand(ply, text)
    if ( string.match(text, "^[!/:.]" .. MapVote.Config.RTVCommands) ) then
        MapVote.RTV(ply)
    end
end
hook.Add("PlayerSay", "MapVote_RTVChatCommands", MapVote.RTVCommand)

function MapVote.NominateChatCommands(ply, text)
    local arguments = string.Split(text, " ")

    if ( table.HasValue(MapVote.Config.NominateCommands, string.sub(string.lower(arguments[1]), 2)) &&
        arguments[2] != nil ) then
        local map = arguments[2]

        if ( MapVote.UpdateNominatedMap(ply, map) ) then
            MapVote.SendMessage(ply, ply:Nick() .. " has nominated a" .. map)
        else
            MapVote.SendMessage(ply, "Can't nominated " .. map)
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