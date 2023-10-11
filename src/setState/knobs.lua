local constants = require("src.lib.constants")
local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")
local combinatorUtils = require("src.lib.combinatorUtils")
local stringUtils = require("src.lib.stringUtils")
local log = require("src.lib.debugUtils").log

local function handleUmpfToCombiMode(knob, value)
    if not isUmpfToCombiMode then
        return
    end

    local deviceType = stateUtils.getNext("deviceType")

    if deviceType ~= "umpfclub" and deviceType ~= "umpfretro" then
        return
    end

    local prevUmpfDataStr = stringUtils.serialise(umpfData)
    local layer = stateUtils.getNext("layer")

    if layer == constants.layerA then
        if deviceType == "umpfclub" then
            if knob == "knob1" then
                umpfData.Chop = value
            elseif knob == "knob2" then
                umpfData.Delay = value
            elseif knob == "knob3" then
                umpfData.Reverb = value
            elseif knob == "knob4" then
                umpfData.Compressr = value
            elseif knob == "knob5" then
                umpfData.Clean = value
            end
        end
    end

    if layer == constants.layerB and knob == "knob1" then
        umpfData["Ch" .. tostring(currentPad) .. "Vol"] = value
    end

    local newUmpfDataStr = stringUtils.serialise(umpfData)
    if newUmpfDataStr ~= prevUmpfDataStr then
        log("umpf data: " .. newUmpfDataStr)
    end
end

return function(changedItems)
    local combinatorConfig = combinatorUtils.getCombinatorConfig()
    local hasCustomLabels = combinatorConfig ~= nil
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local knob = "knob" .. i
            if changedItemIndex == items[knob].index then
                if changedItem.is_enabled then
                    if hasCustomLabels then
                        stateUtils.set(knob .. ".label", combinatorConfig[knob] or "")
                    else
                        stateUtils.set(knob .. ".label", changedItem.short_name)
                    end
                    stateUtils.set(knob .. ".value", changedItem.value)
                    stateUtils.set(knob .. ".enabled", true)
                    handleUmpfToCombiMode(knob, changedItem.value)
                else
                    stateUtils.set(knob .. ".label", "")
                    stateUtils.set(knob .. ".value", 0)
                    stateUtils.set(knob .. ".enabled", false)
                end
            end
        end
    end
end
