-- AikoArenaNotifier
-- Minimal, standalone pixel bridge indicator for PvP queue pops (Retail / Midnight)
-- Author: Aiko

local frame = CreateFrame("Frame", "AikoArenaNotifierFrame", UIParent)
frame:SetSize(5, 5)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
frame:SetFrameStrata("TOOLTIP")
frame:EnableMouse(false)

local texture = frame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(frame)
texture:SetColorTexture(1.0, 0.0, 1.0, 1.0) -- Magenta #FF00FF

frame:Hide()

-- Check active PvP queues for a pending confirmation dialog
local function CheckQueueStatus()
    local maxID = (GetMaxBattlefieldID and GetMaxBattlefieldID()) or 0
    for i = 1, maxID do
        local status = GetBattlefieldStatus(i)
        if status == "confirm" then
            return true
        end
    end
    return false
end

local function UpdateIndicator(event)
    if event == "PVP_BATTLEGROUND_CONFIRMATION_SHOW" then
        frame:Show()
    elseif event == "PVP_BATTLEGROUND_CONFIRMATION_HIDE" then
        if CheckQueueStatus() then
            frame:Show()
        else
            frame:Hide()
        end
    else
        -- UPDATE_BATTLEFIELD_STATUS, PLAYER_ENTERING_WORLD, etc.
        if CheckQueueStatus() then
            frame:Show()
        else
            frame:Hide()
        end
    end
end

frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:RegisterEvent("PVP_BATTLEGROUND_CONFIRMATION_SHOW")
frame:RegisterEvent("PVP_BATTLEGROUND_CONFIRMATION_HIDE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    UpdateIndicator(event)
end)

-- Slash commands for calibration & testing
local testTimer = nil

SLASH_AIKOARENANOTIFIER1 = "/aan"
SLASH_AIKOARENANOTIFIER2 = "/aikonotifier"
SlashCmdList["AIKOARENANOTIFIER"] = function(msg)
    local command = msg and msg:match("^%s*(.-)%s*$"):lower() or ""

    if command == "test" then
        if frame:IsShown() then
            if testTimer then
                testTimer:Cancel()
                testTimer = nil
            end
            frame:Hide()
            print("|cffff00ff[AikoArenaNotifier]|r Test pixel hidden.")
        else
            frame:Show()
            print("|cffff00ff[AikoArenaNotifier]|r Test pixel displayed (magenta 5x5 at TOPLEFT 0,0) for 10 seconds.")
            if testTimer then
                testTimer:Cancel()
            end
            testTimer = C_Timer.NewTimer(10, function()
                if not CheckQueueStatus() then
                    frame:Hide()
                end
                testTimer = nil
            end)
        end
    elseif command == "status" then
        local confirming = CheckQueueStatus()
        print(string.format("|cffff00ff[AikoArenaNotifier]|r Queue confirming: %s | Frame shown: %s",
            confirming and "|cff00ff00YES|r" or "|cffff0000NO|r",
            frame:IsShown() and "|cff00ff00YES|r" or "|cffff0000NO|r"))
    else
        print("|cffff00ff[AikoArenaNotifier]|r Commands:")
        print("  |cffffff00/aan test|r - Toggle test pixel (auto-hides after 10s) for desktop script calibration")
        print("  |cffffff00/aan status|r - Print current queue confirmation status")
    end
end
