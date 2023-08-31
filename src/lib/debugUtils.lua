-- this function accepts a table and returns a string with
-- all the keys in the table; you can specify keys to exclude
-- in the output by providing a second argument
local function concatenateKeys(tbl, excludeKeys)
    local keys = {}
    local exclude = {}

    -- Populate the exclude table for O(1) lookups
    for _, key in ipairs(excludeKeys or {}) do
        exclude[key] = true
    end

    for key, _ in pairs(tbl) do
        if not exclude[key] then
            table.insert(keys, tostring(key))
        end
    end

    return table.concat(keys, ",")
end

local function midiEventToString(event)
    local hexStrings = {}
    for i = 1, #event do
        table.insert(hexStrings, string.format("%02X", event[i]))
    end
    return table.concat(hexStrings, " ")
end


return {
    concatenateKeys = concatenateKeys,
    midiEventToString = midiEventToString
}
