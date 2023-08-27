local combinators = require("combinators")
local stateUtils = require("stateUtils")

local function getCombinatorConfig(itemName)
    local patchName = stateUtils.getNext("patchName")
    return combinators[patchName]
end

local function getLabel(itemName)
    local combinatorConfig = getCombinatorConfig(patchName)
    return combinatorConfig and combinatorConfig[itemName] or nil
end

local function assignConfig(combinatorConfig)
    for i = 1, 8 do
        local knobLabel = combinatorConfig["knob" .. i]
        if knobLabel ~= nil then
            stateUtils.set("knob" .. i .. ".label", knobLabel)
        end
        local buttonLabel = combinatorConfig["button" .. i]
        if buttonLabel then
            stateUtils.set("button" .. i .. ".label", buttonLabel)
        end
    end
end

local function resetConfig()
    for i = 1, 8 do
        stateUtils.set("knob" .. i .. ".label", "Rot " .. 1)
        stateUtils.set("button" .. i .. ".label", "But " .. 1)
    end
end

return {
    assignConfig = assignConfig,
    resetConfig = resetConfig,
    getCombinatorConfig = getCombinatorConfig,
    getLabel = getLabel
}
