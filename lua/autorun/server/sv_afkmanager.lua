
AddCSLuaFile("cfg/afk_config.lua")
include("cfg/afk_config.lua")

util.AddNetworkString("AFKWarning")
util.AddNetworkString("PlayerMoved")
util.AddNetworkString("AFKShowWarning")
util.AddNetworkString("AFKHideWarning")

local playerAFKTimes = {}
local warnedPlayers = {}

hook.Add("OnReloaded", "AFKReload", function()
    playerAFKTimes = {}
    warnedPlayers = {}
    net.Start("AFKHideWarning")
    net.Broadcast()
end)

local function HandleAFK(ply)
    if AFKConfig.SkipGroup[ply:GetUserGroup()] then return end
    local inactiveTime = CurTime() - playerAFKTimes[ply:SteamID()].lastTime
    if inactiveTime >= AFKConfig.WarningTime and inactiveTime < AFKConfig.KickTime then
        if not warnedPlayers[ply:SteamID()] then
            net.Start("AFKShowWarning")
            net.Send(ply)
            warnedPlayers[ply:SteamID()] = true
        end
    elseif inactiveTime >= AFKConfig.KickTime then
        hook.Call("PlayerAFKKick", nil, ply)
        ply:Kick(AFKConfig.KickReason)
    end
end

timer.Create("AFKCheckTimer", 60, 0, function()
    for _, ply in ipairs(player.GetHumans()) do
        if playerAFKTimes[ply:SteamID()] then
            HandleAFK(ply)
        end
    end
end)

hook.Add("PlayerSpawn", "ResetAFKTime", function(ply)
    if AFKConfig.SkipGroup[ply:GetUserGroup()] then return end
    playerAFKTimes[ply:SteamID()] = {lastTime = CurTime()}
    warnedPlayers[ply:SteamID()] = nil
end)

hook.Add("PlayerDisconnected", "RemoveAFKTime", function(ply)
    if AFKConfig.SkipGroup[ply:GetUserGroup()] then return end
    playerAFKTimes[ply:SteamID()] = nil
    warnedPlayers[ply:SteamID()] = nil
end)

hook.Add("PlayerKick", "RemovePlayerFromList", function(ply)
    if AFKConfig.SkipGroup[ply:GetUserGroup()] then return end
    if playerAFKTimes[ply:SteamID()] then
        playerAFKTimes[ply:SteamID()] = nil
        warnedPlayers[ply:SteamID()] = nil
    end
end)

hook.Add("KeyPress", "PlayerMoved", function(ply)
    if AFKConfig.SkipGroup[ply:GetUserGroup()] then return end
    playerAFKTimes[ply:SteamID()] = {lastTime = CurTime()}

    if warnedPlayers[ply:SteamID()] then
        net.Start("AFKHideWarning")
        net.Send(ply)
        warnedPlayers[ply:SteamID()] = nil
    end
end)

net.Receive("PlayerMoved", function(len, ply)
    playerAFKTimes[ply:SteamID()] = {lastTime = CurTime()}

    if warnedPlayers[ply:SteamID()] then
        net.Start("AFKHideWarning")
        net.Send(ply)
        warnedPlayers[ply:SteamID()] = nil
    end
end)

