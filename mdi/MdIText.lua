function()
    -- unitId, abilityName, amount, sourceName
    if aura_env.state.sourceName and aura_env.state.icon then 
        local abilityName = aura_env.state.abilityName
        local name = WA_ClassColorName(aura_env.state.unitId)
        local amount = aura_env.state.amount
        local sourceName = aura_env.state.sourceName
        local overkill = aura_env.state.overkill
        local damageColorString = aura_env.state.damageColorString
        local coloredAbilityName = "|cFF" .. damageColorString .. abilityName .. "|r"
        local coloredAmount = "|cFF".. damageColorString .. amount .. "|r"
        local icon = tostring(aura_env.state.icon)
        
        return name .. " died to " .. "|T" .. icon .. ":16|t " .. coloredAbilityName .. " from " .. sourceName .. " for " .. coloredAmount .. overkill
    else
        return "DEATH SUMMARY"
    end 
end