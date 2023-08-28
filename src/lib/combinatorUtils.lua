local combinators = require("lib.combinators")
local stateUtils = require("lib.stateUtils")

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
        stateUtils.set("knob" .. i .. ".label", knobLabel or "")
        local buttonLabel = combinatorConfig["button" .. i]
        stateUtils.set("button" .. i .. ".label", buttonLabel or "")
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
