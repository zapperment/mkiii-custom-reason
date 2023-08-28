local midiUtils = require("lib.midiUtils")
local hexUtils = require("lib.hexUtils")
local colours = require("lib.colours")
local stateUtils = require("lib.stateUtils")
local items = require("lib.items")
local combinatorUtils = require("lib.combinatorUtils")

local hasCustomLabels

-- This function is called when Remote is auto-detecting surfaces. manufacturer and model are
-- strings specifying the model being auto-detected. This function is always called once for
-- each supported model.
function remote_probe(_, _, prober)

    local request_events = {remote.make_midi("F0 7E 7F 06 01 F7")}
    local response = "F0 7E 00 06 02 00 20 29 01 01 00 00 ?? ?? ?? ?? F7"

    local function match_events(mask, events)
        for _, event in ipairs(events) do
            local res = remote.match_midi(mask, event)

            if res ~= nil then
                return true
            end
        end

        return false
    end

    local results = {}
    local port_out = 0
    local ins = {}
    local dev_found = 0

    -- check all the MIDI OUT ports
    for outPortIndex = 1, prober.out_ports do
        -- send device inquiry msg
        prober.midi_send_function(outPortIndex, request_events)
        prober.wait_function(50)

        -- check all the MIDI IN ports
        for inPortIndex = 1, prober.in_ports do
            local events = prober.midi_receive_function(inPortIndex)

            if match_events(response, events) then
                prober.midi_send_function(outPortIndex, request_events)
                prober.wait_function(50)

                port_out = outPortIndex + 1 -- InControl port
                table.insert(ins, inPortIndex + 1) -- InControl port
                table.insert(ins, inPortIndex) -- MIDI port
                dev_found = 1
                break
            end
        end
        if dev_found == 1 then
            break
        end
    end

    if dev_found ~= 0 then
        local one_result = {
            in_ports = {ins[1], ins[2]},
            out_ports = {port_out}
        }
        table.insert(results, one_result)
    end

    return results
end

-- remote_init() is called when a control surface instance is setup for use. Each instance of
-- a control surface uses its own Lua environment. This function should be used to register
-- all control surface items, using remote.define_items(). It can also be used to register
-- automatic handling of input and output, with remote.define_auto_inputs() and
-- remote.define_auto_outputs(). The define_* functions can only be called from remote_init().
function remote_init()
    local itemsToDefine = {}
    for name, item in pairs(items) do
        table.insert(itemsToDefine, {
            name = name,
            input = item.input,
            output = item.output,
            min = item.min,
            max = item.max
        })
        item.index = #itemsToDefine
    end
    -- remote.define_items registers all control surface items. items is a array with one entry for each item. The
    -- item’s index in the array is important. This index is later used in all other functions that
    -- refer to control surface items.
    remote.define_items(itemsToDefine)
end

-- KEYBOARD => CODEC
-- This function is called for each incoming MIDI event. This is where the codec interprets
-- the message and translates it into a Remote message. The translated message is then
-- passed back to Remote with a call to remote.handle_input(). If the event was translated
-- and handled this function should return true, to indicate that the event was used. If the
-- function returns false, Remote will try to find a match using the automatic input registry
-- defined with remote.define_auto_inputs().
function remote_process_midi(event)
    local processed = false
    for i = 1, 8 do
        local ret
        -- Knob 1 on the SL sends control change events on channel 16 with CC# 21 (0x15)
        -- value is:
        -- * 1-16 for clockwise turns, depending on speed (1 slowest)
        -- * 127-112 for counter-clockwise turns, depending on speed (127 slowest)

        -- remote.match_midi is a utility function that creates a MIDI event from a string mask and variables.
        -- mask should be a string containing the MIDI mask. It may contain variable references (x,y
        -- and z).
        ret = remote.match_midi(items["knob" .. i].midiMatcher, event)
        if ret and stateUtils.get("knob" .. i .. ".enabled") then
            local delta = ret.x <= 63 and ret.x or ret.x - 128
            stateUtils.add("knob" .. i .. ".value", delta, 0, 127)

            -- CODEC => REASON
            remote.handle_input({
                item = items["knob" .. i].index,
                value = delta,
                time_stamp = event.time_stamp
            })
            processed = true
        end

        ret = remote.match_midi(items["button" .. i].midiMatcher, event)
        if ret and stateUtils.get("button" .. i .. ".enabled") and ret.x > 0 then
            stateUtils.flip("button" .. i .. ".value")

            -- CODEC => REASON
            remote.handle_input({
                item = items["button" .. i].index,
                value = stateUtils.getNext("button" .. i .. ".value") and 127 or 0,
                time_stamp = event.time_stamp
            })
            processed = true
        end
    end
    -- DELETE ME: fader 1 controls button colour – just for experimentation
    ret = remote.match_midi("BF 29 xx", event)
    if ret then
        stateUtils.set("buttonColour", ret.x)
        stateUtils.set("patchName", "buttonColour=" .. tostring(ret.x))
    end
    return processed
end

-- REASON => CODEC
-- remote_set_state() is called regularly to update the state of control surface items.
-- changed_items is a table containing indexes to the items that have changed since the last
-- call.
function remote_set_state(changedItems)
    -- We iterate TWICE because we have to make sure the device and patch name changes are processed before
    -- anything else
    for _, changedItemIndex in ipairs(changedItems) do
        if changedItemIndex == items.deviceName.index then
            stateUtils.set("deviceName", remote.get_item_text_value(changedItemIndex))
        end

        if changedItemIndex == items.patchName.index then
            stateUtils.set("patchName", remote.get_item_text_value(changedItemIndex))
            local combinatorConfig = combinatorUtils.getCombinatorConfig()
            if combinatorConfig then
                hasCustomLabels = true
                combinatorUtils.assignConfig(combinatorConfig)
            else
                hasCustomLabels = false
                combinatorUtils.resetConfig(combinatorConfig)
            end
        end
    end

    for _, changedItemIndex in ipairs(changedItems) do
        local changedItem = remote.get_item_state(changedItemIndex)
        for i = 1, 8 do
            local knob = "knob" .. i
            if changedItemIndex == items[knob].index then
                -- remote.get_item_state returns a table with the complete state of the given item. The table has the following
                -- fields:
                -- is_enabled – true if the control surface item is mapped/enabled
                -- value – the value of the item (e.g. 64)
                -- mode – mode the current mode for the item
                -- remote_item_name – the name of the remotable item mapped (e.g. "Rotary 1")
                -- text_value – the text value of the remotable item (e.g. "64")
                -- short_name – the short version of the name (8 characters maximum, e.g. "Rot 1")
                -- shortest_name – the shortest version of the name (4 chars, e.g. "R1")
                -- name_and_value – the name and value combined
                -- short_name_and_value – the short version of name-and-value (16 chars)
                -- shortest_name_and_value - the shortest version of name-and-value (8 chars)

                if changedItem.is_enabled then
                    if hasCustomLabels == false then
                        stateUtils.set(knob .. ".label", changedItem.short_name)
                    end
                    stateUtils.set(knob .. ".value", changedItem.value)
                    stateUtils.set(knob .. ".enabled", true)
                else
                    stateUtils.set(knob .. ".label", "")
                    stateUtils.set(knob .. ".value", 0)
                    stateUtils.set(knob .. ".enabled", false)
                end
            end

            local button = "button" .. i
            if changedItemIndex == items[button].index then
                if changedItem.is_enabled then
                    if hasCustomLabels == false then
                        stateUtils.set(button .. ".label", changedItem.short_name)
                    end
                    stateUtils.set(button .. ".value", changedItem.value > 0)
                    stateUtils.set(button .. ".enabled", true)
                else
                    stateUtils.set(button .. ".label", "")
                    stateUtils.set(button .. ".value", false)
                    stateUtils.set(button .. ".enabled", false)
                end
            end
        end
    end
end

-- CODEC => KEYBOARD
-- This function is called at regular intervals when the host is due to update the control
-- surface state. The return value should be an array of MIDI events.
function remote_deliver_midi()
    local events = {}
    local knobChanged = false
    local knobStates = {}
    local knobLabels = {}
    local knobValues = {}
    local buttonChanged = false
    local buttonStates = {}
    local buttonLabels = {}
    local buttonValues = {}

    for i = 1, 8 do
        local enabled, path, label, value

        path = "knob" .. i .. ".enabled"
        if stateUtils.hasChanged(path) then
            knobChanged = true
            enabled = stateUtils.update(path)
        else
            enabled = stateUtils.get(path)
        end
        table.insert(knobStates, enabled)

        path = "knob" .. i .. ".label"
        if stateUtils.hasChanged(path) then
            knobChanged = true
            label = stateUtils.update(path)
        else
            label = stateUtils.get(path)
        end
        table.insert(knobLabels, label)

        path = "knob" .. i .. ".value"
        if stateUtils.hasChanged(path) then
            knobChanged = true
            value = stateUtils.update(path)
            table.insert(events, midiUtils.makeControlChangeEvent(items["knob" .. i].controller, value))
        else
            value = stateUtils.get(path)
        end
        table.insert(knobValues, tostring(value))

        path = "button" .. i .. ".enabled"
        if stateUtils.hasChanged(path) then
            buttonChanged = true
            enabled = stateUtils.update(path)
        else
            enabled = stateUtils.get(path)
        end
        table.insert(buttonStates, enabled)

        path = "button" .. i .. ".label"
        if stateUtils.hasChanged(path) then
            buttonChanged = true
            label = stateUtils.update(path)
        else
            label = stateUtils.get(path)
        end
        table.insert(buttonLabels, label)

        path = "button" .. i .. ".value"
        if stateUtils.hasChanged(path) then
            buttonChanged = true
            value = stateUtils.update(path)
        else
            value = stateUtils.get(path)
        end
        table.insert(buttonValues, value and "ON" or "off")
    end

    -- Special case handling for Combinators with custom labels: if the
    -- label is an empty string, treat them as if they were disabled
    for i = 1, 8 do
        local knobLabel = knobLabels[i]
        if knobLabel == "" then
            knobStates[i] = false
        end
        local buttonLabel = buttonLabels[i]
        if buttonLabel == "" then
            buttonStates[i] = false
        end
    end

    local buttonColour
    if stateUtils.hasChanged("buttonColour") then
        knobChanged = true
        buttonColour = stateUtils.update("buttonColour")
    else
        buttonColour = stateUtils.get("buttonColour")
    end

    if knobChanged then
        table.insert(events, midiUtils.makeKnobsStatusEvent(knobStates, hexUtils.decToHex(buttonColour)))
        table.insert(events, midiUtils.makeDisplayEvent(knobStates, knobLabels, 1))
        table.insert(events, midiUtils.makeDisplayEvent(knobStates, knobValues, 2))
    end

    if buttonChanged then
        table.insert(events, midiUtils.makeDisplayEvent(buttonStates, buttonLabels, 3))
        table.insert(events, midiUtils.makeDisplayEvent(buttonStates, buttonValues, 4))
        for i, value in ipairs(buttonValues) do
            table.insert(events, midiUtils.makeControlChangeEvent(items["button" .. i].controller,
                value == "ON" and buttonColour or 0))
        end
    end

    if stateUtils.hasChanged("debugMessage1") then
        local message = stateUtils.update("debugMessage1")
        table.insert(events, midiUtils.makeDebugMsgEvent(message, 1))
    end

    if stateUtils.hasChanged("debugMessage2") then
        local message = stateUtils.update("debugMessage2")
        table.insert(events, midiUtils.makeDebugMsgEvent(message, 2))
    end

    if stateUtils.hasChanged("deviceName") or stateUtils.hasChanged("patchName") then
        local deviceName = stateUtils.update("deviceName")
        local patchName = stateUtils.update("patchName")
        local line2 = deviceName == patchName and "" or patchName
        table.insert(events, midiUtils.makeNotificationEvent(deviceName, line2))
    end

    return events
end

function remote_prepare_for_use()
    return {midiUtils.makeKnobsStatusEvent(), midiUtils.makeCreateKnobEvent(1, colours.noColour),
            midiUtils.makeCreateKnobEvent(2, colours.noColour), midiUtils.makeCreateKnobEvent(3, colours.noColour),
            midiUtils.makeCreateKnobEvent(4, colours.noColour), midiUtils.makeCreateKnobEvent(5, colours.noColour),
            midiUtils.makeCreateKnobEvent(6, colours.noColour), midiUtils.makeCreateKnobEvent(7, colours.noColour),
            midiUtils.makeCreateKnobEvent(8, colours.noColour)}
end

function remote_release_from_use()
    return {midiUtils.makeKnobsStatusEvent(), midiUtils.makeCreateKnobEvent(1, colours.noColour),
            midiUtils.makeCreateKnobEvent(2, colours.noColour), midiUtils.makeCreateKnobEvent(3, colours.noColour),
            midiUtils.makeCreateKnobEvent(4, colours.noColour), midiUtils.makeCreateKnobEvent(5, colours.noColour),
            midiUtils.makeCreateKnobEvent(6, colours.noColour), midiUtils.makeCreateKnobEvent(7, colours.noColour),
            midiUtils.makeCreateKnobEvent(8, colours.noColour)}
end
