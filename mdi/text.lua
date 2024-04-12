function()
    local name = WA_ClassColorName(aura_env.state.unit)
    local abilityName = aura_env.state.abilityName
    local amount = aura_env.state.amount
    
    return name, abilityName, amount
end