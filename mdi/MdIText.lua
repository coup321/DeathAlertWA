function()
    if aura_env.state.sourceName then 
        local name = WA_ClassColorName(aura_env.state.unitId)
        local abilityName = aura_env.state.abilityName
        local amount = aura_env.state.amount
        local sourceName = aura_env.state.sourceName
        local coloredAbilityName = "|cFF00FF00" .. abilityName .. "|r"
        local coloredAmount = "|cFF00FF00" .. amount .. "|r"
        
        return name .. " died to" , coloredAbilityName .. " from " .. sourceName .. " for " .. coloredAmount

    end 
end
