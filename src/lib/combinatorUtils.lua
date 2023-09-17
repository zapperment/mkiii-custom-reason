local combinators = require("src.lib.combinators")
local stateUtils = require("src.lib.stateUtils")
local constants = require("src.lib.constants")

local function hasLayers(combinatorConfig)
    return combinatorConfig.layerA or combinatorConfig.layerB
end

local function findMatchingCombinatorConfig(patchName)
    -- First, try direct lookup.
    local config = combinators[patchName]
    if config then
        return config
    end
    -- If not found, then try pattern matching.
    for key, value in pairs(combinators) do
        -- Convert the key into a Lua pattern by escaping special characters 
        -- and replacing '*' with '.*' to match any sequence of characters.
        local pattern = "^" .. key:gsub("[%(%)%.%%%+%-%?%[%]%^%$]", "%%%1"):gsub("%*", ".*") .. "$"
        if patchName:match(pattern) then
            return value
        end
    end
    return nil
end

local function getCombinatorConfig()
    local patchName = stateUtils.getNext("patchName")
    local combinatorConfig = findMatchingCombinatorConfig(patchName)
    if combinatorConfig == nil then
        return nil
    end
    if hasLayers(combinatorConfig) then
        local layer = stateUtils.getNext("layer")
        return combinatorConfig[layer]
    end
    local layer = stateUtils.getNext("layer")
    if layer == constants.layerB then
        return {}
    end
    return combinatorConfig
end

local function getLabel(itemName)
    local combinatorConfig = getCombinatorConfig(patchName)
    return combinatorConfig and combinatorConfig[itemName] or nil
end

local function assignConfig(combinatorConfig)
    for i = 1, 8 do
        local knobLabel = combinatorConfig["knob" .. i]
        stateUtils.set("knob" .. i .. ".label", knobLabel or "")
        local buttonLabel = combinatorConfig["button" .. i]
        stateUtils.set("button" .. i .. ".label", buttonLabel or "")
    end
end

return {
    assignConfig = assignConfig,
    getCombinatorConfig = getCombinatorConfig,
    getLabel = getLabel,
    findMatchingCombinatorConfig = findMatchingCombinatorConfig
}
