MapVote.DefaultConfig = {
    MaxMaps = 6,
    MapTime = 30, -- minutes
    MapsBeforeRevote = 4,
    MaxNominatesPerPlayer = 1,
    NominateCommands = { "rtvmap", "nominate", "addmap", "addnominate" }
}

if (SERVER) then
    if file.Exists("mapvote/config.txt", "DATA") then
        MapVote.Config = util.JSONToTable(file.Read("mapvote/config.txt", "DATA"))
    else
        MapVote.Config = MapVote.DefaultConfig
    end
end
print("config loaded")