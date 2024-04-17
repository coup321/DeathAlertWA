function()
    -- unitId, abilityName, amount, sourceName
    if aura_env.state.sourceName then 
        local abilityName = aura_env.state.abilityName
        local amount = aura_env.state.amount
        local sourceName = aura_env.state.sourceName
        local overkill = aura_env.state.overkill
        local damageColorString = aura_env.state.damageColorString
        local coloredAbilityName = "|cFF" .. damageColorString .. abilityName .. "|r"
        local coloredAmount = "|cFF".. damageColorString .. amount .. "|r"
        return coloredAbilityName .. " from " .. sourceName .. " for " .. coloredAmount .. " (" .. overkill .. " overkill)"

    end 
end
