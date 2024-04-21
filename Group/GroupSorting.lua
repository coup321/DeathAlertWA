function(a, b)
    local a = a.region.state.sortIndex
    local b = b.region.state.sortIndex


    if  a and b then
        return a <= b
    end

    return false
end