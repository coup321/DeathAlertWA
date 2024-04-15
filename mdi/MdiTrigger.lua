function(allstates, ...)
    local _, unitId, abilityName, amount, sourceName, icon, sortIndex = ...
    if unitId then
        allstates[unitId .. sortIndex] = {
                show = true,
                changed = true,
                autoHide = true,
                duration = 5,
                expirationTime = GetTime() + 5,
                icon = icon,
                amount = amount,
                unitId = unitId,
                abilityName = abilityName,
                sourceName = sourceName,
                sortIndex = sortIndex
            }
        return true
    end
end