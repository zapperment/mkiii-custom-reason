local midiUtils = require("lib.midiUtils")
local hexUtils = require("lib.hexUtils")
local colours = require("lib.colours")
local stateUtils = require("lib.stateUtils")
local items = require("lib.items")
local autoInputs = require("lib.autoInputs")
local processMidi = require("processMidi._")
local setState = require("setState._")
local constants = require("lib.constants")

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
    remote.define_auto_inputs(autoInputs)
end

-- KEYBOARD => CODEC
-- This function is called for each incoming MIDI event. This is where the codec interprets
-- the message and translates it into a Remote message. The translated message is then
-- passed back to Remote with a call to remote.handle_input(). If the event was translated
-- and handled this function should return true, to indicate that the event was used. If the
-- function returns false, Remote will try to find a match using the automatic input registry
-- defined with remote.define_auto_inputs().
function remote_process_midi(event)
    return processMidi.knobs(event)
            or processMidi.buttons(event)
            or processMidi.colourFader(event)
            or processMidi.layerButtons(event)
end

-- REASON => CODEC
-- remote_set_state() is called regularly to update the state of control surface items.
-- changed_items is a table containing indexes to the items that have changed since the last
-- call.
function remote_set_state(changedItems)
    setState.layerButtons(changedItems)
    setState.deviceName(changedItems)
    setState.patchName(changedItems)
    setState.knobs(changedItems)
    setState.buttons(changedItems)
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
    local layerChanged = false
    local layer

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

    if stateUtils.hasChanged("layer") then
        layer = stateUtils.update("layer")
        layerChanged = true
    else
        layer = stateUtils.get("layer")
        layerChanged = false
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
        buttonChanged = true
        layerChanged = true
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

    if layerChanged then
        local activeButtonController, inactiveButtonController
        if layer == constants.layerA then
            activeButtonController = items["buttonLayerA"].controller
            inactiveButtonController = items["buttonLayerB"].controller
        else
            activeButtonController = items["buttonLayerB"].controller
            inactiveButtonController = items["buttonLayerA"].controller
        end
        table.insert(events, midiUtils.makeControlChangeEvent(activeButtonController, buttonColour))
        table.insert(events, midiUtils.makeControlChangeEvent(inactiveButtonController, 0))
    end

    return events
end

function remote_prepare_for_use()
    return { midiUtils.makeKnobsStatusEvent(), midiUtils.makeCreateKnobEvent(1, colours.noColour),
             midiUtils.makeCreateKnobEvent(2, colours.noColour), midiUtils.makeCreateKnobEvent(3, colours.noColour),
             midiUtils.makeCreateKnobEvent(4, colours.noColour), midiUtils.makeCreateKnobEvent(5, colours.noColour),
             midiUtils.makeCreateKnobEvent(6, colours.noColour), midiUtils.makeCreateKnobEvent(7, colours.noColour),
             midiUtils.makeCreateKnobEvent(8, colours.noColour),
             midiUtils.makeControlChangeEvent(items["buttonLayerA"].controller, constants.buttonColourNumber),
             midiUtils.makeControlChangeEvent(items["buttonLayerB"].controller, colours.noColour)
    }
end

function remote_release_from_use()
    return { midiUtils.makeKnobsStatusEvent(), midiUtils.makeCreateKnobEvent(1, colours.noColour),
             midiUtils.makeCreateKnobEvent(2, colours.noColour), midiUtils.makeCreateKnobEvent(3, colours.noColour),
             midiUtils.makeCreateKnobEvent(4, colours.noColour), midiUtils.makeCreateKnobEvent(5, colours.noColour),
             midiUtils.makeCreateKnobEvent(6, colours.noColour), midiUtils.makeCreateKnobEvent(7, colours.noColour),
             midiUtils.makeCreateKnobEvent(8, colours.noColour),
             midiUtils.makeControlChangeEvent(items["buttonLayerA"].controller, colours.noColour),
             midiUtils.makeControlChangeEvent(items["buttonLayerB"].controller, colours.noColour)
    }
end
