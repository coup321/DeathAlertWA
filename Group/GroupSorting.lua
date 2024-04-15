function(a, b)
    -- id -> MDI
    -- cloneid
    -- data table
    -- active
    -- dataIndex
    -- controlPoint
    -- parent
    -- dimensions 

    for k,v in pairs(a.region) do
        print("Region data: ", k, v)
    end
    return a.dataIndex <= b.dataIndex
end