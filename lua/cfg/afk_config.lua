AFKConfig = {}

AFKConfig.WarningTime = 600 // Time until a player receives a warning in seconds

AFKConfig.KickTime = 900 // Time until a player is kicked in seconds

AFKConfig.WarningMessage = " ATTENTION: You are reported as AFK by the system. Move to avoid a kick!" // Warning message

AFKConfig.KickReason = "You have been kicked due to inactivity!" // Reason for the kick

AFKConfig.SkipGroup = { // Groups that are not affected by the AFK system
    ["superadmin"] = true,
    ["admin"] = true,
}
