function(newPositions, activeRegions)
    local config
    for i, env in pairs(aura_env.child_envs) do
        if env.id == "Bars" then
            config = env.config
        end
    end
    local mdiP1Width = 0

    for _, regionData in pairs(activeRegions) do
        local id = regionData.id
        if id == "MDI" then
            mdiP1Width = regionData.dimensions.width
            break
        end

    end
    local mdiIndex = nil
    for i, regionData in ipairs(activeRegions) do
        if i > config.maxNumberOfRows then
            break
        end


        local width = regionData.dimensions.width / 2
        local id = regionData.id

        if id == "MDI2" then
            width = width + mdiP1Width
        end

        if mdiIndex == nil and (id == "MDI2" or id == "MDI") then
            mdiIndex = i + 1
        end

        if id == "MDI" or id == "MDI2" then
            newPositions[i] = {width, -1*mdiIndex*25, true}
        else
            newPositions[i] = {width, -1*i*25, true}
        end
    end
end