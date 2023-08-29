local combinators = require("lib.combinators")
local stateUtils = require("lib.stateUtils")
local constants = require("lib.constants")

local function hasLayers(combinatorConfig)
    return combinatorConfig.layerA or combinatorConfig.layerB
end

local function getCombinatorConfig()
    local patchName = stateUtils.getNext("patchName")
    local combinatorConfig = combinators[patchName]
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
