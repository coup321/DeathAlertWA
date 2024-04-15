function(a, b)
    if a.region.state.sortIndex and b.region.state.sortIndex then
        return a.region.state.sortIndex <= b.region.state.sortIndex
    end
    return false
end