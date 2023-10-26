local items = require("src.lib.items")
local log = require("src.lib.debugUtils").log
local stateUtils = require("src.lib.stateUtils")
local constants = require("src.lib.constants")

local function toggleUmpfToCombiMode()
    isUmpfToCombiMode = isUmpfToCombiMode == false
    if isUmpfToCombiMode then
        log("Ump to combi mode ON")
    else
        log("Ump to combi mode OFF")
        umpfData = {}
    end
end

local function sendUmpfToCombi(event)
    if not isUmpfToCombiMode then
        return false
    end

    local deviceType = stateUtils.getNext("deviceType")

    if deviceType ~= "combinator" then
        return false
    end

    local retVal = false
    local layer = stateUtils.get("layer")

    if layer == constants.layerA then
        for i = 1, 8 do
            local knobValue = umpfData["Ch" .. tostring(i) .. "Vol"]
            if knobValue ~= nil then
                local currentKnobValue = stateUtils.get("knob" .. tostring(i) .. ".value")
                local knobDeltaValue = (currentKnobValue - knobValue) * -1
                if knobDeltaValue ~= -0 then
                    log("setting knob " .. i .. ": " .. currentKnobValue .. " => " .. knobValue ..
                            " (delta=" .. knobDeltaValue .. ")")
                    remote.handle_input({
                        item = items["knob" .. tostring(i)].index,
                        value = knobDeltaValue,
                        time_stamp = event.time_stamp
                    })
                    retVal = true
                else
                    log("knob " .. i .. " value is already " .. knobValue .. ", nothing to do")
                end
            end

            local buttonValue = umpfData["Ch" .. i .. "On"]
            if buttonValue ~= nil then
                local currentButtonValue = stateUtils.get("button" .. i .. ".value")
                if buttonValue == currentButtonValue then
                    if buttonValue then
                        log("button " .. i .. " is already on, nothing to do")
                    else
                        log("button " .. i .. " is already off, nothing to do")
                    end
                else
                    if buttonValue then
                        log("turning button " .. i .. " on")
                    else
                        log("turning button " .. i .. " off")
                    end
                    remote.handle_input({
                        item = items["button" .. i].index,
                        value = 127,
                        time_stamp = event.time_stamp
                    })
                    retVal = true
                end
            end
        end
    else
        local values = {}
        values.knob2 = umpfData.Chop ~= nil and umpfData.Chop or umpfData.Echo
        values.knob3 = umpfData.Delay ~= nil and umpfData.Delay or umpfData.Gate
        values.knob4 = umpfData.Reverb
        values.knob5 = umpfData.Compressr ~= nil and umpfData.Compressr or umpfData.Tape
        values.knob6 = umpfData.Clean

        for i = 2, 6 do
            local knobValue = values["knob" .. tostring(i)]
            if knobValue ~= nil then
                local currentKnobValue = stateUtils.get("knob" .. i .. ".value")
                local knobDeltaValue = (currentKnobValue - knobValue) * -1
                if knobDeltaValue ~= -0 then
                    log("setting knob " .. i .. ": " .. currentKnobValue .. " => " .. knobValue ..
                            " (delta=" .. knobDeltaValue .. ")")
                    remote.handle_input({
                        item = items["knob" .. i].index,
                        value = knobDeltaValue,
                        time_stamp = event.time_stamp
                    })
                    retVal = true
                else
                    log("knob " .. i .. " value is already " .. knobValue .. ", nothing to do")
                end
            end
        end

        if umpfData.Rev2Comp ~= nil then
            local buttonValue = umpfData.Rev2Comp
            local currentButtonValue = stateUtils.get("button1.value")
            if buttonValue == currentButtonValue then
                if buttonValue then
                    log("button 1 is already on, nothing to do")
                else
                    log("button 1 is already off, nothing to do")
                end
            else
                if buttonValue then
                    log("turning button 1 on")
                else
                    log("turning button 1 off")
                end
                remote.handle_input({
                    item = items.button1.index,
                    value = 127,
                    time_stamp = event.time_stamp
                })
                retVal = true
            end
        end
    end
    return retVal
end

return function(event)
    local ret
    if not ENV_UMPF_TO_COMBI_MODE then
        -- Umpf-to-Combi mode can only be used when the Codec was installed
        -- with the "umpf" flag
        return false
    end
    if not isShifted then
        -- if the shift button on the SL MkIII is not pressed, the
        -- layer buttons are used for setting the layer
        return false
    end
    ret = remote.match_midi(items.buttonLayerA.midiMatcher, event)
    if ret and ret.x > 0 then
        toggleUmpfToCombiMode()
        return true
    end
    ret = remote.match_midi(items.buttonLayerB.midiMatcher, event)
    if ret and ret.x > 0 then
        return sendUmpfToCombi(event)
    end
    return false
end
