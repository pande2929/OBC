-- spellcheck.lua

local ns = NextUp

-- Check if the target is both in range and the spell is ready.
local ticket = C_Timer.NewTicker(0.1, function()
    local spellID = ns.recSpellID

    if not spellID then
        spellID = 0
    end

    -- Spell ready?
    local isReady = ns:IsSpellReady(spellID)
    ns:ApplyDimEffect(not isReady)

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