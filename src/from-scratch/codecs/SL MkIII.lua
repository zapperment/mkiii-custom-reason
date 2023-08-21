-- Header for InControl system exclusive messages
g_sysex_header = "f0 00 20 29 02 0A 01"

-- System exclusive message to reset the displays below the encoders
g_sysex_encoder_layout = "f0 00 20 29 02 0A 01 01 01 f7"

g_encoder1_item_index = 1

-- The label of the first encoder, shown in the display below the encoder
g_encoder1_label = " "
g_encoder1_label_prev = " "

-- The current value associated with the first encoder, shown as knob image below the encoder
g_encoder1_value = " "
g_encoder1_value_prev = " "

-- Whether the first encoder currently has a control in Reason associated to it
g_encoder1_enabled = false
g_encoder1_enabled_prev = false

function text_to_sysex(text)
    local sysex = ""
    for i = 1, string.len(text) do
        sysex = sysex .. dec_to_hex(string.byte(text, i)) .. " "
    end
    return sysex
end

function dec_to_hex(IN)
    local B, K, OUT, I, D = 16, "0123456789ABCDEF", "", 0, 0
    while IN > 0 do
        I = I + 1
        IN, D = math.floor(IN / B), math.fmod(IN, B) + 1
        OUT = string.sub(K, D, D) .. OUT
    end
    return OUT
end

-- This function is called when Remote is auto-detecting surfaces. manufacturer and model are
-- strings specifying the model being auto-detected. This function is always called once for
-- each supported model.
function remote_probe(manufacturer, model, prober)

    local request_events = {remote.make_midi("F0 7E 7F 06 01 F7")}
    local response = "F0 7E 00 06 02 00 20 29 01 01 00 00 ?? ?? ?? ?? F7"

    local function match_events(mask, events)
        for i, event in ipairs(events) do
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
    local received_ports = {}
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
    local items = {{
        name = "Knob 1",
        input = "delta",
        output = "value",
        min = 0,
        max = 127
    }}

    -- remote.define_items registers all control surface items. items is a array with one entry for each item. The
    -- item’s index in the array is important. This index is later used in all other functions that
    -- refer to control surface items.
    remote.define_items(items)
end

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
    if ret ~= nil and g_encoder1_enabled then
        if ret.x <= 63 then
            -- encoder turned clockwise
            g_encoder1_value = g_encoder1_value + ret.x
            if g_encoder1_value > 127 then
                g_encoder1_value = 127
            end
        else
            -- encoder turned counter-clockwise
            g_encoder1_value = g_encoder1_value + ret.x - 128
            if g_encoder1_value < 0 then
                g_encoder1_value = 0
            end
        end
        return true
    end
    return false
end

-- remote_set_state() is called regularly to update the state of control surface items.
-- changed_items is a table containing indexes to the items that have changed since the last
-- call.
function remote_set_state(changed_items)
    for i, item_index in ipairs(changed_items) do
        local changed_item_data = remote.get_item_state(item_index)
        if item_index == g_encoder1_item_index then
            -- remote.get_item_state returns a table with the complete state of the given item. The table has the following
            -- fields:
            -- is_enabled – true if the control surface item is mapped/enabled
            -- value – the value of the item (e.g. 64)
            -- mode – mode the current mode for the item
            -- remote_item_name – the name of the remotable item mapped (e.g. "Knob 1")
            -- text_value – the text value of the remotable item (e.g. "64")
            -- short_name – the short version of the name (8 characters maximum, e.g. "Knob 1")
            -- shortest_name – the shortest version of the name (4 chars, e.g. "Knob")
            -- name_and_value – the name and value combined
            -- short_name_and_value – the short version of name-and-value (16 chars)
            -- shortest_name_and_value - the shortest version of name-and-value (8 chars)

            if changed_item_data.is_enabled then
                g_encoder1_label = changed_item_data.short_name
                g_encoder1_value = changed_item_data.value
                g_encoder1_enabled = true
            else
                g_encoder1_label = " "
                g_encoder1_value = " "
                g_encoder1_enabled = false
            end
        end

    end
end

-- This function is called at regular intervals when the host is due to update the control
-- surface state. The return value should be an array of MIDI events.
function remote_deliver_midi()
    local ret_events = {}
    if g_encoder1_enabled ~= g_encoder1_enabled_prev then
        local event = "f0 00 20 29 02 0A 01 02 "
        if g_encoder1_enabled then
            -- 00: Knob 1
            -- 02 01: Sets color
            -- 09: orange
            event = event .. "00 02 01 09"
        else
            event = event .. "00 02 01 00"
        end
        event = event .. "f7"
        table.insert(ret_events, remote.make_midi(event))

        g_encoder1_enabled_prev = g_encoder1_enabled
    end

    if g_encoder1_label ~= g_encoder1_label_prev then
        local column = "00" -- column 1
        local row = "00" -- row 1
        local text = text_to_sysex(g_encoder1_label)
        local event = "F0 00 20 29 02 0A 01 02 " .. column .. " 01 " .. row .. " " .. text .. " 00 "
        event = event .. "01 01 00 00 02 01 00 00 03 01 00 00 04 01 00 00 05 01 00 00 06 01 00 00 07 01 00 00 F7"
        table.insert(ret_events, remote.make_midi(event))
        g_encoder1_label_prev = g_encoder1_label
    end

    if g_encoder1_value ~= g_encoder1_value_prev then
        local column = "00" -- column 1
        local row = "01" -- row 2
        local text = text_to_sysex(g_encoder1_value)
        local event = "F0 00 20 29 02 0A 01 02 " .. column .. " 01 " .. row .. " " .. text .. " 00 "
        event = event .. "01 01 01 00 02 01 01 00 03 01 01 00 04 01 01 00 05 01 01 00 06 01 01 00 07 01 01 00 F7"
        table.insert(ret_events, remote.make_midi(event))
        g_encoder1_value_prev = g_encoder1_value
    end
    return ret_events
end
