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

-- Check whether any queue confirmation dialog is physically visible on screen
local function IsDialogShown()
    if PVPReadyDialog and PVPReadyDialog:IsShown() then
        return true
    end
    if LFGDungeonReadyDialog and LFGDungeonReadyDialog:IsShown() then
        return true
    end
    return false
end

local function UpdateIndicator()
    if IsDialogShown() then
        frame:Show()
    else
        frame:Hide()
    end
end

-- Safely hook dialog show, hide, and button clicks
local function HookDialog(dialog)
    if not dialog or dialog._aanHooked then return end
    dialog._aanHooked = true

    if dialog.HookScript then
        dialog:HookScript("OnShow", function()
            frame:Show()
        end)
        dialog:HookScript("OnHide", function()
            frame:Hide()
        end)
    end

    if dialog.enterButton and dialog.enterButton.HookScript then
        dialog.enterButton:HookScript("OnClick", function()
            frame:Hide()
        end)
    end
    if dialog.leaveButton and dialog.leaveButton.HookScript then
        dialog.leaveButton:HookScript("OnClick", function()
            frame:Hide()
        end)
    end
    if dialog.hideButton and dialog.hideButton.HookScript then
        dialog.hideButton:HookScript("OnClick", function()
            frame:Hide()
        end)
    end
    if dialog.closeButton and dialog.closeButton.HookScript then
        dialog.closeButton:HookScript("OnClick", function()
            frame:Hide()
        end)
    end
end

-- Hook Blizzard's PVPReadyDialog_Display function
if PVPReadyDialog_Display then
    hooksecurefunc("PVPReadyDialog_Display", function(dialog)
        HookDialog(dialog or PVPReadyDialog)
        frame:Show()
    end)
end

-- Initial hook attempts for known dialogs
HookDialog(PVPReadyDialog)
HookDialog(LFGDungeonReadyDialog)

-- Event Handling: valid retail events only
frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:RegisterEvent("LFG_PROPOSAL_SHOW")
frame:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
frame:RegisterEvent("LFG_PROPOSAL_DONE")
frame:RegisterEvent("LFG_PROPOSAL_FAILED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        HookDialog(PVPReadyDialog)
        HookDialog(LFGDungeonReadyDialog)
        UpdateIndicator()
    elseif event == "LFG_PROPOSAL_SHOW" then
        HookDialog(LFGDungeonReadyDialog)
        frame:Show()
    elseif event == "LFG_PROPOSAL_SUCCEEDED" or event == "LFG_PROPOSAL_DONE" or event == "LFG_PROPOSAL_FAILED" then
        frame:Hide()
    elseif event == "PLAYER_ENTERING_WORLD" then
        frame:Hide()
    else
        -- UPDATE_BATTLEFIELD_STATUS
        UpdateIndicator()
    end
end)

-- Slash commands for calibration & testing
local testTimer = nil

local function ToggleTestPixel()
    if frame:IsShown() then
        if testTimer then
            testTimer:Cancel()
            testTimer = nil
        end
        frame:Hide()
        print("|cffff00ff[AikoArenaNotifier]|r Test pixel |cffff0000HIDDEN|r.")
    else
        frame:Show()
        print("|cffff00ff[AikoArenaNotifier]|r Test pixel |cff00ff00SHOWN|r (5x5 magenta at TOPLEFT 0,0) for 10s. Type |cffffff00/aan|r again to hide.")
        if testTimer then
            testTimer:Cancel()
        end
        testTimer = C_Timer.NewTimer(10, function()
            if not IsDialogShown() then
                frame:Hide()
            end
            testTimer = nil
        end)
    end
end

SLASH_AIKOARENANOTIFIER1 = "/aan"
SLASH_AIKOARENANOTIFIER2 = "/aikonotifier"
SLASH_AIKOARENANOTIFIER3 = "/aikoarena"
SlashCmdList["AIKOARENANOTIFIER"] = function(msg)
    local command = msg and msg:match("^%s*(.-)%s*$"):lower() or ""

    if command == "status" then
        local shown = IsDialogShown()
        print(string.format("|cffff00ff[AikoArenaNotifier]|r Dialog visible: %s | Pixel indicator shown: %s",
            shown and "|cff00ff00YES|r" or "|cffff0000NO|r",
            frame:IsShown() and "|cff00ff00YES|r" or "|cffff0000NO|r"))
    elseif command == "help" then
        print("|cffff00ff[AikoArenaNotifier]|r Commands:")
        print("  |cffffff00/aan|r or |cffffff00/aan test|r - Toggle test pixel (auto-hides after 10s)")
        print("  |cffffff00/aan status|r - Print current dialog confirmation status")
    else
        ToggleTestPixel()
    end
end

-- Confirmation print on load
print("|cffff00ff[AikoArenaNotifier]|r loaded. Type |cffffff00/aan|r to test pixel.")
