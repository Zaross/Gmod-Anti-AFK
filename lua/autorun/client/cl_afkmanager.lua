include("cfg/afk_config.lua")

local lastMoveTime = CurTime()
local lastSentTime = CurTime()
local MOVE_NOTIFY_INTERVAL = 60
local afkWarningFrame

surface.CreateFont("AFKWarningFont", {
	font = "Arial",
	size = 42,
	weight = 500,
	antialias = true
})

local function CheckPlayerMovement()
    local ply = LocalPlayer()

    if not IsValid(ply) or not ply:Alive() then return end

    if ply:GetVelocity():Length() > 0 then
        lastMoveTime = CurTime()

        if CurTime() - lastSentTime > MOVE_NOTIFY_INTERVAL then
            net.Start("PlayerMoved")
            net.SendToServer()
            lastSentTime = CurTime()
        end
    end
end

timer.Create("PlayerMoveCheck", 0.5, 0, function()
    CheckPlayerMovement()
end)

net.Receive("AFKShowWarning", function()
    if not IsValid(afkWarningFrame) then
        afkWarningFrame = vgui.Create("DFrame")
        afkWarningFrame:SetTitle("")
        afkWarningFrame:SetSize(ScrW(), ScrH())
        afkWarningFrame:Center()
		afkWarningFrame:SetDraggable(false)
		afkWarningFrame:ShowCloseButton(false)
		afkWarningFrame:SetBackgroundBlur(true)
        afkWarningFrame.Paint = function(self, w, h)
			draw.RoundedBox(0, 0, 0, w, h, Color(0,0,0,240))
			draw.SimpleText(AFKConfig.WarningMessage, "AFKWarningFont", w / 2, h / 2 - 100, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end
    end
end)

net.Receive("AFKHideWarning", function()
    if IsValid(afkWarningFrame) then
        afkWarningFrame:Close()
        afkWarningFrame = nil
    end
end)