local stateUtils = require("src.lib.stateUtils")
local stringUtils = require("src.lib.stringUtils")
local items = require("src.lib.items")
local constants = require("src.lib.constants")
local log = require("src.lib.debugUtils").log

return function(event)
    local processed = false
    if not isShifted then
        -- if the shift button on the SL MkIII is not pressed, the
        -- layer buttons are used for setting the layer
        return processed
    end
    local deviceType = stateUtils.get("deviceType")
    local ret = remote.match_midi(items.buttonLayerA.midiMatcher, event)
    if deviceType == "umpfclub" and ret and ret.x > 0 then
        umpfData = {}
        for i = 1, 5 do
            umpfData["umpfKnob" .. i] = stateUtils.get("knob" .. i .. ".value")
        end
        umpfData["umpfButton3"] = stateUtils.get("button3.value")
        log("received umpf data: " .. stringUtils.serialise(umpfData))
        processed = true
    end
    ret = remote.match_midi(items.buttonLayerB.midiMatcher, event)
    if deviceType == "combinator" and umpfData and ret and ret.x > 0 then
        local combiDeltaValues = {}
        for i = 1, 5 do
            local combiDeltaValue = (stateUtils.get("knob" .. (i + 1) .. ".value") - umpfData["umpfKnob" .. i]) * -1
            stateUtils.set("knob" .. (i + 1) .. ".value", umpfData["umpfKnob" .. i])
            combiDeltaValues["combiKnob" .. i + 1] = combiDeltaValue
            remote.handle_input({
                item = items["knob" .. (i + 1)].index,
                value = combiDeltaValue,
                time_stamp = event.time_stamp
            })
        end
        stateUtils.set("button1.value", umpfData.umpfButton3)
        local buttonValue = umpfData.umpfButton3 and 127 or 0
        remote.handle_input({
            item = items.button1.index,
            value = buttonValue,
            time_stamp = event.time_stamp
        })
        log("sent umpf data: " .. stringUtils.serialise(combiDeltaValues) .. ",combiButton1=" .. tostring(buttonValue))
        umpfData = nil
        processed = true
    end
    return processed
end

