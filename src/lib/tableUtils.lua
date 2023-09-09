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

function deepCopy(orig)
    local origType = type(orig)
    local copy

    if origType == 'table' then
        copy = {}
        for origKey, origValue in next, orig, nil do
            copy[deepCopy(origKey)] = deepCopy(origValue)
        end
        setmetatable(copy, deepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc.
        copy = orig
    end
    return copy
end

return {
    getValueFromPath = getValueFromPath,
    map = map,
    deepCopy = deepCopy
}
