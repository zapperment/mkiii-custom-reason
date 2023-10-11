local constants = require("src.lib.constants")
local stateUtils = require("src.lib.stateUtils")
local items = require("src.lib.items")
local combinatorUtils = require("src.lib.combinatorUtils")
local stringUtils = require("src.lib.stringUtils")
local log = require("src.lib.debugUtils").log

local function handleUmpfToCombiMode(button, value)
    if not isUmpfToCombiMode then
        return
    end

    local deviceType = stateUtils.getNext("deviceType")

    if deviceType ~= "umpfclub" and deviceType ~= "umpfretro" then
        return
    end

    local prevUmpfDataStr = stringUtils.serialise(umpfData)
    local layer = stateUtils.getNext("layer")

    if deviceType == "umpfclub" then
        if layer == constants.layerA and button == "button3" then
            umpfData.Rev2Comp = value > 0
        end
    end


    if layer == constants.layerB and button == "button1" then
        umpfData["Ch" .. tostring(currentPad) .. "On"] = not (value > 0)
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
            local button = "button" .. i
            if changedItemIndex == items[button].index then
                if changedItem.is_enabled then
                    if hasCustomLabels then
                        stateUtils.set(button .. ".label", combinatorConfig[button] or "")
                    else
                        stateUtils.set(button .. ".label", changedItem.short_name)
                    end
                    stateUtils.set(button .. ".value", changedItem.value > 0)
                    stateUtils.set(button .. ".enabled", true)
                    handleUmpfToCombiMode(button, changedItem.value)
                else
                    stateUtils.set(button .. ".label", "")
                    stateUtils.set(button .. ".value", false)
                    stateUtils.set(button .. ".enabled", false)
                end
            end
        end
    end
end
