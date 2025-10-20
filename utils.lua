-- utils.lua

local ns = NextUp

local actionBarPrefixes = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarRightButton",
	"MultiBarLeftButton",
	"MultiBar5Button",
	"MultiBar6Button",
	"MultiBar7Button",
	"StanceButton"
}

local actionBarPrefixMatrix = {
	["ActionButton"] = "ACTIONBUTTON",
	["MultiBarBottomLeftButton"] = "MULTIACTIONBAR1BUTTON",
	["MultiBarBottomRightButton"] = "MULTIACTIONBAR2BUTTON",
	["MultiBarRightButton"] = "MULTIACTIONBAR3BUTTON",
	["MultiBarLeftButton"] = "MULTIACTIONBAR4BUTTON",
	["MultiBar5Button"] = "MULTIACTIONBAR5BUTTON",
	["MultiBar6Button"] = "MULTIACTIONBAR6BUTTON",
	["MultiBar7Button"] = "MULTIACTIONBAR7BUTTON",
}

------------------------------------------------------------
-- Function: Get the currently highlighted button
------------------------------------------------------------
function ns:GetHighlightedButton()
	local highlightedButton = nil

	for _, barPrefix in pairs(actionBarPrefixes) do
		for i = 1, 12 do
			local button = _G[barPrefix .. i]

			if button and button:IsVisible() then --don't look at non-visible bars
				if AssistedCombatManager:IsRecommendedAssistedHighlightButton(button) then
					highlightedButton = button
					break
				end
			end
		end
	end

	return highlightedButton
end

------------------------------------------------------------
-- Function: Get the currently recommended spell.
------------------------------------------------------------
function ns:GetHighlightedSpell()
	local button = ns:GetHighlightedButton()
	return ns:GetSpellIDFromButton(button)
end

------------------------------------------------------------
-- Function: Gets action bar button name from a button.
------------------------------------------------------------
local function GetActionBarButtonName(button)
	local prefix, num = button:GetName():match("^(.-)(%d+)$")
	return actionBarPrefixMatrix[prefix] .. num
end

------------------------------------------------------------
-- Function: Returns the keybinds for a given action button.
------------------------------------------------------------
function ns:GetKeybinds(button)
	if not button or not button.action then
		return nil
	end
	
	local binding = ""
	local name = GetActionBarButtonName(button)
	local keys = { GetBindingKey(name) }

	if #keys > 0 then
		binding = keys[1] --default to first binding
	end

	binding = binding:upper():gsub("SHIFT", "S")

	return binding
end

------------------------------------------------------------
-- Function: Gets a spellID from a button.
------------------------------------------------------------
function ns:GetSpellIDFromButton(button)
    --if not button or not button.action then return nil end
	if not button then
		return nil
	end

	spellID = nil

	if button.action then
		local actionType, id, subType = GetActionInfo(button.action)

		if actionType == "spell" then
			spellID = id
		elseif actionType == "macro" and subType == "spell" then
			-- macros can cast spells, so check the macro body
			--local macroSpell = GetMacroSpell(id)
			--return macroSpell
			spellID = id
		end
	else
		_, _, _, stanceSpellID = GetShapeshiftFormInfo(button:GetID())
		--local spInfo = C_Spell.GetSpellInfo(stanceSpellID)
		--print(spInfo.name)
		spellID = stanceSpellID
	end

    return spellID
end

------------------------------------------------------------
-- Function: Checks if spell is ready or not.
------------------------------------------------------------
function ns:IsSpellReady(spellID)
    local isUsable, insufficientPower = C_Spell.IsSpellUsable(spellID)

    if not isUsable or insufficientPower then
        return false
    end

    local cdInfo = C_Spell.GetSpellCooldown(spellID)
    if cdInfo.startTime == 0 then
        return true
    end

    -- Still on cooldown
    return false
end

------------------------------------------------------------
-- Function: Checks if the spell matches suggested spell.
------------------------------------------------------------
function ns:IsRecommendedSpell(spellID)
	return ns.recSpellID == spellID
end