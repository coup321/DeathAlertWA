function(allstates, ...)
    local _, unitId, abilityName, amount, sourceName, icon, sortIndex, overkill, visibilityDuration, damageColorString = ...
    if unitId then
        allstates[unitId .. sortIndex] = {
                show = true,
                changed = true,
                autoHide = true,
                duration = visibilityDuration,
                expirationTime = GetTime() + visibilityDuration,
                icon = icon,
                amount = amount,
                unitId = unitId,
                abilityName = abilityName,
                sourceName = sourceName,
                sortIndex = sortIndex,
                overkill = overkill,
                damageColorString = damageColorString
            }
        return true
    end
end