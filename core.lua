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
texture:SetColorTexture(1.0, 0.0, 1.0, 1.0) -- Bright Magenta #FF00FF

frame:Hide()

local isLFGConfirming = false

-- Check active PvP queues for a pending confirmation dialog
local function IsBattlefieldConfirming()
    local maxID = (GetMaxBattlefieldID and GetMaxBattlefieldID()) or 0
    for i = 1, maxID do
        local status = GetBattlefieldStatus(i)
        if status == "confirm" then
            return true
        end
    end
    if PVPReadyDialog and PVPReadyDialog:IsShown() then
        return true
    end
    return false
end

local function UpdateIndicator()
    local battlefieldConfirm = IsBattlefieldConfirming()
    local lfgConfirm = isLFGConfirming or (LFGDungeonReadyDialog and LFGDungeonReadyDialog:IsShown())

    if battlefieldConfirm or lfgConfirm then
        frame:Show()
    else
        frame:Hide()
    end
end

-- Hook Blizzard's PVPReadyDialog display function (as used in BetterBlizzQueue)
if PVPReadyDialog_Display then
    hooksecurefunc("PVPReadyDialog_Display", function()
        frame:Show()
    end)
end

if PVPReadyDialog then
    PVPReadyDialog:HookScript("OnShow", function()
        frame:Show()
    end)
    PVPReadyDialog:HookScript("OnHide", function()
        UpdateIndicator()
    end)
end

if LFGDungeonReadyDialog then
    LFGDungeonReadyDialog:HookScript("OnShow", function()
        isLFGConfirming = true
        frame:Show()
    end)
    LFGDungeonReadyDialog:HookScript("OnHide", function()
        isLFGConfirming = false
        UpdateIndicator()
    end)
end

-- Event Handling: Battlefield and LFG queue notifications
frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:RegisterEvent("PVP_BATTLEGROUND_CONFIRMATION_SHOW")
frame:RegisterEvent("PVP_BATTLEGROUND_CONFIRMATION_HIDE")
frame:RegisterEvent("LFG_PROPOSAL_SHOW")
frame:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
frame:RegisterEvent("LFG_PROPOSAL_DONE")
frame:RegisterEvent("LFG_PROPOSAL_FAILED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PVP_BATTLEGROUND_CONFIRMATION_SHOW" or event == "LFG_PROPOSAL_SHOW" then
        if event == "LFG_PROPOSAL_SHOW" then
            isLFGConfirming = true
        end
        frame:Show()
    elseif event == "LFG_PROPOSAL_SUCCEEDED" or event == "LFG_PROPOSAL_DONE" or event == "LFG_PROPOSAL_FAILED" then
        isLFGConfirming = false
        UpdateIndicator()
    else
        -- UPDATE_BATTLEFIELD_STATUS, PVP_BATTLEGROUND_CONFIRMATION_HIDE, PLAYER_ENTERING_WORLD
        UpdateIndicator()
    end
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
                if not (IsBattlefieldConfirming() or isLFGConfirming or (LFGDungeonReadyDialog and LFGDungeonReadyDialog:IsShown())) then
                    frame:Hide()
                end
                testTimer = nil
            end)
        end
    elseif command == "status" then
        local confirming = IsBattlefieldConfirming() or isLFGConfirming or (LFGDungeonReadyDialog and LFGDungeonReadyDialog:IsShown())
        print(string.format("|cffff00ff[AikoArenaNotifier]|r Queue confirming: %s | Frame shown: %s",
            confirming and "|cff00ff00YES|r" or "|cffff0000NO|r",
            frame:IsShown() and "|cff00ff00YES|r" or "|cffff0000NO|r"))
    else
        print("|cffff00ff[AikoArenaNotifier]|r Commands:")
        print("  |cffffff00/aan test|r - Toggle test pixel (auto-hides after 10s) for desktop script calibration")
        print("  |cffffff00/aan status|r - Print current queue confirmation status")
    end
end
