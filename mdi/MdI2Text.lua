function()
    -- unitId, abilityName, amount, sourceName
    if aura_env.state.sourceName then 
        local abilityName = aura_env.state.abilityName
        local amount = aura_env.state.amount
        local sourceName = aura_env.state.sourceName
        local damageColorString = aura_env.damageColorString
        local coloredAbilityName = damageColorString .. abilityName .. "|r"
        local coloredAmount = damageColorString .. amount .. "|r"
        local overkill = aura_env.state.overkill
        
        return coloredAbilityName .. " from " .. sourceName .. " for " .. coloredAmount .. " (" .. overkill .. " overkill)"

    end 
end
