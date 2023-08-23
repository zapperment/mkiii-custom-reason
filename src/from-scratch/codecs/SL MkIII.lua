local midiUtils = require("midiUtils")
local colours = require("colours")

g_knob1_item_index = 1

-- The label of the first encoder, shown in the display below the encoder
g_knob1_label = " "
g_knob1_label_prev = " "

-- The current value associated with the first encoder, shown as knob image below the encoder
g_knob1_value = " "
g_knob1_value_prev = " "

-- Whether the first encoder currently has a control in Reason associated to it
g_knob1_enabled = false
g_knob1_enabled_prev = false

-- These can be used to display any text on the SL's LCD panels, which
-- can be useful for debugging
g_debug_msg1 = " "
g_debug_msg1_prev = " "
g_debug_msg2 = " "
g_debug_msg2_prev = " "

-- Names of current device and currently loaded patch
g_device_name = " "
g_device_name_prev = " "
g_device_name_index = 2
g_patch_name = " "
g_patch_name_prev = " "
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
    if ret ~= nil and g_knob1_enabled then
        local delta
        if ret.x <= 63 then
            -- encoder turned clockwise
            delta = ret.x
            g_knob1_value = g_knob1_value + delta
            if g_knob1_value > 127 then
                g_knob1_value = 127
            end
        else
            -- encoder turned counter-clockwise
            delta = ret.x - 128
            g_knob1_value = g_knob1_value + delta
            if g_knob1_value < 0 then
                g_knob1_value = 0
            end
        end
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
                g_knob1_label = changed_item_data.short_name
                g_knob1_value = changed_item_data.value
                g_knob1_enabled = true
            else
                g_knob1_label = " "
                g_knob1_value = " "
                g_knob1_enabled = false
            end
        end

        if item_index == g_device_name_index then
            g_device_name = remote.get_item_text_value(item_index)
        end

        if item_index == g_patch_name_index then
            g_patch_name = remote.get_item_text_value(item_index)
        end
    end
end

-- CODEC => KEYBOARD
-- This function is called at regular intervals when the host is due to update the control
-- surface state. The return value should be an array of MIDI events.
function remote_deliver_midi()
    local events = {}
    if g_knob1_enabled ~= g_knob1_enabled_prev then
        table.insert(events, midiUtils.makeKnobsStatusEvent(
                { g_knob1_enabled, false, false, false, false, false, false, false },
                colours.orange
        ))
        g_knob1_enabled_prev = g_knob1_enabled
    end

    if g_knob1_label ~= g_knob1_label_prev then
        table.insert(events, midiUtils.makeKnobsTextEvent(
                { g_knob1_enabled, false, false, false, false, false, false, false },
                { g_knob1_label, " ", " ", " ", " ", " ", " ", " " },
                1
        ))
        g_knob1_label_prev = g_knob1_label
    end

    if g_knob1_value ~= g_knob1_value_prev then
        table.insert(events, midiUtils.makeKnobsTextEvent(
                { g_knob1_enabled, false, false, false, false, false, false, false },
                { tostring(g_knob1_value), " ", " ", " ", " ", " ", " ", " " },
                2
        ))
        table.insert(events, midiUtils.makeControlChangeEvent(21, g_knob1_value))
        g_knob1_value_prev = g_knob1_value
    end

    if g_debug_msg1 ~= g_debug_msg1_prev then
        table.insert(events, midiUtils.makeDebugMsgEvent(g_debug_msg1, 1))
        g_debug_msg1_prev = g_debug_msg1
    end

    if g_debug_msg2 ~= g_debug_msg2_prev then
        table.insert(events, midiUtils.makeDebugMsgEvent(g_debug_msg2, 2))
        g_debug_msg2_prev = g_debug_msg2
    end

    if g_device_name ~= g_device_name_prev or g_patch_name ~= g_patch_name_prev then
        local line2 = g_device_name == g_patch_name and " " or g_patch_name
        table.insert(events, midiUtils.makeNotificationEvent(g_device_name, line2))
        g_device_name_prev = g_device_name
        g_patch_name_prev = g_patch_name
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
