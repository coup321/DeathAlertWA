function()
    if aura_env.state.sourceName then
        
        local timeDelta = aura_env.state.timeDelta
        local abilityName = aura_env.state.abilityName
        local sourceName = aura_env.state.sourceName
        local amount = aura_env.state.amount

        local maxLength = 22

        if #abilityName > maxLength then
            abilityName = string.sub(abilityName, 0, maxLength)
        end

        if #abilityName + #sourceName > maxLength then
            sourceName = string.sub(sourceName, 0, maxLength - #abilityName)
        end

        local colorizedSourceName = "|cFF867792" .. sourceName .. "|r"

        local secondString = abilityName .. " (" .. colorizedSourceName ..")"
        return timeDelta, secondString , amount
    end
        
end