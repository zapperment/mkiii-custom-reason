local faderStates = require("lib.faderStates")
local items = require("lib.mixerItems")
local constants = require("lib.constants")
local debugUtils = require("lib.debugUtils")
local stateUtils = require("lib.stateUtils")

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local fader = "fader" .. i
            if changedItemIndex == items[fader].index then
                if changedItem.is_enabled then
                    local value = changedItem.value
                    local slValue = faderStates[fader].sl
                    local state
                    if slValue == nil then
                        state = faderStates.unknown
                    elseif value >= slValue - constants.pickupTolerance and value <= slValue + constants.pickupTolerance then
                        state = faderStates.inSync
                    elseif value > slValue then
                        state = faderStates.tooLow
                    elseif value < slValue then
                        state = faderStates.tooHigh
                    end
                    faderStates[fader].reason = value
                    stateUtils.set(fader, state)
                else
                    faderStates[fader] = {}
                    stateUtils.set(fader, faderStates.unassigned)
                end
            end
        end
    end
end
