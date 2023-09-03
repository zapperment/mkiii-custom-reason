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
                        debugUtils.log("Value " .. tostring(value) ..
                                           " received from Reason - we don't know the position of " .. fader ..
                                           " on the SL, sync state 'unknown'")
                        state = faderStates.unknown
                    elseif value >= slValue - constants.pickupTolerance and value <= slValue + constants.pickupTolerance then
                        if stateUtils.get(fader) ~= faderStates.inSync then
                            debugUtils.log("Reason fader now has the same value " .. tostring(value) .. " as SL " ..
                                               fader .. ", now in sync")
                        end
                        state = faderStates.inSync
                    elseif value > slValue then
                        debugUtils.log("Reason fader " .. tostring(value) .. " is higher than SL " .. fader .. " " ..
                                           tostring(slValue) .. ", setting state 'too low'")
                        state = faderStates.tooLow
                    elseif value < slValue then
                        debugUtils.log("Reason fader " .. tostring(value) .. " is lower than SL " .. fader .. " " ..
                                           tostring(slValue) .. ", setting state 'too high'")
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
