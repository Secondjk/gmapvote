MapVote = MapVote or {}

if (SERVER) then
    include("mapvote/config.lua")
    include("mapvote/sv_mapvote.lua")
    include("mapvote/sv_netmessages.lua")
elseif (CLIENT) then
    include("mapvote/cl_mapvote.lua")
    include("mapvote/cl_interface.lua")
    AddCSLuaFile("mapvote/cl_interface.lua")
    AddCSLuaFile("mapvote/cl_mapvote.lua")
end