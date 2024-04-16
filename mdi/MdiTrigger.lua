function(allstates, ...)
    local _, unitId, abilityName, amount, sourceName, icon, sortIndex, overkill, visibilityDuration = ...
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
                overkill = overkill
            }
        return true
    end
end