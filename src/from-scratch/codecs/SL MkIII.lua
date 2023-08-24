local midiUtils = require("midiUtils")
local colours = require("colours")
local stateUtils = require("stateUtils")
local items = require("items")

-- This function is called when Remote is auto-detecting surfaces. manufacturer and model are
-- strings specifying the model being auto-detected. This function is always called once for
-- each supported model.
function remote_probe(_, _, prober)

    local request_events = { remote.make_midi("F0 7E 7F 06 01 F7") }
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
            in_ports = { ins[1], ins[2] },
            out_ports = { port_out }
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
        -- Knob 1 on the SL sends control change events on channel 16 with CC# 21 (0x15)
        -- value is:
        -- * 1-16 for clockwise turns, depending on speed (1 slowest)
        -- * 127-112 for counter-clockwise turns, depending on speed (127 slowest)

        -- remote.match_midi is a utility function that creates a MIDI event from a string mask and variables.
        -- mask should be a string containing the MIDI mask. It may contain variable references (x,y
        -- and z).
        local ret = remote.match_midi(items["knob" .. i].midiMatcher, event)
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
    end
    return processed
end

-- REASON => CODEC
-- remote_set_state() is called regularly to update the state of control surface items.
-- changed_items is a table containing indexes to the items that have changed since the last
-- call.
function remote_set_state(changed_items)
    for _, item_index in ipairs(changed_items) do
        local changed_item_data = remote.get_item_state(item_index)
        for i = 1, 8 do
            if item_index == items["knob" .. i].index then
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

                if changed_item_data.is_enabled then
                    stateUtils.set("knob" .. i .. ".label", changed_item_data.short_name)
                    stateUtils.set("knob" .. i .. ".value", changed_item_data.value)
                    stateUtils.set("knob" .. i .. ".enabled", true)
                else
                    stateUtils.set("knob" .. i .. ".label", " ")
                    stateUtils.set("knob" .. i .. ".value", 0)
                    stateUtils.set("knob" .. i .. ".enabled", false)
                end
            end
        end

        if item_index == items.deviceName.index then
            stateUtils.set("deviceName", remote.get_item_text_value(item_index))
        end

        if item_index == items.patchName.index then
            stateUtils.set("patchName", remote.get_item_text_value(item_index))
        end
    end
end

-- CODEC => KEYBOARD
-- This function is called at regular intervals when the host is due to update the control
-- surface state. The return value should be an array of MIDI events.
function remote_deliver_midi()
    local events = {}
    local knobStateChanged = false
    local knobStates = {}
    local knobLabelChanged = false
    local knobLabels = {}
    local knobValueChanged = false
    local knobValues = {}

    for i = 1, 8 do
        local enabled
        local path = "knob" .. i .. ".enabled"
        if stateUtils.hasChanged(path) then
            knobStateChanged = true
            enabled = stateUtils.update(path)
        else
            enabled = stateUtils.get(path)
        end
        table.insert(knobStates, enabled)

        local label
        path = "knob" .. i .. ".label"
        if stateUtils.hasChanged(path) then
            knobLabelChanged = true
            label = stateUtils.update(path)
        else
            label = stateUtils.get(path)
        end
        table.insert(knobLabels, label)

        local value
        path = "knob" .. i .. ".value"
        if stateUtils.hasChanged(path) then
            knobValueChanged = true
            value = stateUtils.update(path)
            table.insert(events, midiUtils.makeControlChangeEvent(items["knob" .. i].controller, value))
        else
            value = stateUtils.get(path)
        end
        table.insert(knobValues, tostring(value))
    end

    if knobStateChanged then
        table.insert(events, midiUtils.makeKnobsStatusEvent(knobStates, colours.orange))
    end

    if knobLabelChanged then
        table.insert(events, midiUtils.makeKnobsTextEvent(
                knobStates,
                knobLabels,
                1
        ))
    end

    if knobValueChanged then
        table.insert(events, midiUtils.makeKnobsTextEvent(
                knobStates,
                knobValues,
                2
        ))
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
        local line2 = deviceName == patchName and " " or patchName
        table.insert(events, midiUtils.makeNotificationEvent(deviceName, line2))
    end

    return events
end

function remote_prepare_for_use()
    return { midiUtils.makeKnobsStatusEvent(),
             midiUtils.makeCreateKnobEvent(1, colours.noColour),
             midiUtils.makeCreateKnobEvent(2, colours.noColour),
             midiUtils.makeCreateKnobEvent(3, colours.noColour),
             midiUtils.makeCreateKnobEvent(4, colours.noColour),
             midiUtils.makeCreateKnobEvent(5, colours.noColour),
             midiUtils.makeCreateKnobEvent(6, colours.noColour),
             midiUtils.makeCreateKnobEvent(7, colours.noColour),
             midiUtils.makeCreateKnobEvent(8, colours.noColour)
    }
end

function remote_release_from_use()
    return { midiUtils.makeKnobsStatusEvent(),
             midiUtils.makeCreateKnobEvent(1, colours.noColour),
             midiUtils.makeCreateKnobEvent(2, colours.noColour),
             midiUtils.makeCreateKnobEvent(3, colours.noColour),
             midiUtils.makeCreateKnobEvent(4, colours.noColour),
             midiUtils.makeCreateKnobEvent(5, colours.noColour),
             midiUtils.makeCreateKnobEvent(6, colours.noColour),
             midiUtils.makeCreateKnobEvent(7, colours.noColour),
             midiUtils.makeCreateKnobEvent(8, colours.noColour)
    }
end
