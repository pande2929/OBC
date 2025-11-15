-- spellcheck.lua

local ns = NextUp

-- Periodically update the main frame with effects.
local effectTicker = C_Timer.NewTicker(0.1, function()
    local spellID = ns.recSpellID

    if not spellID then
        return
    end

    -- Spell ready?
    --local isReady = ns:IsSpellReady(spellID)
    isReady = true

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

    -- Apply dim overlay
    -- spell is not ready
    -- is out of range

    if isReady == false then
        ns:ApplyDimEffect(true)
    elseif inRange == false then
        ns:ApplyDimEffect(true)
    else
        ns:ApplyDimEffect(false)
    end
end)

local verifyTicker = C_Timer.NewTicker(1, function()
    local button = ns:GetHighlightedButton()
	local spellID = ns:GetSpellIDFromButton(button)

    -- Check if ns.recSpellID is currently selected, if not then update it.
    
    if spellID and spellID ~= ns.recSpellID then
        ns.recSpellID = spellID
        ns:UpdateHighlightFrame(button)
    end
end)