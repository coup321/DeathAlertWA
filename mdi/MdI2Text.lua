function()
    -- unitId, abilityName, amount, sourceName
    if aura_env.state.sourceName then 
        local abilityName = aura_env.state.abilityName
        local amount = aura_env.state.amount
        local sourceName = aura_env.state.sourceName
        local coloredAbilityName = "|cFF00FF00" .. abilityName .. "|r"
        local coloredAmount = "|cFF00FF00" .. amount .. "|r"
        local overkill = aura_env.state.overkill
        
        return coloredAbilityName .. " from " .. sourceName .. " for " .. coloredAmount .. " (" .. overkill .. " overkill)"

    end 
end
