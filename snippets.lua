 -- add to trigger to print all the 
 local function printEvents(...)
    local args = {...}  -- Put all variable arguments into a table
    for i = 1, select('#', ...) do
        args[i] = '"' .. tostring(args[i]) .. '"'  -- Convert each argument to a string
    end

    local argsString = table.concat(args, " ")  -- Concatenate all elements with a comma and space as separator
    print(argsString)
end
printEvents(...)


CLEU:UNIT_DIED:SPELL_DAMAGE:SWING_DAMAGE:RANGE_DAMAGE:SPELL_PERIODIC_DAMAGE:SPELL_BUILDING_DAMAGE:ENVIRONMENTAL_DAMAGE:SPELL_HEAL:SPELL_PERIODIC_HEAL, UNIT_HEALTH:player:party:raid:group:arena, PLAYER_ENTERING_WORLD, GROUP_ROSTER_UPDATE
