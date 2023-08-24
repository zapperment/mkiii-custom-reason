local function getValueFromPath(tbl, path)
    local current = tbl
    for token in string.gmatch(path, "([^%.]+)") do
        if current[token] then
            current = current[token]
        else
            return nil -- This means the token/path doesn't exist in the table
        end
    end
    return current
end

function map(tbl, func)
    local newTbl = {}
    for i, v in ipairs(tbl) do
        newTbl[i] = func(v)
    end
    return newTbl
end


return {
    getValueFromPath = getValueFromPath
}
