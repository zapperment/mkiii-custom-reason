local faderStates = require("lib.faderStates")
local items = require("lib.mixerItems")
local constants = require("lib.constants")
local debugUtils = require("lib.debugUtils")

return function(changedItems)
    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local fader = "fader" .. i
            if changedItemIndex == items[fader].index then
                local value = changedItem.value
                local slValue = faderStates[fader].sl
                local state
                if value == slValue then
                    debugUtils.log("Reason fader now has the same value as SL, now in sync")
                    state = constants.inSync
                end
                if value > slValue then
                    debugUtils.log("Reason fader is higher than SL, setting state 'too low'")
                    state = constants.tooLow
                end
                if value < slValue then
                    debugUtils.log("Reason fader is lower than SL, setting state 'too high'")
                    state = constants.tooHigh
                end
                faderStates[fader].reason = value
                faderStates[fader].state = state
            end
        end
    end
end
