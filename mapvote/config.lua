MapVote.DefaultConfig = {
    MaxMaps = 6,
    VoteTime = 30, -- seconds
    --MapTime = 30, -- minutes
    MapsBeforeRevote = 4,
    AllowCurrentMap = true,
    MaxNominatesPerPlayer = 1,
    PlayersCanNominateMaps = true,
    MaxNominatedMaps = 3,
    NominateCommands = { "rtvmap", "nominate", "addmap", "addnominate" }
}

MapVote.DefaultConfig.ExtraPower = {
    vip = 2,
    admin = 1,
    superadmin = 1
}

if (SERVER) then
    if file.Exists("mapvote/config.txt", "DATA") then
        MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
    else
        MapVote.Config = MapVote.DefaultConfig
    end
end
print("config loaded")