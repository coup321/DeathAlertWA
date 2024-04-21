function(a, b)
    -- guarentees that MDI comes before MDI2 for the grow function

    local mdiCondition =  a.region.id == "MDI2_separate" and b.region.id == "MDI_separate"
    local sortIndexCondition = a.region.state.sortIndex == b.region.state.sortIndex
    if mdiCondition and sortIndexCondition then
        return false
    end

    local a = a.region.state.sortIndex
    local b = b.region.state.sortIndex


    if  a and b then
        return a <= b
    end

    return false
end