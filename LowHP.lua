-- LowHP.lua
-- https://github.com/ticstyle/WoW-LowHP

-- luacheck: globals CreateFrame UIParent LowHPDB StopSound PlaySound PlaySoundFile
-- luacheck: globals C_Timer ColorPickerFrame Settings InterfaceOptions_AddCategory

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
	fontIndex = 1,
	color = { r = 1, g = 0, b = 0, a = 1 },
}

local soundList = {
	{ name = "[1] You seek death", id = "Interface\\AddOns\\LowHP\\media\\rivendareaggro01.ogg" },
	{ name = "[2] Sheathshield", id = "Interface\\AddOns\\LowHP\\media\\sheathshield.ogg" },
	{ name = "[3] Creature Fidget 1", id = "Interface\\AddOns\\LowHP\\media\\8061616_fidget_8343178.ogg" },
	{ name = "[4] Creature Fidget 2", id = "Interface\\AddOns\\LowHP\\media\\8061616_fidget_8343188.ogg" },
	{
		name = "[5] Goblin Welder",
		id = "Interface\\AddOns\\LowHP\\media\\go_11go_goblin_fakebanana02_loop_6381616.ogg",
	},
	{ name = "[6] Coins", id = 120 },
	{ name = "[7] Legendary", id = 63971 },
	{ name = "[8] Ready Check", id = 8960 },
	{ name = "[9] Fel Reaver", id = 8593 },
	{ name = "[10] Splash", id = 1269 },
	{ name = "[11] Quest Done", id = 618 },
	{ name = "[12] Boss Whisper", id = 8959 },
	{ name = "[13] PVP Flag", id = 8212 },
	{ name = "[14] Monster ghasp", id = 1396 },
	{ name = "[15] Cage", id = "Interface\\AddOns\\LowHP\\media\\go_twilightshammercage_close_04.ogg" },
	{ name = "[16] Coin", id = 1204 },
	{ name = "[17] Magic", id = 1435 },
	{ name = "[18] Human Help Me", id = 2776 },
	{ name = "[19] Murloc", id = 399 },
	{ name = "[20] Door Runes", id = "Interface\\AddOns\\LowHP\\media\\ahn_qiraj_doorrunesopen.ogg" },
	{ name = "[21] Executus", id = 8279 },
	{ name = "[22] Air Horn", id = 12867 },
	{ name = "[23] Cooldown", id = 878 },
	{ name = "[24] Fizzle", id = 918 },
	{ name = "[25] Undead Drake Death", id = "Interface\\AddOns\\LowHP\\media\\undeaddrakedeath.ogg" },
	{ name = "[26] Myst Lightning", id = "Interface\\AddOns\\LowHP\\media\\silvermystlightningbolt01var2.ogg" },
	{ name = "[27] Cata Dragon", id = "Interface\\AddOns\\LowHP\\media\\gs_cata_sfx_kit3_05.ogg" },
	{ name = "[28] Me feast on you all", id = 5824 },
	{ name = "[29] Come forth my servants", id = 8049 },
	{ name = "[30] Help Me/Assist Me", id = 2862 },
	{ name = "[31] Huh, aah", id = 2959 },
	{ name = "[32] Fel Weaver Death", id = "Interface\\AddOns\\LowHP\\media\\vo_70_fel_weaver_death_04.ogg" },
	{ name = "[33] Arator", id = "Interface\\AddOns\\LowHP\\media\\vo_1217_arator_8347261.ogg" },
	{
		name = "[34] Snow Bear Mount",
		id = "Interface\\AddOns\\LowHP\\media\\dwarfbearsnowmount_cast_oneshot_8300922.ogg",
	},
	{
		name = "[35] Kithix Wound",
		id = "Interface\\AddOns\\LowHP\\media\\sound_creature_kithix_kithix_wound_8281484.ogg",
	},
	{ name = "[36] Major Glyph Destroy", id = "Interface\\AddOns\\LowHP\\media\\glyph_majordestroy.ogg" },
	{ name = "[37] Hardcore Duel", id = "Interface\\AddOns\\LowHP\\media\\1.14.4_ui_classic_hardcore_duel_stereo.ogg" },
	{
		name = "[38] Hardcore Death",
		id = "Interface\\AddOns\\LowHP\\media\\1.14.4_ui_classic_hardcore_death_stereo.ogg",
	},
	{ name = "[39] Death Will Not Stop Me", id = "Interface\\AddOns\\LowHP\\media\\rivendaredeath.ogg" },
	{ name = "[40] Blowdart", id = "Interface\\AddOns\\LowHP\\media\\go_11go_goblin_machine07_oneshot_6256194.ogg" },
}

local fontList = {
	{ name = "[1] Morpheus (Clean)", path = "Fonts\\MORPHEUS.TTF", style = "" },
	{ name = "[2] Friz Quadrata", path = "Fonts\\FRIZQT__.TTF", style = "OUTLINE" },
	{ name = "[3] Arial Narrow", path = "Fonts\\ARIALN.TTF", style = "OUTLINE" },
	{ name = "[4] Skurri", path = "Fonts\\SKURRI.TTF", style = "OUTLINE" },
	{ name = "[5] 2002", path = "Fonts\\2002.TTF", style = "OUTLINE" },
	{ name = "[6] Damage Font", path = "Fonts\\K_Damage.TTF", style = "OUTLINE" },
	{ name = "[7] Page Text", path = "Fonts\\K_Pagetext.TTF", style = "OUTLINE" },
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

-- --- CUSTOM SOUND HANDLER ---
local activeSoundHandle = nil

local function PlayAlertSound(soundId)
	-- Stop any currently playing alert sound to prevent overlapping spam
	if activeSoundHandle then
		StopSound(activeSoundHandle, 500)
	end

	local willPlay, handle
	if type(soundId) == "string" then
		-- Custom sound file path bundled with the addon
		willPlay, handle = PlaySoundFile(soundId, "Master")
	else
		-- Try SoundKitID first, then fall back to FileDataID
		willPlay, handle = PlaySound(soundId, "Master")
		if not willPlay then
			willPlay, handle = PlaySoundFile(soundId, "Master")
		end
	end

	if willPlay and handle then
		activeSoundHandle = handle

		-- Start a 3-second timer
		C_Timer.After(3, function()
			if activeSoundHandle == handle then
				StopSound(handle, 1000)
				activeSoundHandle = nil
			end
		end)
	end
end

local function CheckVisuals()
	local defaultFrame = _G["LowHealthFrame"]
	if not defaultFrame then
		return
	end

	if defaultFrame:IsShown() then
		if not isWarningActive then
			local db = LowHPDB or defaults
			ApplyStyle()
			warningText:Show()
			local soundData = soundList[db.soundIndex] or soundList[1]
			PlayAlertSound(soundData.id)
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
		tile = true,
		tileSize = 32,
		edgeSize = 16,
		insets = { left = 5, right = 5, top = 5, bottom = 5 },
	})

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
				r = r,
				g = g,
				b = b,
				opacity = a,
				hasOpacity = true,
				swatchFunc = function()
					ColorCallback()
				end,
				opacityFunc = function()
					ColorCallback()
				end,
				cancelFunc = function()
					ColorCallback({ r, g, b, a })
				end,
			}
			ColorPickerFrame:SetupColorPickerAndShow(info)
		else
			ColorPickerFrame:SetColorRGB(r, g, b)
			ColorPickerFrame.hasOpacity = true
			ColorPickerFrame.opacity = a
			ColorPickerFrame.func = function()
				ColorCallback()
			end
			ColorPickerFrame.opacityFunc = function()
				ColorCallback()
			end
			ColorPickerFrame.cancelFunc = function()
				ColorCallback({ r, g, b, a })
			end
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
	slider:SetScript("OnValueChanged", function(_, value)
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
		if LowHPDB.soundIndex < 1 then
			LowHPDB.soundIndex = #soundList
		end
		UpdateUI()
		PlayAlertSound(soundList[LowHPDB.soundIndex].id)
	end)

	local btnSNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnSNext:SetSize(30, 25)
	btnSNext:SetPoint("LEFT", btnSPrev, "RIGHT", 5, 0)
	btnSNext:SetText(">")
	btnSNext:SetScript("OnClick", function()
		LowHPDB.soundIndex = LowHPDB.soundIndex + 1
		if LowHPDB.soundIndex > #soundList then
			LowHPDB.soundIndex = 1
		end
		UpdateUI()
		PlayAlertSound(soundList[LowHPDB.soundIndex].id)
	end)

	local btnFPrev = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnFPrev:SetSize(30, 25)
	btnFPrev:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -10)
	btnFPrev:SetText("<")
	btnFPrev:SetScript("OnClick", function()
		LowHPDB.fontIndex = LowHPDB.fontIndex - 1
		if LowHPDB.fontIndex < 1 then
			LowHPDB.fontIndex = #fontList
		end
		UpdateUI()
	end)

	local btnFNext = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnFNext:SetSize(30, 25)
	btnFNext:SetPoint("LEFT", btnFPrev, "RIGHT", 5, 0)
	btnFNext:SetText(">")
	btnFNext:SetScript("OnClick", function()
		LowHPDB.fontIndex = LowHPDB.fontIndex + 1
		if LowHPDB.fontIndex > #fontList then
			LowHPDB.fontIndex = 1
		end
		UpdateUI()
	end)

	local btnTest = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	btnTest:SetSize(120, 30)
	btnTest:SetPoint("BOTTOMLEFT", 20, 40)
	btnTest:SetText("Test Alert")
	btnTest:SetScript("OnClick", function()
		ApplyStyle()
		warningText:Show()
		PlayAlertSound(soundList[LowHPDB.soundIndex].id)
		C_Timer.After(3, function()
			if not isWarningActive then
				warningText:Hide()
			end
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
			color = { r = defaults.color.r, g = defaults.color.g, b = defaults.color.b, a = defaults.color.a },
		}
		UpdateUI()
		print("|cff9966ffLowHP:|r Reset to defaults.")
	end)

	panel:SetScript("OnShow", function()
		UpdateUI()
	end)

	return panel
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then
		if type(LowHPDB) ~= "table" then
			LowHPDB = {}
		end

		if not LowHPDB.text or LowHPDB.text == "" then
			LowHPDB.text = defaults.text
		end
		if not LowHPDB.size then
			LowHPDB.size = defaults.size
		end
		if not LowHPDB.soundIndex then
			LowHPDB.soundIndex = defaults.soundIndex
		end
		if not LowHPDB.fontIndex then
			LowHPDB.fontIndex = defaults.fontIndex
		end
		if not LowHPDB.color then
			LowHPDB.color = { r = defaults.color.r, g = defaults.color.g, b = defaults.color.b, a = defaults.color.a }
		end

		ApplyStyle()

		local optionsPanel = CreateOptions()
		if Settings and Settings.RegisterCanvasLayoutCategory then
			local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "LowHP")
			Settings.RegisterAddOnCategory(category)
		else
			InterfaceOptions_AddCategory(optionsPanel)
		end

		print("|cff9966ffLowHP:|r Loaded. Options: Esc -> Options -> AddOns -> LowHP")
		return
	end

	if event == "PLAYER_ENTERING_WORLD" then
		if not ticker then
			ticker = C_Timer.NewTicker(0.2, CheckVisuals)
		end
	end
end)
