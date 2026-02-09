local addonName = ...
local textFrame = CreateFrame("Frame", "LowHP_TextFrame", UIParent)
local warningText = textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")

local isWarningActive = false 
local ticker = nil 
local previewText = nil 

local defaults = {
    text = "Low HEALTH",
    size = 40,
    soundIndex = 1,
    fontIndex = 1, -- Morpheus is now index 1
    color = { r = 1, g = 0, b = 0, a = 1 }
}

local soundList = {
    { name = "Raid Warning", id = 3081 },
    { name = "Aggro", id = 120 },
    { name = "Legendary", id = 63971 },
    { name = "Ready Check", id = 8960 },
    { name = "Fel Reaver", id = 8593 },
    { name = "Level Up", id = 1269 },
    { name = "Auction", id = 1198 },
    { name = "Quest Done", id = 618 },
    { name = "Boss Whisper", id = 8959 },
    { name = "PVP Flag", id = 8212 },
    { name = "Drum", id = 10006 },
    { name = "Gong", id = 16964 },
    { name = "Bell", id = 16806 },
    { name = "Explosion", id = 3280 },
    { name = "Shotgun", id = 1396 },
    { name = "Sword", id = 3163 },
    { name = "Click", id = 1133 },
    { name = "Ping", id = 3109 },
    { name = "Coin", id = 1204 },
    { name = "Error", id = 1435 },
    { name = "Human Aggro", id = 2776 },
    { name = "Orc Aggro", id = 2686 },
    { name = "Murloc", id = 399 },
    { name = "Illidan", id = 11466 },
    { name = "C'thun", id = 8585 },
    { name = "Executus", id = 8279 },
    { name = "Air Horn", id = 12867 },
    { name = "Alarm", id = 14571 },
    { name = "Cooldown", id = 878 },
    { name = "OOM", id = 250 },
    { name = "Fizzle", id = 918 },
    { name = "Unsheath", id = 669 },
    { name = "Sheath", id = 673 },
    { name = "Invite", id = 1211 },
    { name = "Whisper", id = 3125 },
    { name = "Wrong", id = 12891 },
    { name = "Right", id = 12892 },
    { name = "Escape", id = 851 },
    { name = "Gnome Laugh", id = 5824 },
    { name = "Goblin Laugh", id = 15307 },
    { name = "Hearthstone", id = 1426 },
    { name = "Resurrect", id = 1421 },
    { name = "Bloodlust", id = 8049 },
    { name = "Execute", id = 2862 },
    { name = "Stealth", id = 2963 },
    { name = "Mark", id = 2959 },
    { name = "Shield", id = 2598 },
    { name = "Blink", id = 2548 },
    { name = "Shape", id = 2478 },
    { name = "Aura", id = 2542 },
}

local fontList = {
    { name = "Morpheus (Clean)",        path = "Fonts\\MORPHEUS.TTF",   style = "" },
    { name = "Friz Quadrata",           path = "Fonts\\FRIZQT__.TTF",   style = "OUTLINE" },
    { name = "Arial Narrow",            path = "Fonts\\ARIALN.TTF",     style = "OUTLINE" },
    { name = "Skurri",                  path = "Fonts\\SKURRI.TTF",     style = "OUTLINE" },
    { name = "2002",                    path = "Fonts\\2002.TTF",       style = "OUTLINE" },
    { name = "Damage Font",             path = "Fonts\\K_Damage.TTF",   style = "OUTLINE" },
    { name = "Page Text",               path = "Fonts\\K_Pagetext.TTF", style = "OUTLINE" },
}

textFrame:SetSize(300, 100)
textFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
textFrame:SetFrameStrata("HIGH")

warningText:SetPoint("CENTER", textFrame, "CENTER", 0, 0)
warningText:Hide()

local function ApplyStyle()
    local db = LowHPDB or defaults
    local safeText = (db.text and db.text ~= "") and db.text or defaults.text
    local fontData = fontList[db.fontIndex] or fontList[1]
    
    warningText:SetFont(fontData.path, db.size, fontData.style)
    warningText:SetText(safeText)
    warningText:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)

    if previewText then
        previewText:SetFont(fontData.path, db.size, fontData.style)
        previewText:SetText(safeText)
        previewText:SetTextColor(db.color.r, db.color.g, db.color.b, db.color.a)
    end
end

local function CheckVisuals()
    local defaultFrame = _G["LowHealthFrame"]
    if not defaultFrame then return end

    if defaultFrame:IsShown() then
        if not isWarningActive then
            local db = LowHPDB or defaults
            ApplyStyle()
            warningText:Show()
            local soundData = soundList[db.soundIndex] or soundList[1]
            PlaySound(soundData.id, "Master") 
            isWarningActive = true
        end
    else
        if isWarningActive then
            warningText:Hide()
            isWarningActive = false
        end
    end
end

local function CreateOptions()
    local panel = CreateFrame("Frame", "LowHPOptionsPanel", UIParent)
    panel.name = "LowHP"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("LowHP Settings")

    local previewBg = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    previewBg:SetSize(300, 100)
    previewBg:SetPoint("TOP", panel, "TOP", 0, -50)
    previewBg:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    })
    
    -- Added GameFontNormal here to prevent 'Font not set' error before ApplyStyle runs
    previewText = previewBg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    previewText:SetPoint("CENTER")
    previewText:SetText("Preview")

    local editBoxLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    editBoxLabel:SetPoint("TOPLEFT", 20, -180)
    editBoxLabel:SetText("Message:")

    local editBox = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    editBox:SetSize(200, 30)
    editBox:SetPoint("TOPLEFT", editBoxLabel, "BOTTOMLEFT", 5, -10)
    editBox:SetAutoFocus(false)
    
    editBox:SetScript("OnTextChanged", function(self)
        local val = self:GetText()
        if val then 
            LowHPDB.text = val
            ApplyStyle()
        end
    end)

    local colorBtn = CreateFrame("Button", nil, panel)
    colorBtn:SetSize(30, 30)
    colorBtn:SetPoint("LEFT", editBox, "RIGHT", 10, 0)
    local colorSwatch = colorBtn:CreateTexture(nil, "OVERLAY")
    colorSwatch:SetAllPoints()
    colorSwatch:SetColorTexture(1, 0, 0) 

    colorBtn:SetScript("OnClick", function()
        local r, g, b, a = LowHPDB.color.r, LowHPDB.color.g, LowHPDB.color.b, LowHPDB.color.a
        local function ColorCallback(restore)
            local newR, newG, newB, newA
            if restore then
             newR, newG, newB, newA = unpack(restore)
            else
             newA, newR, newG, newB = ColorPickerFrame:GetColorAlpha(), ColorPickerFrame:GetColorRGB()
            end
            LowHPDB.color = { r = newR, g = newG, b = newB, a = newA }
            colorSwatch:SetColorTexture(newR, newG, newB, newA)
            ApplyStyle()
        end

        if ColorPickerFrame.SetupColorPickerAndShow then
            local info = {
                r = r, g = g, b = b, opacity = a,
                hasOpacity = true,
                swatchFunc = function() ColorCallback() end,
                opacityFunc = function() ColorCallback() end,
                cancelFunc = function() ColorCallback({r, g, b, a}) end,
            }
            ColorPickerFrame:SetupColorPickerAndShow(info)
        else
            ColorPickerFrame:SetColorRGB(r, g, b)
            ColorPickerFrame.hasOpacity = true
            ColorPickerFrame.opacity = a
            ColorPickerFrame.func = function() ColorCallback() end
            ColorPickerFrame.opacityFunc = function() ColorCallback() end
            ColorPickerFrame.cancelFunc = function() ColorCallback({r, g, b, a}) end
            ColorPickerFrame:Show()
        end
    end)

    local slider = CreateFrame("Slider", "LowHPSlider", panel, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", 0, -40)
    slider:SetMinMaxValues(10, 100)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)
    _G[slider:GetName() .. "Low"]:SetText("10")
    _G[slider:GetName() .. "High"]:SetText("100")
    _G[slider:GetName() .. "Text"]:SetText("Text Size")
    slider:SetScript("OnValueChanged", function(self, value)
        LowHPDB.size = math.floor(value)
        ApplyStyle()
    end)

    local soundLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    soundLabel:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -40)
    soundLabel:SetText("Sound:")
    local soundValue = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    soundValue:SetPoint("LEFT", soundLabel, "RIGHT", 10, 0)

    local fontLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fontLabel:SetPoint("LEFT", soundLabel, "LEFT", 250, 0)
    fontLabel:SetText("Font:")
    local fontValue = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fontValue:SetPoint("LEFT", fontLabel, "RIGHT", 10, 0)

    local function UpdateUI()
        local currentText = (LowHPDB.text and LowHPDB.text ~= "") and LowHPDB.text or defaults.text
        editBox:SetText(currentText)
        
        slider:SetValue(LowHPDB.size)
        soundValue:SetText(soundList[LowHPDB.soundIndex].name)
        fontValue:SetText(fontList[LowHPDB.fontIndex].name)
        colorSwatch:SetColorTexture(LowHPDB.color.r, LowHPDB.color.g, LowHPDB.color.b, LowHPDB.color.a)
        ApplyStyle()
    end

    local btnSPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnSPrev:SetSize(30, 25)
    btnSPrev:SetPoint("TOPLEFT", soundLabel, "BOTTOMLEFT", 0, -10)
    btnSPrev:SetText("<")
    btnSPrev:SetScript("OnClick", function()
        LowHPDB.soundIndex = LowHPDB.soundIndex - 1
        if LowHPDB.soundIndex < 1 then LowHPDB.soundIndex = #soundList end
        UpdateUI()
        PlaySound(soundList[LowHPDB.soundIndex].id, "Master")
    end)

    local btnSNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnSNext:SetSize(30, 25)
    btnSNext:SetPoint("LEFT", btnSPrev, "RIGHT", 5, 0)
    btnSNext:SetText(">")
    btnSNext:SetScript("OnClick", function()
        LowHPDB.soundIndex = LowHPDB.soundIndex + 1
        if LowHPDB.soundIndex > #soundList then LowHPDB.soundIndex = 1 end
        UpdateUI()
        PlaySound(soundList[LowHPDB.soundIndex].id, "Master")
    end)

    local btnFPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnFPrev:SetSize(30, 25)
    btnFPrev:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -10)
    btnFPrev:SetText("<")
    btnFPrev:SetScript("OnClick", function()
        LowHPDB.fontIndex = LowHPDB.fontIndex - 1
        if LowHPDB.fontIndex < 1 then LowHPDB.fontIndex = #fontList end
        UpdateUI()
    end)

    local btnFNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnFNext:SetSize(30, 25)
    btnFNext:SetPoint("LEFT", btnFPrev, "RIGHT", 5, 0)
    btnFNext:SetText(">")
    btnFNext:SetScript("OnClick", function()
        LowHPDB.fontIndex = LowHPDB.fontIndex + 1
        if LowHPDB.fontIndex > #fontList then LowHPDB.fontIndex = 1 end
        UpdateUI()
    end)

    local btnTest = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnTest:SetSize(120, 30)
    btnTest:SetPoint("BOTTOMLEFT", 20, 40)
    btnTest:SetText("Test Alert")
    btnTest:SetScript("OnClick", function()
        ApplyStyle()
        warningText:Show()
        PlaySound(soundList[LowHPDB.soundIndex].id, "Master")
        C_Timer.After(3, function() 
             if not isWarningActive then warningText:Hide() end 
        end)
    end)

    local btnReset = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    btnReset:SetSize(120, 30)
    btnReset:SetPoint("LEFT", btnTest, "RIGHT", 20, 0)
    btnReset:SetText("Reset to Default")
    btnReset:SetScript("OnClick", function()
        LowHPDB = {
            text = defaults.text,
            size = defaults.size,
            soundIndex = defaults.soundIndex,
            fontIndex = defaults.fontIndex,
            color = { r=defaults.color.r, g=defaults.color.g, b=defaults.color.b, a=defaults.color.a }
        }
        UpdateUI()
        print("|cff9966ffLowHP:|r Reset to defaults.")
    end)

    panel:SetScript("OnShow", function() UpdateUI() end)
    
    return panel
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        if type(LowHPDB) ~= "table" then LowHPDB = {} end
        
        if not LowHPDB.text or LowHPDB.text == "" then LowHPDB.text = defaults.text end
        if not LowHPDB.size then LowHPDB.size = defaults.size end
        if not LowHPDB.soundIndex then LowHPDB.soundIndex = defaults.soundIndex end
        if not LowHPDB.fontIndex then LowHPDB.fontIndex = defaults.fontIndex end
        if not LowHPDB.color then LowHPDB.color = { r=defaults.color.r, g=defaults.color.g, b=defaults.color.b, a=defaults.color.a } end
        
        ApplyStyle()

        local optionsPanel = CreateOptions()
        if Settings and Settings.RegisterCanvasLayoutCategory then
            local category, layout = Settings.RegisterCanvasLayoutCategory(optionsPanel, "LowHP")
            Settings.RegisterAddOnCategory(category)
        else
            InterfaceOptions_AddCategory(optionsPanel)
        end
        
        print("|cff9966ffLowHP:|r Loaded. Type /lhp.")
        return 
    end

    if event == "PLAYER_ENTERING_WORLD" then
        if not ticker then
            ticker = C_Timer.NewTicker(0.2, CheckVisuals)
        end
    end
end)

SLASH_LOWHP1 = "/lhp"
SlashCmdList["LOWHP"] = function(msg)
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory("LowHP")
    else
        InterfaceOptionsFrame_OpenToCategory("LowHP")
    end
end
