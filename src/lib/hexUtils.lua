local function decToHex(decimalValue)
    return string.format("%02X", decimalValue)
end

local function hexToDec(stringWithHexCode)
    return tonumber(stringWithHexCode, 16)
end

local function textToHex(text)
    local hex = ""
    for i = 1, string.len(text) do
        hex = hex .. decToHex(string.byte(text, i))
        if i ~= text_len then
            hex = hex .. " "
        end
    end
    return hex
end

return {
    textToHex = textToHex,
    decToHex = decToHex,
    hexToDec = hexToDec
}
