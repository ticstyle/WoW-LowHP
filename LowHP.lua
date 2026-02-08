-- --- SETUP ---
local addonName = ...
local textFrame = CreateFrame("Frame", "LowHP_TextFrame", UIParent)
local warningText = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")

-- State variables
local isWarningActive = false 
local ticker = nil 
local defaultText = "Low HEALTH"

-- --- DESIGN ---
textFrame:SetSize(300, 100)
textFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
textFrame:SetFrameStrata("HIGH")

warningText:SetPoint("CENTER", textFrame, "CENTER", 0, 0)
warningText:SetTextColor(1, 0, 0, 1) -- Red color
warningText:SetFont("Fonts\\FRIZQT__.TTF", 40, "OUTLINE") 
warningText:Hide()

-- --- LOGIC ---
local function CheckVisuals()
    -- Check if the default Blizzard red border frame is visible
    local defaultFrame = _G["LowHealthFrame"]
    
    if not defaultFrame then return end

    if defaultFrame:IsShown() then
        if not isWarningActive then
            -- Get custom text from DB or use default
            local displayText = (type(LowHPDB) == "table" and LowHPDB.text) or defaultText
            warningText:SetText(displayText)

            warningText:Show()
            PlaySound(3081, "Master") 
            isWarningActive = true
        end
    else
        if isWarningActive then
            warningText:Hide()
            isWarningActive = false
        end
    end
end

-- --- EVENTS ---
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Initialize SavedVariables table if it doesn't exist or is invalid
        if type(LowHPDB) ~= "table" then
            LowHPDB = { text = defaultText }
        end
        print("|cff9966ffLowHP:|r Loaded.")
        return 
    end

    if event == "PLAYER_ENTERING_WORLD" then
        if not ticker then
            -- Check status 5 times per second (0.2s)
            ticker = C_Timer.NewTicker(0.2, CheckVisuals)
        end
    end
end)

-- --- SLASH COMMANDS ---
SLASH_LOWHP1 = "/lhp"
SlashCmdList["LOWHP"] = function(msg)
    -- Split command into action and argument (e.g. "set" and "my custom text")
    local cmd, arg = strsplit(" ", msg, 2)
    cmd = cmd and cmd:lower() or ""

    if cmd == "test" then
        local displayText = (type(LowHPDB) == "table" and LowHPDB.text) or defaultText
        warningText:SetText(displayText)
        warningText:Show()
        PlaySound(3081, "Master")
        print("|cff9966ffLowHP:|r Testing: " .. displayText)
        
        -- Auto-hide after 3 seconds during test
        C_Timer.After(3, function() 
            if not isWarningActive then warningText:Hide() end 
        end)

    elseif cmd == "set" and arg then
        -- Save the new text
        if type(LowHPDB) ~= "table" then LowHPDB = {} end
        LowHPDB.text = arg
        print("|cff9966ffLowHP:|r Text updated to: " .. arg)

    elseif cmd == "reset" then
        -- Reset to default
        LowHPDB = { text = defaultText }
        print("|cff9966ffLowHP:|r Text reset to default.")

    else
        print("|cff9966ffLowHP:|r Commands:")
        print("  /lhp set YOUR TEXT HERE")
        print("  /lhp reset")
        print("  /lhp test")
    end
end
