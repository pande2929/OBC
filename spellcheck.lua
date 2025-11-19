-- spellcheck.lua

local ns = NextUp

-- Periodically update the main frame with effects.
-- TODO: Move spell ready check into ACTIONBAR_UPDATE_USABLE
local effectTicker = C_Timer.NewTicker(0.15, function()
    local spellID = ns.recSpellID

    if not spellID then
        ns:ApplyDimEffect(false)
        ns:ApplyRedShift(false)
        return
    end

    -- Target in range?
    local inRange = true
    if UnitExists("target") and UnitCanAttack("player", "target") and 
        not UnitIsDead("target") and not UnitIsDeadOrGhost("target") then
        inRange = C_Spell.IsSpellInRange(spellID, "target")
    end

    -- Apply the red shift
    if inRange ~= nil then
        ns:ApplyRedShift(not inRange)
    else
        ns:ApplyRedShift(false)
    end
end)

-- Check if ns.recSpellID is currently selected, if not then update it.
-- This is sort of a failsafe for uncommon situations.
local verifyTicker = C_Timer.NewTicker(1, function()
    local button = ns:GetHighlightedButton()
	
    if button then -- this will be nil if nothing is highlighted
        local spellID = ns:GetSpellIDFromButton(button)

        if spellID and spellID ~= ns.recSpellID then
            ns.recSpellID = spellID
            ns:UpdateHighlightFrame(button)
        end
    else
        ns.recSpellID = nil
        ns:UpdateHighlightFrame(nil)
    end
end)