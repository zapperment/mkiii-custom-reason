local function splitToChunks(str, chunkLength, numChunks)
    -- Check if the provided parameters are valid
    if not str or not chunkLength or not numChunks then
        return nil, "Invalid parameters"
    end

    local result = {}
    local index = 1
    for _ = 1, numChunks do
        local chunk = str:sub(index, index + chunkLength - 1)

        -- Pad the chunk with spaces if it's too short
        while #chunk < chunkLength do
            chunk = chunk .. " "
        end

        table.insert(result, chunk)
        index = index + chunkLength
    end

    return result
end

local function serialise(o)
    if type(o) == "number" then
        return tostring(o)
    elseif type(o) == "string" then
        return string.format("%q", o)
    elseif type(o) == "table" then
        local tokens = {}
        for k, v in pairs(o) do
            table.insert(tokens, "[" .. serialise(k) .. "]=" .. serialise(v))
        end
        return "{" .. table.concat(tokens,",") .. "}"
    else
        -- For unsupported data types, simply convert to string (this might not be unique across different types!)
        return tostring(o)
    end
end

return {
    splitToChunks = splitToChunks,
    serialise = serialise
}
