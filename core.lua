-- AikoArenaNotifier
-- Minimal, standalone pixel bridge indicator for PvP queue pops (Retail / Midnight)
-- Author: Aiko

local DISPLAY_DURATION = 3 -- Seconds the indicator stays visible on queue pop
local PREFIX = "|cffA330C9AikoArenaNotifier:|r"

local frame = CreateFrame("Frame", "AikoArenaNotifierFrame", UIParent)
frame:SetSize(5, 5)
frame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 0)
frame:SetFrameStrata("TOOLTIP")
frame:EnableMouse(false)

local texture = frame:CreateTexture(nil, "BACKGROUND")
texture:SetAllPoints(frame)
texture:SetColorTexture(163 / 255, 48 / 255, 201 / 255, 1.0) -- #A330C9 (RGB: 0.639, 0.188, 0.788)

frame:Hide()

local popToken = 0
local lastPopTime = 0
local wasConfirming = false

local function HideIndicator()
    popToken = popToken + 1
    frame:Hide()
end

local function TriggerPop(duration, isTest)
    local now = GetTime()
    if not isTest and (now - lastPopTime < 1) then
        return -- Debounce duplicate triggers within 1 second
    end
    lastPopTime = now

    popToken = popToken + 1
    local currentToken = popToken
    local secs = duration or DISPLAY_DURATION

    frame:Show()

    if isTest then
        print(string.format("%s Test pixel shown for %d seconds.", PREFIX, secs))
    end

    C_Timer.After(secs, function()
        if popToken == currentToken then
            frame:Hide()
            if isTest then
                print(string.format("%s Test pixel hidden (timeout).", PREFIX))
            end
        end
    end)
end

-- Hook Blizzard's PVPReadyDialog_Display for instant zero-latency popup reaction
if PVPReadyDialog_Display then
    hooksecurefunc("PVPReadyDialog_Display", function()
        TriggerPop(DISPLAY_DURATION)
    end)
end

-- Event Handling: Battlefield state, LFG proposals, and loading screens
frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:RegisterEvent("LFG_PROPOSAL_SHOW")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        wasConfirming = false
        HideIndicator()
    elseif event == "LFG_PROPOSAL_SHOW" then
        TriggerPop(DISPLAY_DURATION)
    elseif event == "UPDATE_BATTLEFIELD_STATUS" then
        local isConfirm = false
        local maxID = (GetMaxBattlefieldID and GetMaxBattlefieldID()) or 0
        for i = 1, maxID do
            if GetBattlefieldStatus(i) == "confirm" then
                isConfirm = true
                break
            end
        end

        if isConfirm and not wasConfirming then
            TriggerPop(DISPLAY_DURATION)
        end
        wasConfirming = isConfirm
    end
end)

-- Slash commands for calibration & testing
SLASH_AIKOARENANOTIFIER1 = "/aan"
SLASH_AIKOARENANOTIFIER2 = "/aikonotifier"
SLASH_AIKOARENANOTIFIER3 = "/aikoarena"
SlashCmdList["AIKOARENANOTIFIER"] = function(msg)
    local raw = msg and msg:match("^%s*(.-)%s*$") or ""
    local command = raw:lower()

    if command == "hide" or (frame:IsShown() and raw == "") then
        HideIndicator()
        print(string.format("%s Pixel hidden.", PREFIX))
    elseif command == "help" then
        print(string.format("%s Commands:", PREFIX))
        print("  |cffA330C9/aan|r - Show test pixel for 3 seconds (or toggle off)")
        print("  |cffA330C9/aan <seconds>|r - Show test pixel for custom seconds (e.g. /aan 5)")
        print("  |cffA330C9/aan hide|r - Hide pixel immediately")
    else
        local secs = tonumber(command) or DISPLAY_DURATION
        TriggerPop(secs, true)
    end
end

-- Startup load message matching AikoQoL style
print(string.format("%s Use |cffA330C9/aan|r to test indicator", PREFIX))
