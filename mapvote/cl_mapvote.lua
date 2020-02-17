function MapVote:CreateFont(name, size, weigth) 
    surface.CreateFont(name, {
        font = "Monsterrat Medium",
        size = size,
        weigth = 500,
        extended = true,
        antialias = true
    })
end

net.Receive("MapVote_Start", function() 
    MapVote.CurrentMaps = net.ReadTable()
    MapVote.VoteTime = net.ReadUInt(32)
    MapVote.Votes = {}

    MapVote.EndVoteTime = MapVote.VoteTime + CurTime()

    if ( IsValid(MapVote.PANEL) ) then
        MapVote.PANEL:Remove()
    end

    MapVote.PANEL = vgui.Create("MapVote_VoteMenu")
end)

net.Receive("MapVote_Update", function()
    local ply = net.ReadEntity()
    local map_id = net.ReadUInt(32)

    if ( IsValid(ply) ) then MapVote.Votes[ply:SteamID()] = map_id

    if ( IsValid(MapVote.PANEL) ) then
        MapVote.PANEL:AddVotePlayer(ply)
    end
end)

net.Receive("MapVote_Cancel", function()
    if ( IsValid(MapVote.PANEL) ) then
        MapVote.PANEL:Remove()
    end
end)

print("cl_mapvote loaded")