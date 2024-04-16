function()
    -- unitId, abilityName, amount, sourceName
    if aura_env.state.sourceName then 
        local name = WA_ClassColorName(aura_env.state.unitId)
        return name .. " died to" 
    end 
end
