local constants = require("constants")
local hexUtils = require("hexUtils")
local numUtils = require("numUtils")
local midiUtils = require("midiUtils")
local colours = require("colours")

-- table.insertPID = 0x0A																													-- product ID
dim = "08"
dim_decimal = 8
white_decimal = 3
green_decimal = 21
dim_green_decimal = 22
orange_decimal = 9
dim_orange_decimal = 83
red_decimal = 120
dim_red_decimal = 121
button_on = white_decimal
fader_index = { "29 ", "2A ", "2B ", "2C ", "2D ", "2E ", "2F ", "30 " }
fader_sysex_index = { "36 ", "37 ", "38 ", "39 ", "3A ", "3B ", "3C ", "3D " }
divided_by_127 = 0.007874015748031

---------------------------------------------------------------------------
-------------------------------FUNCTIONS-----------------------------------
---------------------------------------------------------------------------

---------------------------------------------------------------------------
local function set_fader_colour(x, colour)
    msg = "b3 " .. fader_index[x] .. colour

    return remote.make_midi(msg)
end

---------------------------------------------------------------------------
local function set_fader_brightness(x, brightness)
    begin = "f0 00 20 29 02 0a 01 03 "
    -- RGB for ORANGE
    r = tostring(hexUtils.decToHex(numUtils.truncate(83 * brightness * divided_by_127)))
    g = tostring(hexUtils.decToHex(numUtils.truncate(17 * brightness * divided_by_127)))
    b = "00"
    msg = begin .. fader_sysex_index[x] .. " 01 " .. r .. " " .. g .. " " .. b .. " F7"

    return remote.make_midi(msg)
end

---------------------------------------------------------------------------
local function clear_screens()
    return remote.make_midi(constants.sysexHeader .. "01 00 f7")
end

---------------------------------------------------------------------------
function greater_than_zero(x)
    if x ~= 0 then
        return 1
    else
        return 0
    end
end

--------------------------------------------------------------------------------
function delta_reader(x)
    -- read values from knobs
    local output
    if x > 63 then
        output = -(128 - x)
        return output
    else
        return x
    end
end

--------------------------------------------------------------------------------
function reset_buttons_state()
    return { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
             false, false, false, false, false, false, false, false, false }
end

--------------------------------------------------------------------------------
function reset_pads_state()
    return { false, false, false, false, false, false, false, false, false, false, false, false, false, false, false,
             false, false, false, false, false, false, false, false, false }
end
--------------------------------------------------------------------------------
------------------------------------MAIN----------------------------------------
--------------------------------------------------------------------------------

function remote_init()
    -- initializes controls
    local items = { {
                        name = "Keyboard",
                        input = "keyboard"
                    }, {
                        name = "Pitch Bend",
                        input = "value",
                        min = 0,
                        max = 16383
                    }, {
                        name = "Modulation",
                        input = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Footswitch",
                        input = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Expression",
                        input = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Sustain",
                        input = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Channel Pressure",
                        input = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 1",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 2",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 3",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 4",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 5",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 6",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 7",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Knob 8",
                        input = "delta",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 1",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 2",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 3",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 4",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 5",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 6",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 7",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Fader 8",
                        input = "value",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 1",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 2",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 3",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 4",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 5",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 6",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 7",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 8",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 9",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 10",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 11",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 12",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 13",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 14",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 15",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Pad 16",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 1",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 2",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 3",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 4",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 5",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 6",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 7",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 8",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 9",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 10",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 11",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 12",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 13",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 14",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 15",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 16",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 17",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 18",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 19",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 20",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 21",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 22",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 23",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Button 24",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Options",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "REWIND",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "FORWARD",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "STOP",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "PLAY",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "LOOP",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "RECORD",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Cliplaunch 1",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Cliplaunch 2",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Clip Up",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Clip Down",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Track Left",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, {
                        name = "Track Right",
                        input = "button",
                        output = "value",
                        min = 0,
                        max = 127
                    }, -- output="text" for sysex messages
                    {
                        name = "Screens",
                        output = "text"
                    } }
    -- registers all control surface items
    remote.define_items(items)

    -- store screen and knobs position in global variables
    -- g_screens_index = #items
    g_knob_1_index = 8
    g_knob_2_index = 9
    g_knob_3_index = 10
    g_knob_4_index = 11
    g_knob_5_index = 12
    g_knob_6_index = 13
    g_knob_7_index = 14
    g_knob_8_index = 15
    g_cliplaunch_1_index = 70
    g_cliplaunch_2_index = 71

    local inputs = { {
                         pattern = "e? xx yy",
                         name = "Pitch Bend",
                         value = "y*128 + x",
                         port = 2
                     }, {
                         pattern = "b? 01 xx",
                         name = "Modulation",
                         port = 2
                     }, {
                         pattern = "<100x>? yy zz",
                         name = "Keyboard",
                         port = 2
                     }, {
                         pattern = "b? 42 xx",
                         name = "Footswitch",
                         port = 2
                     }, {
                         pattern = "b? 0B xx",
                         name = "Expression",
                         port = 1
                     }, {
                         pattern = "b? 40 xx",
                         name = "Sustain",
                         port = 2
                     }, {
                         pattern = "D? xx ??",
                         name = "Channel Pressure",
                         port = 1
                     }, {
                         pattern = "bF 29 xx",
                         name = "Fader 1",
                         port = 1
                     }, {
                         pattern = "bF 2A xx",
                         name = "Fader 2",
                         port = 1
                     }, {
                         pattern = "bF 2B xx",
                         name = "Fader 3",
                         port = 1
                     }, {
                         pattern = "bF 2C xx",
                         name = "Fader 4",
                         port = 1
                     }, {
                         pattern = "bF 2D xx",
                         name = "Fader 5",
                         port = 1
                     }, {
                         pattern = "bF 2E xx",
                         name = "Fader 6",
                         port = 1
                     }, {
                         pattern = "bF 2F xx",
                         name = "Fader 7",
                         port = 1
                     }, {
                         pattern = "bF 30 xx",
                         name = "Fader 8",
                         port = 1
                     }, {
                         pattern = "bF 15 xx",
                         name = "Knob 1",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 16 xx",
                         name = "Knob 2",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 17 xx",
                         name = "Knob 3",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 18 xx",
                         name = "Knob 4",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 19 xx",
                         name = "Knob 5",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 1A xx",
                         name = "Knob 6",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 1B xx",
                         name = "Knob 7",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 1C xx",
                         name = "Knob 8",
                         value = "delta_reader(x)",
                         port = 1
                     }, {
                         pattern = "bF 70 ?<???x>",
                         name = "REWIND",
                         port = 1
                     }, {
                         pattern = "bF 71 ?<???x>",
                         name = "FORWARD",
                         port = 1
                     }, {
                         pattern = "bF 72 ?<???x>",
                         name = "STOP",
                         port = 1
                     }, {
                         pattern = "bF 73 ?<???x>",
                         name = "PLAY",
                         port = 1
                     }, {
                         pattern = "bF 74 ?<???x>",
                         name = "LOOP",
                         port = 1
                     }, {
                         pattern = "bF 75 ?<???x>",
                         name = "RECORD",
                         port = 1
                     }, {
                         pattern = "bF 33 ?<???x>",
                         name = "Button 1",
                         port = 1
                     }, {
                         pattern = "bF 34 ?<???x>",
                         name = "Button 2",
                         port = 1
                     }, {
                         pattern = "bF 35 ?<???x>",
                         name = "Button 3",
                         port = 1
                     }, {
                         pattern = "bF 36 ?<???x>",
                         name = "Button 4",
                         port = 1
                     }, {
                         pattern = "bF 37 ?<???x>",
                         name = "Button 5",
                         port = 1
                     }, {
                         pattern = "bF 38 ?<???x>",
                         name = "Button 6",
                         port = 1
                     }, {
                         pattern = "bF 39 ?<???x>",
                         name = "Button 7",
                         port = 1
                     }, {
                         pattern = "bF 3A ?<???x>",
                         name = "Button 8",
                         port = 1
                     }, {
                         pattern = "bF 3B ?<???x>",
                         name = "Button 9",
                         port = 1
                     }, {
                         pattern = "bF 3C ?<???x>",
                         name = "Button 10",
                         port = 1
                     }, {
                         pattern = "bF 3D ?<???x>",
                         name = "Button 11",
                         port = 1
                     }, {
                         pattern = "bF 3E ?<???x>",
                         name = "Button 12",
                         port = 1
                     }, {
                         pattern = "bF 3F ?<???x>",
                         name = "Button 13",
                         port = 1
                     }, {
                         pattern = "bF 40 ?<???x>",
                         name = "Button 14",
                         port = 1
                     }, {
                         pattern = "bF 41 ?<???x>",
                         name = "Button 15",
                         port = 1
                     }, {
                         pattern = "bF 42 ?<???x>",
                         name = "Button 16",
                         port = 1
                     }, {
                         pattern = "bF 43 ?<???x>",
                         name = "Button 17",
                         port = 1
                     }, {
                         pattern = "bF 44 ?<???x>",
                         name = "Button 18",
                         port = 1
                     }, {
                         pattern = "bF 45 ?<???x>",
                         name = "Button 19",
                         port = 1
                     }, {
                         pattern = "bF 46 ?<???x>",
                         name = "Button 20",
                         port = 1
                     }, {
                         pattern = "bF 47 ?<???x>",
                         name = "Button 21",
                         port = 1
                     }, {
                         pattern = "bF 48 ?<???x>",
                         name = "Button 22",
                         port = 1
                     }, {
                         pattern = "bF 49 ?<???x>",
                         name = "Button 23",
                         port = 1
                     }, {
                         pattern = "bF 4A ?<???x>",
                         name = "Button 24",
                         port = 1
                     }, {
                         pattern = "bF 5A ?<???x>",
                         name = "Options",
                         port = 1
                     }, {
                         pattern = "9F 60 xx",
                         name = "Pad 1",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 61 xx",
                         name = "Pad 2",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 62 xx",
                         name = "Pad 3",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 63 xx",
                         name = "Pad 4",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 64 xx",
                         name = "Pad 5",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 65 xx",
                         name = "Pad 6",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 66 xx",
                         name = "Pad 7",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 67 xx",
                         name = "Pad 8",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 70 xx",
                         name = "Pad 9",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 71 xx",
                         name = "Pad 10",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 72 xx",
                         name = "Pad 11",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 73 xx",
                         name = "Pad 12",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 74 xx",
                         name = "Pad 13",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 75 xx",
                         name = "Pad 14",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 76 xx",
                         name = "Pad 15",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "9F 77 xx",
                         name = "Pad 16",
                         value = "greater_than_zero(x)",
                         port = 1
                     }, {
                         pattern = "bF 53 xx",
                         name = "Cliplaunch 1",
                         port = 1
                     }, {
                         pattern = "bF 54 xx",
                         name = "Cliplaunch 2",
                         port = 1
                     }, {
                         pattern = "bF 55 xx",
                         name = "Clip Up",
                         port = 1
                     }, {
                         pattern = "bF 56 xx",
                         name = "Clip Down",
                         port = 1
                     }, {
                         pattern = "bF 66 ?<???x>",
                         name = "Track Left",
                         port = 1
                     }, {
                         pattern = "bF 67 ?<???x>",
                         name = "Track Right",
                         port = 1
                     } }
    remote.define_auto_inputs(inputs)

    local outputs = { -- FADERS RGB
        {
            pattern = "f0 00 20 29 02 0a 01 03 36 01 xx yy zz F7",
            name = "Fader 1",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 37 01 xx yy zz F7",
            name = "Fader 2",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 38 01 xx yy zz F7",
            name = "Fader 3",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 39 01 xx yy zz F7",
            name = "Fader 4",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 3A 01 xx yy zz F7",
            name = "Fader 5",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 3B 01 xx yy zz F7",
            name = "Fader 6",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 3C 01 xx yy zz F7",
            name = "Fader 7",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, {
            pattern = "f0 00 20 29 02 0a 01 03 3D 01 xx yy zz F7",
            name = "Fader 8",
            x = "53*value*divided_by_127",
            y = "value*divided_by_127*17",
            z = "00"
        }, --
        -- -- FADERS non RGB
        -- {pattern="bF 29 xx", name="Fader 1"},
        -- {pattern="bF 2A xx", name="Fader 2"},
        -- {pattern="bF 2B xx", name="Fader 3"},
        -- {pattern="bF 2C xx", name="Fader 4"},
        -- {pattern="bF 2D xx", name="Fader 5"},
        -- {pattern="bF 2E xx", name="Fader 6"},
        -- {pattern="bF 2F xx", name="Fader 7"},
        -- {pattern="bF 30 xx", name="Fader 8"},
        -- BUTTONS
        {
            pattern = "bF 33 xx",
            name = "Button 1",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 34 xx",
            name = "Button 2",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 35 xx",
            name = "Button 3",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 36 xx",
            name = "Button 4",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 37 xx",
            name = "Button 5",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 38 xx",
            name = "Button 6",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 39 xx",
            name = "Button 7",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 3A xx",
            name = "Button 8",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 3B xx",
            name = "Button 9",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 3C xx",
            name = "Button 10",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 3D xx",
            name = "Button 11",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 3E xx",
            name = "Button 12",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 3F xx",
            name = "Button 13",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 40 xx",
            name = "Button 14",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 41 xx",
            name = "Button 15",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 42 xx",
            name = "Button 16",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 43 xx",
            name = "Button 17",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 44 xx",
            name = "Button 18",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 45 xx",
            name = "Button 19",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 46 xx",
            name = "Button 20",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 47 xx",
            name = "Button 21",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 48 xx",
            name = "Button 22",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 49 xx",
            name = "Button 23",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "bF 4A xx",
            name = "Button 24",
            x = "value*button_on",
            port = 1
        }, -- VARIOUS
        {
            pattern = "bF 5A xx",
            name = "Options",
            x = "(value*(button_on-dim_orange_decimal))+dim_orange_decimal",
            port = 1
        }, {
            pattern = "bF 70 xx",
            name = "REWIND",
            x = "value*(button_on)",
            port = 1
        }, {
            pattern = "bF 71 xx",
            name = "FORWARD",
            x = "value*(button_on)",
            port = 1
        }, {
            pattern = "bF 72 xx",
            name = "STOP",
            x = "value*(button_on)",
            port = 1
        }, {
            pattern = "bF 73 xx",
            name = "PLAY",
            x = "(value*(green_decimal-dim_green_decimal))+dim_green_decimal",
            port = 1
        }, {
            pattern = "bF 74 xx",
            name = "LOOP",
            x = "value*(button_on)",
            port = 1
        }, {
            pattern = "bF 75 xx",
            name = "RECORD",
            x = "(value*(red_decimal-dim_red_decimal))+dim_red_decimal",
            port = 1
        }, -- PADS
        {
            pattern = "9F 60 xx",
            name = "Pad 1",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 61 xx",
            name = "Pad 2",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 62 xx",
            name = "Pad 3",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 63 xx",
            name = "Pad 4",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 64 xx",
            name = "Pad 5",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 65 xx",
            name = "Pad 6",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 66 xx",
            name = "Pad 7",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 67 xx",
            name = "Pad 8",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 70 xx",
            name = "Pad 9",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 71 xx",
            name = "Pad 10",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 72 xx",
            name = "Pad 11",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 73 xx",
            name = "Pad 12",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 74 xx",
            name = "Pad 13",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 75 xx",
            name = "Pad 14",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 76 xx",
            name = "Pad 15",
            x = "value*button_on",
            port = 1
        }, {
            pattern = "9F 77 xx",
            name = "Pad 16",
            x = "value*button_on",
            port = 1
        },
        {
            pattern = "bF 15 xx",
            name = "Knob 1",
            port = 1
        }, {
            pattern = "bF 16 xx",
            name = "Knob 2",
            port = 1
        }, {
            pattern = "bF 17 xx",
            name = "Knob 3",
            port = 1
        }, {
            pattern = "bF 18 xx",
            name = "Knob 4",
            port = 1
        }, {
            pattern = "bF 19 xx",
            name = "Knob 5",
            port = 1
        }, {
            pattern = "bF 1A xx",
            name = "Knob 6",
            port = 1
        }, {
            pattern = "bF 1B xx",
            name = "Knob 7",
            port = 1
        }, {
            pattern = "bF 1C xx",
            name = "Knob 8",
            port = 1
        }, -- CLIP BUTTONS
        {
            pattern = "bF 53 xx",
            name = "Cliplaunch 1",
            port = 1
        }, {
            pattern = "bF 54 xx",
            name = "Cliplaunch 2",
            port = 1
        }, {
            pattern = "bF 55 xx",
            name = "Clip Up",
            x = "dim_orange_decimal",
            port = 1
        }, {
            pattern = "bF 56 xx",
            name = "Clip Down",
            x = "dim_orange_decimal",
            port = 1
        }, {
            pattern = "bF 66 xx",
            name = "Track Left",
            x = "dim_orange_decimal",
            port = 1
        }, {
            pattern = "bF 67 xx",
            name = "Track Right",
            x = "dim_orange_decimal",
            port = 1
        } }
    remote.define_auto_outputs(outputs)

end

---------------------------------------------------------------------------
function remote_probe(_, _, prober)
    -- auto detect the surface

    local request_events = {}
    local response = {}

    request_events = { remote.make_midi("F0 7E 7F 06 01 F7") }
    response = "F0 7E 00 06 02 00 20 29 01 01 00 00 ?? ?? ?? ?? F7"

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

---------------------------------------------------------------------------
g_label_1_row_enabled = { false, false, false, false, false, false, false, false }
g_label_1_row_prev_state = { nil, nil, nil, nil, nil, nil, nil, nil }
g_label_1_row_text = { false, false, false, false, false, false, false, false }
g_label_1_row_prev_text = { nil, nil, nil, nil, nil, nil, nil, nil }
g_label_1_row_value = { false, false, false, false, false, false, false, false }
g_label_1_row_prev_value = { nil, nil, nil, nil, nil, nil, nil, nil }
g_gui_knobs_enabled = { false, false, false, false, false, false, false, false }
g_gui_knobs_prev_state = { nil, nil, nil, nil, nil, nil, nil, nil }
g_gui_buttons_enabled = { false, false, false, false, false, false, false, false, -- enabled buttons are the dim ones
                          false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false }
g_gui_buttons_prev_state = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                             nil, nil, nil, nil, nil, nil }
g_gui_buttons_param_name = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                             nil, nil, nil, nil, nil, nil }
g_gui_buttons_param_value = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                              nil, nil, nil, nil, nil, nil }
g_gui_buttons_prev_param_value = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                                   nil, nil, nil, nil, nil, nil, nil }
g_gui_faders_param_name = { nil, nil, nil, nil, nil, nil, nil, nil }
g_gui_faders_param_value = { nil, nil, nil, nil, nil, nil, nil, nil }
g_gui_faders_prev_param_value = { nil, nil, nil, nil, nil, nil, nil, nil }
g_gui_pads_enabled = { false, false, false, false, false, false, false, false, -- enabled pads are the dim ones
                       false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false }
g_gui_pads_prev_state = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                          nil, nil, nil, nil, nil }
g_gui_buttons_name = { " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ", " ",
                       " ", " ", " ", " ", " " }
g_gui_buttons_prev_name = { nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
                            nil, nil, nil, nil, nil, nil }

g_gui_faders_value = { 0, 0, 0, 0, 0, 0, 0, 0 }
g_gui_faders_enabled = { false, false, false, false, false, false, false, false }

buttons_cc_nr = -- buttons cc midi msg first 2 bytes (space at the end of the string needed!)
{ "bF 33 ", "bF 34 ", "bF 35 ", "bF 36 ", "bF 37 ", "bF 38 ", "bF 39 ", "bF 3A ", "bF 3B ", "bF 3C ", "bF 3D ", "bF 3E ",
  "bF 3F ", "bF 40 ", "bF 41 ", "bF 42 ", "bF 43 ", "bF 44 ", "bF 45 ", "bF 46 ", "bF 47 ", "bF 48 ", "bF 49 ", "bF 4A " }

pads_note_nr = -- pads note midi msg first 2 bytes (space at the end of the string needed!)
{ "9F 60 ", "9F 61 ", "9F 62 ", "9F 63 ", "9F 64 ", "9F 65 ", "9F 66 ", "9F 67 ", "9F 70 ", "9F 71 ", "9F 72 ", "9F 73 ",
  "9F 74 ", "9F 75 ", "9F 76 ", "9F 77 " }

faders_cc_nr = -- pads note midi msg first 2 bytes (space at the end of the string needed!)
{ "bF 29 ", "bF 2A ", "bF 2B ", "bF 2C ", "bF 2D ", "bF 2E ", "bF 2F ", "bF 30 " }

knobs_index_start = 8
knobs_index_end = 15
buttons_index_start = 40
buttons_index_end = 63
-- button_note_start = 0x33
-- button_note_end = 0x4A
faders_index_start = 16
faders_index_end = 23
-- faders_cc_start = 0x29
-- faders_cc_end = 0x30
pads_index_start = 24
pads_index_end = 39
pressed_button = -1

---------------------------------------------------------------------------
function remote_set_state(changed_items)
    -- returns an array of items that have changed - "changed_items"
    -- used to create a new "machine state"
    for _, item_index in ipairs(changed_items) do
        if item_index ~= nil then

            -- look for KNOBS
            if item_index > (knobs_index_start - 1) and item_index < (knobs_index_end + 1) then
                local knob_info = remote.get_item_state(item_index)

                -- look for enabled KNOBS
                if remote.is_item_enabled(item_index) then
                    -- retrieve param name
                    g_label_1_row_text[item_index - (knobs_index_start - 1)] = knob_info.short_name
                    g_label_1_row_value[item_index - (knobs_index_start - 1)] = knob_info.value
                    g_label_1_row_enabled[item_index - (knobs_index_start - 1)] = true
                    g_gui_knobs_enabled[item_index - (knobs_index_start - 1)] = true

                else
                    -- look for disbled KNOBS
                    g_gui_knobs_enabled[item_index - (knobs_index_start - 1)] = false
                    g_label_1_row_enabled[item_index - (knobs_index_start - 1)] = false
                    g_label_1_row_text[item_index - (knobs_index_start - 1)] = " "
                    g_label_1_row_value[item_index - (knobs_index_start - 1)] = " "
                end

                -- look for BUTTONS
            elseif item_index > (buttons_index_start - 1) and item_index < (buttons_index_end + 1) then

                -- update BUTTONS status (enabled or not)
                g_gui_buttons_enabled[item_index - (buttons_index_start - 1)] = remote.is_item_enabled(item_index)
                local button_info = remote.get_item_state(item_index)

                -- only checks the enabled ones no need to check the disabled ones - Reason will turn them off
                if remote.is_item_enabled(item_index) then
                    -- button pressed (both on HW and Reason)

                    if button_info.value ~= 0 then
                        -- don't set it to "dim" - it automatically receives
                        -- a midi message form Reason that will light it up
                        g_gui_buttons_enabled[item_index - (buttons_index_start - 1)] = false
                        pressed_button = item_index - (buttons_index_start - 1)
                    end

                end

                if button_info.short_name ~= nil then
                    g_gui_buttons_param_name[item_index - (buttons_index_start - 1)] = button_info.remote_item_name
                    g_gui_buttons_param_value[item_index - (buttons_index_start - 1)] = button_info.text_value
                else
                    g_gui_buttons_param_name[item_index - (buttons_index_start - 1)] = nil
                    g_gui_buttons_param_value[item_index - (buttons_index_start - 1)] = " "
                end

                -- look for FADERS
            elseif item_index > (faders_index_start - 1) and item_index < (faders_index_end + 1) then
                -- update FADERS status (enabled or not)
                g_gui_faders_enabled[item_index - (faders_index_start - 1)] = remote.is_item_enabled(item_index)

                local fader_info = remote.get_item_state(item_index)
                if fader_info.short_name ~= nil then
                    g_gui_faders_param_name[item_index - (faders_index_start - 1)] = fader_info.remote_item_name
                    g_gui_faders_param_value[item_index - (faders_index_start - 1)] = fader_info.text_value
                else
                    g_gui_faders_param_name[item_index - (faders_index_start - 1)] = nil
                    g_gui_faders_param_value[item_index - (faders_index_start - 1)] = " "
                end

                -- look for PADS
            elseif item_index > (pads_index_start - 1) and item_index < (pads_index_end + 1) then

                -- update PADS status (enabled or not)
                g_gui_pads_enabled[item_index - (pads_index_start - 1)] = remote.is_item_enabled(item_index)

                -- it only checks the enabled ones
                if remote.is_item_enabled(item_index) then
                    local pads_info = remote.get_item_state(item_index)

                    if pads_info.value ~= 0 then
                        -- don't set it to "dim" - automatically receives a midi message form Reason that will light it up
                        g_gui_pads_enabled[item_index - (pads_index_start - 1)] = false
                    end

                end

            end
        end
    end
end

---------------------------------------------------------------------------
function remote_deliver_midi()
    -- it tra  slates variables into MIDI events
    local ret_events = {}
    local counter = 0 -- increase if KNOBS change their status
    local counter_2 = 0 -- increase if LABELS change their status
    local counter_3 = 0

    for i, status in ipairs(g_gui_knobs_enabled) do

        -- check if the actual KNOBS status is different from the previous one
        if status ~= g_gui_knobs_prev_state[i] then
            -- set previous status == actual status
            g_gui_knobs_prev_state[i] = g_gui_knobs_enabled[i]
            counter = counter + 1
        end

        -- check if the actual LABELS are different from the previous ones
        if g_label_1_row_prev_text[i] ~= g_label_1_row_text[i] then
            g_label_1_row_prev_text[i] = g_label_1_row_text[i]
            counter_2 = counter_2 + 1
            -- if labels are changed reset buttons and pads state
            if counter_2 == 1 then
                g_gui_buttons_prev_state = reset_buttons_state()
                g_gui_pads_prev_state = reset_pads_state()
            end

        elseif g_label_1_row_prev_value[i] ~= g_label_1_row_value[i] then
            g_label_1_row_prev_value[i] = g_label_1_row_value[i]
            counter_3 = counter_3 + 1
        end
    end

    -- if one or more knob status changed append the right
    -- sysex message to the table which will be sent to LKP
    if counter > 0 then
        table.insert(ret_events, midiUtils.makeKnobsStatusEvent(g_gui_knobs_enabled, colours.orange))
    end

    if counter_2 > 0 then
        table.insert(ret_events, midiUtils.makeDisplayEvent(g_label_1_row_enabled, g_label_1_row_text, 1))
    end

    if counter_3 > 0 then
        table.insert(ret_events, midiUtils.makeDisplayEvent(g_label_1_row_enabled, g_label_1_row_value, 2))
    end

    -- check if enabled BUTTONS have changed their status
    for i, status in ipairs(g_gui_buttons_enabled) do
        if status ~= g_gui_buttons_prev_state[i] then
            if status == true then
                local cc_to_button = buttons_cc_nr[i] .. colours.dimOrange
                table.insert(ret_events, remote.make_midi(cc_to_button))
            end
            g_gui_buttons_prev_state[i] = g_gui_buttons_enabled[i]
        end
    end

    -- check if BUTTON VALUES have changed their status
    for i, param_value in ipairs(g_gui_buttons_param_value) do
        if param_value ~= g_gui_buttons_prev_param_value[i] then
            -- if param_value ~= "-1" then
            table.insert(ret_events, midiUtils.makeNotificationEvent(g_gui_buttons_param_name[i], param_value))
            -- end
            g_gui_buttons_prev_param_value[i] = param_value
        end
    end

    -- check if FADER VALUES have changed their status
    for i, param_value in ipairs(g_gui_faders_param_value) do
        if param_value ~= g_gui_faders_prev_param_value[i] then
            -- if param_value ~= "-1" then
            table.insert(ret_events, midiUtils.makeNotificationEvent(g_gui_faders_param_name[i], param_value))
            -- end
            g_gui_faders_prev_param_value[i] = param_value
        end
    end

    -- check if enabled PADS have changed their status
    for i, status in ipairs(g_gui_pads_enabled) do
        if status ~= g_gui_pads_prev_state[i] then
            if status == true then
                local midi_to_pads = pads_note_nr[i] .. colours.dimOrange
                table.insert(ret_events, remote.make_midi(midi_to_pads))
            end
            g_gui_pads_prev_state[i] = g_gui_pads_enabled[i]
        end
    end

    return ret_events
end

---------------------------------------------------------------------------
function remote_prepare_for_use()
    -- create screen layout with 8 invisible knobs (set to colour 0)
    return { midiUtils.makeKnobsStatusEvent(),
             midiUtils.makeCreateKnobEvent(1, colours.noColour),
             midiUtils.makeCreateKnobEvent(2, colours.noColour),
             midiUtils.makeCreateKnobEvent(3, colours.noColour),
             midiUtils.makeCreateKnobEvent(4, colours.noColour),
             midiUtils.makeCreateKnobEvent(5, colours.noColour),
             midiUtils.makeCreateKnobEvent(6, colours.noColour),
             midiUtils.makeCreateKnobEvent(7, colours.noColour),
             midiUtils.makeCreateKnobEvent(8, colours.noColour),
             set_fader_colour(1, colours.noColour), set_fader_colour(2, colours.noColour), set_fader_colour(3, colours.noColour),
             set_fader_colour(4, colours.noColour), set_fader_colour(5, colours.noColour), set_fader_colour(6, colours.noColour),
             set_fader_colour(7, colours.noColour), set_fader_colour(8, colours.noColour) }
end

---------------------------------------------------------------------------
-- things to do when device is not in use - not connected to an instrument
function remote_release_from_use()
    return { midiUtils.makeKnobsStatusEvent(),
             midiUtils.makeCreateKnobEvent(1, colours.noColour),
             midiUtils.makeCreateKnobEvent(2, colours.noColour),
             midiUtils.makeCreateKnobEvent(3, colours.noColour),
             midiUtils.makeCreateKnobEvent(4, colours.noColour),
             midiUtils.makeCreateKnobEvent(5, colours.noColour),
             midiUtils.makeCreateKnobEvent(6, colours.noColour),
             midiUtils.makeCreateKnobEvent(7, colours.noColour),
             midiUtils.makeCreateKnobEvent(8, colours.noColour),
             set_fader_colour(1, colours.noColour), set_fader_colour(2, colours.noColour), set_fader_colour(3, colours.noColour),
             set_fader_colour(4, colours.noColour), set_fader_colour(5, colours.noColour), set_fader_colour(6, colours.noColour),
             set_fader_colour(7, colours.noColour), set_fader_colour(8, colours.noColour)
    }
end

---------------------------------------------------------------------------
