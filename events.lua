-- events.lua

local ns = NextUp
local lastCastSpell = 0

------------------------------------------------------------
-- Function: When assisted highlight spell changes.
------------------------------------------------------------
local function OnSpellChange()
    -- Get highlighted button and then duplicate the texture
    local button = ns:GetHighlightedButton()

    if button then
        ns.recSpellID = ns:GetSpellIDFromButton(button)
        local keybind = ns:GetKeybinds(button)
        local tex = button.icon:GetTexture()
        
        ns:UpdateHighlightFrame(tex, keybind)
    end
end

------------------------------------------------------------
-- Function: When player leaves combat.
------------------------------------------------------------
local function OnLeaveCombat()
    if event == "PLAYER_REGEN_ENABLED" then
        if ns.dirtyUI then
            ns:RefreshUI()
        end
    end
end

------------------------------------------------------------
-- Function: Registers events.
------------------------------------------------------------
function ns:RegisterEvents()
    -- Track combat state.
    local c = CreateFrame("Frame")
    c:RegisterEvent("PLAYER_REGEN_ENABLED")
    c:SetScript("OnEvent", OnLeaveCombat)

	-- Track when assisted highlight button changes.
	EventRegistry:RegisterCallback("AssistedCombatManager.OnAssistedHighlightSpellChange", OnSpellChange)

    -- Track whenever player uses an ability.
    hooksecurefunc("UseAction", function(slot, checkCursor, onSelf)
        local actionType, id = GetActionInfo(slot)

        if id then
            lastCastSpell = id
        end
    end)

	-- Create listeners for spell activation events
	--[[
	local s = CreateFrame("Frame")
	s:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
	s:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")

	s:SetScript("OnEvent", function(self, event, spellID)
		if event == "SPELL_ACTIVATION_OVERLAY_GLOW_SHOW" and suggestedSpell == spellID then
			ActionButton_ShowOverlayGlow(highlightFrame)
		elseif event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" and suggestedSpell == spellID  then
			--hide glowing overlay
			ActionButton_HideOverlayGlow(highlightFrame)
		end
	end)
	]]

	-- Create listeners for casting events.
	local f = CreateFrame("Frame")
	f:RegisterEvent("UNIT_SPELLCAST_START")
	f:RegisterEvent("UNIT_SPELLCAST_STOP")
	f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	f:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	f:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
    f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
    f:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")

    -- When should the cooldown animation display?
    -- Ability or macro used. Automatic casts or abilities should not show the animation.

	f:SetScript("OnEvent", function(_, event, unit, _, spellID)
		if unit ~= "player" then
			return
		end

		local startTime = GetTime()

		-- Show the cooldown animation with duration of spell, otherwise use GCD for instant casts.
		if event == "UNIT_SPELLCAST_START" then
			local spInfo = C_Spell.GetSpellInfo(spellID)
			ns:ShowCooldownAnimation(startTime, spInfo.castTime / 1000.0)
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			local _, _, _, startTimeMS, endTimeMS = UnitChannelInfo("player")
			-- Check for empowered and channeled casts. Otherwise proceed.
			if startTimeMS == nil and endTimeMS == nill and lastCastSpell == spellID then
				-- Nope, just a regular instant cast
				local cdInfo = C_Spell.GetSpellCooldown(61304)
				ns:ShowCooldownAnimation(startTime, cdInfo.duration)
			end
        elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
			local _, _, _, startTimeMS, endTimeMS = UnitChannelInfo("player")

            if startTimeMS and endTimeMS then
			    ns:ShowCooldownAnimation(startTime, (endTimeMS - startTimeMS) / 1000.0)
		    end
		elseif
			event == "UNIT_SPELLCAST_INTERRUPTED" or 
            event == "UNIT_SPELLCAST_CHANNEL_STOP" or 
            event == "UNIT_SPELLCAST_STOP" or
            event == "UNIT_SPELLCAST_EMPOWER_STOP" then
			ns:ShowCooldownAnimation(0, 0)
			ns.currentSpell = 0
        end
	end)
end

------------------------------------------------------------
-- Function: Fires when a setting is changed.
------------------------------------------------------------
function ns:OnSettingChanged(setting, value)
    -- flag the UI as dirty
    ns.dirtyUI = true

    -- Don't make changes in combat to avoid taint        
    if not InCombatLockdown() then
	    -- Update the UI
        ns:RefreshUI()
    else
        print("Setting change will be deferred until out of combat.")
    end
end

------------------------------------------------------------
-- Event handler for addon initialization.
------------------------------------------------------------
local login = CreateFrame("Frame")
login:RegisterEvent("PLAYER_LOGIN")

login:SetScript("OnEvent", function(_, event, arg1)
	if event == "PLAYER_LOGIN" then
		-- Load or initialize database
		NextUp_SavedVariables = NextUp_SavedVariables or {}
		if not NextUp_SavedVariables.settings then
			NextUp_SavedVariables.settings = {
				fontSize = 35,
				offsetX = 0,
				offsetY = -180,
				sizeX = 62,
				sizeY = 62,
				buttonScale = 1.0,
				point = "CENTER",
				textPoint = "CENTER",
				textOffsetX = 0,
				textOffsetY = 0,
                hideActionBar1 = false,
                hideActionBar2 = false,
                hideActionBar3 = false
			}
		end

		print(ns.name .. " settings initialized.")

		-- Check if Assisted Hightlight is active. If it isn't, then ask the user if they want to enable it.
		if GetCVarBool("assistedCombatHighlight") then
			ns:OnInitialize()
		else
			--print("Blizzard's Assisted Highlight feature is not enabled. Please enable and reload.")
			StaticPopupDialogs["NEXTUP_ADDON_CONFIRM"] = {
				text = "Blizzard's Assisted Highlight feature is not enabled, which the NextUp addon requires. Do you wish to enable it?",
				button1 = "Yes",
				button2 = "No",
				OnAccept = function(self)
					SetCVar("assistedCombatHighlight", true)
					ns:OnInitialize()
				end,
				OnCancel = function(self) end,
				timeout = 0, -- stay open until user clicks
				whileDead = true, -- show even if the player is dead
				hideOnEscape = true, -- pressing ESC closes it
				preferredIndex = 3, -- avoid frame conflicts
			}

			-- Show the popup:
			StaticPopup_Show("NEXTUP_ADDON_CONFIRM")
		end
	end
end)
