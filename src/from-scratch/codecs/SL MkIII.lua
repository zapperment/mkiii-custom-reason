local midiUtils = require("midiUtils")
local colours = require("colours")
local states = require("states")

g_knob1_item_index = 1
g_device_name_index = 2
g_patch_name_index = 3

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
    local items = { {
                        name = "knob1",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "deviceName",
                        output = "text"
                    }, {
                        name = "patchName",
                        output = "text"
                    } }

    -- remote.define_items registers all control surface items. items is a array with one entry for each item. The
    -- item’s index in the array is important. This index is later used in all other functions that
    -- refer to control surface items.
    remote.define_items(items)
end

-- KEYBOARD => CODEC
-- This function is called for each incoming MIDI event. This is where the codec interprets
-- the message and translates it into a Remote message. The translated message is then
-- passed back to Remote with a call to remote.handle_input(). If the event was translated
-- and handled this function should return true, to indicate that the event was used. If the
-- function returns false, Remote will try to find a match using the automatic input registry
-- defined with remote.define_auto_inputs().
function remote_process_midi(event)
    -- Knob 1 on the SL sends control change events on channel 16 with CC# 21 (0x15)
    -- value is:
    -- * 1-16 for clockwise turns, depending on speed (1 slowest)
    -- * 127-112 for counter-clockwise turns, depending on speed (127 slowest)

    -- remote.match_midi is a utility function that creates a MIDI event from a string mask and variables.
    -- mask should be a string containing the MIDI mask. It may contain variable references (x,y
    -- and z).
    local ret = remote.match_midi("bf 15 xx", event)
    if ret ~= nil and states.knob1.current.enabled then
        local delta
        if ret.x <= 63 then
            -- encoder turned clockwise
            delta = ret.x
            states.knob1.next.value = states.knob1.current.value + delta
            if states.knob1.next.value > 127 then
                states.knob1.next.value = 127
            end
        else
            -- encoder turned counter-clockwise
            delta = ret.x - 128
            states.knob1.next.value = states.knob1.current.value + delta
            if states.knob1.next.value < 0 then
                states.knob1.next.value = 0
            end
        end
        -- CODEC => REASON
        remote.handle_input({
            item = g_knob1_item_index,
            value = delta,
            time_stamp = event.time_stamp
        })
        return true
    end
    return false
end

-- REASON => CODEC
-- remote_set_state() is called regularly to update the state of control surface items.
-- changed_items is a table containing indexes to the items that have changed since the last
-- call.
function remote_set_state(changed_items)
    for _, item_index in ipairs(changed_items) do
        local changed_item_data = remote.get_item_state(item_index)
        if item_index == g_knob1_item_index then
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
                states.knob1.next.label = changed_item_data.short_name
                states.knob1.next.value = changed_item_data.value
                states.knob1.next.enabled = true
            else
                states.knob1.next.label = " "
                states.knob1.next.value = 0
                states.knob1.next.enabled = false
            end
        end

        if item_index == g_device_name_index then
            states.deviceName.next.value = remote.get_item_text_value(item_index)
        end

        if item_index == g_patch_name_index then
            states.patchName.next.value = remote.get_item_text_value(item_index)
        end
    end
end

-- CODEC => KEYBOARD
-- This function is called at regular intervals when the host is due to update the control
-- surface state. The return value should be an array of MIDI events.
function remote_deliver_midi()
    local events = {}
    if states.knob1.next.enabled ~= states.knob1.current.enabled then
        states.knob1.current.enabled = states.knob1.next.enabled
        table.insert(events, midiUtils.makeKnobsStatusEvent(
                { states.knob1.current.enabled, false, false, false, false, false, false, false },
                colours.orange
        ))
    end

    if states.knob1.next.label ~= states.knob1.current.label then
        states.knob1.current.label = states.knob1.next.label
        table.insert(events, midiUtils.makeKnobsTextEvent(
                { states.knob1.current.enabled, false, false, false, false, false, false, false },
                { states.knob1.current.label, " ", " ", " ", " ", " ", " ", " " },
                1
        ))
    end

    if states.knob1.next.value ~= states.knob1.current.value then
        states.knob1.current.value = states.knob1.next.value
        table.insert(events, midiUtils.makeKnobsTextEvent(
                { states.knob1.current.enabled, false, false, false, false, false, false, false },
                { tostring(states.knob1.current.value), " ", " ", " ", " ", " ", " ", " " },
                2
        ))
        table.insert(events, midiUtils.makeControlChangeEvent(21, states.knob1.current.value))
    end

    if states.debugMessage1.next.value ~= states.debugMessage1.current.value then
        states.debugMessage1.current.value = states.debugMessage1.next.value
        table.insert(events, midiUtils.makeDebugMsgEvent(states.debugMessage1.current.value, 1))
    end

    if states.debugMessage2.next.value ~= states.debugMessage2.current.value then
        states.debugMessage2.current.value = states.debugMessage2.next.value
        table.insert(events, midiUtils.makeDebugMsgEvent(states.debugMessage2.current.value, 2))
    end

    if states.deviceName.next.value ~= states.deviceName.current.value or states.patchName.next.value ~= states.patchName.current.value then
        states.deviceName.current.value = states.deviceName.next.value
        states.patchName.current.value = states.patchName.next.value
        local line2 = states.deviceName.current.value == states.patchName.current.value and " " or states.patchName.current.value
        table.insert(events, midiUtils.makeNotificationEvent(states.deviceName.current.value, line2))
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
