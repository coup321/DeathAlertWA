function(a, b)
    -- guarentees that MDI comes before MDI2 for the grow function
    if a.region.id == "MDI2" and b.region.id == "MDI" then
        return true
    end

    local a = a.region.state.sortIndex
    local b = b.region.state.sortIndex


    if  a and b then
        return a <= b
    end

    return false
end